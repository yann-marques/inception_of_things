echo "\033[0;32m<============ Creating  cluster for k3d ===========>"
sudo k3d cluster create p3-cluster

echo "<============ Connecting to the Cluster ===========>"
sudo k3d kubeconfig merge p3-cluster

echo "<============ Creating argocd namespace ===========>"
sudo kubectl create namespace argocd

echo "<============ Creating argocd pods ===========>"
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "<============ Setting argocd namespace to default ===========>"
kubectl config set-context --current --namespace=argocd


echo "<============ Fetching argocd binary ===========>"
wget https://github.com/argoproj/argo-cd/releases/download/v3.5.4/argocd-linux-amd64

echo "<============ Making argocd executable ===========>"
chmod +x argocd-linux-amd64

echo "<============ Putting argocd into the /bin ===========>"
sudo mv argocd-linux-amd64 /bin/argocd

echo "<============ Connecting to the argocd in-cluster mod ===========>"
sudo argocd login --core

echo "\033[0;34m[INFO]: to see your cluster status use: sudo argocd cluster list\033[0;32m"

echo "<============ Creating dev namespace ===========>"
sudo kubectl create namespace dev
