#!/usr/bin/env bash
set -e

GEMINI_UID=${GEMINI_UID:-1000}
GEMINI_GID=${GEMINI_GID:-1000}
GEMINI_HOME="/home/$USER"

# Ensure the Gemini group exists, create if not.
getent group ${GEMINI_GID} >/dev/null || groupadd -g ${GEMINI_GID} $GROUP
# Ensure the Gemini user exists, create if not.
getent passwd ${GEMINI_UID} >/dev/null || {
    [ -d "${GEMINI_HOME}" ] || (mkdir -p "${GEMINI_HOME}" && chown "${GEMINI_UID}:${GEMINI_GID}" "${GEMINI_HOME}")
    useradd -u "${GEMINI_UID}" -g "${GEMINI_GID}" -s /bin/bash "$USER"
}
# Change ownership of HOME directory only if it is empty.
[ -n "$(ls -A "${GEMINI_HOME}")" ] || chown "${GEMINI_UID}:${GEMINI_GID}" "${GEMINI_HOME}"

GEMINI_CMD="npx -y @google/gemini-cli"

case "$1" in
    cli)
        shift
        exec gosu "${GEMINI_UID}:${GEMINI_GID}" bash -c 'export HOME="'$HOME'"; '"$GEMINI_CMD"' "$@"' _ "$@"
        ;;
    ttyd)
        exec ttyd -w "$WORKSPACE" -u ${GEMINI_UID} -g ${GEMINI_GID} -p $PORT --writable $GEMINI_CMD
        ;;
    *)
        echo "Allowed start options: cli, ttyd"
        exit 1
        ;;
esac
