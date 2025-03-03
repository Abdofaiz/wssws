#!/bin/bash

# Get the PORT from environment variable or default to 8080
PORT="${PORT:-8080}"
export PORT

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

# Start Node.js application with the correct port
PORT=$PORT node index.js 