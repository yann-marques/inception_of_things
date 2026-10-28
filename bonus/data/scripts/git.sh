#!/bin/bash

echo -e "\033[0;32m<============ Creating the folder for the repo ===========>\033[0m"
mkdir ymarques_wil42

echo -e "\033[0;32m<============ Moving into the folder ===========>\033[0m"
cd ymarques_wil42

echo -e "\033[0;32m<============ Creating the git repository ===========>\033[0m"
git init

echo -e "\033[0;32m<============ adding both remote repos ===========>\033[0m"
git remote add gitlab ssh://git@10.171.52.213:2222/ymarques/ymarques_wil42.git
git remote add github git@github.com:yann-marques/ymarques_wil42_deployment.git 

echo -e "\033[0;32m<============ Pulling from github ===========>\033[0m"
git pull github main

echo -e "\033[0;32m<============ Pushing to gitlab ===========>\033[0m"
git push gitlab

echo -e "\033[0;32m<============ Creating wil42 app ===========>\033[0m"
sudo argocd app create wil42-deployment \
  --repo https://gitlab-webservice-default.gitlab.svc:8181/ymarques/ymarques_wil42.git \
  --path confs \
  --dest-namespace dev \
  --dest-server https://kubernetes.default.svc \
  --directory-recurse \
  --revision master

echo -e "\033[0;32m<============ Set automated policy ===========>\033[0m"
sudo argocd app set wil42-deployment --sync-policy automated
sleep 5

echo -e "\033[0;32m<============ Waiting up status ===========>\033[0m"
while [ "$(sudo kubectl get pods -n dev | grep "wil42-playground" | awk '{print $2}')" = "0/1" ]; do
        echo -e "\033[0;35mWaiting for wil42 to be up..."
        sleep 5
done
sleep 5

echo -e "\033[0;32m<============ Port forward wil42 ===========>\033[0m"
sudo kubectl port-forward --address=0.0.0.0 "$(sudo kubectl get pods -n dev | grep 'wil42-playground' | awk '{print $1}')" -n dev 7777:8888 &
