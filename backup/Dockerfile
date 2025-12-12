FROM postgres:18-alpine

RUN apk add --no-cache minio-client libc6-compat tzdata ca-certificates

WORKDIR /backup
COPY run_backup.sh entrypoint.sh ./
RUN chmod +x /backup/run_backup.sh /backup/entrypoint.sh

ENTRYPOINT ["/backup/entrypoint.sh"]
