#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ../lib/utils
load ./lib/test_utils

setup() {
  setup_test
}

teardown() {
  teardown_test
}

@test 'lintball fix # lintball lang=bash' {
  run lintball fix "b_bash"
  assert_success
  directive="# lintball lang=bash"
  expected="$(
    cat <<EOF
$directive

a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "b_bash")" "$expected"
}

@test 'lintball fix #!/bin/sh' {
  run lintball fix "a_sh"
  assert_success
  expected="$(
    cat <<EOF
#!/bin/sh

a() {
  echo

}

b() {

  echo
}
EOF
  )"
  assert_equal "$(cat "a_sh")" "$expected"
}

@test 'lintball fix #!/usr/bin/env bash' {
  run lintball fix "a_bash"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env bash

a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "a_bash")" "$expected"
}

@test 'lintball fix #!/usr/bin/env deno' {
  run lintball fix "b_js"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env deno

modules.exports = {
  foo: function() {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "b_js")" "$expected"
}
@test 'lintball fix #!/usr/bin/env node' {
  run lintball fix "a_js"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env node

modules.exports = {
  foo: function() {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "a_js")" "$expected"
}

@test 'lintball fix #!/usr/bin/env python3' {
  run lintball fix "a_py"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env python3

"""A Python module.

This module docstring should be dedented.
"""

import path
import system


def a(arg):
    """This should be trimmed."""
    print(arg, "b", "c", "d")
    print(path)
    print(system)
EOF
  )"
  assert_equal "$(cat "a_py")" "$expected"
}

@test 'lintball fix #!/usr/bin/env ruby' {
  run lintball fix "a_rb"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env ruby
# frozen_string_literal: true
d = [123, 456, 789]

echo d
EOF
  )"
  assert_equal "$(cat "a_rb")" "$expected"
}

@test 'lintball fix *.bash' {
  run lintball fix "a.bash"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "a.bash")" "$expected"
}

@test 'lintball fix *.bats' {
  run lintball fix "a.bats"
  assert_success
  assert_equal "$(cat "a.bats")" "$(cat "a.bats.expected")"
}

@test 'lintball fix *.c' {
  run lintball fix "a.c"
  assert_success
  expected="$(
    cat <<EOF
#include <stdio.h>

int main()
{
	printf("Hello World!");
	return (0);
}
EOF
  )"
  assert_equal "$(cat "a.c")" "$expected"
}

@test 'lintball fix *.cpp' {
  run lintball fix "a.cpp"
  assert_success
  expected="$(
    cat <<EOF
#include <iostream>

int main()
{
  std::cout << "Hello World!";
  return 0;
}
EOF
  )"
  assert_equal "$(cat "a.cpp")" "$expected"
}

@test 'lintball fix *.cs' {
  run lintball fix "a.cs"
  assert_success
  expected="$(
    cat <<EOF
namespace HelloWorld {
class Hello {
  static void Main(string[] args)
  {
    System.Console.WriteLine("Hello World!");
  }
}
}
EOF
  )"
  assert_equal "$(cat "a.cs")" "$expected"
}

@test 'lintball fix *.css' {
  run lintball fix "a.css"
  assert_success
  expected="$(
    cat <<EOF
html body h1 {
  font-weight: 800;
}
EOF
  )"
  assert_equal "$(cat "a.css")" "$expected"
}

@test 'lintball fix *.d' {
  run lintball fix "a.d"
  assert_success
  expected="$(
    cat <<EOF

import std.stdio;

void main()   {
  writeln(
    "Hello, World!");
}
EOF
  )"
  assert_equal "$(cat "a.d")" "$expected"
}

@test 'lintball fix *.dash' {
  run lintball fix "a.dash"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}
EOF
  )"
  assert_equal "$(cat "a.dash")" "$expected"
}

@test 'lintball fix *.h' {
  run lintball fix "a.h"
  assert_success
  expected="$(
    cat <<EOF
#include <stdio.h>

int main();
EOF
  )"
  assert_equal "$(cat "a.h")" "$expected"
}

@test 'lintball fix *.hpp' {
  run lintball fix "a.hpp"
  assert_success
  expected="$(
    cat <<EOF
#include <iostream>

int main();
EOF
  )"
  assert_equal "$(cat "a.hpp")" "$expected"
}

@test 'lintball fix *.html' {
  run lintball fix "a.html"
  assert_success
  expected="$(
    cat <<EOF
<html>
  <head>
    <title>A</title>
  </head>

  <body>
    <h1>B</h1>
  </body>
</html>
EOF
  )"
  assert_equal "$(cat "a.html")" "$expected"
}

@test 'lintball fix *.java' {
  run lintball fix "a.java"
  assert_success
  expected="$(
    cat <<EOF
class HelloWorld {

  public static void main(String[] args) {
    System.out.println("Hello, World!");
  }
}
EOF
  )"
  assert_equal "$(cat "a.java")" "$expected"
}

@test 'lintball fix *.js' {
  run lintball fix "a.js"
  assert_success
  expected="$(
    cat <<EOF
modules.exports = {
  foo: function() {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "a.js")" "$expected"
}

@test 'lintball fix *.json' {
  run lintball fix "a.json"
  assert_success
  expected="$(
    cat <<EOF
{ "a": "b", "c": "d" }
EOF
  )"
  assert_equal "$(cat "a.json")" "$expected"
}

@test 'lintball fix *.jsx' {
  run lintball fix "a.jsx"
  assert_success
  expected="$(
    cat <<EOF
ReactDOM.render(<h1>Hello, world!</h1>, document.getElementById("root"));
EOF
  )"
  assert_equal "$(cat "a.jsx")" "$expected"
}

@test 'lintball fix *.ksh' {
  run lintball fix "a.ksh"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "a.ksh")" "$expected"
}

