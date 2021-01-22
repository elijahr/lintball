![Test](https://github.com/elijahr/lintball/workflows/Test/badge.svg)

```
█   █ █▄ █ ▀█▀ ██▄ ▄▀▄ █   █
█▄▄ █ █ ▀█  █  █▄█ █▀█ █▄▄ █▄▄
keep your entire project tidy with one command.
```

lintball is a wrapper script around linters (static code analysis tools) and code formatters (prettier, black, etc).

## Why use lintball?

Most software projects contain more than one programming language. Besides source code, there will be docs, configs, scripts, and so on. Each language may have tools to find and fix issues - but configuring CI, git hooks, etc for each of these tools can be tedious. The goal of lintball is to streamline the installation and running of these tools so that you have more time to play with your dog and work on your art.

## Supported languages

| Language     | Detection                                                 |                                 Tools used                                 |
| :----------- | --------------------------------------------------------- | :------------------------------------------------------------------------: |
| bash         | `*.bash`, `#!/usr/bin/env bash`                           |                        [shellcheck][1], [shfmt][1]                         |
| bats         | `*.bats`, `#!/usr/bin/env bats`                           |                        [shellcheck][1], [shfmt][2]                         |
| C            | `*.c`, `*.h`                                              |                              [uncrustify][3]                               |
| C#           | `*.cs`                                                    |                              [uncrustify][3]                               |
| C++          | `*.cpp`, `*.hpp`                                          |                              [uncrustify][3]                               |
| CSS          | `*.css`                                                   |                               [prettier][4]                                |
| Cython       | `*.pyx`, `*.pxd`, `*.pxi`                                 |              [autoflake][5], [autopep8][6], [docformatter][7]              |
| D            | `*.d`                                                     |                              [uncrustify][3]                               |
| dash         | `*.dash`, `#!/usr/bin/env dash`                           |                        [shellcheck][1], [shfmt][2]                         |
| GraphQL      | `*.graphql`                                               |                               [prettier][4]                                |
| HTML         | `*.html`                                                  |                               [prettier][4]                                |
| Java         | `*.java`                                                  |                             [prettier-java][8]                             |
| JavaScript   | `*.js`, `#!/usr/bin/env node`, `#!/usr/bin/env deno`      |                            [prettier-eslint][9]                            |
| JSON         | `*.json`                                                  |                               [prettier][4]                                |
| JSX          | `*.jsx`                                                   |                            [prettier-eslint][9]                            |
| ksh          | `*.ksh`, `#!/usr/bin/env ksh`                             |                        [shellcheck][1], [shfmt][2]                         |
| Lua          | `*.lua`                                                   |                                [StyLua][10]                                |
| Luau         | `*.lua`                                                   |                                [StyLua][10]                                |
| Markdown     | `*.md`                                                    |                               [prettier][4]                                |
| mksh         | `*.mksh`, `#!/usr/bin/env mksh`                           |                        [shellcheck][1], [shfmt][2]                         |
| Nim          | `*.nim`                                                   |                              [nimpretty][11]                               |
| Objective-C  | `*.m`, `*.mm`, `*.M`                                      |                              [uncrustify][3]                               |
| package.json | `package.json`                                            |                        [prettier-package-json][12]                         |
| pug          | `*.pug`                                                   |                         [prettier/plugin-pug][13]                          |
| Python       | `*.py`, `#!/usr/bin/env python`, `#!/usr/bin/env python3` | [autoflake][5], [autopep8][6], [black][14], [docformatter][7], [isort][15] |
| Ruby         | `*.rb`, `Gemfile`, `#!/usr/bin/env ruby`                  |                 [@prettier/plugin-ruby][16], [rubocop][17]                 |
| Rust         | `Cargo.toml`                                              |                                [clippy][18]                                |
| SASS         | `*.scss`                                                  |                               [prettier][4]                                |
| sh           | `*.sh`, `#!/bin/sh`                                       |                        [shellcheck][1], [shfmt][2]                         |
| TSX          | `*.tsx`                                                   |                            [prettier-eslint][9]                            |
| TypeScript   | `*.ts`                                                    |                            [prettier-eslint][9]                            |
| XML          | `*.xml`                                                   |                         [prettier/plugin-xml][19]                          |
| YAML         | `*.yml`, `*.yaml`                                         |                       [prettier][4], [yamllint][20]                        |

## Installation

```sh
npm install https://github.com/elijahr/lintball.git
```

## Usage

```

```

## Updating

You can update to the latest version of lintball by running:

```sh
lintball update
```

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
      #     ruby-version: "3.0.0"

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

      ## Uncomment if your project contains Rust code
      # - uses: hecrj/setup-rust-action@v1
      #  with:
      #    rust-version: nightly

      - name: Install lintball
        shell: bash
        run: |
          npm install -g https://github.com/elijahr/lintball.git
          npx lintball install-tools --yes

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

Patterns should match what is passed to the `find` command's `-path` argument.
To add or remove items from this list, run `lintball install-lintballrc` and edit the `ignores` section in the created `.lintballrc.json` file.

### Disabling tools

Many of the tools used by lintball can be configured to suit your needs. See:

- autopep8: https://pypi.org/project/autopep8/#configuration
- clippy: https://github.com/rust-lang/rust-clippy#configuration
- eslint: https://eslint.org/docs/user-guide/configuring
- prettier: https://prettier.io/docs/en/configuration.html
- rubocop: https://docs.rubocop.org/rubocop/1.8/configuration.html
- shellcheck: https://www.mankier.com/1/shellcheck#RC_Files
- uncrustify: https://github.com/uncrustify/uncrustify#configuring-the-program

If you need to pass custom arguments to a tool (such as specifying a config file), run `lintball install-lintballrc` and override `write_args` and/or `check_args` as needed in the created `.lintballrc.json` file. The default `write_args` and `check_args` are defined in [configs/lintballrc-defaults.json][21].

### Tool configuration

Many of the tools used by lintball can be configured to suit your needs. See:

- autopep8: https://pypi.org/project/autopep8/#configuration
- clippy: https://github.com/rust-lang/rust-clippy#configuration
- eslint: https://eslint.org/docs/user-guide/configuring
- prettier: https://prettier.io/docs/en/configuration.html
- rubocop: https://docs.rubocop.org/rubocop/1.8/configuration.html
- shellcheck: https://www.mankier.com/1/shellcheck#RC_Files
- uncrustify: https://github.com/uncrustify/uncrustify#configuring-the-program

If you need to pass custom arguments to a tool (such as specifying a config file), run `lintball install-lintballrc` and override `write_args` and/or `check_args` as needed in the created `.lintballrc.json` file. The default `write_args` and `check_args` are defined in [configs/lintballrc-defaults.json][21].

## Acknowledgements

lintball is a wrapper around existing tools. Many thanks to the authors of the tools used by lintball! This project (and your tidy code) stand on the shoulders of giants.

## Contributing

Pull requests are welcome! lintball has a suite of unit tests written with bats, located in the `test` directory. The tests can be run locally with `npm run test`. Please ensure that your features or fixes come with unit tests.

[1]: https://www.shellcheck.net/
[2]: https://github.com/mvdan/sh
[3]: http://uncrustify.sourceforge.net/
[4]: https://prettier.io/
[5]: https://pypi.org/project/autoflake/
[6]: https://pypi.org/project/autopep8/
[7]: https://pypi.org/project/docformatter/
[8]: https://github.com/jhipster/prettier-java
[9]: https://github.com/prettier/prettier-eslint-cli
[10]: https://github.com/JohnnyMorganz/StyLua
[11]: https://nim-lang.org/docs/tools.html
[12]: https://github.com/cameronhunter/prettier-package-json
[13]: https://github.com/prettier/plugin-pug
[14]: https://github.com/psf/black
[15]: https://pypi.org/project/isort/
[16]: https://github.com/prettier/plugin-ruby
[17]: https://github.com/rubocop-hq/rubocop
[18]: https://github.com/rust-lang/rust-clippy
[19]: https://github.com/prettier/plugin-xml
[20]: https://yamllint.readthedocs.io/en/stable/
[21]: https://github.com/elijahr/lintball/tree/devel/config/lintballrc-defaults.json
