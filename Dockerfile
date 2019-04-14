FROM alpine:3.9

RUN apk --no-cache add --update sshpass openssh-client rsync tzdata bash mysql-client gzip openssl p7zip postgresql-client\
  && rm -rf /var/cache/apk/* \
  && mkdir -p /backups \
  && mkdir -p /backncrypt

COPY scripts /backncrypt
RUN chmod -R u+x /backncrypt
WORKDIR /backncrypt
ENTRYPOINT ["./set.bash"]