cardano-node  run \
    --topology /opt/cardano/relay/config/shelley_testnet-topology.json \
    --database-path /opt/cardano/relay/db \
    --socket-path /opt/cardano/relay/db/node.socket \
    --host-addr 0.0.0.0 \
    --port 4500 \
    --config /opt/cardano/relay/config/shelley_testnet-config.json