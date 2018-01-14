#!/bin/bash
# Import the sql file in the DB engine

# If MySQL
if [ $DB_BACKEND = "mysql" ]; then
  if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" < /tmp/restore.sql; then
    echo "RESTORE BACKUP => FAILED => Couldn't import file in MySQL DB"
    rm -rf "/tmp/restore.sql.gz"
    rm -rf "/tmp/restore.sql"
    exit 1;
  fi
elif [ $DB_BACKEND = "postgres" ]; then
  SQL_FILE=$(ls -t /tmp/*.sql | head -1)
  if ! PGPASSWORD="$DB_PASSWORD" PGHOST="$DB_HOST" PGPORT="$DB_PORT" PGUSER="$DB_USER" psql -f $SQL_FILE postgres; then
    echo "RESTORE BACKUP => FAILED => Couldn't import file in PostreSQL DB"
    rm -rf "$SQL_FILE"
    exit 1;
  fi
  rm -rf "$SQL_FILE"
else
  echo "RESTORE BACKUP => FAILED => Database engine not recognized. Options are 'mysql' or 'postgres'"
  exit 1;
fi
rm -rf "/tmp/restore.sql.gz"
rm -rf "/tmp/restore.sql"
exit 0;
