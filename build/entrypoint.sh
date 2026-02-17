#!/usr/bin/env bash
set -e

export TARGET_UID=${GEMINI_UID:-1000}
export TARGET_GID=${GEMINI_GID:-1000}
export TARGET_USER=${GEMINI_USER:-gemini}
export TARGET_GROUP=${GEMINI_GROUP:-gemini}
export TARGET_HOME=${GEMINI_HOME:-/home/${TARGET_USER}}
export TARGET_SHELL=${GEMINI_SHELL:-/bin/bash}

/usr/local/bin/ensure_user_group_home.sh

TARGET_CMD="npx -y @google/gemini-cli"
case "$1" in
    cli)
        shift
        exec gosu "${TARGET_UID}:${TARGET_GID}" bash -c ''"${TARGET_CMD}"' "$@"' _ "$@"
        ;;
    ttyd)
        shift
        exec ttyd -w "$(pwd)" -u "${TARGET_UID}" -g "${TARGET_GID}" -p "${TTYD_PORT:-7681}" --writable ${TARGET_CMD} "$@"
        ;;
    *)
        echo "Allowed start options: cli, ttyd" >&2
        exit 1
        ;;
esac
