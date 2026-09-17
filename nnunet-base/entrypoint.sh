#!/bin/bash
set -e

# Environment variables from docker-compose
HOST_UID=${HOST_UID:-1000}
HOST_GID=${HOST_GID:-1000}
HOST_USER=${HOST_USER:-eucaim}

echo "Configuring container user: $HOST_USER ($HOST_UID:$HOST_GID)"

# -------------------------
# 1. Ensure host group exists and has correct GID
# -------------------------
EXISTING_GROUP=$(getent group "$HOST_GID" | cut -d: -f1)
if [ -n "$EXISTING_GROUP" ] && [ "$EXISTING_GROUP" != "$HOST_USER" ]; then
    # GID is taken by another group -> reassign it to a free GID >= 2000
    FREE_GID=$(awk -F: '{print $3}' /etc/group | sort -n | awk 'BEGIN{n=2000} {if ($1==n) n++} END{print n}')
    echo "GID $HOST_GID already taken by group $EXISTING_GROUP, reassigning to $FREE_GID"
    groupmod -g "$FREE_GID" "$EXISTING_GROUP"
fi

if ! getent group "$HOST_USER" >/dev/null; then
    groupadd -g "$HOST_GID" "$HOST_USER"
    echo "Adding group with GID = $HOST_GID and group name = $HOST_USER"
fi

# -------------------------
# 2. Ensure host user exists with correct UID
# -------------------------

EXISTING_UID_USER=$(getent passwd "$HOST_UID" | cut -d: -f1)
if id -u "$HOST_USER" >/dev/null 2>&1; then
    CURRENT_UID=$(id -u "$HOST_USER")
    if [ "$CURRENT_UID" -ne "$HOST_UID" ]; then
        if [ -n "$EXISTING_UID_USER" ] && [ "$EXISTING_UID_USER" != "$HOST_USER" ]; then
            FREE_UID=$(awk -F: '{print $3}' /etc/passwd | sort -n | awk 'BEGIN{n=2000} {if ($1==n) n++} END{print n}')
            echo "UID $HOST_UID already taken by user $EXISTING_UID_USER, reassigning to $FREE_UID"
            usermod -u "$FREE_UID" "$EXISTING_UID_USER"
        fi
        echo "Updating UID of $HOST_USER to $HOST_UID"
        usermod -u "$HOST_UID" "$HOST_USER"
    fi
else
    if [ -n "$EXISTING_UID_USER" ]; then
        FREE_UID=$(awk -F: '{print $3}' /etc/passwd | sort -n | awk 'BEGIN{n=2000} {if ($1==n) n++} END{print n}')
        echo "UID $HOST_UID already taken by user $EXISTING_UID_USER, reassigning to $FREE_UID"
        usermod -u "$FREE_UID" "$EXISTING_UID_USER"
    fi
    echo "Creating user $HOST_USER with UID $HOST_UID and GID $HOST_GID"
    useradd -m -u "$HOST_UID" -g "$HOST_GID" -s /bin/bash "$HOST_USER"
fi

# -------------------------
# 3. Fix ownership of /sandbox
# -------------------------
chown -R "$HOST_UID:$HOST_GID" /sandbox || true

# -------------------------
# 4. Switch to host user and run script.py
# -------------------------

# Default command if none supplied
if [ "$#" -eq 0 ]; then
    set -- bash
fi

echo "Launching app as $HOST_USER ($HOST_UID:$HOST_GID)"

exec gosu "$HOST_USER" "$@"

