#!/bin/bash

useradd -c "user to run cardano block node" -m -d /opt/cardano -s /sbin/nologin cblock
passwd -d cblock

export CARDANO_NODE_SOCKET_PATH=/opt/cardano/relay/db/node.socket

mkdir -p /opt/cardano/block/db
mkdir -p /opt/cardano/block/keys
mkdir -p /opt/cardano/block/config

cp block/config/*.json /opt/cardano/block/config

echo "Creating Verification Keys..."
cardano-cli shelley address key-gen \
    --verification-key-file  /opt/cardano/block/keys/payment.vkey \
    --signing-key-file /opt/cardano/block/keys/payment.skey

echo "Creating Stake Keys..."
cardano-cli shelley stake-address key-gen \
    --verification-key-file /opt/cardano/block/keys/stake.vkey \
    --signing-key-file /opt/cardano/block/keys/stake.skey

echo "Creating Payment Address..."
cardano-cli shelley address build \
    --payment-verification-key-file /opt/cardano/block/keys/payment.vkey \
    --stake-verification-key-file /opt/cardano/block/keys/stake.vkey \
    --out-file /opt/cardano/block/keys/payment.addr \
    --testnet-magic 42

echo "Querying the payment address..."
cardano-cli shelley query utxo \
    --address $(cat /opt/cardano/block/keys/payment.addr) \
    --testnet-magic 42

echo "Building the staking address..."
cardano-cli shelley stake-address build \
    --stake-verification-key-file /opt/cardano/block/keys/stake.vkey \
    --out-file /opt/cardano/block/keys/stake.addr \
    --testnet-magic 42

echo "Fetching funds from the faucet..."
curl -v -XPOST "https://faucet.shelley-testnet.dev.cardano.org/send-money/$(cat payment.addr)"

echo "Checking funds were recieved from the faucet..."
sleep 5
cardano-cli shelley query utxo \
    --address $(cat /opt/cardano/block/keys/payment.addr) \
    --testnet-magic 42

echo "Generating keys for a second payment address.."
cardano-cli shelley address key-gen \
    --verification-key-file /opt/cardano/block/keys/payment2.vkey \
    --signing-key-file /opt/cardano/block/keys/payment2.skey

echo "Building the second payment address..."
cardano-cli shelley address build \
    --payment-verification-key-file /opt/cardano/block/keys/payment2.vkey \
    --stake-verification-key-file /opt/cardano/block/keys/stake.vkey \
    --out-file /opt/cardano/block/keys/payment2.addr \
    --testnet-magic 42

echo "Building the protocol parameters..."
cardano-cli shelley query protocol-parameters \
   --testnet-magic 42 \
   --out-file /opt/cardano/block/keys/protocol.json

TTL=$(expr $(cardano-cli shelley query tip --testnet-magic 42 | jq '.blockNo?') + 1000)

echo "Calculating the minimum fee for a transaction..."
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 2 \
    --ttl $TTL \
    --testnet-magic 42 \
    --signing-key-file /opt/cardano/block/keys/payment.skey \
    --protocol-params-file /opt/cardano/block/keys/protocol.json

cardano-cli shelley query utxo \
    --address $(cat /opt/cardano/block/keys/payment.addr) \
    --testnet-magic 42

chown -R cblock:cblock /opt/cardano

cp systemd/cardano-block.sh /usr/bin/cardano-block.sh
chmod +x /usr/bin/cardano-block.sh

cp systemd/cardano-block.environment /opt/cardano/block/cardano-block.environment
cp systemd/cardano-block.service /etc/systemd/system/cardano-block.service
chmod 644 /etc/systemd/system/cardano-block.service

systemctl enable cardano-block.service
systemctl start cardano-block.service

echo "Manually install longview - https://cloud.linode.com/longview/clients"