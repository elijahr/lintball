# lintball

Multi-linter tool for keeping your project tidy.

lintball can fix all your code with one command, or a convenient githook that you can set and forget.

## Supported languages

| language                                                      |                                   tools used                                   |
| :------------------------------------------------------------ | :----------------------------------------------------------------------------: |
| JavaScript, TypeScript, JSON, <br/> Markdown, HTML, CSS, SASS |                                [`prettier`][1]                                 |
| YAML                                                          |                        [`prettier`][1] [`yamllint`][10]                        |
| sh, bash, dash, ksh, mksh                                     |                         [`shellcheck`][2] [`shfmt`][3]                         |
| Bats tests                                                    |                                  [`shfmt`][2]                                  |
| Python                                                        | [`autoflake`][4] [`autopep8`][5] [`black`][6] [`docformatter`][7] [`isort`][8] |
| Cython                                                        |              [`autoflake`][4] [`autopep8`][5] [`docformatter`][7]              |
| Nim                                                           |                                [`nimpretty`][9]                                |
| Ruby                                                          |                                [`rubocop`][11]                                 |

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

## Installation

```sh
curl -o- https://raw.githubusercontent.com/elijahr/lintball/v0.2.0/install.sh | bash
```

Running the above command downloads a script and runs it. The script clones the lintball repository to ~/.lintball, and configures your PATH to include the lintball scripts. Currently, fish, bash, and zsh are supported.

If you are using lintball with a git-managed project, we suggest using the pre-commit hook, installed via `install-lintball-githooks`. Your code will be automatically fixed on commit - and any linter errors will block the commit with a helpful error message.

### Dependencies

By default, lintball will not install any linters. You do not need to install all linters to use lintball; lintball will only use linters that correspond to the files in your project. To install all linters:

```sh
~/.lintball/install.sh --deps
```

The above install script assumes that you already have Python, Ruby, and NodeJS installed on your system.

If lintball checks are failing because of some missing linter that you do not wish to install, you can add an entry to your `.lintball-ignore` file - see the section on [ignore patterns](#ignore-patterns) below.

## Usage

lintball provides two scripts:

- `install-lintball-githooks` will configure the current working directory to use lintball's pre-commit hook, which fixes all auto-fixable problems found in the staged changes, and exits with an error if any issues cannot be fixed.
- `lintball`, usage below:

  ```
  Usage: lintball [options] [path ...]

  Running without any options will check your code, skipping over directories such as node_modules.

  Options:
  -h|--help
      Show this help message & exit.
  --write
      Auto fix any fixable issues. By default lintball will simply notify
      you of linter issues.
  --list
      List files which lintball will attempt to fix. Useful for debugging a
      .lintball-ignore file.
  ```

### Continuous Integration

lintball uses itself for lint checks in CI - see our GitHub Actions [workflow config](https://github.com/elijahr/lintball/blob/devel/.github/workflows/workflow.yml).

## Updating

You can update your installation of lintball with:

```sh
cd ~/.lintball; ./install.sh
```

## Configuration

### Ignore patterns

By default, lintball will not check any files matching the following patterns:

```sh
*/.git/*
*/.hg/*
*/node_modules/*
*/package-lock.json
*/.next/*
*/.serverless_nextjs/*
*/.tmp/*
*/tmp/*
*/.build/*
*/build/*
*/dist/*
*/__pycache__/*
*/Pipfile.lock
*/vendor/*
*/Gemfile.lock
```

Patterns are globs, as would be passed to the `find` command's `-path` argument.
To customize this list, create a `.lintball-ignore` file in your project.
`install-lintball-githooks` will create this file for you.

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
