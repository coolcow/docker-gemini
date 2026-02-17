ARG ENTRYPOINTS_VERSION=2.1.0
ARG NODE_VERSION=22

FROM ghcr.io/coolcow/entrypoints:${ENTRYPOINTS_VERSION} AS entrypoints

FROM node:${NODE_VERSION}

ARG TTYD_VERSION=1.7.7
ARG TARGETARCH
RUN case ${TARGETARCH} in \
        "amd64") TTYD_ARCH="x86_64" ;; \
        "arm64") TTYD_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -sSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gosu \
    && rm -rf /var/lib/apt/lists/*

COPY --from=entrypoints /assets/ensure_user_group_home.sh /usr/local/bin/ensure_user_group_home.sh
RUN chmod +x /usr/local/bin/ensure_user_group_home.sh

ENV GEMINI_API_KEY=
ENV GEMINI_USER=gemini
ENV GEMINI_GROUP=gemini
ENV GEMINI_HOME=/home/gemini
ENV GEMINI_SHELL=/bin/bash
ENV TTYD_PORT=7681

EXPOSE $TTYD_PORT

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]