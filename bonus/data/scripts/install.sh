#!/bin/bash

echo "\033[0;32m<============ Remove every disrupting packages ===========>\033[0m"
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

echo "\033[0;32m<============ Official docker GPG keys ===========>\033[0m"
sudo apt update
sudo apt upgrade -y
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo "\033[0;32m<============ Adding dcoker repository to apt sources ===========>\033[0m"
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "\033[0;32m<============ Update the apt repository ===========>\033[0m"
sudo apt update

echo "\033[0;32m<============ Docker install ===========>\033[0m"
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "\033[0;32m<============ Testing docker run ===========>\033[0m"
sudo docker run hello-world

echo "\033[0;32m<============ Fetching  kubectl ===========>\033[0m"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "\033[0;32m<============ Installing  kubectl ===========>\033[0m"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "\033[0;32m<============ Adding exec rights to kubectl ===========>\033[0m"
chmod +x kubectl

echo "\033[0;32m<============ Moving kubectl to the /usr/local/bin folder ===========>\033[0m"
sudo mv ./kubectl /usr/local/bin/kubectl

echo "\033[0;32m<============ Fetching k3d ===========>\033[0m"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "\033[0;32m<============ Installing Helm ===========>\033[0m"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
