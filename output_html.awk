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
  title = "DATEX - output_html"
  "date" | getline date
}

$0 == "" {
  next
}

!h[$1]++ {
  if ($1 == "id") {
    head = "      <tr>\n"
  }
  head = head "        <th>" $1 "</th>\n"
  if ($1 == "del") {
    head = head "      </tr>\n"
  }
}

{
  value = ""
  for (i = 3; i <= NF; i++) {
    value = value " " $i
  }
  if ($1 == "id") {
    line = line "      <tr>\n"
  }
  line = line "        <td>" trim(value) "</td>\n"
  if ($1 == "del") {
    line = line "      </tr>\n"
  }
}

END {
  printf "<!doctype html>\n"                                                  \
    "<html>\n"                                                                \
    "<head>\n"                                                                \
    "  <title>" title "</title>\n"                                            \
    "</head>\n"                                                               \
    "<body>\n"                                                                \
    "  <h1>" title "</h1>\n"                                                  \
    "  <hr>\n"                                                                \
    "  <table border=\"1\" cellpadding=\"4\" cellspacing=\"1\">\n"            \
    "    <thead>\n" head "    </thead>\n"                                     \
    "    <tbody>\n" line "    </tbody>\n"                                     \
    "  </table>\n"                                                            \
    "  <hr>\n"                                                                \
    "  <i>Generated on " date ".<br>Get DATEX on <a href=\"https://github.c"  \
    "om/facmachado/datex\" target=\"_blank\">https://github.com/facmachado/"  \
    "datex</a></i>\n"                                                         \
    "</body>\n"                                                               \
    "</html>\n"
}
