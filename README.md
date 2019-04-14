# backNcrypt
[![Alpine 3.7](https://img.shields.io/badge/Alpine-3.7-brightgreen.svg)](https://hub.docker.com/_/alpine/) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/elavaud/backNcrypt/blob/master/LICENSE) [![Github elavaud](https://img.shields.io/badge/Github-elavaud-red.svg)](https://github.com/elavaud/backNcrypt) [![Docker elavaud](https://img.shields.io/badge/Docker-elavaud-lightgrey.svg)](https://hub.docker.com/r/elavaud/backncrypt/)  
Docker alpine image for CRON SQL dumps, encryption and restore.  
Database engine: PostreSQL or MySQL  
Encryption type: OpenSSL + Gzip, or 7zip (recommended for Windows users)

### Backups 

Backups are stored in the container in "/backups". There are 3 levels of backup, each of them stored in their respective directory "L#" (e.g.: /backups/L1).
* L1: Overwrite. No history is kept on this backup.
* L2: History backup. Old ones are deleted as and when new ones arrive. 
* L3: History backup. Old ones are deleted as and when new ones arrive.

All of these backups have their own schedule using a [CRON expression](https://en.wikipedia.org/wiki/Cron#CRON_expression), and level 2 and 3 have their own maximum of backup files to keep.  
For example, level 1 could be set to every half an hour, level 2 to every day with a max of 30 (1 month), and level 3 every month with a max of 36 (3 years).

File name pattern:  
The L1 backup is simply called "backup" followed by the extension (or ".gz.enc" or "7z").  
L2 and L3 backups begin by the date/time of the backup , then the level, "backup" and the extension (e.g.: 201801122355.l2.backup.gz.enc for a level 2 backup made the 12 January 2018 at 23:55, and encrypted using openssl)

### Variables

A template for the environment variables is included in this github folder "env.template". If a CRON time for a specific level is not specified, the backup will not be executed. 
* BACKUP_NAME: mandatory - folder name where the backups are stored
* DB_BACKEND: Database engine to use. Choices are or "mysql" or "postgres". default to postgres
* DB_HOST: Host (or docker-compose service) of the database to reach. default to database 
* DB_DB: specific database to backup. default to all databases
* DB_USER: User of the database to reach. default to POSTGRES_USER or postgres
* DB_PASSWORD: Password of the database to reach. Mandatory
* DUMP_ARGS: extra options passed to the pg_dump program (postgres only for now) default to -c -O 
(e.g. for DHIS2 use -c -O -T aggregated\* -T analytics* -T completeness\* )
* ENC_TYPE: Encryption type to use. Choices are or "openssl" or "7z". default to 7z
* ENC_PASS: Encryption pass to use. Mandatory
* CRON_TIME_L1: CRON expression for the level 1 backups. 
* CRON_TIME_L2: CRON expression for the level 2 backups. 
* MAX_BACKUPS_L2: Maximum number of level 2 backups to keep. Mandatory if CRON_TIME_L2 is defined
* CRON_TIME_L3: CRON expression for the level 3 backups. 
* MAX_BACKUPS_L3: Maximum number of level 3 backups to keep. Mandatory if CRON_TIME_L3 is defined
* DATE_FMT: date format for the backup prefix file. default to  +%Y_%b_%d__%Hh%M (2018_Dec_19__23h16)
* TZ: [time zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). default to Europe/Brussels 
* REMOTE: to duplicate the backup folder via rsync on a remote server e.g. dhis2@192.168.123.150:/volume1/backups/DHIS2/ - where /volume1/backups/DHIS2/ is the root folder in the remote server -do not forget the trailing slash-, the backups will be stored in /volume1/backups/DHIS2/${BACKUP_NAME}/
* REMOTE_PASS: the password used to authenticate rsync on the remote server
* REMOTE_OPTIONS: extra rsync options (e.g. --delete --exclude 'old_backups')
* REMOTE2 : same options as for REMOTE for a tertiary backup

### Use

Two main functionalities are available. The corresponding scripts are located in "/backncrypt" as is the work directory. 

**set.sh**  
This script will use the environment variables provided to create the cron jobs and activate them. 

**restore.sh**  
The restore script use the same settings as above: the encryption type, password, database settings should be the same.  
It can be used through the host as follow:

    docker exec {{container_name}} ./restore.sh {{backup_file}} 

And replace {{container_name}} with the name of the backNcrypt container running, and {{backup_file}} by the path in the container of the encrypted backup you want to restore.

### Integration
Add it to your docker-compose stack - you can pass the env variables in .env.