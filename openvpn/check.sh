#!/bin/bash

# Get username and password from environment variables
USERNAME=$1
PASSWORD=$2

# Check against the users file
if grep -q "^$USERNAME:$PASSWORD$" /etc/openvpn/users; then
    exit 0
else
    exit 1
fi 