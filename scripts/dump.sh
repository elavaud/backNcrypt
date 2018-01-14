#!/bin/bash
# Script to check if the variables needed are set

# MySQL or / Postgres dump
DUMP_RESULT=false
if ["$DB_BACKEND" = "mysql"]; then
  if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" --all-databases --add-drop-database --single-transaction --quick --add-locks --disable-keys --extended-insert > "$2.sql"; then
    DUMP_RESULT=true;
elif ["$DB_BACKEND" == "postgres"]; then
  if PGPASSWORD="$DB_PASSWORD" pg_dumpall -h "$DB_HOST" -P "$DB_PORT" -U "$DB_USER" -O -c > "$2.sql"; then
    DUMP_RESULT=true;
else
  echo "$1 BACKUP => FAILED => Database backend not recognized. Values accepted for variable DB_BACKEND are 'mysql' or 'postgres'."
fi
if [ "$DUMP_RESULT" = false ]; then
  echo "$1 BACKUP => FAILED => Error of connection with the DB serveur. Check the variables you provided.";
  exit 1;
fi
exit 0;
