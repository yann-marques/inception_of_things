#!/bin/bash

echo "<============ Remove every disrupting packages ===========>"
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

echo "<============ Official docker GPG keys ===========>"
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo "<============ Adding dcoker repository to apt sources ===========>"
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "<============ Update the apt repository ===========>"
sudo apt update

echo "<============ Docker install ===========>"
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "<============ Testing docker run ===========>"
sudo docker run hello-world

echo "<============ Fetching  kubectl ===========>"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "<============ Installing  kubectl ===========>"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "<============ Adding exec rights to kubectl ===========>"
chmod +x kubectl

echo "<============ Moving kubectl to the /usr/local/bin folder ===========>"
sudo mv ./kubectl /usr/local/bin/kubectl

echo "<============ Fetching k3d ===========>"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
