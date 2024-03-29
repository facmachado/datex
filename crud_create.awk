#!/usr/bin/awk -f

#
#  DATEX - Textual database library for Shell Script
#
#  Copyright (c) 2021 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

BEGINFILE {
  total = 0
  while (getline <FILENAME) {
    total++
  }
}

BEGIN {
  FS = ","
  now = systime()
}

NR == 1 {
  split($0, head)
  for (i = 1; i <= NF; i++) {
    for (j = 0; j < ARGC; j++) {
      if (ARGV[j] ~ "=") {
        key = ARGV[j]
        value = ARGV[j]
        sub(/=.*$/, "", key)
        sub(/^.*=/, "", value)
        if (head[i] == key) {
          row[i] = value
        }
      }
    }
  }
  row[1] = total
  row[NF - 2] = now
  row[NF - 1] = now
  row[NF] = 0
  for (i = 1; i <= NF; i++) {
    print head[i] " = " row[i]
  }
}
