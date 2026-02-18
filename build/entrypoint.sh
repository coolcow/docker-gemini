#!/usr/bin/env bash
set -e

export TARGET_UID=${GEMINI_UID:-1000}
export TARGET_GID=${GEMINI_GID:-1000}
export TARGET_USER=${GEMINI_USER:-gemini}
export TARGET_GROUP=${GEMINI_GROUP:-gemini}
export TARGET_HOME=${GEMINI_HOME:-/home/${TARGET_USER}}
export TARGET_SHELL=${GEMINI_SHELL:-/bin/bash}
export DOCKER_SOCK_PATH=${DOCKER_SOCK_PATH:-/var/run/docker.sock}

/usr/local/bin/ensure_user_group_home.sh

if [ -S "${DOCKER_SOCK_PATH}" ]; then
    SOCKET_GID="$(stat -c '%g' "${DOCKER_SOCK_PATH}" 2>/dev/null || true)"

    if [ -n "${SOCKET_GID}" ]; then
        DOCKER_GROUP_NAME="${DOCKER_GROUP_NAME:-docker}"
        EXISTING_GROUP_BY_GID="$(getent group "${SOCKET_GID}" | cut -d: -f1 || true)"

        if [ -n "${EXISTING_GROUP_BY_GID}" ]; then
            DOCKER_GROUP_NAME="${EXISTING_GROUP_BY_GID}"
        elif ! getent group "${DOCKER_GROUP_NAME}" > /dev/null; then
            groupadd -g "${SOCKET_GID}" "${DOCKER_GROUP_NAME}"
        elif [ "$(getent group "${DOCKER_GROUP_NAME}" | cut -d: -f3)" != "${SOCKET_GID}" ]; then
            DOCKER_GROUP_NAME="docker-${SOCKET_GID}"
            if ! getent group "${DOCKER_GROUP_NAME}" > /dev/null; then
                groupadd -g "${SOCKET_GID}" "${DOCKER_GROUP_NAME}"
            fi
        fi

        usermod -aG "${DOCKER_GROUP_NAME}" "${TARGET_USER}"
    fi
fi

TARGET_CMD=(npx -y @google/gemini-cli)
RUN_MODE="${RUN_MODE:-}"

case "${RUN_MODE}" in
    ttyd)
        exec gosu "${TARGET_USER}" env HOME="${TARGET_HOME}" ttyd -w "$(pwd)" -p "${TTYD_PORT:-7681}" --writable "${TARGET_CMD[@]}" "$@"
        ;;
    *)
        exec gosu "${TARGET_USER}" env HOME="${TARGET_HOME}" "${TARGET_CMD[@]}" "$@"
        ;;
esac