@test 'lintball fix *.lua' {
  run lintball fix "a.lua"
  assert_success
  expected="$(
    cat <<EOF
type A = { b: number, c: number }

local a: A = { b = 1, c = 2 }

print(a.b, a.c)
EOF
  )"
  assert_equal "$(cat "a.lua")" "$expected"
}

@test 'lintball fix *.m' {
  run lintball fix "a.m"
  assert_success
  expected="$(
    cat <<EOF
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"Hello, World!");
    [pool drain];
    return 0;
}
EOF
  )"
  assert_equal "$(cat "a.m")" "$expected"
}

@test 'lintball fix *.md' {
  run lintball fix "a.md"
  assert_success
  expected="$(
    cat <<EOF
| aaaa | bbbbbb |  cc |
| :--- | :----: | --: |
| a    |   b    |   c |
EOF
  )"
  assert_equal "$(cat "a.md")" "$expected"
}

@test 'lintball fix *.mksh' {
  run lintball fix "a.mksh"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "a.mksh")" "$expected"
}

@test 'lintball fix *.nim' {
  run lintball fix "a.nim"
  assert_success
  expected="$(
    cat <<EOF

type
  A* = int
  B* = int

EOF
  )"
  assert_equal "$(cat "a.nim")" "$expected"
}

@test 'lintball fix *.pug' {
  run lintball fix "a.pug"
  assert_success
  expected="$(
    cat <<EOF
html
  head
    title
      | A
  body
    h1 B
EOF
  )"
  assert_equal "$(cat "a.pug")" "$expected"
}

@test 'lintball fix *.py' {
  run lintball fix "a.py"
  assert_success
  expected="$(
    cat <<EOF
"""A Python module.

This module docstring should be dedented.
"""

import path
import system


def a(arg):
    """This should be trimmed."""
    print(arg, "b", "c", "d")
    print(path)
    print(system)
EOF
  )"
  assert_equal "$(cat "a.py")" "$expected"
}

@test 'lintball fix *.pyx' {
  run lintball fix "a.pyx"
  assert_success
  expected="$(
    cat <<EOF

cdef void fun(char * a) nogil:
    cdef:
        char * dest = a
EOF
  )"
  assert_equal "$(cat "a.pyx")" "$expected"
}

@test 'lintball fix *.rb' {
  run lintball fix "a.rb"
  assert_success
  expected="$(
    cat <<EOF
# frozen_string_literal: true
d = [123, 456, 789]

echo d
EOF
  )"
  assert_equal "$(cat "a.rb")" "$expected"
}

@test 'lintball fix *.scss' {
  run lintball fix "a.scss"
  assert_success
  expected="$(
    cat <<EOF
html {
  body {
    h1 {
      font-weight: 800;
    }
  }
}
EOF
  )"
  assert_equal "$(cat "a.scss")" "$expected"
}

@test 'lintball fix *.sh' {
  run lintball fix "a.sh"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}
EOF
  )"
  assert_equal "$(cat "a.sh")" "$expected"
}

@test 'lintball fix *.tsx' {
  run lintball fix "a.tsx"
  assert_success
  expected="$(
    cat <<EOF
import { h, Component } from "preact";

export interface HelloWorldProps {
  name: string;
}

export default class HelloWorld extends Component<HelloWorldProps, any> {
  render(props) {
    return <p>Hello {props.name}!</p>;
  }
}
EOF
  )"
  assert_equal "$(cat "a.tsx")" "$expected"
}

@test 'lintball fix *.xml' {
  run lintball fix "a.xml"
  assert_success
  expected="$(
    cat <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<items>
    <a>A</a>
    <b>B</b>
    <c />
</items>
EOF
  )"
  assert_equal "$(cat "a.xml")" "$expected"
}

@test 'lintball fix *.yml' {
  run lintball fix "a.yml"
  assert_success
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "a.yml")" "$expected"
}

@test 'lintball fix Cargo.toml' {
  run lintball fix "Cargo.toml"
  expected="$(
    cat <<EOF

#![allow(clippy::stable_sort_primitive)]



fn unnecessary_sort_by() {
    fn id(x: isize) -> isize {
        x
    }
    let mut vec: Vec<isize> = vec![3, 6, 1, 2, 5];
    // Forward examples
    vec.sort();
    vec.sort_unstable();
    vec.sort_by_key(|a| (a + 5).abs());
    vec.sort_unstable_by_key(|a| id(-a));
}

fn main() {
    unnecessary_sort_by();
}
EOF
  )"
  assert_success
  assert_equal "$(cat "src/main.rs")" "$expected"
}

@test 'lintball fix handles implicit path' {
  mkdir foo
  cd foo
  run lintball fix
  assert_success
}

@test 'lintball fix does not fix ignored files' {
  mkdir -p vendor
  cp a.rb vendor/
  run lintball fix vendor/a.rb
  assert_success
  assert_equal "$(cat "vendor/a.rb")" "$(cat "a.rb")"
}

@test 'lintball fix handles paths with spaces' {
  mkdir -p "aaa aaa/bbb bbb"
  cp "a.yml" "aaa aaa/bbb bbb/a b.yml"
  run lintball fix "aaa aaa/bbb bbb/a b.yml"
  assert_success
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "aaa aaa/bbb bbb/a b.yml")" "$expected"
}

@test 'lintball fix package.json' {
  run lintball fix "package.json"
  assert_success
  expected="$(
    cat <<EOF
{
  "main": "a.js",
  "name": "fixture",
  "version": "1.0.0",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "description": ""
}
EOF
  )"
  assert_equal "$(cat "package.json")" "$expected"
}

@test 'lintball fix unhandled is a no-op' {
  run lintball fix "a.txt"
  assert_success
}
