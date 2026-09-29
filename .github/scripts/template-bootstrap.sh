#!/usr/bin/env bash
# Personalizes a repository generated from this template: replaces the
# placeholders, writes CODEOWNERS, and strips the template notices. The
# Template Bootstrap workflow runs it, and so can a person setting up the
# repository by hand (see the README). It only rewrites files in the working
# tree: it never commits, pushes, or calls GitHub.
#
# Run it from the repository root:
#   OWNER=octocat REPO=my-repo FULL_NAME="Mona Lisa" OWNER_TYPE=User \
#     bash .github/scripts/template-bootstrap.sh
#
# FULL_NAME defaults to OWNER. OWNER_TYPE is "User" or "Organization", as the
# GitHub API reports it; anything else writes a CODEOWNERS file that holds only
# instructions.
#
# With --check, it changes nothing and exits 0 if any placeholder remains, or 1
# if there is nothing left to do.
#
# Perl does the editing rather than sed, whose -i flag differs between GNU and
# macOS.

set -euo pipefail

PLACEHOLDERS='GITHUB_USERNAME|REPO_SLUG|PROJECT_NAME|FULL_NAME'

# Lists the text files matching a pattern. The bootstrap workflow, this script,
# and its test spell out the placeholders and markers on purpose, so they are
# skipped.
files_matching() {
  grep -rlIE "$1" . \
    --exclude-dir=.git \
    --exclude='*template-bootstrap*' \
    || true
}

if [ "${1:-}" = "--check" ]; then
  if [ -n "$(files_matching "$PLACEHOLDERS")" ]; then
    exit 0
  fi
  echo "No placeholders left -- nothing to do."
  exit 1
fi

: "${OWNER:?Set OWNER to the account that owns the repository.}"
: "${REPO:?Set REPO to the repository name.}"
FULL_NAME="${FULL_NAME:-$OWNER}"
OWNER_TYPE="${OWNER_TYPE:-Unknown}"
export OWNER REPO FULL_NAME
echo "Owner: ${OWNER} / Type: ${OWNER_TYPE} / Repo: ${REPO} / Name: ${FULL_NAME}"

# Every TEMPLATE-SETUP or TEMPLATE-NOTICE start marker must be closed by an end
# marker of the same kind before any file is touched. The deletion further down
# would otherwise treat an unclosed block as running to the end of the file and
# remove everything after it. A marker pair on a single line is closed.
marker_errors=""
while IFS= read -r file; do
  if ! errors="$(perl -ne '
    my ($start) = /TEMPLATE-(SETUP|NOTICE):START/;
    my ($end) = /TEMPLATE-(SETUP|NOTICE):END/;
    if ($start) {
      if ($open) { print "$ARGV:$.: start marker inside the block opened on line $open\n"; $bad = 1 }
      ($open, $kind) = $end ? (0, "") : ($., $start);
    } elsif ($end) {
      if (!$open) { print "$ARGV:$.: end marker without a start marker\n"; $bad = 1 }
      elsif ($end ne $kind) { print "$ARGV:$.: TEMPLATE-$end end marker closes the TEMPLATE-$kind block opened on line $open\n"; $bad = 1 }
      $open = 0;
    }
    END {
      if ($open) { print "$ARGV:$open: start marker is never closed\n"; $bad = 1 }
      exit($bad ? 1 : 0);
    }
  ' "$file")"; then
    marker_errors+="${errors}"$'\n'
  fi
done < <(files_matching 'TEMPLATE-(SETUP|NOTICE):(START|END)')
if [ -n "$marker_errors" ]; then
  printf '%s' "$marker_errors" | sed 's/^/  /' >&2
  echo "Unmatched template markers; nothing was changed. Fix them and run this again." >&2
  exit 1
fi

# The replacements are read from the environment rather than spliced into the
# program text, so a name containing \, &, | or / is safe.
while IFS= read -r file; do
  echo "  updating ${file}"
  perl -pi -e '
    s/GITHUB_USERNAME/$ENV{OWNER}/g;
    s/REPO_SLUG/$ENV{REPO}/g;
    s/PROJECT_NAME/$ENV{REPO}/g;
    s/FULL_NAME/$ENV{FULL_NAME}/g;
  ' "$file"
done < <(files_matching "$PLACEHOLDERS")

# CODEOWNERS is written here rather than carrying a placeholder, so that the
# template repository itself does not ship a file GitHub reports as invalid.
#
# A personal account is a valid CODEOWNER. An organization account is not:
# organization repositories must name a visible team with write access in the
# @org/team-name form.
case "$OWNER_TYPE" in
  User)
    printf '%s\n' "* @${OWNER}" > .github/CODEOWNERS
    ;;
  Organization)
    printf '%s\n' \
      '# Organization repositories must assign a visible team with write access.' \
      '# Replace "team-name" and uncomment the line below.' \
      "# * @${OWNER}/team-name" \
      > .github/CODEOWNERS
    ;;
  *)
    printf '%s\n' \
      '# The bootstrap could not determine a valid CODEOWNER automatically.' \
      '# Add a GitHub user or a visible organization team with write access.' \
      '# * @username-or-org/team-name' \
      > .github/CODEOWNERS
    ;;
esac

# Deletes every block between TEMPLATE-SETUP or TEMPLATE-NOTICE start and end
# markers, in any file, then the blank lines the deletion leaves at the top.
# Each file gets its own perl so that an unclosed block cannot run on into the
# next file.
while IFS= read -r file; do
  echo "  removing template notices from ${file}"
  perl -ni -e '
    next if /TEMPLATE-(?:SETUP|NOTICE):START/ .. /TEMPLATE-(?:SETUP|NOTICE):END/;
    print if $seen ||= /./;
  ' "$file"
done < <(files_matching 'TEMPLATE-(SETUP|NOTICE):START')
