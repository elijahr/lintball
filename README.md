![Test](https://github.com/elijahr/lintball/workflows/Test/badge.svg)

```
█   █ █▄ █ ▀█▀ ██▄ ▄▀▄ █   █
█▄▄ █ █ ▀█  █  █▄█ █▀█ █▄▄ █▄▄
keep your code tidy with one command.
```

lintball is a wrapper script around linters (static code analysis tools) and code formatters (prettier, black, etc).

## Why use lintball?

Most software projects contain more than just a single programming language. Besides source code, there will be docs, configs, scripts, and so on. Each language may have tools to find and fix issues - but configuring CI, git hooks, etc for each of these tools can be tedious. The goal of lintball is to streamline the installation and running of these tools so that you have more time to play with your dog and work on your art.

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
| Lua          |                               [StyLua][15]                               |
| Luau         |                               [StyLua][15]                               |
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
| TSX          |                          [prettier-eslint][12]                           |
| TypeScript   |                          [prettier-eslint][12]                           |
| XML          |                        [prettier/plugin-xml][19]                         |
| YAML         |                      [prettier][1], [yamllint][10]                       |

## Installation

```sh
npm install lintball
```

## Usage

```

Usage: lintball [options] [command]

Options:
  -h, --help                Show this help message & exit.
  -v, --version             Print version & exit.
  -c, --config <path>       Use the .lintballrc.json config file at <path>.

Commands:
  check [path …]            Recursively check for issues.
                            Exits with status 1 if any issues are found.
  fix [path …]              Recursively fix issues.
                            Exits with status 1 if any issues exist which cannot
                            be fixed.
  list [path …]             List files which lintball is configured for
                            checking. If [paths …] are provided, lintball will
                            echo back the subset of those paths which it would
                            check with the given configuration. Useful for
                            debugging the ignores section of a .lintballrc.json
                            config file.
  update                    Update lintball to the latest version.
  githooks [path]           Install lintball githooks in the working directory
                            or [path].
  lintballrc [path]         Place a default .lintballrc.json config file in
                            the working directory or [path]

Examples:
  $ lintball check          # Check the working directory for issues.
  $ lintball fix            # Fix issues in the working directory.
  $ lintball check foo      # Check the foo directory for issues.
  $ lintball fix foo        # Fix issues in the foo directory.
  $ lintball check foo.py   # Check the foo.py file for issues.
  $ lintball fix foo.py     # Fix issues in the foo.py file.
```

## Updating

You can update to the latest version of lintball by running:

```sh
lintball update
```

## Dependencies

Lintball does not have any hard dependencies besides bash. Running `install.sh`
or `lintball update` will install linter packages for Python, Ruby, and/or
Node.js if those languages are found on your system. `nimpretty` is already
installed if you have Nim, and `shellcheck` and `shfmt` are available via
package managers.

Note for Debian/Ubuntu and WSL users: the version of shellcheck installed via
`apt-get` is outdated; we recommend installing a
[shellcheck release](https://github.com/koalaman/shellcheck/releases) or using
[linuxbrew](https://docs.brew.sh/Homebrew-on-Linux).

If your project contains a mixture of code you wish to lint and code you do not
wish to lint, you can configure [ignore patterns](#ignore-patterns).

## Continuous Integration

An example GitHub Actions workflow for linting your project:

```yml
# yamllint disable rule:line-length

name: Lint
on:
  pull_request:
    branches: ['*']
  push:
    branches: ['*']
    tags: ['*']

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

By default, lintball will not check files matching the following globs:

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

Glob patterns should match what is passed to the `find` command's `-path` argument.
To add or remove items from this list, run `lintball lintballrc` and edit the `ignores` section in the created `.lintballrc.json` file.

### Tool configuration

Many of the tools used by lintball can be configured to suit your needs. See:

- autopep8: https://pypi.org/project/autopep8/#configuration
- clippy: https://github.com/rust-lang/rust-clippy#configuration
- eslint: https://eslint.org/docs/user-guide/configuring
- prettier: https://prettier.io/docs/en/configuration.html
- rubocop: https://docs.rubocop.org/rubocop/1.8/configuration.html
- shellcheck: https://www.mankier.com/1/shellcheck#RC_Files
- uncrustify: https://github.com/uncrustify/uncrustify#configuring-the-program

If you need to pass custom arguments to a tool (such as specifying a config file), run `lintball lintballrc` and override `write_args` and/or `check_args` as needed in the created `.lintballrc.json` file. The default `write_args` and `check_args` are defined in [configs/lintballrc-defaults.json][21].

## Acknowledgements

lintball is a wrapper around existing tools. Many thanks to the authors of the tools used by lintball! This project (and your tidy code) stand on the shoulders of giants.

## Contributing

Pull requests are welcome! lintball has a suite of unit tests written with bats, located in the `test` directory. The tests can be run locally with `npm run test`. Please ensure that your features or fixes come with unit tests.

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
[21]: https://github.com/elijahr/lintball/tree/devel/config/lintballrc-defaults.json
