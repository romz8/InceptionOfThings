#!/bin/bash

# Define variables
ip="192.168.56.110"
SERVER_IP="192.168.56.110"

# Update and install dependencies
sudo apk update
if [ $? -ne 0 ]; then
    echo "Failed to update package lists. Exiting."
    exit 1
fi

sudo apk add net-tools
if [ $? -ne 0 ]; then
    echo "Failed to install net-tools. Exiting."
    exit 1
fi
echo "net-tools & curl installed successfully."

# Retrieve the K3s token from the K3s server

echo "Fetching the K3s token from the server..."

SERVER_TOKEN=$(cat /vagrant/k3s_token)
if [ -z "$SERVER_TOKEN" ]; then
    echo "Failed to retrieve the server token. Exiting."
    exit 1
fi
echo "Server token retrieved successfully."
echo $SERVER_TOKEN

# Install K3s worker node
export SERVER_TOKEN
export SERVER_IP
export INSTALL_K3S_EXEC="agent --server https://${SERVER_IP}:6443 --token ${SERVER_TOKEN} --node-ip=192.168.56.111"
echo "Installing K3s worker node..."
sudo curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install K3s worker node. Exiting."
    exit 1
fi

echo "K3s worker node installed successfully and running."
rm -f /vagrant/k3s_token