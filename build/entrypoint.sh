#!/usr/bin/env bash
set -e

GEMINI_UID=${GEMINI_UID:-1000}
GEMINI_GID=${GEMINI_GID:-1000}
GEMINI_USERNAME=gemini
GEMINI_GROUPNAME=gemini
GEMINI_HOME="/home/${GEMINI_USERNAME}"

# Function to remap existing UIDs or GIDs if they conflict with the desired ones.
remap_if_conflict() {
    local type=$1 # "user" or "group"
    local id=$2
    local name=$3
    local file_path="/etc/$( [[ "$type" == "user" ]] && echo "passwd" || echo "group" )"
    local existing_name

    existing_name=$(getent "${file_path##*/}" "${id}" | cut -d: -f1 || true)

    if [[ -n "${existing_name}" && "${existing_name}" != "${name}" ]]; then
        local new_id
        new_id=$(awk -F: 'BEGIN{ max=1000 } $3>=max{ max=$3 } END{ print max+1 }' "${file_path}")
        echo "Warning: ${type^^} ID ${id} is used by '${existing_name}'. Remapping '${existing_name}' to a new ID: ${new_id}."
        if [[ "$type" == "user" ]]; then
            usermod -u "${new_id}" "${existing_name}"
        else
            groupmod -g "${new_id}" "${existing_name}"
        fi
    fi
}

remap_if_conflict "group" "${GEMINI_GID}" "${GEMINI_GROUPNAME}"
remap_if_conflict "user" "${GEMINI_UID}" "${GEMINI_USERNAME}"

# Ensure group exists with the correct GID.
if ! getent group "${GEMINI_GROUPNAME}" >/dev/null; then
    groupadd --gid "${GEMINI_GID}" "${GEMINI_GROUPNAME}"
else
    # If group exists, ensure GID is correct.
    if [[ "$(getent group "${GEMINI_GROUPNAME}" | cut -d: -f3)" != "${GEMINI_GID}" ]]; then
        groupmod -g "${GEMINI_GID}" "${GEMINI_GROUPNAME}"
    fi
fi

# Ensure user exists with the correct UID and GID.
if ! getent passwd "${GEMINI_USERNAME}" >/dev/null; then
    USERADD_ARGS="--shell /bin/bash --uid ${GEMINI_UID} --gid ${GEMINI_GID} --home-dir ${GEMINI_HOME}"
    if [ ! -d "${GEMINI_HOME}" ]; then
        useradd ${USERADD_ARGS} --create-home "${GEMINI_USERNAME}"
    else
        useradd ${USERADD_ARGS} "${GEMINI_USERNAME}"
    fi
else
    # If user exists, ensure UID and GID are correct.
    usermod -u "${GEMINI_UID}" -g "${GEMINI_GID}" "${GEMINI_USERNAME}"
fi

chown -R "${GEMINI_UID}:${GEMINI_GID}" "${GEMINI_HOME}"

GEMINI_CMD="npx -y @google/gemini-cli"
case "$1" in
    cli)
        shift
        exec gosu "${GEMINI_UID}:${GEMINI_GID}" bash -c ''"${GEMINI_CMD}"' "$@"' _ "$@"
        ;;
    ttyd)
        shift
        exec ttyd -u "${GEMINI_UID}" -g "${GEMINI_GID}" -p "${PORT:-7681}" --writable "${GEMINI_CMD}" "$@"
        ;;
    *)
        echo "Allowed start options: cli, ttyd" >&2
        exit 1
        ;;
esac
