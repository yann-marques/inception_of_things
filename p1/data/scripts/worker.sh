#!/bin/sh


echo "<========================= Waiting for k3s token =========================>"

while [ ! -s "/data/.k3s-token" ]; do
  echo "En attente du token K3s..."
  sleep 2
done

TOKEN="$(cat '/data/.k3s-token')"

echo "<========================= Installing k3s worker =========================>"

curl -sfL https://get.k3s.io | \
	K3S_URL="https://192.168.56.110:6443" \
    K3S_TOKEN="$TOKEN" \
    sh -s - agent --node-ip=192.168.56.110 --node-external-ip=192.168.56.110 --flannel-iface=192.168.56.110
