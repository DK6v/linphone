#!/usr/bin/env bash
set -e

# Create persistent storage for each scaled container
ID=$(get_name.py)
mkdir -p "/app/data/${ID}"

if [ ! -d "/app/data/${ID}/.local" ]; then 
    mv "${HOME}" "/app/data/${ID}"
fi
ln -sfT "/app/data/${ID}" "${HOME}"

# D-Bus is an Inter-Process Communication (IPC) and Remote Procedure Calling (RPC) mechanism.
# D-Bus allows QT applications to send messages to each other.
DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address)
export DBUS_SESSION_BUS_ADDRESS

if [ "${1:0:1}" = '-' ]; then
    set -- linphone "$@"
fi

umask 002

echo "RUN: $*"
exec "$@"
