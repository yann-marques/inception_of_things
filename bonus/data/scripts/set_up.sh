#!/bin/bash

echo -e "\033[0;32m<============ Deleting cluster for k3d ===========>\033[0m"
sudo k3d cluster delete bonus-cluster 2> /dev/null

echo -e "\033[0;32m<============ Creating cluster for k3d ===========>\033[0m"
sudo k3d cluster create bonus-cluster

echo -e "\033[0;32m<============ Connecting to the Cluster ===========>\033[0m"
sudo k3d kubeconfig merge bonus-cluster

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
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 &
echo -e "\033[0;34m[INFO]: The port forward allows you to connect to the WebApp through: localhost:8080\033[0;32m"

echo -e "\033[0;32m<============ Creating dev namespace ===========>\033[0m"
sudo kubectl create namespace dev

echo -e "\033[0;32m<============ Creating Gitlab namespace ===========>\033[0m"
sudo kubectl create namespace gitlab

echo -e "\033[0;32m<============ Launching gitlab deps services ===========>\033[0m"
sudo kubectl apply -n gitlab -f ../confs/gitlab-postgres-redis.yaml

echo -e "\033[0;32m<============ Adding Gitlab helm ===========>\033[0m"
sudo helm repo add gitlab https://charts.gitlab.io
sudo helm repo update

echo -e "\033[0;32m<============ Removing crd ===========>\033[0m"
sudo kubectl delete crd gatewayclasses.gateway.networking.k8s.io gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io referencegrants.gateway.networking.k8s.io backendtlspolicies.gateway.networking.k8s.io grpcroutes.gateway.networking.k8s.io --ignore-not-found

echo -e "\033[0;32m<============ Installing gitlab Helm ===========>\033[0m"
sudo helm upgrade --install gitlab gitlab/gitlab -n gitlab -f ../confs/custom-values.yaml --server-side --force-conflicts

echo -e "\033[0;32m\033[0;34m[INFO]: Address of the gitlab: \033[0;32m"
sudo kubectl get ingress -n gitlab -lrelease=gitlab

echo -e "\033[0;32m\033[0;34m[INFO]: Gitlab Credentials: root : $(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 -d) \033[0;32m"
