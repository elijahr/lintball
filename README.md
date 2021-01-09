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
curl -o- https://raw.githubusercontent.com/elijahr/lintball/v0.1.0/install.sh | bash
# or with wget
wget -qO- https://raw.githubusercontent.com/elijahr/lintball/v0.1.0/install.sh | bash
```

Running either of the above commands downloads a script and runs it. The script clones the lintball repository to ~/.lintball, and attempts to add the source lines from the snippet below to your profile files (~/.bash_profile, ~/.bashrc, ~/.config/fish/config.fish):

### bash

```bash
if [ -z "${LINTBALL_DIR:-}" ]; then
  export LINTBALL_DIR="${HOME}/.lintball"
  . "${LINTBALL_DIR}/lintball.sh"
fi
```

### fish

```lua
if test -z "$LINTBALL_DIR"
  set -gx LINTBALL_DIR "$HOME/.lintball"
  source "$LINTBALL_DIR/lintball.fish"
end
```

## Usage

lintball provides three scripts:

- `check-all` will
- `fix-all` will
- `install-lintball-githooks` will
