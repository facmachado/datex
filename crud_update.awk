#!/usr/bin/awk -f

#
#  DATEX - Textual database library for Shell Script
#
#  Copyright (c) 2020 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

function trim(x) {
  sub(/^\"/, "", x)
  sub(/\"$/, "", x)
  return x
}

BEGIN {
  FS = ","
  now = systime()
}

NR == 1 {
  split($0, head)
}

NR > 1 && NR == ARGV[2] + 1 {
  split($0, row)
  if (row[NF] == 1) {
    exit
  }
  for (i = 1; i <= NF; i++) {
    for (j = 0; j < ARGC; j++) {
      if (ARGV[j] ~ "=") {
        key = ARGV[j]
        value = ARGV[j]
        sub(/=.*$/, "", key)
        sub(/^.*=/, "", value)
        if (head[i] == key && head[i] != "id" && head[i] != "ins") {
          row[i] = value
        }
      }
    }
  }
  row[NF - 1] = now
  for (i = 1; i <= NF; i++) {
    print head[i] " = " trim(row[i])
  }
}
