FROM docker:29.1.2-cli AS dockercli

FROM code.forgejo.org/forgejo/runner:12.1.2

USER root
COPY --from=dockercli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=dockercli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins
COPY entrypoint.sh /usr/local/bin/runner-entrypoint.sh
COPY config.yaml /etc/forgejo-runner/config.template.yaml
RUN chmod +x /usr/local/bin/runner-entrypoint.sh && \
    if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache docker-cli docker-cli-buildx; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update && apt-get install -y --no-install-recommends docker.io docker-buildx-plugin && rm -rf /var/lib/apt/lists/*; \
    elif command -v dnf >/dev/null 2>&1; then \
      dnf install -y docker-cli docker-buildx-plugin && dnf clean all; \
    else \
      echo "Unable to find a supported package manager to install docker-cli" && exit 1; \
    fi

ENTRYPOINT ["/usr/local/bin/runner-entrypoint.sh"]
