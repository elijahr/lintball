# lintball

Multi-linter tool for automatically keeping your project tidy.

lintball can fix all your code with one command, and comes with a convenient githook.

Linters/formatters used:

- [`prettier`](https://prettier.io/) - for JavaScript, TypeScript, YAML, Markdown
- [`shellcheck`](https://www.shellcheck.net/) - for bash scripts
- [`shfmt`](https://github.com/mvdan/sh) - for bash scripts and bats tests
- [`black`](https://github.com/psf/black) - for Python
- [`autoflake`](https://github.com/myint/autoflake) - for Python
- [`nimpretty`](https://nim-lang.org/docs/tools.html) - for Nim

## Installation

```shell
curl -o- https://raw.githubusercontent.com/elijahr/lintball/v0.2.0/install.sh | bash
```

Running the above commands downloads a script and runs it. The script clones the lintball repository to ~/.lintball, and configures your PATH to include the lintball scripts. Currently, bash and fish are supported.

If you are using lintball with a git-managed project, we suggest running `install-lintball-githooks` to install a pre-commit hook to auto-fix your code.

## Usage

lintball provides three scripts:

- `install-lintball-githooks` will configure the current working directory to use lintball's pre-commit hook, which fixes all auto-fixable problems found in the staged changes, and exits with an error if any issues cannot be fixed.
- `check-all` will run linter checks against all files in the current working directory.
- `fix-all` will fix any auto-fixable linter issues in the current working directory.
