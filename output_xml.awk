#!/usr/bin/awk -f

#
#  DATEX - Textual database library for Shell Script
#
#  Copyright (c) 2021 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#

function trim(x) {
  sub(/^ */, "", x)
  sub(/ *$/, "", x)
  return x
}

BEGIN {
  total = 0
  fields = 0
}

$0 == "" {
  next
}

!h[$1]++ {
  fields++
}

{
  value = ""
  for (i = 3; i <= NF; i++) {
    value = value " " $i
  }
  if ($1 == "id") {
    line = line "    <record>\n"
  }
  line = line "      <" $1 ">" trim(value) "</" $1 ">\n"
  if ($1 == "del") {
    line = line "    </record>\n"
  }
  total++
}

END {
  total = total / fields
  printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"  \
    "<result>\n"                                         \
    "  <total>" total "</total>\n"                       \
    "  <records>\n" line "  </records>\n"                \
    "</result>\n"
}
