#!/bin/sh
set -euo pipefail

CONFIG_FILE=${CONFIG_FILE:-/data/config.yaml}
TEMPLATE_FILE=${CONFIG_TEMPLATE:-/etc/forgejo-runner/config.template.yaml}

INSTANCE=${FORGEJO_INSTANCE_URL:?FORGEJO_INSTANCE_URL is required}
TOKEN=${FORGEJO_RUNNER_TOKEN:?FORGEJO_RUNNER_TOKEN is required}
NAME=${FORGEJO_RUNNER_NAME:-docker-runner}
LABELS=${FORGEJO_RUNNER_LABELS:-docker}
CONTAINER_NETWORK=${CONTAINER_NETWORK:-bridge}
DOCKER_HOST_VALUE=${DOCKER_HOST:-tcp://dind:2375}
DOCKER_TLS_CERTDIR_VALUE=${DOCKER_TLS_CERTDIR:-}

cat >"$CONFIG_FILE" <<EOF
log:
  level: info

runner:
  name: ${NAME}
  capacity: 1
  workdir: /data/_work
  envs:
    DOCKER_HOST: ${DOCKER_HOST_VALUE}
    DOCKER_TLS_CERTDIR: "${DOCKER_TLS_CERTDIR_VALUE}"
  labels:
    - '${LABELS}'

container:
  network: ${CONTAINER_NETWORK}
EOF

if [ ! -f /data/.runner ]; then
  forgejo-runner register \
    --config "$CONFIG_FILE" \
    --instance "$INSTANCE" \
    --token "$TOKEN" \
    --name "$NAME" \
    --labels "$LABELS" \
    --no-interactive
fi

exec forgejo-runner daemon --config "$CONFIG_FILE"
