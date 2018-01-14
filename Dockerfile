FROM alpine:3.7

RUN apk --no-cache add --update bash mysql-client gzip openssl p7zip postgresql-client\
  && rm -rf /var/cache/apk/* \
  && mkdir -p /backups \
  && mkdir -p /backups/L1 \
  && mkdir -p /backups/L2 \
  && mkdir -p /backups/L3 \
  && mkdir -p /backncrypt

COPY scripts /backncrypt
RUN chmod -R u+x /backncrypt
WORKDIR /backncrypt
