![Test](https://github.com/elijahr/lintball/workflows/Test/badge.svg)

# lintball

Multi-linter tool for keeping your project tidy.

lintball can fix all your code with one command, or a convenient githook that you can set and forget.

## Supported languages

| language                        |                                   tools used                                   |
| :------------------------------ | :----------------------------------------------------------------------------: |
| Markdown, JSON, HTML, CSS, SASS |                                [`prettier`][1]                                 |
| YAML                            |                        [`prettier`][1] [`yamllint`][10]                        |
| JavaScript, TypeScript, JSX     |                            [`prettier-eslint`][12]                             |
| sh, bash, dash, ksh, mksh       |                         [`shellcheck`][2] [`shfmt`][3]                         |
| Bats tests                      |                                  [`shfmt`][2]                                  |
| Python                          | [`autoflake`][4] [`autopep8`][5] [`black`][6] [`docformatter`][7] [`isort`][8] |
| Cython                          |              [`autoflake`][4] [`autopep8`][5] [`docformatter`][7]              |
| Nim                             |                                [`nimpretty`][9]                                |
| Ruby                            |                                [`rubocop`][11]                                 |

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
[12]: https://github.com/prettier/prettier-eslint

## Installation

```sh
curl -o- https://raw.githubusercontent.com/elijahr/lintball/v0.3.0/install.sh | bash
```

Running the above command downloads a script and runs it. The script clones the lintball repository to ~/.lintball, and configures your PATH to include the lintball scripts. Currently, fish, bash, and zsh are supported.

If you are using lintball with a git-managed project, we suggest using the pre-commit hook, installed via `lintball copy-githooks`. Your code will be automatically fixed on commit - and any linter errors will block the commit with a helpful error message.

## Usage

```
Usage: lintball [options] [command] [command options]

Options:

  -h | --help
      Show this help message & exit.

  -v | --version
      Print version & exit.

  -c | --config path
      Use the .lintballrc.json config file at path.

Commands:

  check [path ...]
      Check for and display linter issues recursively in paths or working dir.

  fix [path ...]
      Auto fix all fixable issues recursively in paths or working dir.

  list [path ...]
      List files which lintball recognizes for checking or fixing.

  copy-githooks [path]
      Install lintball githooks in the git repo at path or working dir.

  copy-lintballrc [path]
      Place a default .lintballrc.json configuration file in path or working dir.
```

### Continuous Integration

lintball provides a GitHub Action for

## Updating

You can update your installation of lintball with:

```sh
cd ~/.lintball; ./install.sh
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
*/tmp/*
*/vendor/*
```

Patterns are globs, as would be passed to the `find` command's `-path` argument.
To add or remove items from this list, run `lintball copy-lintballrc` and edit the created `.lintballrc.json` file.

### Tool configuration

Many of the tools used by lintball can be configured to suit your needs. See:

- shellcheck: https://www.mankier.com/1/shellcheck#RC_Files
- prettier: https://prettier.io/docs/en/configuration.html
- autopep8: https://pypi.org/project/autopep8/#configuration
- rubocop: https://docs.rubocop.org/rubocop/1.8/configuration.html

## Acknowledgements

lintball is a wrapper around existing tools. Many thanks to the authors of the tools used by lintball! We stand on the shoulders of giants.

## Contributing

Pull requests are welcome! lintball has a suite of unit tests written with bats, located in the `test` directory. The tests can be run locally with `npm run test`. Please ensure that your features or fixes come with unit tests.
