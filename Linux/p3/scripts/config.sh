#!/bin/sh

GREEN="\033[32m"
RESET="\033[0m"

#0. we first start a k3d cluster if none are present -> otherwise keep as is

echo -e "${GREEN}Creating k3d cluster...${RESET}"
if ! k3d cluster list | grep -q "iot" ; then
    sudo k3d cluster create iot --agents 2
    echo -e "${GREEN}Created...${RESET}"
else
    echo -e "${GREEN}IoT alread exist. skipping creation step...${RESET}"
fi

# 1. Create Namespaces
echo -e "${GREEN}Creating Namespaces...${RESET}"
sudo kubectl apply -f confs/namespaces.yaml

# 2. Install ArgoCD in argocd Namespace
echo -e "${GREEN}Installing ArgoCD...${RESET}"
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Wait for ArgoCD Pods to Be Ready
echo -e "${GREEN}Waiting for ArgoCD Pods to be Ready...${RESET}"
sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

#4. Deploy the Application with ArgoCD
echo -e "${GREEN}Deploying Application with ArgoCD...${RESET}"
sudo kubectl apply -f confs/deployment.yaml -n argocd

# 5. Retrieve ArgoCD Admin Password
echo -e "${GREEN}Retrieving ArgoCD Admin Password...${RESET}"
echo -n "${GREEN}ARGOCD PASSWORD: "
sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo "${RESET}"

# 6. Port-Forward ArgoCD UI
echo -e "${GREEN}Port-Forwarding ArgoCD UI...${RESET}"
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

echo -e "${GREEN}Access ArgoCD at https://localhost:8080${RESET}"