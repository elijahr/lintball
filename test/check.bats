#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ./lib/test_utils

setup() {
  setup_test
}

teardown() {
  teardown_test
}

@test 'lintball check' {
  # Remove all but two files - just an optimization
  find . -type f -not -name 'a.json' -not -name 'a.yml' -delete
  run lintball check
  assert_failure
  run lintball fix
  run lintball check
  assert_success
}

@test 'lintball check --since HEAD~1' {
  git add .
  git reset a.html a.xml a.yml
  git commit -m "commit 1"
  git add a.html
  git commit -m "commit 2"
  git rm a.md
  git commit -m "commit 3"
  git add a.yml
  run lintball check --since HEAD~2
  assert_failure
  # previously committed
  assert_line "[warn] a.html"
  # untracked
  assert_line "[warn] a.xml"
  # staged, never committed
  assert_line "[warn] a.yml"
  # deleted
  refute_line "[warn] a.md"
  # committed before HEAD~2
  refute_line "[warn] a.css"
  run lintball fix --since HEAD~1
  run lintball check --since HEAD~1
  assert_success
}

@test 'lintball check # lintball lang=bash' {
  run lintball check "b_bash"
  assert_failure
  run lintball fix "b_bash"
  run lintball check "b_bash"
  assert_success
}

@test 'lintball check #!/bin/sh' {
  run lintball check "a_sh"
  assert_failure
  run lintball fix "a_sh"
  run lintball check "a_sh"
  assert_success
}

@test 'lintball check #!/usr/bin/env bash' {
  run lintball check "a_bash"
  assert_failure
  run lintball fix "a_bash"
  run lintball check "a_bash"
  assert_success
}

@test 'lintball check #!/usr/bin/env deno' {
  run lintball check "b_js"
  assert_failure
  run lintball fix "b_js"
  run lintball check "b_js"
  assert_success
}

@test 'lintball check #!/usr/bin/env node' {
  run lintball check "a_js"
  assert_failure
  run lintball fix "a_js"
  run lintball check "a_js"
  assert_success
}

@test 'lintball check #!/usr/bin/env python3' {
  run lintball check "a_py"
  assert_failure
  run lintball fix "a_py"
  run lintball check "a_py"
  assert_success
}

@test 'lintball check #!/usr/bin/env ruby' {
  run lintball check "a_rb"
  assert_failure
  run lintball fix "a_rb"
  run lintball check "a_rb"
  assert_success
}

@test 'lintball check *.bash' {
  run lintball check "a.bash"
  assert_failure
  run lintball fix "a.bash"
  run lintball check "a.bash"
  assert_success
}

@test 'lintball check *.bats' {
  run lintball check "a.bats"
  assert_failure
  run lintball fix "a.bats"
  run lintball check "a.bats"
  assert_success
}

@test 'lintball check *.c' {
  run lintball check "a.c"
  assert_failure
  run lintball fix "a.c"
  run lintball check "a.c"
  assert_success
}

@test 'lintball check *.cpp' {
  run lintball check "a.cpp"
  assert_failure
  run lintball fix "a.cpp"
  run lintball check "a.cpp"
  assert_success
}

@test 'lintball check *.cs' {
  run lintball check "a.cs"
  assert_failure
  run lintball fix "a.cs"
  run lintball check "a.cs"
  assert_success
}

@test 'lintball check *.css' {
  run lintball check "a.css"
  assert_failure
  run lintball fix "a.css"
  run lintball check "a.css"
  assert_success
}

@test 'lintball check *.d' {
  run lintball check "a.d"
  assert_failure
  run lintball fix "a.d"
  run lintball check "a.d"
  assert_success
}

@test 'lintball check *.dash' {
  run lintball check "a.dash"
  assert_failure
  run lintball fix "a.dash"
  run lintball check "a.dash"
  assert_success
}

@test 'lintball check *.h' {
  run lintball check "a.h"
  assert_failure
  run lintball fix "a.h"
  run lintball check "a.h"
  assert_success
}

@test 'lintball check *.hpp' {
  run lintball check "a.hpp"
  assert_failure
  run lintball fix "a.hpp"
  run lintball check "a.hpp"
  assert_success
}

@test 'lintball check *.html' {
  run lintball check "a.html"
  assert_failure
  run lintball fix "a.html"
  run lintball check "a.html"
  assert_success
}

