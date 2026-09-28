<!-- TEMPLATE-SETUP:START -->
> ### 🧰 You are looking at a template repository
>
> Press **Use this template** to create your own repository from it. On the first
> push to `main`, the [Template Bootstrap](.github/workflows/template-bootstrap.yml)
> workflow replaces the `GITHUB_USERNAME`, `REPO_SLUG`, `PROJECT_NAME`, and
> `FULL_NAME` placeholders across every file, strips the template notices, opens a
> checklist issue covering the parts that still need a human, applies the
> labels from `.github/labels.yml`, and then deletes itself.
>
> It commits directly when repository rules allow that; otherwise it preserves
> the changes on a setup branch and opens a pull request, and if repository
> policy blocks automated pull requests too, the checklist issue links to that
> branch. `GITHUB_TOKEN` is not always permitted to write under
> `.github/workflows`; when it is not, the bootstrap applies everything else,
> disables itself, and asks you to delete its file by hand.
>
> If it did not run, start it by hand from **Actions → Template Bootstrap → Run
> workflow**.
>
> <details>
> <summary>Setting up without GitHub Actions</summary>
>
> From a clone of the new repository, with Bash and Perl available:
>
> 1. Run the file edits the workflow would make. They replace the placeholders,
>    write `.github/CODEOWNERS`, and remove every template notice, including
>    this one. Use `OWNER_TYPE=Organization` for an organization account.
>
>    ```sh
>    OWNER=your-login REPO=your-repo FULL_NAME="Your Name" OWNER_TYPE=User \
>      bash .github/scripts/template-bootstrap.sh
>    ```
>
> 2. Open an issue from `.github/TEMPLATE_CHECKLIST.md` (or keep it as your own
>    to-do list), then delete the template-only files:
>
>    ```sh
>    git rm -r .github/TEMPLATE_CHECKLIST.md .github/scripts \
>      .github/workflows/template-bootstrap.yml .github/workflows/template-test.yml
>    ```
>
> 3. Commit and push. This commit does not touch `.github/labels.yml`, so the
>    Sync labels workflow will not start by itself: run it once from **Actions →
>    Sync labels → Run workflow** to create the labels the PR Labels check needs.
>
> Deleting `template-bootstrap.yml` is what stops it running on every push, so
> do not skip step 2.
> </details>
<!-- TEMPLATE-SETUP:END -->

<div align="center">

# PROJECT_NAME
A short description of PROJECT_NAME goes here.

  <a href="https://github.com/GITHUB_USERNAME/REPO_SLUG/issues/new?assignees=&labels=bug&template=01_bug_report.yml&title=bug%3A+">Report a Bug</a>
  ·
  <a href="https://github.com/GITHUB_USERNAME/REPO_SLUG/issues/new?assignees=&labels=enhancement&template=02_feature_request.yml&title=feat%3A+">Request a Feature</a>
  ·
  <a href="https://github.com/GITHUB_USERNAME/REPO_SLUG/discussions">Ask a Question</a>
</div>
<div align="center">

