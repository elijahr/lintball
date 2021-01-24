# version_compare (1.0.0) [![Build Status](https://travis-ci.org/unicorn-fail/version_compare.svg?branch=master)](https://travis-ci.org/unicorn-fail/version_compare)

> Compares [semantic versions (1.0.0)](http://semver.org/spec/v1.0.0.html) versions in Bash, comparable to PHP's version_compare function.

## Usage

`version_compare [-hV] <version1> <version2> [<operator>]`

## Required arguments

- `<version1>`: First version number to compare.
- `<version2>`: Second version number to compare.

## Optional arguments

- `<operator>`: When this argument is provided, it will test for a particular relationship.
  This argument is case-sensitive, values should be lowercase.
  Possible operators are:
  - `=, ==, eq` (equal)
  - `>, gt` (greater than)
  - `>=, ge` (greater than or equal)
  - `<, lt` (less than)
  - `<=, le` (less than or equal)
  - `!=, <>, ne` (not equal)

## Return Value

There are two distinct operation modes for version_compare. It's solely based
on whether or not the `<operator>` argument was provided:

- When `<operator>` **IS** provided, `version_compare` will return either a `0` or `1`
  exit code (no output printed to /dev/stdout) based on the result of the `<operator>`
  relationship between the versions. This is particularly useful in cases where
  testing versions can, historically, be quite cumbersome:

  ```bash
  ! version_compare ${version1} ${version2} ">" && echo "You have not met the minimum version requirements." && exit 1
  ```

  You can, of course, opt for the more traditional/verbose conditional
  block in that suites your fancy:

  ```bash
  version_compare ${version1} ${version2}
  if [ $? -gt 0 ]; then
    echo "You have not met the minimum version requirements."
    exit 1
  fi
  ```

- When `<operator>` is **NOT** provided, `version_compare` will output (print to /dev/stdout):

  - `-1`: `<version1>` is lower than `<version2>`
  - `0`: `<version1>` and `<version2>` are equal"
  - `1`: `<version2>` is lower than `<version1>`

  This mode is primarily only ever helpful when there is a need to determine the
  relationship between two versions and provide logic for all three states:

  ```bash
  ret=$(version_compare ${version1} ${version2})
  if [ "${ret}" == "-1" ]; then
    # Do some logic here.
  elif [ "${ret}" == "0" ]; then
    # Do some logic here.
  else
    # Do some logic here.
  fi
  ```

  While there are use cases for both modes, it's recommended that you provide an
  `<operator>` argument to reduce any logic whenever possible.

## Options

- `-h`: Display help and exit.
- `-V`: Display version information and exit.
