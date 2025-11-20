#!/bin/bash
db_name=draft #copy to project db when this is where desired
schema_target=schema_draft #^
default_table=
if [[ ! -f $schema_target.sql ]]; then
  read -n1 -s -p "You will need to set up a schema_draft.sql file for a base schema for your database. Press any key to continue " any_key
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

print_sql_file() {
  cat $schema_target.sql
}

main

alias shc='source hermit_crab.sh'
alias vhc='vim hermit_crab.sh'
alias vdb="vim $schema_target.sql"
