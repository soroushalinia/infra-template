#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backup}"
MINIO_ALIAS=local
DATE_TAG="$(date +%F)"

MC_BIN=""
if command -v mc >/dev/null 2>&1; then
  MC_BIN="mc"
elif command -v mcli >/dev/null 2>&1; then
  MC_BIN="mcli"
fi

if [ -z "${MC_BIN}" ]; then
  echo 'Installing minio client...'
  apk add --no-cache libc6-compat minio-client >/dev/null
  if command -v mc >/dev/null 2>&1; then
    MC_BIN="mc"
  elif command -v mcli >/dev/null 2>&1; then
    MC_BIN="mcli"
  else
    echo 'MinIO client not found after install'; exit 1
  fi
fi

mkdir -p "${BACKUP_DIR}"

echo 'Backing up Keycloak DB...'
PGPASSWORD="${PGPASSWORD_KEYCLOAK:-${KEYCLOAK_DB_PASSWORD:-keycloak}}" pg_dump -h keycloak-db -U "${KEYCLOAK_DB_USER:-keycloak}" "${KEYCLOAK_DB_NAME:-keycloak}" > "${BACKUP_DIR}/keycloak_${DATE_TAG}.sql"

echo 'Backing up Forgejo DB...'
PGPASSWORD="${PGPASSWORD_FORGEJO:-${FORGEJO_DB_PASSWORD:-forgejo}}" pg_dump -h forgejo-db -U "${FORGEJO_DB_USER:-forgejo}" "${FORGEJO_DB_NAME:-forgejo}" > "${BACKUP_DIR}/forgejo_${DATE_TAG}.sql"

echo 'Backing up Forgejo data...'
tar czf "${BACKUP_DIR}/forgejo_data_${DATE_TAG}.tar.gz" -C /data .

echo 'Backing up Nexus data...'
tar czf "${BACKUP_DIR}/nexus_${DATE_TAG}.tar.gz" -C /nexus-data .

echo 'Backing up Mailserver data...'
tar czf "${BACKUP_DIR}/mailserver_${DATE_TAG}.tar.gz" -C /data_mail .

echo 'Backing up LDAP data...'
tar czf "${BACKUP_DIR}/ldap_data_${DATE_TAG}.tar.gz" -C /ldap_data .
tar czf "${BACKUP_DIR}/ldap_config_${DATE_TAG}.tar.gz" -C /ldap_config .

echo 'Uploading to Minio...'
"${MC_BIN}" alias set "${MINIO_ALIAS}" http://minio:9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"
"${MC_BIN}" mb -p "${MINIO_ALIAS}/${MINIO_BUCKET}" || true
"${MC_BIN}" cp "${BACKUP_DIR}"/* "${MINIO_ALIAS}/${MINIO_BUCKET}/"

echo 'Backup completed.'
