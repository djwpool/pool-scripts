#!/bin/bash

useradd -c "user to run cardano relay" -m -d /opt/cardano -s /sbin/nologin crelay
passwd -d crelay

mkdir -p /opt/cardano/relay/db
mkdir -p /opt/cardano/relay/config

cp relay/config/*.json /opt/cardano/relay/config
chown -R crelay:crelay /opt/cardano

cp systemd/cardano-relay.sh /usr/bin/cardano-relay.sh
chmod +x /usr/bin/cardano-relay.sh

cp systemd/cardano-relay.environment /opt/cardano/relay/cardano-relay.environment
cp systemd/cardano-relay.service /etc/systemd/system/cardano-relay.service
chmod 644 /etc/systemd/system/cardano-relay.service

systemctl enable cardano-relay.service
systemctl start cardano-relay.service

echo "Manually install longview - https://cloud.linode.com/longview/clients"