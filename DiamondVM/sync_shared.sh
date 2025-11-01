#!/bin/ash
cd /home/container
VPS_PORT=${VPS_PORT:-22}
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/home/container/.ssh/known_hosts -o LogLevel=ERROR"
if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
    SSH_OPTS="${SSH_OPTS} -i /home/container/.ssh/private_key"
fi
sync_direction="$1"
case "${sync_direction}" in
    "to-remote")
        echo "Syncing local → remote..."
        if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
            rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" /home/container/shared/ ${VPS_USER}@${VPS_HOST}:~/shared/
        else
            sshpass -p "${VPS_PASSWORD}" rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" /home/container/shared/ ${VPS_USER}@${VPS_HOST}:~/shared/
        fi
        ;;
    "from-remote")
        echo "Syncing remote → local..."
        if [ "${VPS_USE_KEY}" = "true" ] || [ "${VPS_USE_KEY}" = "1" ]; then
            rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" ${VPS_USER}@${VPS_HOST}:~/shared/ /home/container/shared/
        else
            sshpass -p "${VPS_PASSWORD}" rsync -avz -e "ssh ${SSH_OPTS} -p ${VPS_PORT}" ${VPS_USER}@${VPS_HOST}:~/shared/ /home/container/shared/
        fi
        ;;
    *)
        echo "Usage: $0 [to-remote|from-remote]"
        echo "  to-remote   - Sync local shared folder to remote VPS"
        echo "  from-remote - Sync remote shared folder to local"
        exit 1
        ;;
esac
echo "Sync completed!"
