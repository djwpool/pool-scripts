cardano-node  run \
    --topology /opt/cardano/block/config/shelley_testnet-topology.json \
    --database-path /opt/cardano/block/db \
    --socket-path /opt/cardano/block/db/node.socket \
    --host-addr 0.0.0.0 \
    --port 4500 \
    --config /opt/cardano/block/config/shelley_testnet-config.json