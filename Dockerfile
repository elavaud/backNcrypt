FROM alpine:3.7

RUN apk --no-cache add --update bash mysql-client gzip openssl p7zip postgresql-client\
  && rm -rf /var/cache/apk/* \
  && mkdir -p /backups \
  && mkdir -p /backups/L1 \
  && mkdir -p /backups/L2 \
  && mkdir -p /backups/L3 \

COPY ["backup.sh", "check_variables.sh", "clean.sh", "dump.sh", "encrypt.sh", "set.sh", "restore.sh", "/"]
RUN chmod u+x /backup.sh /check_variables.sh /clean.sh /dump.sh /encrypt.sh /set.sh /restore.sh /set.sh
