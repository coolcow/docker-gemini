ARG ENTRYPOINTS_VERSION=2.1.0
ARG NODE_VERSION=22
ARG DOCKER_CLI_VERSION=27.5.1
ARG TTYD_VERSION=1.7.7

FROM ghcr.io/coolcow/entrypoints:${ENTRYPOINTS_VERSION} AS entrypoints

FROM node:${NODE_VERSION}

ARG TARGETARCH
RUN case ${TARGETARCH} in \
        "amd64") TTYD_ARCH="x86_64" ;; \
        "arm64") TTYD_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -sSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

RUN case ${TARGETARCH} in \
        "amd64") DOCKER_ARCH="x86_64" ;; \
        "arm64") DOCKER_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_CLI_VERSION}.tgz" -o /tmp/docker.tgz && \
    tar -xzf /tmp/docker.tgz -C /tmp && \
    mv /tmp/docker/docker /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker && \
    rm -rf /tmp/docker /tmp/docker.tgz

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gosu \
    && rm -rf /var/lib/apt/lists/*

COPY --from=entrypoints /assets/ensure_user_group_home.sh /usr/local/bin/ensure_user_group_home.sh
RUN chmod +x /usr/local/bin/ensure_user_group_home.sh

EXPOSE 7681

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]