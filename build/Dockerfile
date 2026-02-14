ARG NODE_VERSION=22
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

ENV GEMINI_API_KEY=
ENV USER=gemini
ENV GROUP=gemini
ENV HOME=/home/$USER
ENV PORT=7681

EXPOSE $PORT

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]