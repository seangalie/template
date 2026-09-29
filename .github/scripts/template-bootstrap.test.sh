#!/usr/bin/env bash
# Regression test for template-bootstrap.sh. Each case copies the template into
# a temporary directory, runs the script there, and checks the generated tree.
# The template itself is never modified.
#
# Run it from the repository root:
#   bash .github/scripts/template-bootstrap.test.sh
#
# The Template Bootstrap workflow runs it on every push and pull request in the
# template repository.

set -euo pipefail

ROOT="$(pwd)"
SCRIPT=".github/scripts/template-bootstrap.sh"
PLACEHOLDERS='GITHUB_USERNAME|REPO_SLUG|PROJECT_NAME|FULL_NAME'
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

failures=0
fail() {
  echo "  FAIL: $*"
  failures=$((failures + 1))
}

# Copies the template into a fresh directory and changes into it.
fresh_copy() {
  local dir="${WORK}/$1"
  mkdir -p "$dir"
  tar -C "$ROOT" --exclude=.git -cf - . | tar -C "$dir" -xf -
  cd "$dir"
}

# Lists files that still contain a pattern, skipping the bootstrap's own files,
# which spell out the placeholders and markers on purpose.
leftovers() {
  grep -rlIE "$1" . --exclude-dir=.git --exclude='*template-bootstrap*' || true
}

run_bootstrap() {
  bash "$SCRIPT" > "${WORK}/last-run.log" 2>&1 \
    || { cat "${WORK}/last-run.log"; fail "the script exited non-zero"; }
}

echo "case: the template needs bootstrapping"
fresh_copy check
bash "$SCRIPT" --check > /dev/null || fail "--check reported nothing to do before the bootstrap ran"

echo "case: the setup checklist names every file with a prompt left to fill in"
# The bootstrap cannot answer "[?]" prompts, "[NOTE: ...]" placeholders, or TODO
# steps, so the checklist issue has to send a human to each file that has one.
while IFS= read -r file; do
  file="${file#./}"
  grep -qF "\`${file}\`" .github/TEMPLATE_CHECKLIST.md \
    || fail "${file} has a prompt, but .github/TEMPLATE_CHECKLIST.md does not mention it"
done < <(grep -rlIE '\[\?\]|\[NOTE:|^[0-9]+\. TODO' . \
  --exclude-dir=.git \
  --exclude='*template-bootstrap*' \
  --exclude=TEMPLATE_CHECKLIST.md || true)

echo "case: the PR label list is the same everywhere it is repeated"
# Each copy is reduced to a sorted set, one label per line, and compared with
# the set the PR Labels check actually enforces, so a label added to or removed
# from any single copy is caught.

# The folded `labels: >-` block of the PR Labels check.
pr_label_set() {
  awk '
    /^[[:space:]]*labels: >-/ { grab = 1; next }
    grab && /^[[:space:]]*[a-z]/ { print; next }
    grab { exit }
  ' .github/workflows/pr-labels.yml | tr -s ', ' '\n' | grep -v '^$' | sort -u
}

# The "Kind of change" group at the top of labels.yml, up to its blank line.
labels_yml_set() {
  awk '
    /^# Kind of change/ { grab = 1; next }
    grab && /^$/ { exit }
    grab
  ' .github/labels.yml | sed -n 's/^- name: "\(.*\)"$/\1/p' | sort -u
}

