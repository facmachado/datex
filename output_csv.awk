#!/usr/bin/awk -f

#
#  DATEX - Textual database library for Shell Script
#
#  Copyright (c) 2020 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

function output() {
  if (line) {
    print line
  }
  line = ""
}

function trim(x) {
  sub(/^ */, "", x)
  sub(/ *$/, "", x)
  return x
}

BEGIN {
  line = ""
}

NF == 0 {
  output()
  next
}

{
  if (line) {
    line = line ","
  }
  i = index($0, "=")
  value = ((substr($0, i + 2) ~ /^[0-9]+$/) \
    ? substr($0, i + 2) \
    : "\"" substr($0, i + 2) "\"")
  line = line value
}

END {
  output()
}
