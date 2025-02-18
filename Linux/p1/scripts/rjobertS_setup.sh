#!/bin/bash

echo "Starting server setup..."
sudo apk update
sudo apk add net-tools
echo "net-tools installed successfully."
sudo curl -sfL https://get.k3s.io | sh -
echo "k3s installed successfully. runnning k3s server..."

# Copy the K3s token to the shared folder
sleep 10
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s_token
if [ $? -ne 0 ]; then
    echo "Failed to copy the K3s token to the shared folder. Exiting."
    exit 1
fi

# Set appropriate permissions for the token
sudo chmod 644 /vagrant/k3s_token
echo "K3s token has been copied to the shared folder."