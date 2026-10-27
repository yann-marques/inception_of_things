#!/bin/sh

SERVER_IP="192.168.56.110"
IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2}')

echo "<========================= Removing old k3s token =========================>"

rm -f /data/.k3s-token

echo "<========================= Installing k3s server =========================>"

curl -sfL https://get.k3s.io | sh -s - server --disable traefik --node-ip="$SERVER_IP" --flannel-iface="$IFACE"

echo "<========================= Writing k3s token =========================>"

cat /var/lib/rancher/k3s/server/node-token > /data/.k3s-token

sudo chmod 600 "/data/.k3s-token"
