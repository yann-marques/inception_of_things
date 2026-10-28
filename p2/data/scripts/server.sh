#!/bin/sh

echo "<========================= Installing k3s server =========================>"

SERVER_IP="192.168.56.110"
IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2}')

curl -sfL https://get.k3s.io | sh -s - server --node-ip="$SERVER_IP" --flannel-iface="$IFACE"

echo "<========================= Installing k3s server =========================>"

alias k='sudo k3s kubectl'

k apply -f /data/confs/app1-deployment.yaml -f /data/confs/app1-service.yaml
k apply -f /data/confs/app2-deployment.yaml -f /data/confs/app2-service.yaml
k apply -f /data/confs/app3-deployment.yaml -f /data/confs/app3-service.yaml
k apply -f /data/confs/ingress.yaml
