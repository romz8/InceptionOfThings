#!/bin/bash

echo "Starting server setup..."
sudo apk update
sudo apk add net-tools
sudo apk add iptables
echo "net-tools installed successfully."
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip=192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110"
sudo curl -sfL https://get.k3s.io | sh -
echo "k3s installed successfully. runnning k3s server..."

# checking K3s is up and running
# Wait for API server to be responsive
echo "Waiting for K3s API server to become responsive..."
sleep 20

# Wait for Nodes to become Ready
echo "Waiting for nodes to become ready..."
while ! sudo k3s kubectl get nodes | grep -q 'Ready'; do
  echo "Nodes are not ready yet. Retrying in 10 seconds..."
  sleep 10
done
echo "Nodes are ready."
echo "K3s server is responsive."

#extra check
sudo k3s kubectl wait --for=condition=Ready node --all --timeout=600s

# Copy the K3s token to the shared folder
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s_token
if [ $? -ne 0 ]; then
    echo "Failed to copy the K3s token to the shared folder. Exiting."
    exit 1
fi

# Set appropriate permissions for the token
sudo chmod 644 /vagrant/k3s_token
echo "K3s token has been copied to the shared folder."