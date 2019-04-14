#!/bin/bash
# Script to check if the variables needed are set
# $1: Backup level (choices: L1, L2 or L3)
# $2: Temp file path

# MySQL or / Postgres dump
: "${DB_BACKEND:=postgres}"
: "${DB_HOST:=database}"
: "${DB_PORT:=5432}"
: "${DB_DB:=${POSTGRES_DB}}"
: "${DUMP_ARGS:=-c -O }"
: "${POSTGRES_USER:=postgres}"
: "${DB_USER:=${POSTGRES_USER}}"
: "${DB_PASSWORD:=${POSTGRES_PASSWORD}}"

DUMP_RESULT=false
if [ $DB_BACKEND = "mysql" ]; then
  if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" --all-databases --add-drop-database --single-transaction --quick --add-locks --disable-keys --extended-insert > "$2.sql"; then
    DUMP_RESULT=true;
  fi
elif [ $DB_BACKEND == "postgres" ]; then
 	echo dumping with flags : ${DUMP_ARGS}
	if [ "$DB_DB" = "_all_" ]; then
    if PGPASSWORD="$DB_PASSWORD" pg_dumpall -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" $DUMP_ARGS > "$2.sql"; then
      DUMP_RESULT=true;
    fi
  else
    if PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d $DB_DB $DUMP_ARGS > "$2.sql"; then
      DUMP_RESULT=true;
    fi
  fi
else
  echo "$1 BACKUP => FAILED => Database backend not recognized. Values accepted for variable DB_BACKEND are 'mysql' or 'postgres'."
fi
if [ "$DUMP_RESULT" = false ]; then
  echo "$1 BACKUP => FAILED => Dump Error - Check the variables you provided.";
  exit 1;
fi
exit 0;
