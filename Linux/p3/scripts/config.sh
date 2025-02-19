#!/bin/sh

#create initial cluster
sudo k3d cluster create iot --agents 2

#create namespaces
sudo kubectl create -f confs/namespaces/dev.yaml
sudo kubectl create -f confs/namespaces/argocd.yaml

#install argocd in argo namespace
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#install deployment
sudo kubectl apply -n dev -f confs/deployment.yaml
sudo kubectl apply -n dev -f confs/service.yaml

