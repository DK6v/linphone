#!/usr/bin/env bash
set -e

create_symlink() {
    local dir_name="$1"
    local persistent_dir="$2"
    
    local current_target=$(readlink "${HOME}/${dir_name}" 2>/dev/null || true)
    if [[ "$current_target" != "$persistent_dir" ]]; then

        # Backup existing directory if it's a real directory
        if [[ -d "${HOME}/${dir_name}" && ! -L "${HOME}/${dir_name}" ]]; then
            echo "INFO: Backing up existing ${dir_name} directory"
            mv "${HOME}/${dir_name}" "${HOME}/${dir_name}.bak.$(date +%s)"
        fi

        # Remove broken symlink if exists
        if [[ -L "${HOME}/${dir_name}" && ! -e "${HOME}/${dir_name}" ]]; then
            rm "${HOME}/${dir_name}"
        fi

        echo "INFO: Creating symlink ${HOME}/${dir_name} -> ${persistent_dir}"
        ln -sfT "${persistent_dir}" "${HOME}/${dir_name}"
    else
        echo "INFO: ${dir_name} already correctly linked to persistent storage"
    fi
}

# Create persistent storage for scaled containers
ID=$(get_name.py)
STORAGE_DIR="/app/data/${ID}"
mkdir -p "${STORAGE_DIR}"
echo "INFO: Using persistent storage: ${STORAGE_DIR}"

# Create persistent .local and .config directory
LOCAL_DIR="${STORAGE_DIR}/.local"
mkdir -p "${LOCAL_DIR}"
CONFIG_DIR="${STORAGE_DIR}/.config"
mkdir -p "${CONFIG_DIR}"

create_symlink ".local" "${LOCAL_DIR}"
create_symlink ".config" "${CONFIG_DIR}"

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