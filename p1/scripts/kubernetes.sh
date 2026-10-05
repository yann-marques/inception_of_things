#!/bin/sh


echo "<=========================Clonning kubectl before installation=========================>"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "<=========================		fetching the sha256			=========================>"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "<=========================		Verifying the checksum		=========================>"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

if [ $? -ne 0 ]; then
	echo "Error The checksum differs, stopping here."
	exit 1
fi

echo "<=========================		Installing kubectl			=========================>"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
