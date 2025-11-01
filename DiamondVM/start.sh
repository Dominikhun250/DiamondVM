#!/bin/ash
cd /home/container
mkdir -p logs
if [ ! -f/home/container/.ssh/known_hosts ]; then
    touch /home/container/.ssh/known_hosts
    chmod 600 /home/container/.ssh/known_hosts
fi
if [ -z "${VPS_HOST}" ]; then
    echo "ERROR: VPS_HOST environment variable is required"
    exit 1
fi
if [ -z "${VPS_USER}" ]; then
    echo "ERROR: VPS_USER environment variable is required"
    exit 1
fi
VPS_PORT=${VPS_PORT:-22}
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/home/container/.ssh/known_hosts -o LogLevel=ERROR"
if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
    if [ -n "${VPS_PRIVATE_KEY}" ]; then
        echo "Using SSH key authentication"
        echo "${VPS_PRIVATE_KEY}" > /home/container/.ssh/private_key
        chmod 600 /home/container/.ssh/private_key
        SSH_OPTS="${SSH_OPTS} -i /home/container/.ssh/private_key"
    else
        echo "ERROR: VPS_USE_KEY is enabled but no VPS_PRIVATE_KEY provided"
        exit 1
    fi
else
    if [ -z "${VPS_PASSWORD}" ]; then
        echo "ERROR: VPS_PASSWORD is required when not using key authentication"
        exit 1
    fi
    echo "Using password authentication"
fi
setup_shared_folder() {
    if [ "${SHARED_FOLDER_ENABLED}" = "true" ] || [ "${SHARED_FOLDER_ENABLED}" = "1" ]; then
        echo "Setting up shared folder synchronization..."
        if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
            ssh ${SSH_OPTS} -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST} "mkdir -p ~/shared"
        else
            sshpass -p "${VPS_PASSWORD}" ssh ${SSH_OPTS} -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST} "mkdir -p ~/shared"
        fi
        echo "Shared folder is ready"
        echo "Local path: /home/container/shared"
        echo "Remote path: ~/shared on ${VPS_HOST}"
    fi
}
sync_to_remote() {
    if [ "${SHARED_FOLDER_ENABLED}" = "true" ] || [ "${SHARED_FOLDER_ENABLED}" = "1" ]; then
        echo "Syncing local changes to remote..."
        if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
            rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" /home/container/shared/ ${VPS_USER}@${VPS_HOST}:~/shared/
        else
            sshpass -p "${VPS_PASSWORD}" rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" /home/container/shared/ ${VPS_USER}@${VPS_HOST}:~/shared/
        fi
    fi
}
sync_from_remote() {
    if [ "${SHARED_FOLDER_ENABLED}" = "true" ] || [ "${SHARED_FOLDER_ENABLED}" = "1" ]; then
        echo "Syncing remote changes to local..."
        if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
            rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" ${VPS_USER}@${VPS_HOST}:~/shared/ /home/container/shared/
        else
            sshpass -p "${VPS_PASSWORD}" rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" ${VPS_USER}@${VPS_HOST}:~/shared/ /home/container/shared/
        fi
    fi
}
setup_shared_folder
sync_from_remote
echo "=== SSH Connection Details ==="
echo "Host: ${VPS_HOST}:${VPS_PORT}"
echo "User: ${VPS_USER}"
echo "=============================="
echo ""
echo "Connecting to VPS..."

if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
    ssh ${SSH_OPTS} -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}
else
    sshpass -p "${VPS_PASSWORD}" ssh ${SSH_OPTS} -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}
fi
SSH_EXIT_CODE=$?
if [ "${SHARED_FOLDER_ENABLED}" = "true" ] || [ "${SHARED_FOLDER_ENABLED}" = "1" ]; then
    echo "SSH session ended. Syncing final changes..."
    sync_to_remote
fi
echo "SSH connection closed with exit code: ${SSH_EXIT_CODE}"
exit ${SSH_EXIT_CODE}
