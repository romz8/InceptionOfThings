#!/bin/sh

sudo apk add curl

#INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --tls-san $(hostname) --node-ip=$1--bind-address=$1 "

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --bind-address=192.168.56.110  --write-kubeconfig-mode 644" sh -

sleep 20

sudo kubectl apply -f /vagrant/confs/deployment.yaml
sudo kubectl apply -f /vagrant/confs/service.yaml
sudo kubectl apply -f /vagrant/confs/ingress.yaml

sudo kubectl get all
