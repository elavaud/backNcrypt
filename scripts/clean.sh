#!/bin/bash
# Scripts to delete old backups

if [ "$1" = "L2"]; then
  MAX_B=$MAX_BACKUPS_L2
elif [ "$1" = "L3"]; then
  MAX_B=$MAX_BACKUPS_L3
fi

if [ -n "$MAX_B" ]
then
  while [ "$(find /backups/$1 -maxdepth 1 -name "*.gz.enc" | wc -l)" -gt "$MAX_B" ]
  do
    TARGET=$(find /backups/$1 -maxdepth 1 -name "*.gz.enc" | sort | head -n 1)
    echo "Backup $TARGET is deleted"
    rm -rf "$TARGET"
  done
fi