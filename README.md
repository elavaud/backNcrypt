# backNcrypt
[![Alpine 3.7](https://img.shields.io/badge/Alpine-3.7-brightgreen.svg)](https://hub.docker.com/_/alpine/) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/elavaud/backNcrypt/blob/master/LICENSE) [![Github elavaud](https://img.shields.io/badge/Github-elavaud-red.svg)](https://github.com/elavaud/backNcrypt) [![Docker elavaud](https://img.shields.io/badge/Docker-elavaud-lightgrey.svg)](https://hub.docker.com/r/elavaud/backncrypt/)

Docker alpine image for CRON SQL dumps, encryption and restore.  
Database engine: PostreSQL or MySQL  
Encryption type: OpenSSL with Gunzip, or 7z alone  

### Backups 

Backups are stored in the container in "/backups". There are 3 levels of backup, each of them stored in their respective directory "L#" (e.g.: /backups/L1).
* L1: Overwrite. No history is kept on this backup.
* L2: History backup. Old ones are deleted as and when new ones arrive. 
* L3: History backup. Old ones are deleted as and when new ones arrive.

All of these backups have their own schedule using a [CRON expression](https://en.wikipedia.org/wiki/Cron#CRON_expression), and level 2 and 3 have their own maximum of backup files to keep.  
For example, level 1 could be set to every half an hour, level 2 to every day with a max of 30 (1 month), and level 3 every month with a max of 36 (3 years).

File name pattern:  
The L1 backup is simply called "backup" followed by the extension (or ".gz.enc" or "7z").  
L2 and L3 backups begin by the date/time of the backup (YYYYMMDDHHMM), then the level, "backup" and the extension (e.g.: 201801122355.l2.backup.gz.enc for a level 2 backup made the 12 January 2018 at 23:55, and encrypted using openssl)

### Variables

A template for the environment variables is included in this github folder "env.template". If a CRON time for a specific level is not specified, the backup will not be executed. The rest of the variables are mandatory.
* DB_BACKEND: Database engine to use. Choices are or "mysql" or "postgres".
* DB_HOST: Host of the database to reach.
* DB_USER: User of the database to reach.
* DB_PASSWORD: Password of the database to reach.
* ENC_TYPE: Encryption type to use. Choices are or "openssl" or "7z".
* ENC_PASS: Encryption pass to use.
* CRON_TIME_L1: CRON expression for the level 1 backups.
* CRON_TIME_L2: CRON expression for the level 2 backups.
* MAX_BACKUPS_L2: Maximum number of level 2 backups to keep.
* CRON_TIME_L3: CRON expression for the level 3 backups.
* MAX_BACKUPS_L3: Maximum number of level 3 backups to keep.

### Use

Three main functionalities are available. The corresponding scripts are located in "/backncrypt" as is the work directory.  

**wait-for**
This script is coming from [eficode](https://github.com/eficode/wait-for) and is used to wait for another service to become available.  
It is sh and alpine compatible and was inspired by [vishnubob/wait-for-it](https://github.com/vishnubob/wait-for-it).

    ./wait-for host:port [-t timeout] [-- command args]

**set.sh**  
This script will use the environment variables provided to create the cron jobs and activate them. 

**restore.sh**  
The restore script use the same settings as above: the encryption type, password, database settings should be the same.  
It can be used through the host as follow:

    docker exec {{container_name}} restore.sh {{backup_file}} 

And replace {{container_name}} with the name of the backNcrypt container running, and {{backup_file}} by the path in the container of the encrypted backup you want to restore.

### Compose example

Example using MySQL and OpenSSL. More examples can be found in the folder "tests" of the github repository.

**docker-compose.yml:**
```yaml
services:
  backups:
    image: elavaud/backncrypt
    env_file: .bnc.env
    volumes:
      - ./backups:/backups
    command: [sh, -c, "wait-for -t 5000 mysql:3306 -- set.sh"]
  mysql:
    image: mysql
    expose:
      - "3306"
    env_file: .mysql.env
```


**.bnc.env:**
```
DB_BACKEND=mysql
DB_HOST=mysql
DB_PORT=3306
DB_USER=user
DB_PASSWORD=password
ENC_TYPE=openssl
ENC_PASS=opensslpass
CRON_TIME_L1=*/30 * * * *
CRON_TIME_L2=55 23 * * *
MAX_BACKUPS_L2=30
CRON_TIME_L3=0 0 1 * *
MAX_BACKUPS_L3=36
```

**.mysql.env:**
```
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_ROOT_PASSWORD=password
```
