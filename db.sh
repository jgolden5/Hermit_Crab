#!/bin/bash
db_name="$1"
if [[ ! $1 ]]; then
  db_name=bountyhunter
  #read -p "Please enter a name for your db: " db_name
fi
rm $db_name.db 2>/dev/null
sqlite3 $db_name.db < target_db.sql

main() {
  echo "a - print all program info"
  echo "e - eval exact SQL command"
  echo "q - quit db script"
  read -n1 -p "Select a db command: " cmd
  echo
  case $cmd in
    a)
      select_all
      main
      ;;
    e)
      read -p "Enter SQL command: " sql_cmd
      eval_db_command "$sql_cmd"
      main
      ;;
    q)
      echo "Quitting db.sh"
      ;;
    *)
      echo "command not recognized"
      main
      ;;
  esac
}

select_all() {
  sqlite3 bountyhunter.db "SELECT * FROM programs"
}

eval_db_command() {
  db_cmd="$@"
  eval 'sqlite3 bountyhunter.db "$sql_cmd"'
}

main

alias sd='source db.sh'
alias vd='vim db.sh'
