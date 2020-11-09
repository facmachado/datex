#!/bin/bash

#
#  datex - textual database library
#
#  Copyright (c) 2020 Flavio Augusto (@facmachado)
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#
#  Usage: source datex.sh
#

#
# Arquivo declarado em variável obrigatório
#
if test -z "$DBFILE"; then
  echo "Declare filename in variable DBFILE" >&2
  return 1
fi
if ! test -r "$DBFILE" -a -w "$DBFILE"; then
  echo "File $DBFILE is unavailable" >&2
  return 1
fi

#
# Constantes iniciais
#
src_dir=$(dirname "${BASH_SOURCE[0]}")
output_csv="$src_dir/output_csv.awk"
crud_create="$src_dir/crud_create.awk"
crud_update="$src_dir/crud_update.awk"
crud_read="$src_dir/crud_read.awk"

#
# Aguarda o arquivo ser liberado para escrita
#
function wait_write() {
  while lsof "$(readlink -f "$DBFILE")" >/dev/null 2>&1; do :; done
}

#
# Gera um cabeçalho CSV com os campos informados como parâmetros
# Ex: create_header nome ender cidade uf cep obs
# @param {string} field
# @param {string} field
# ...
# @returns {string}
#
function create_header() { (
  local sep
  sep=,

  function show_header() {
    grep -m1 "^id${sep}.*${sep}ins${sep}upd${sep}del$" "$DBFILE"  \
      >/dev/null 2>&1
  }

  if show_header; then
    echo "Header was already created in file $DBFILE" >&2
    return 1
  fi
  if ((${#*} < 1)); then
    echo 'You must enter at least ONE field to create header' >&2
    return 1
  fi

  read -r -a fields <<<"id $* ins upd del"
  wait_write && sed "s/ /$sep/g" <<<"${fields[@]}" >"$DBFILE"
) }

#
# Lista os registros não apagados (no formato chave = valor)
# Ex: list_records 2 3 (parâmetros opcionais)
# @param {number} lines (0 => all)
# @param {number} start (1)
# @returns {string}
#
function list_records() {
  local -i lines start
  ((${1:-0} < 1)) && lines=$(($(wc -l <"$DBFILE") - 1)) || lines=$1
  ((${2:-0} > 0)) && start=$2 || start=1

  awk -f "$crud_read"             \
    -v start=$((start + 1))       \
    -v finish=$((start + lines))  \
    "$DBFILE"
}

#
# Busca por palavra-chave nos registros
# Ex: search_records Teste
# @param {string} query
# @returns {string}
#
function search_records() {
  test "$1" && awk -f "$crud_read" -v query="$1" "$DBFILE"
}

#
# Mostra o registro requisitado
# Ex: select_record 3
# @param {number} line
# @returns {string}
#
function select_record() {
  ((${1:-0} > 0)) && list_records 1 "$1"
}

#
# Cria um novo registro
# Ex: insert_record nome='Testa de Ferro' obs='Teste de Brasa'
# @param {string} field=value
# @param {string} field=value
# ...
#
function insert_record() {
  local new output
  output="awk -f $output_csv"
  new=$(awk -f "$crud_create" "$DBFILE" "$@" | $output)

  test "$*" && wait_write && echo "$new" >>"$DBFILE"
}

#
# Modifica os dados do registro informado
# Ex: update_record 3 nome='Testa de Ferro' obs='Teste de Brasa'
# @param {number} id
# @param {string} field=value
# @param {string} field=value
# ...
#
function update_record() {
  local old new output
  output="awk -f $output_csv"
  old=$(select_record "$1" | $output)
  new=$(awk -f "$crud_update" "$DBFILE" "$@" 2>/dev/null | $output)

  test "$1" && wait_write && sed -i "s/^$old$/$new/" "$DBFILE"
}

#
# "Apaga" o registro (marca para possível recuperação)
# Ex: delete_record 3
# @param {number} id
#
function delete_record() {
  test "$1" && update_record "$1" del=1
}
