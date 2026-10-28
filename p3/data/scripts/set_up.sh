#!/bin/bash

echo -e "\033[0;32m<============ Deleting cluster for k3d ===========>\033[0m"
sudo k3d cluster delete -a 2> /dev/null

echo -e "\033[0;32m<============ Creating cluster for k3d ===========>\033[0m"
sudo k3d cluster create p3-cluster

echo -e "\033[0;32m<============ Connecting to the Cluster ===========>\033[0m"
sudo k3d kubeconfig merge p3-cluster

echo -e "\033[0;32m<============ Creating argocd namespace ===========>\033[0m"
sudo kubectl create namespace argocd

echo -e "\033[0;32m<============ Creating argocd pods ===========>\033[0m"
sudo kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "\033[0;32m<============ Setting argocd namespace to default ===========>\033[0m"
sudo kubectl config set-context --current --namespace=argocd


echo -e "\033[0;32m<============ Fetching argocd binary ===========>\033[0m"
wget https://github.com/argoproj/argo-cd/releases/download/v3.5.4/argocd-linux-amd64

echo -e "\033[0;32m<============ Making argocd executable ===========>\033[0m"
chmod +x argocd-linux-amd64

echo -e "\033[0;32m<============ Putting argocd into the /bin ===========>\033[0m"
sudo mv argocd-linux-amd64 /bin/argocd

echo -e "\033[0;32m<============ Connecting to the argocd in-cluster mod ===========>\033[0m"
sudo argocd login --core

echo -e "\033[0;32m\033[0;34m[INFO]: to see your cluster status use: sudo argocd cluster list\033[0;32m"

while [ "$(kubectl get pods -n argocd | grep "argocd-server" | awk '{print $2}')" = "0/1" ]; do
        echo -e "\033[0;35mWaiting for the server to be up..."
        sleep 5
done

echo -e "\033[0;32m<============ Port forwarding argocd WebApp ===========>\033[0m"
sudo kubectl port-forward --address=0.0.0.0 svc/argocd-server -n argocd 8080:443 &
echo -e "\033[0;34m[INFO]: The port forward allows you to connect to the WebApp through: localhost:8080\033[0;32m"

echo -e "\033[0;32m<============ Creating dev namespace ===========>\033[0m"
sudo kubectl create namespace dev

echo -e "\033[0;32m<============ Creating wil42 app ===========>\033[0m"
sudo argocd app create wil42-deployment --repo https://github.com/yann-marques/ymarques_wil42_deployment.git --path confs --dest-namespace dev --dest-server https://kubernetes.default.svc --directory-recurse
sudo argocd app set wil42-deployment --sync-policy automated


sleep 3
while [ "$(kubectl get pods -n dev | grep "wil42-playground" | awk '{print $2}')" = "0/1" ]; do
        echo -e "\033[0;35mWaiting for wil42 to be up..."
        sleep 5
done

echo -e "\033[0;32m<============ Port forwarding wil42-playground ===========>\033[0m"
wil_app_name="$(kubectl get pods -n dev | grep 'wil42-playground' | awk '{print $1}')"
sudo kubectl port-forward --address=0.0.0.0 "$(sudo kubectl get pods -n dev | grep 'wil42-playground' | awk '{print $1}')" -n dev 8888:8888 &

echo -e "\033[0;34m[INFO]: The default credentials are: admin : $(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) \033[0;32m"