@test 'lintball check *.java' {
  run lintball check "a.java"
  assert_failure
  run lintball fix "a.java"
  run lintball check "a.java"
  assert_success
}

@test 'lintball check *.js' {
  run lintball check "a.js"
  assert_failure
  run lintball fix "a.js"
  run lintball check "a.js"
  assert_success
}

@test 'lintball check *.json' {
  run lintball check "a.json"
  assert_failure
  run lintball fix "a.json"
  run lintball check "a.json"
  assert_success
}

@test 'lintball check *.jsx' {
  run lintball check "a.jsx"
  assert_failure
  run lintball fix "a.jsx"
  run lintball check "a.jsx"
  assert_success
}

@test 'lintball check *.ksh' {
  run lintball check "a.ksh"
  assert_failure
  run lintball fix "a.ksh"
  run lintball check "a.ksh"
  assert_success
}

@test 'lintball check *.lua' {
  run lintball check "a.lua"
  assert_failure
  run lintball fix "a.lua"
  run lintball check "a.lua"
  assert_success
}

@test 'lintball check *.m' {
  run lintball check "a.m"
  assert_failure
  run lintball fix "a.m"
  run lintball check "a.m"
  assert_success
}

@test 'lintball check *.md' {
  run lintball check "a.md"
  assert_failure
  run lintball fix "a.md"
  run lintball check "a.md"
  assert_success
}

@test 'lintball check *.mksh' {
  run lintball check "a.mksh"
  assert_failure
  run lintball fix "a.mksh"
  run lintball check "a.mksh"
  assert_success
}

@test 'lintball check *.nim' {
  run lintball check "a.nim"
  assert_failure
  run lintball fix "a.nim"
  run lintball check "a.nim"
  assert_success
}

@test 'lintball check *.pug' {
  run lintball check "a.pug"
  assert_failure
  run lintball fix "a.pug"
  run lintball check "a.pug"
  assert_success
}

@test 'lintball check *.py' {
  run lintball check "a.py"
  assert_failure
  run lintball fix "a.py"
  run lintball check "a.py"
  assert_success
}

@test 'lintball check *.pyx' {
  run lintball check "a.pyx"
  assert_failure
  run lintball fix "a.pyx"
  run lintball check "a.pyx"
  assert_success
}

@test 'lintball check *.rb' {
  run lintball check "a.rb"
  assert_failure
  run lintball fix "a.rb"
  run lintball check "a.rb"
  assert_success
}

@test 'lintball check *.scss' {
  run lintball check "a.scss"
  assert_failure
  run lintball fix "a.scss"
  run lintball check "a.scss"
  assert_success
}

@test 'lintball check *.sh' {
  run lintball check "a.sh"
  assert_failure
  run lintball fix "a.sh"
  run lintball check "a.sh"
  assert_success
}

@test 'lintball check *.tsx' {
  run lintball check "a.tsx"
  assert_failure
  run lintball fix "a.tsx"
  run lintball check "a.tsx"
  assert_success
}

@test 'lintball check *.xml' {
  run lintball check "a.xml"
  assert_failure
  run lintball fix "a.xml"
  run lintball check "a.xml"
  assert_success
}

@test 'lintball check *.yml' {
  run lintball check "a.yml"
  assert_failure
  run lintball fix "a.yml"
  run lintball check "a.yml"
  assert_success
}

@test 'lintball check Cargo.toml' {
  run lintball check "Cargo.toml"
  assert_failure
  run lintball fix "Cargo.toml"
  run lintball check "Cargo.toml"
  assert_success
}

@test 'lintball check does not check ignored files' {
  mkdir -p vendor
  cp a.rb vendor/
  run lintball check vendor/a.rb
  assert_success
}

@test 'lintball check handles paths with spaces' {
  mkdir -p "aaa aaa/bbb bbb"
  cp "a.yml" "aaa aaa/bbb bbb/a b.yml"
  run lintball check "aaa aaa/bbb bbb/a b.yml"
  assert_failure
  assert_line "[warn] aaa aaa/bbb bbb/a b.yml"
}

@test 'lintball check package.json' {
  run lintball check "package.json"
  assert_failure
  run lintball fix "package.json"
  run lintball check "package.json"
  assert_success
}

@test 'lintball check unhandled is a no-op' {
  run lintball check "a.txt"
  assert_success
}
