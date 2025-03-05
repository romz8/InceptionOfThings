#!/bin/sh

GREEN="\033[32m"
RESET="\033[0m"

#0. we first start a k3d cluster if none are present -> otherwise keep as is
echo "${GREEN}Creating k3d cluster...${RESET}"
if ! k3d cluster list | grep -q "iot" ; then
    sudo k3d cluster create iot --agents 2
    echo "${GREEN}Created...${RESET}"
else
     echo "${GREEN}IoT alread exist. skipping creation step...${RESET}"
fi

# 1. Create Namespaces
echo "${GREEN}Creating Namespaces...${RESET}"
sudo kubectl apply -f confs/namespaces.yaml

# 2. Install ArgoCD in argocd Namespace
echo "${GREEN}Installing ArgoCD...${RESET}"
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Wait for ArgoCD Pods to Be Ready - ROMAIN : crucial step -> at least 600s as long set up 
echo "${GREEN}Waiting for ArgoCD Pods to be Ready...${RESET}"
sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

#4. Deploy the Application with ArgoCD
echo "${GREEN}Deploying Application with ArgoCD...${RESET}"
sudo kubectl apply -f confs/deployment.yaml -n argocd

# 5. Retrieve ArgoCD Admin Password
echo "${GREEN}Retrieving ArgoCD Admin Password...${RESET}"
echo -n "${GREEN}ARGOCD PASSWORD: "
sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo "${RESET}"

# 6. Port-Forward ArgoCD UI -> start by closing if any previou one"
echo "${GREEN}Port-Forwarding ArgoCD UI...${RESET}"
sudo pkill -f "kubectl port-forward" 
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

#7. All ready, display argoCD
echo "${GREEN}Access ArgoCD at https://localhost:8080${RESET}"

# 8 . Port-Forward dev 8080 to 8888
echo "${GREEN}Port-Forwarding Dev App to 8888...${RESET}"
sleep 10
sudo kubectl port-forward svc/playground-service -n dev 8888:8080
echo "${GREEN}used: kubectl port-forward svc/playground-service -n dev 8888:8080${RESET}"
echo "${GREEN}this port fwd here on this tty : close with ctrl+c ...${RESET}"

