#!/usr/bin/env bash
set -e

# Create persistent storage for scaled containers
ID=$(get_name.py)
STORAGE_DIR="/app/data/${ID}"
mkdir -p "${STORAGE_DIR}"
echo "INFO: Using persistent storage directory: ${STORAGE_DIR}"

# Create persistent .local directory
LOCAL_DIR="${STORAGE_DIR}/.local"
mkdir -p "${LOCAL_DIR}"

current_target=$(readlink "${HOME}/.local" 2>/dev/null || true)
if [[ "$current_target" != "$LOCAL_DIR" ]]; then

    # Backup existing .local if it's a real directory
    if [[ -d "${HOME}/.local" && ! -L "${HOME}/.local" ]]; then
        echo "INFO: Backing up existing .local directory"
        mv "${HOME}/.local" "${HOME}/.local.bak.$(date +%s)"
    fi

    # Remove broken symlink if exists
    if [[ -L "${HOME}/.local" && ! -e "${HOME}/.local" ]]; then
        rm "${HOME}/.local"
    fi

    echo "INFO: Creating symlink ${HOME}/.local -> ${LOCAL_DIR}"
    ln -sfT "${LOCAL_DIR}" "${HOME}/.local"
else
    echo "INFO: .local already correctly linked to persistent storage"
fi

# D-Bus is an Inter-Process Communication (IPC) and Remote Procedure Calling (RPC) mechanism.
# D-Bus allows QT applications to send messages to each other.
echo "INFO: Starting D-Bus daemon"
DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address)
export DBUS_SESSION_BUS_ADDRESS

if [ "${1:0:1}" = '-' ]; then
    set -- linphone "$@"
fi

umask 002

echo "RUN: $*"
exec "$@"