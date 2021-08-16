#!/usr/bin/awk -f

#
#  DATEX - Textual database library for Shell Script
#
#  Copyright (c) 2021 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

function output() {
  if (n++ && line) {
    printf ","
  }
  if (line) {
    printf "{" line "}"
  }
  line = ""
}

function trim(x) {
  sub(/^ */, "", x)
  sub(/ *$/, "", x)
  return x
}

BEGIN {
  printf "["
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
  si = substr($0, i + 2)
  key = "\"" trim(substr($0, 1, i - 1)) "\""
  value = ((si ~ /^[0-9]+$/) ? si : "\"" si "\"")
  line = line key ":" value
}

END {
  output()
  print "]"
}
