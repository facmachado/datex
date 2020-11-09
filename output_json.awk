#!/usr/bin/awk -f

#
#  datex - textual database library
#
#  Copyright (c) 2020 Flavio Augusto (@facmachado)
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
  key = "\"" trim(substr($0, 1, i - 1)) "\""
  value = ((substr($0, i + 2) ~ /^[0-9]+$/) \
    ? substr($0, i + 2) \
    : "\"" substr($0, i + 2) "\"")
  line = line key ":" value
}

END {
  output()
  print "]"
}
