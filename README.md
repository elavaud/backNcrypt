# backNcrypt
<a href="https://hub.docker.com/r/elavaud/backncrypt">Docker alpine image</a> for CRON SQL dumps, encryption and restore.
<br/>Database engine: PostreSQL or MySQL
<br/>Encryption type: OpenSSL with Gunzip or 7z
<br/>Image size: 17 Mb

<h3> Backups </h3>

Backups are stored in the container in "/backups". There are 3 levels of backup, each of them stored in their respective directory "L#"(e.g.: /backups/L1).
<ul>
  <li>L1: Overwrite. No history is kept on this backup. File named "backup" + extension</li>
  <li>L2: History backup. Old ones are deleted as and when new ones arrive. File beginning by the date/time of the backup (YYYYMMDDHHMM), then the level, "backup" + extension (e.g.: 201801122355.l2.backup.gz.enc)</li>
  <li>L3: History backup. Old ones are deleted as and when new ones arrive. File beginning by the date/time of the backup (YYYYMMDDHHMM), then the level, "backup" + extension (e.g.: 201712012355.l3.backup.7z)</li>
</ul>
All of these backups have their own schedule using a <a href="https://en.wikipedia.org/wiki/Cron#CRON_expression">CRON expression</a>, and level 2 and 3 have their own maximum of backup files to keep.
<br/>For example, level 1 could be set to every half an hour, level 2 to every day with a max of 30 (1 month), and level 3 every month with a max of 36 (3 years).

<h3>Variables</h3>
A template for the environment variables is included in this github folder "env.template". If a CRON time for a specific level is not specified, the backup will not be executed. The rest of the variables are mandatory.
<ul>
  <li>DB_BACKEND: Database engine to use. Choices are or "mysql" or "postgres".</li>
  <li>DB_HOST: Host of the database to reach.</li>
  <li>DB_USER: User of the database to reach.</li>
  <li>DB_PASSWORD: Password of the database to reach.</li>
  <li>ENC_TYPE: Encryption type to use. Choices are or "openssl" or "7z".</li>
  <li>ENC_PASS: Encryption pass to use.</li>
  <li>CRON_TIME_L1: CRON expression for the level 1 backups.</li>
  <li>CRON_TIME_L2: CRON expression for the level 2 backups.</li>
  <li>MAX_BACKUPS_L2: Maximum number of level 2 backups to keep.</li>
  <li>CRON_TIME_L3: CRON expression for the level 3 backups.</li>
  <li>MAX_BACKUPS_L3: Maximum number of level 3 backups to keep.</li>
</ul>

<h3>Restore</h3>

The restore script use the same settings as above. The encryption type, and password should be the same. 
<br/>It can be used through the host as follow:
```
docker exec {{container_name}} restore.sh {{backup_file}} 
```
And replace {{container_name}} with the name of the backNcrypt container running, and {{backup_file}} by the path in the container of the encrypted backup you want to restore.

<h3>Compose example</h3>

Example using MySQL and OpenSSL. More examples can be found in the folder "tests" of this repository.
<br/><br/>
docker-compose.yml:
```
services:
  backups:
    image: elavaud/backncrypt:1.0
    env_file: .bnc.env
    volumes:
      - ./backups:/backups
    command: [sh, -c, "./set.sh"]
  mysql:
    image: mysql:5.7
    expose:
      - "3306"
    env_file: .mysql.env
```
.bnc.env
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
.mysql.env
```
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_ROOT_PASSWORD=password
```
