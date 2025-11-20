#!/bin/bash
db_name="$1"
schema_target="$2"
default_table=
if [[ ! $1 ]]; then
  read -p "DB file name (don't include the .db): " db_name
fi
if [[ ! $2 ]]; then
  read -p "Schema file name (don't include the .sql): " schema_target
fi
rm $db_name.db 2>/dev/null
sqlite3 $db_name.db < $schema_target.sql

main() {
  read -n1 -p "Select a db command: " cmd
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
    s)
      print_sql_file
      ;;
    S)
      edit_sql_file
      return 0 #this is because edit_sql_file sources this file in order to apply changes to sql file
      ;;
    t)
      set_default_table
      ;;
    q|Q)
      echo "Quitting db.sh"
      return 0
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
  read -n1 -p "Do you want to change default table? " confirm
  echo
  if [[ $confirm == 'y' ]]; then
    read -p "Changing default table \"$default_table\" to " new_default
    default_table=$new_default
  else
    echo "Ok, default table remains \"$default_table\""
  fi
}

edit_sql_file() {
  vim $schema_target.sql
  source hermit_crab.sh
}

eval_db_command() {
  db_cmd="$@"
  eval "sqlite3 $db_name.db "$sql_cmd""
}

hermit_crab_help() {
  echo "a   - print all info from default table"
  echo "d   - set default table (for 'a' command)"
  echo "e   - eval exact SQL command"
  echo "h/? - print this help text"
  echo "s   - print target sql file"
  echo "S   - edit target sql file"
  echo "q/Q - quit db script"
}

print_sql_file() {
  cat $schema_target.sql
}

main

alias shc='source hermit_crab.sh'
alias vhc='vim hermit_crab.sh'
alias vdb="vim $schema_target.sql"
