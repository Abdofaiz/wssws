#!/bin/bash

# Start fail2ban
service fail2ban start

# Start firewall
ufw --force enable

# Start OpenVPN
openvpn --config /etc/openvpn/server.conf &

# Start SSH service
service ssh start

# Start Nginx
service nginx start

# Start Node.js application
node index.js 