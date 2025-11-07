#!/bin/bash
db_name="$1"
if [[ ! $1 ]]; then
  db_name=bountyhunter
  #read -p "Please enter a name for your db: " db_name
fi
rm $db_name.db 2>/dev/null
sqlite3 $db_name.db < target_db.sql

main() {
  read -n1 -p "Select a db command: " cmd
  echo
  case $cmd in
    a)
      select_all
      ;;
    e)
      read -p "Enter SQL command: " sql_cmd
      eval_db_command "$sql_cmd"
      ;;
    h)
      hermit_crab_help
      ;;
    p)
      print_sql_file
      ;;
    q)
      echo "Quitting db.sh"
      return 0
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
  main
}

select_all() {
  sqlite3 bountyhunter.db "SELECT * FROM programs"
}

eval_db_command() {
  db_cmd="$@"
  eval 'sqlite3 bountyhunter.db "$sql_cmd"'
}

hermit_crab_help() {
  echo "a - print all program info"
  echo "e - eval exact SQL command"
  echo "h - print this help text"
  echo "q - quit db script"
}

main

alias shc='source hermit_crab.sh'
alias vhc='vim hermit_crab.sh'
