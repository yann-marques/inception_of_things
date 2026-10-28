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
wget https://github.com/argoproj/argo-cd/releases/download/v3.5.4/argocd-linux-amd64 -O argocd

echo -e "\033[0;32m<============ Making argocd executable ===========>\033[0m"
chmod +x argocd

echo -e "\033[0;32m<============ Putting argocd into the /bin ===========>\033[0m"
sudo mv argocd /bin/argocd

echo -e "\033[0;32m<============ Connecting to the argocd in-cluster mod ===========>\033[0m"
sudo argocd login --core

while [ "$(kubectl get pods -n argocd | grep "argocd-server" | awk '{print $2}')" = "0/1" ]; do
        echo -e "\033[0;35mWaiting for the server to be up..."
        sleep 5
done

echo -e "\033[0;32m<============ Port forwarding argocd WebApp ===========>\033[0m"
sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8181:443 &
echo -e "\033[0;34m[INFO]: The port forward allows you to connect to the WebApp through: https://<vm-ip>:8080\033[0;32m"

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

echo -e "\033[0;32m<============ Creating self-signed TLS certificate ===========>\033[0m"
openssl req -x509 -nodes -newkey rsa:2048 -days 365 -keyout tls.key -out tls.crt \
  -subj "/CN=gitlab.gitlab.local/emailAddress=cmorel-ymarques@example.com" \
  -addext "subjectAltName=DNS:gitlab.gitlab.local,DNS:gitlab-webservice-default,DNS:gitlab-webservice-default.gitlab.svc,DNS:gitlab-webservice-default.gitlab.svc.cluster.local,IP:$(hostname -I | awk '{print $1}')"

sudo kubectl create secret tls gitlab-workhorse-tls -n gitlab --cert=tls.crt --key=tls.key
sudo kubectl create secret generic gitlab-workhorse-ca -n gitlab --from-file=ca.crt=tls.crt

echo -e "\033[0;32m<============ Add the self signed certificate to ArgoCD ===========>\033[0m"
# equivalent de "argocd cert add-tls", sans dependre du namespace du contexte kubectl
# la cle doit etre exactement l'hote de l'URL du repo
sudo kubectl -n argocd create configmap argocd-tls-certs-cm \
  --from-file=gitlab-webservice-default.gitlab.svc=tls.crt \
  --dry-run=client -o yaml | sudo kubectl apply --server-side -f -

echo -e "\033[0;32m<============ Installing gitlab Helm ===========>\033[0m"
sudo helm upgrade --install gitlab gitlab/gitlab -n gitlab -f ../confs/custom-values.yaml --server-side --force-conflicts

echo -e "\033[0;35mWaiting for the gitlab webservice to be up (can take several minutes)..."
sudo kubectl wait --for=condition=Ready pod -l app=webservice -n gitlab --timeout=1200s

echo -e "\033[0;32m<============ Port forwarding gitlab WebApp ===========>\033[0m"
sudo kubectl port-forward --address 0.0.0.0 -n gitlab svc/gitlab-webservice-default 8443:8181 &
echo -e "\033[0;34m[INFO]: Connect through: https://$(hostname -I | awk '{print $1}'):8443\033[0;32m"

echo -e "\033[0;32m<============ Port forwarding gitlab shell server ===========>\033[0m"
sudo kubectl port-forward --address 0.0.0.0 -n gitlab svc/gitlab-gitlab-shell 2222:22 &

echo -e "\033[0;32m\033[0;34m[INFO]: Gitlab Credentials: root : $(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 -d) \033[0;32m"
echo -e "\033[0;34m[INFO]: The default credentials are: admin : $(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) \033[0;32m"

sudo rm -fr tls.crt tls.key

#sudo kubectl port-forward --address=0.0.0.0 "$(sudo kubectl get pods -n dev | grep 'wil42-playground' | awk '{print $1}')" -n dev 8888:8888
#git clone ssh://git@10.171.52.243:2222/ymarques/ymarques_wil42.git
#https://gitlab-webservice-default.gitlab.svc:8181/ymarques/ymarques_wil42.git
