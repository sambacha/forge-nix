#!/usr/bin/env bash

source forge2nix
source ../critic.shlib

# Test suite
_describe forge2nix
  # Since no function/expression is passed to _test,
  # it defaults to the test suite name (forge2nix). So, the function
  # forge2nix is invoked for each test
  _test "Should print forge2nix"
    _assert _output_equals forge2nix

_describe bar
  _test "Should not print baz"
    _assert _not _output_equals baz

_describe echo_first
  # If you want to pass arguments to the test function,
  # the function name has to be explicitly specified
  _test "Should get the correct number of args" echo_first "first arg" "second\\ arg"
    _assert _nth_arg_equals 0 "first arg" "First argument equals 0"
    _assert _nth_arg_equals 1 "second\\ arg"

_describe "custom expression"
  # The true expression means don't do anything
  # You can pass any bash expression there!
  _test "Should test custom expression" true
    _assert "[ 1 -eq 1 ]"
    _assert "[ 2 -eq 2 ]" "Two should be equal to two"

# This is just a regular script, so setup tests as you like!
readme="$(cat <<EOF
critic.sh test file
Usage: test.sh forge2nix|bar
EOF
)"

_describe "readme"
  _test "Should print readme" "echo \$readme"
    _assert _output_contains "forge2nix|bar" "Readme contains options"
    _assert _output_contains "critic.sh"