[![Project license](https://img.shields.io/github/license/GITHUB_USERNAME/REPO_SLUG.svg?style=flat-square)](LICENSE) [![Pull Requests welcome](https://img.shields.io/badge/PRs-welcome-ff69b4.svg?style=flat-square)](https://github.com/GITHUB_USERNAME/REPO_SLUG/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) [![code with love by GITHUB_USERNAME](https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%99%A5%20by-GITHUB_USERNAME-ff1414.svg?style=flat-square)](https://github.com/GITHUB_USERNAME)

  <a href="https://github.com/GITHUB_USERNAME/REPO_SLUG">
    <img src="docs/logo.svg" alt="Terminal Placeholder for the Logo" width="640" height="360">
  </a>
</div>

<details open="open">
<summary>Table of Contents</summary>

- [About](#about)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Changelog](#changelog)
- [Support](#support)
- [Project assistance](#project-assistance)
- [Contributing](#contributing)
- [Authors & contributors](#authors--contributors)
- [Security](#security)
- [License](#license)
- [Acknowledgements](#acknowledgements)

</details>

## About

> **[?]**
> Provide general information about your project here.
> What problem does it (intend to) solve?
> What is the purpose of your project?
> Why did you undertake it?
> You don't have to answer all the questions -- just the ones relevant to your project.

<details>
<summary>Screenshots</summary>
<br>

> **[?]**
> Please provide your screenshots here.

|                               Home Page                               |                               Login Page                               |
| :-------------------------------------------------------------------: | :--------------------------------------------------------------------: |
| <img src="docs/screenshot.png" title="Home Page" width="100%"> | <img src="docs/screenshot.png" title="Login Page" width="100%"> |

</details>

### Built With

> **[?]**
> Please provide the technologies that are used in the project.

## Getting Started

### Prerequisites

> **[?]**
> What are the project requirements/dependencies?

### Installation

> **[?]**
> Describe how to install and get started with the project.

## Usage

> **[?]**
> How does one go about using it?
> Provide various use cases and code examples here.

## Roadmap

See the [open issues](https://github.com/GITHUB_USERNAME/REPO_SLUG/issues) for a list of proposed features (and known issues).

- [Top Feature Requests](https://github.com/GITHUB_USERNAME/REPO_SLUG/issues?q=label%3Aenhancement+is%3Aopen+sort%3Areactions-%2B1-desc) (Add your votes using the 👍 reaction)
- [Top Bugs](https://github.com/GITHUB_USERNAME/REPO_SLUG/issues?q=is%3Aissue+is%3Aopen+label%3Abug+sort%3Areactions-%2B1-desc) (Add your votes using the 👍 reaction)
- [Newest Bugs](https://github.com/GITHUB_USERNAME/REPO_SLUG/issues?q=is%3Aopen+is%3Aissue+label%3Abug)

## Changelog

Notable changes to each release are recorded in [CHANGELOG.md](CHANGELOG.md).

## Support

See [our support guide](docs/SUPPORT.md) for where to ask what, and what to expect.

> **[?]**
> Add any other ways to reach the maintainers here -- a chat channel, a mailing
> list, an email address.

The quickest routes are this repository's [discussions](https://github.com/GITHUB_USERNAME/REPO_SLUG/discussions) and the maintainer's [GitHub profile](https://github.com/GITHUB_USERNAME).

## Project assistance

If you want to say **thank you** and/or support active development of PROJECT_NAME:

- Add a [GitHub Star](https://github.com/GITHUB_USERNAME/REPO_SLUG) to the project.
- Post about PROJECT_NAME on X/Twitter, BlueSky, Mastodon, or your favorite social channels.
- Share more about PROJECT_NAME with your favorite communities or on your personal blog.

Together, we can make PROJECT_NAME **better**!

## Contributing

First off, thanks for taking the time to contribute! Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make will benefit everybody else and are **greatly appreciated**.

Please read [our contribution guidelines](docs/CONTRIBUTING.md), and thank you for being involved!

## Authors & contributors

The original setup of this repository is by [FULL_NAME](https://github.com/GITHUB_USERNAME).

For a full list of all authors and contributors, see [the contributors page](https://github.com/GITHUB_USERNAME/REPO_SLUG/contributors).

## Security

PROJECT_NAME follows good practices of security, but 100% security cannot be assured.
PROJECT_NAME is provided **"as is"** without any **warranty**. Use at your own risk.

_For more information and to report security issues, please refer to our [security documentation](docs/SECURITY.md)._

## License

This project is licensed under the **Apache 2.0 license**.

See [LICENSE](LICENSE) for more information.

## Acknowledgements

> **[?]**
> If your work was funded by any organization or institution, acknowledge their support here.
> In addition, if your work relies on other software libraries, or was inspired by looking at other work, it is appropriate to acknowledge this intellectual debt too.
