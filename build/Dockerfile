ARG NODE_VERSION=lts-alpine3.22
FROM node:${NODE_VERSION}

RUN apk add --no-cache shadow bash curl gosu

ARG TTYD_VERSION=1.7.7
ARG TARGETARCH
RUN case ${TARGETARCH} in \
        "amd64") TTYD_ARCH="x86_64" ;; \
        "arm64") TTYD_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -sSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

ENV USER=gemini
ENV GROUP=gemini
ENV HOME=/home/$USER
ENV WORKSPACE=/workspace
ENV PORT=7681
ENV GEMINI_API_KEY=

WORKDIR $WORKSPACE

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE $PORT

ENTRYPOINT ["/entrypoint.sh"]
