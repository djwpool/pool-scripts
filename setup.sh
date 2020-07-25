#!/bin/bash

adduser djworth
usermod -aG sudo djworth
mkdir /home/djworth/.ssh

git clone https://github.com/djwpool/pool-scripts.git /home/djworth/pool-scripts

cp ../linode/ssh/id_rsa.pub /home/djworth/.ssh/authorized_keys
chown -R djworth:djworth /home/djworth

cp ../linode/ssh/sshd_config /etc/ssh/sshd_config
systemctl restart ssh.service

echo "Setting up the firewall..."
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 2319/tcp
ufw status verbose