# The backticked lower-case words in the Markdown list item or line that
# contains the marker, which filters out file names and `PR Labels`.
# shellcheck disable=SC2016 # The backticks are Markdown, matched literally.
doc_label_set() {
  awk -v marker="$2" '
    index($0, marker) { grab = 1; print; next }
    grab && (/^- / || /^$/) { exit }
    grab
  ' "$1" | grep -oE '`[a-z][a-z-]*`' | tr -d '`' | sort -u
}

# compare_labels NAME SET: fails with the labels NAME has extra or lacks.
compare_labels() {
  local extra missing
  extra="$(comm -13 <(printf '%s\n' "$expected") <(printf '%s\n' "$2") | tr '\n' ' ')"
  missing="$(comm -23 <(printf '%s\n' "$expected") <(printf '%s\n' "$2") | tr '\n' ' ')"
  [ -z "$extra" ] || fail "$1 lists labels the PR Labels check does not accept: ${extra}"
  [ -z "$missing" ] || fail "$1 is missing PR labels: ${missing}"
}

expected="$(pr_label_set)"
if [ -z "$expected" ]; then
  fail "could not read the label list from .github/workflows/pr-labels.yml"
else
  compare_labels ".github/labels.yml" "$(labels_yml_set)"
  compare_labels "AGENTS.md" "$(doc_label_set AGENTS.md '**Pull requests**')"
  compare_labels "docs/CONTRIBUTING.md" "$(doc_label_set docs/CONTRIBUTING.md '**A label is required.**')"
  # shellcheck disable=SC2016 # The backticks are Markdown, matched literally.
  compare_labels ".github/PULL_REQUEST_TEMPLATE.md" \
    "$(doc_label_set .github/PULL_REQUEST_TEMPLATE.md 'the `PR Labels` check requires')"
fi

echo "case: personal account, with shell and regex metacharacters in the name"
fresh_copy user
# Every character here would break a naive sed or perl substitution.
# shellcheck disable=SC2016 # The $HOME is meant literally.
name='Mona \1 & $HOME | /Lisa/ O'"'"'Hara'
OWNER=octo-cat REPO=my-widget FULL_NAME="$name" OWNER_TYPE=User run_bootstrap

[ -z "$(leftovers "$PLACEHOLDERS")" ] || fail "placeholders remain in: $(leftovers "$PLACEHOLDERS" | tr '\n' ' ')"
[ -z "$(leftovers 'TEMPLATE-(SETUP|NOTICE)')" ] || fail "template markers remain in: $(leftovers 'TEMPLATE-(SETUP|NOTICE)' | tr '\n' ' ')"
grep -qF "[${name}](https://github.com/octo-cat)" README.md || fail "README.md does not credit the author verbatim"
grep -qxF '# my-widget' README.md || fail "README.md heading is not the repository name"
grep -qF 'git clone https://github.com/octo-cat/my-widget' docs/CONTRIBUTING.md || fail "docs/CONTRIBUTING.md clone URL is wrong"
grep -qxF '# Working on my-widget' AGENTS.md || fail "AGENTS.md heading is wrong"
grep -qF 'Working on the template itself' AGENTS.md && fail "AGENTS.md still has the template-only note"
[ "$(cat .github/CODEOWNERS)" = "* @octo-cat" ] || fail "CODEOWNERS is not '* @octo-cat'"

# The deletions must not leave a blank first line behind.
for f in README.md AGENTS.md .gitattributes .gitignore; do
  [ -n "$(head -n 1 "$f")" ] || fail "${f} starts with a blank line"
done

# The Icon rule holds a literal carriage return, which the rewrite must keep.
grep -q $'^Icon\\[\r\\]$' .gitignore || fail ".gitignore lost the carriage return in its Icon rule"

# Files with no placeholders or markers must come through byte for byte.
for f in LICENSE docs/screenshot.png docs/logo.svg .github/labels.yml CLAUDE.md; do
  cmp -s "$f" "${ROOT}/${f}" || fail "${f} changed but should not have"
done

if bash "$SCRIPT" --check > /dev/null; then
  fail "--check still reports work to do after the bootstrap"
fi

echo "case: running it a second time changes nothing"
cp -r . "${WORK}/user-before-rerun"
OWNER=octo-cat REPO=my-widget FULL_NAME="$name" OWNER_TYPE=User run_bootstrap
diff -r "${WORK}/user-before-rerun" . > /dev/null || fail "the second run changed files"

echo "case: organization account"
fresh_copy org
OWNER=octo-org REPO=my-widget FULL_NAME="Octo Org" OWNER_TYPE=Organization run_bootstrap
grep -qxF '# * @octo-org/team-name' .github/CODEOWNERS || fail "CODEOWNERS lacks the commented team example"
grep -qE '^[^#]' .github/CODEOWNERS && fail "CODEOWNERS assigns an owner, which an organization cannot be"

echo "case: unknown account type, and FULL_NAME left unset"
fresh_copy unknown
OWNER=someone REPO=my-widget run_bootstrap
grep -qE '^[^#]' .github/CODEOWNERS && fail "CODEOWNERS assigns an owner for an unknown account type"
grep -qF '[someone](https://github.com/someone)' README.md || fail "the author did not fall back to the login"

echo "case: OWNER is required"
fresh_copy missing
if REPO=my-widget bash "$SCRIPT" > /dev/null 2>&1; then
  fail "the script ran without OWNER"
fi
[ -n "$(leftovers "$PLACEHOLDERS")" ] || fail "the script changed files before rejecting a missing OWNER"

cd "$ROOT"
if [ "$failures" -gt 0 ]; then
  echo "${failures} check(s) failed."
  exit 1
fi
echo "All checks passed."
