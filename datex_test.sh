#!/bin/bash

#
#  datex_test.sh - testing environment for DATEX
#
#  Copyright (c) 2021 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

#
# Checks for shunit2
#
if [ ! "$(command -v shunit2)" ]; then
  echo 'Error: shunit2 not installed' >&2
  exit 1
fi

#
# Defines task name
#
function task() {
  echo -n ". $1 "
}

#
# Marks task as successful
#
function check() {
  sleep 0.1
  echo -e '\r\033[1;32m✓\033[0m'
}

#
# Unit test common routines, like Selenium Webdriver
#

function oneTimeSetUp() {
  src_dir=$(dirname "${BASH_SOURCE[0]}")
  DBFILE="$src_dir/data.csv"
  echo "Test start: $(date)"
  test -f "$DBFILE" || : >"$DBFILE"
}

function setUp() {
  echo
}

function tearDown() {
  sleep 0.2
}

function oneTimeTearDown() {
  rm -f "$DBFILE"
  echo -e "\nTest finish: $(date)"
}

#
# Test scenarios
#

function testSource() {
  task 'ls data.csv'
  ls "$DBFILE" >/dev/null 2>&1
  assertEquals 'ls data.csv' 0 $? && \
  check

  task 'source datex.sh'
  source "$src_dir/datex.sh"
  assertEquals 'source datex.sh' 0 $? && \
  check
}

function testCrudSetup() {
  local result

  task 'create header'
  create_header f_var f_type f_value
  assertEquals 'create header' 0 $? && \
  check

  task 'check empty table'
  result=$(list_records | wc -l)
  assertEquals 'check empty table' 1 "$result" && \
  check
}

function testCrudWrite() {
  local result

  task 'insert_record 1'
  result=$(insert_record f_var=seq f_type=integer f_value=1)
  assertContains 'insert_record 1' '"seq","integer",1' "$result" && \
  check

  task 'insert_record 2'
  result=$(insert_record f_var=name f_type=string f_value=bob)
  assertContains 'insert_record 2' '"name","string","bob"' "$result" && \
  check

  task 'insert_record 3'
  result=$(insert_record f_var=admin f_type=boolean f_value=false)
  assertContains 'insert_record 3' '"admin","boolean","false"' "$result" && \
  check

  task 'update_record 2'
  result=$(update_record 2 f_var=name f_type=string f_value=robert)
  assertContains 'update_record 2' '"name","string","robert"' "$result" && \
  check

  task 'delete_record 3'
  assertTrue 'delete_record 3' && \
  check
}

# function testRandom() {
#   task 'random_hash with base 2'
#   random_hash 8 2 >/dev/null
#   assertEquals 'random_hash with base 2' 0 $? && \
#   check
#
#   task 'random_hash with base 8'
#   random_hash 4 8 >/dev/null
#   assertEquals 'random_hash with base 8' 0 $? && \
#   check
#
#   task 'random_hash with base 10'
#   random_hash 5 10 >/dev/null
#   assertEquals 'random_hash with base 10' 0 $? && \
#   check
#
#   task 'random_hash with base 16'
#   random_hash 2 16 >/dev/null
#   assertEquals 'random_hash with base 16' 0 $? && \
#   check
#
#   task 'random_word'
#   random_word 12 >/dev/null
#   assertEquals 'random_word' 0 $? && \
#   check
#
#   task 'random_draw'
#   random_draw 1000 1 >/dev/null
#   assertEquals 'random_draw' 0 $? && \
#   check
#
#   task 'random_draw with excitement'
#   random_draw 1000 -1 >/dev/null
#   assertEquals 'random_draw with excitement' 0 $? && \
#   check
#
#   task 'random_guid'
#   random_guid >/dev/null
#   assertEquals 'random_guid' 0 $? && \
#   check
#
#   task 'random_mac'
#   random_mac >/dev/null
#   assertEquals 'random_mac' 0 $? && \
#   check
# }

# function testWol() {
#   local mac result
#   mac=$(random_mac)
#
#   task 'wol_str'
#   result=$(wol_str "$mac" | wc -c)
#   assertEquals 'wol_str' 102 "$result" && \
#   check
#
#   task 'wol_send'
#   wol_send "$mac"
#   assertEquals 'wol_send' 0 $? && \
#   check
# }

# function testHexorg() {
#   task 'hexorg w/o parameters'
#   bash "$src_dir/hexorg.sh" >/dev/null
#   assertEquals 'hexorg w/o parameters' 1 $? && \
#   check
# }

#
# Calls shunit2
#
# shellcheck disable=SC1091
source shunit2
