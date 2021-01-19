![Test](https://github.com/elijahr/lintball/workflows/Test/badge.svg)

```
█   █ █▄ █ ▀█▀ ██▄ ▄▀▄ █  O █
█▄▄ █ █ ▀█  █  █▄█ █▀█ █▄▄ █▄▄
keep your code tidy with one command.
```

## Supported languages

| language     |                                tools used                                |
| :----------- | :----------------------------------------------------------------------: |
| bash         |                       [shellcheck][2], [shfmt][3]                        |
| bats         |                       [shellcheck][2], [shfmt][3]                        |
| C            |                             [uncrustify][13]                             |
| C#           |                             [uncrustify][13]                             |
| C++          |                             [uncrustify][13]                             |
| CSS          |                              [prettier][1]                               |
| Cython       |             [autoflake][4], [autopep8][5], [docformatter][7]             |
| dash         |                       [shellcheck][2], [shfmt][3]                        |
| GraphQL      |                              [prettier][1]                               |
| HTML         |                              [prettier][1]                               |
| Java         |                           [prettier-java][18]                            |
| JavaScript   |                          [prettier-eslint][12]                           |
| JSON         |                              [prettier][1]                               |
| JSX          |                          [prettier-eslint][12]                           |
| ksh          |                       [shellcheck][2], [shfmt][3]                        |
| Luau         |                               [StyLua][15]                               |
| Lua          |                               [StyLua][15]                               |
| Markdown     |                              [prettier][1]                               |
| Nim          |                              [nimpretty][9]                              |
| Objective-C  |                             [uncrustify][13]                             |
| package.json |                       [prettier-package-json][17]                        |
| pug          |                        [prettier/plugin-pug][20]                         |
| Python       | [autoflake][4], [autopep8][5], [black][6], [docformatter][7], [isort][8] |
| Ruby         |                [@prettier/plugin-ruby][14], [rubocop][11]                |
| Rust         |                               [clippy][16]                               |
| SASS         |                              [prettier][1]                               |
| sh           |                       [shellcheck][2], [shfmt][3]                        |
| TOML         |                              [prettier][1]                               |
| TSX          |                          [prettier-eslint][12]                           |
| TypeScript   |                          [prettier-eslint][12]                           |
| XML          |                        [prettier/plugin-xml][19]                         |
| YAML         |                      [prettier][1], [yamllint][10]                       |

[1]: https://prettier.io/
[2]: https://www.shellcheck.net/
[3]: https://github.com/mvdan/sh
[4]: https://pypi.org/project/autoflake/
[5]: https://pypi.org/project/autopep8/
[6]: https://github.com/psf/black
[7]: https://pypi.org/project/docformatter/
[8]: https://pypi.org/project/isort/
[9]: https://nim-lang.org/docs/tools.html
[10]: https://yamllint.readthedocs.io/en/stable/
[11]: https://github.com/rubocop-hq/rubocop
[12]: https://github.com/prettier/prettier-eslint-cli
[13]: http://uncrustify.sourceforge.net/
[14]: https://github.com/prettier/plugin-ruby
[15]: https://github.com/JohnnyMorganz/StyLua
[16]: https://github.com/rust-lang/rust-clippy
[17]: https://github.com/cameronhunter/prettier-package-json
[18]: https://github.com/jhipster/prettier-java
[19]: https://github.com/prettier/plugin-xml
[20]: https://github.com/prettier/plugin-pug

## Installation

```sh
curl -o- https://raw.githubusercontent.com/elijahr/lintball/devel/install.sh | bash
```

Running the above command downloads a script and runs it. The script downloads the latest release of lintball to ~/.lintball, [installs linters](#dependencies), and configures your PATH to include the lintball script. Currently, fish, bash, and zsh are supported.

If you are using lintball with a git-managed project, we suggest using the pre-commit hook, installed via `lintball githooks`. Your code will be automatically fixed on commit - and any non-auto-fixable issues will block the commit with a helpful error message.

## Usage

```
Usage: lintball [lintball options] [command] [command options]

lintball options:
  -h | --help
      Show this help message & exit.
  -v | --version
      Print version & exit.
  -c | --config path
      Use the .lintballrc.json config file at path.

commands:
  check [path ...]
      Check for and display linter issues recursively in paths or working dir.
  fix [path ...]
      Auto fix all fixable issues recursively in paths or working dir.
  list [path ...]
      List files which lintball recognizes for checking or fixing.
  update
      Update lintball to the latest version.
  githooks [path]
      Install lintball githooks in the git repo at path or working dir.
  lintballrc [path]
      Place a default .lintballrc.json config file in path or working dir.
```

## Updating

You can update to the latest version of lintball by running:

```sh
~/.lintball/install.sh
```

## Dependencies

Lintball does not have any hard dependencies besides bash. Running `install.sh` will install
linter packages for Python, Ruby, and/or Node.js if those languages are found on
your system. `nimpretty` is already installed if you have Nim, and `shellcheck`
and `shfmt` are available via package managers.

Note for Debian/Ubuntu and WSL users: the version of shellcheck installed via
`apt-get` is outdated; we recommend installing a
[shellcheck release](https://github.com/koalaman/shellcheck/releases) or using [linuxbrew](https://docs.brew.sh/Homebrew-on-Linux).

If your project contains a mixture of code you wish to lint and code you do not
wish to lint, you can configure [ignore patterns](#ignore-patterns).

## Continuous Integration

An example GitHub Actions workflow for linting your project:

```yml
# yamllint disable rule:line-length

name: Lint
on:
  pull_request:
    branches: ["*"]
  push:
    branches: ["*"]
    tags: ["*"]

jobs:
  lint:
    name: lint

    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      ## Uncomment if your project contains JS, CSS, Markdown, HTML, GraphQL or YAML
      # - uses: actions/setup-node@v2
      #   with:
      #     node-version: "15.x"

      ## Uncomment if your project contains Python code or YAML
      # - uses: actions/setup-python@v2
      #   with:
      #     python-version: "3.x"

      ## Uncomment if your project contains Ruby code
      # - uses: actions/setup-ruby@v1
      #   with:
      #     ruby-version: "3.x"

      ## Uncomment if your project contains shell scripts
      # - name: Install shellcheck & shfmt
      #   run: |
      #     # Linuxbrew has more recent versions than apt
      #     brew install shellcheck shfmt

      ## Uncomment if your project contains Nim code
      # - uses: asdf-vm/actions/install@v1
      #   with:
      #     tool_versions: |
      #       nim 1.4.2

      - name: Install lintball
        shell: bash
        run: curl -o- https://raw.githubusercontent.com/elijahr/lintball/devel/install.sh | bash

      - name: Check for linter issues
        run: lintball check
```

## Configuration

### Ignore patterns

By default, lintball will not check any files matching the following patterns:

```sh
*/.build/*
*/.bundle/*
*/.cache/*
*/.git/*
*/.hg/*
*/.next/*
*/.serverless_nextjs/*
*/.tmp/*
*/__pycache__/*
*/build/*
*/dist/*
*/Gemfile.lock
*/node_modules/*
*/package-lock.json
*/Pipfile.lock
*/target/*
*/tmp/*
*/vendor/*
```

Patterns are globs, as would be passed to the `find` command's `-path` argument.
To add or remove items from this list, run `lintball lintballrc` and edit the created `.lintballrc.json` file.

### Tool configuration

Many of the tools used by lintball can be configured to suit your needs. See:

- shellcheck: https://www.mankier.com/1/shellcheck#RC_Files
- prettier: https://prettier.io/docs/en/configuration.html
- eslint: https://eslint.org/docs/user-guide/configuring
- autopep8: https://pypi.org/project/autopep8/#configuration
- rubocop: https://docs.rubocop.org/rubocop/1.8/configuration.html
- uncrustify: https://github.com/uncrustify/uncrustify#configuring-the-program

If you need to pass custom arguments to a linter command (such as providing a path to a config file), run `lintball lintballrc` and edit the created `.lintballrc.json` file.

## Acknowledgements

lintball is a wrapper around existing tools. Many thanks to the authors of the tools used by lintball! This project (and your tidy code) stand on the shoulders of giants.

## Contributing

Pull requests are welcome! lintball has a suite of unit tests written with bats, located in the `test` directory. The tests can be run locally with `npm run test`. Please ensure that your features or fixes come with unit tests.
