#!/bin/bash
db_name=draft #copy to project db when this is where desired
schema_target=schema_draft #^
default_table=
if [[ ! -f $schema_target.sql ]]; then
  echo "c - copy schema_draft.sql from source file"
  echo "s - craft schema_draft.sql from scratch"
  read -n1 -p "Type one of the keys from above: " any_key
  echo
  if [[ $any_key == 'c' ]]; then
    ls #this is, of course, to list the files/directories in current working directory for user's reference
    read -p "Please enter the exact name of the file you want to use as template for schema_draft.sql: " file_name
    echo
    cat $file_name >> $schema_target.sql
  else
    echo "Starting from scratch"
  fi
  echo
  vim $schema_target.sql
fi
rm $db_name.db 2>/dev/null
sqlite3 $db_name.db < $schema_target.sql

main() {
  read -n1 -s -p "Select a db command: " cmd
  echo
  case $cmd in
    a)
      select_all_from_default_table
      ;;
    e)
      read -p "Enter SQL command: " sql_cmd
      eval_db_command "$sql_cmd"
      ;;
    h|\?)
      hermit_crab_help
      ;;
    i)
      insert_element_into_default_table
      ;;
    p)
      print_sql_file
      ;;
    t)
      set_default_table
      ;;
    q|Q)
      echo "Quitting db.sh"
      return 0
      ;;
    v)
      edit_sql_file
      return 0 #this is because edit_sql_file sources this file in order to apply changes to sql file
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
  main
}

select_all_from_default_table() {
  sqlite3 $db_name.db "SELECT * FROM $default_table" && echo "Pulled from default table $default_table"
}

set_default_table() {
  read -p "Changing default table \"$default_table\" to " new_default
  if [[ ! $new_default ]] || [[ $new_default =~ ^[qQ]$ ]]; then
    echo "Ok, default table was not changed, and remains \"$default_table\""
  else
    echo "Default table was changed to \"$new_default\""
    default_table=$new_default
  fi
}

edit_sql_file() {
  vim $schema_target.sql
  source hermit_crab.sh
}

eval_db_command() {
  sql_cmd="$@"
  eval "sqlite3 $db_name.db \"$sql_cmd;\""
}

hermit_crab_help() {
  echo "a   - print all info from default table"
  echo "e   - eval exact SQL command"
  echo "h/? - print this help text"
  echo "p   - print target sql file"
  echo "t   - set default table (for 'a' command)"
  echo "q/Q - quit db script"
}

insert_element_into_default_table() {
  if [[ ! $default_table ]]; then
    read -p "What do you want to use for your default table? " default_table
    if [[ ! $default_table ]]; then
      echo "Sorry, can't insert a column without a default table" && return 1
    fi
  fi
  mapfile -t columns_in_default_table < <(awk -v tbl="$default_table" '
    /CREATE TABLE/ { if ($0 ~ ("CREATE TABLE " tbl)) {flag=1; next} }
    /\);/ {flag=0}
    flag
  ' "$schema_target.sql" | awk '{ print $1 }')
  values_to_add=()
  for column in "${columns_in_default_table[@]}"; do
    read -p "What value do you want to add to the \"$column\" column in \"$default_table\" table? " val
    echo
    values_to_add+=("'$val'")
  done
  IFS=', '; columns_in_default_table="${columns_in_default_table[*]}"; values_to_add="${values_to_add[*]}"; unset IFS
  eval_db_command "INSERT INTO $default_table ("$columns_in_default_table") VALUES ("$values_to_add")"
}

print_sql_file() {
  cat $schema_target.sql
}

main

alias shc='source hermit_crab.sh'
alias vhc='vim hermit_crab.sh'
alias vdb="vim $schema_target.sql"
