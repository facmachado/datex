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
  output_json="$src_dir/output_json.awk"
  output_csv="$src_dir/output_csv.awk"
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
  assertEquals 'ls data.csv' $? 0 && \
  check

  task 'source datex.sh'
  # shellcheck source=/dev/null
  source "$src_dir/datex.sh"
  assertEquals 'source datex.sh' $? 0 && \
  check
}

function testCrudSetup() {
  local result

  task 'create header'
  create_header f_var f_type f_value
  assertEquals 'create header' $? 0 && \
  check

  task 'check empty table'
  result=$(list_records | wc -l)
  assertEquals 'check empty table' "$result" 1 && \
  check
}

function testCrudWrite() {
  local result

  task 'insert_record 1'
  insert_record f_var=seq f_type=integer f_value=1
  result=$(select_record 1 | head -1)
  assertEquals 'insert_record 1' "$result" 'id = 1' && \
  check

  task 'insert_record 2'
  insert_record f_var=name f_type=string f_value=bob
  result=$(select_record 2 | head -1)
  assertEquals 'insert_record 2' "$result" 'id = 2' && \
  check

  task 'insert_record 3'
  insert_record f_var=admin f_type=boolean f_value=false
  result=$(select_record 3 | head -1)
  assertEquals 'insert_record 3' "$result" 'id = 3' && \
  check

  task 'insert_record 4'
  insert_record f_var=status f_type=integer f_value=0
  result=$(select_record 4 | head -1)
  assertEquals 'insert_record 4' "$result" 'id = 4' && \
  check

  task 'update_record 2'
  update_record 2 f_value=robert
  result=$(select_record 2 | grep robert)
  assertEquals 'update_record 2' "$result" 'f_value = robert' && \
  check

  task 'delete_record 4'
  delete_record 4
  result=$(grep -E ',1$' "$DBFILE" | grep -cE '^4,')
  assertEquals 'delete_record 4' "$result" 1 && \
  check
}

function testCrudRead() {
  local result

  task 'list_records'
  result=$(list_records | wc -l)
  assertEquals 'list_records' "$result" 23 && \
  check

  task 'list_records 2 2'
  result=$(list_records 2 2 | wc -l)
  assertEquals 'list_records 2 2' "$result" 15 && \
  check

  task 'search_records robert'
  result=$(search_records robert)
  assertContains 'search_records robert' "$result" 'f_value = robert' && \
  check

  task 'select_record 3'
  result=$(select_record 3 | head -1)
  assertEquals 'select_record 3' "$result" 'id = 3' && \
  check
}

function testOutput() {
  local result

  task 'output_csv'
  result=$(select_record 1 | awk -f "$output_csv")
  assertContains 'output_csv' "$result" '"seq","integer",1' && \
  check

  task 'output_json'
  result=$(select_record 1 | awk -f "$output_json")
  assertContains 'output_json' "$result" '"f_var":"seq","f_type":"integer","f_value":1' && \
  check
}

#
# Calls shunit2
#
# shellcheck disable=SC1091
source shunit2
