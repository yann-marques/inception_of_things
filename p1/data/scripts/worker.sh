#!/bin/sh

SERVER_IP="192.168.56.110"
WORKER_IP="192.168.56.111"
IFACE=$(ip -o -4 addr show | awk -v ip="$WORKER_IP" '$4 ~ "^"ip"/" {print $2}')

echo "<========================= Waiting for k3s token =========================>"

while [ ! -s "/data/.k3s-token" ]; do
  echo "En attente du token K3s..."
  sleep 2
done

TOKEN="$(cat '/data/.k3s-token')"

echo "<========================= Installing k3s worker =========================>"

curl -sfL https://get.k3s.io | \
  K3S_URL="https://$SERVER_IP:6443" \
  K3S_TOKEN="$TOKEN" \
  sh -s - agent --node-ip="$WORKER_IP" --node-external-ip="$WORKER_IP" --flannel-iface="$IFACE"
