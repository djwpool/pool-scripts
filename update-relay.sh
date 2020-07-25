#!/bin/bash

cp relay/config/*.json /opt/cardano/relay/config
systemctl restart cardano-relay.service