#!/bin/sh

echo "<========================= Installing k3s server =========================>"

curl -sfL https://get.k3s.io | sh -s - server

echo "<========================= Installing k3s server =========================>"

echo "alias k='sudo k3s kubectl'" >> ~/.bashrc
echo "alias c=clear" >> ~/.bashrc

k apply -f /data/confs/app1-deployment.yaml -f /data/confs/app1-service.yaml
k apply -f /data/confs/app2-deployment.yaml -f /data/confs/app2-service.yaml
k apply -f /data/confs/app3-deployment.yaml -f /data/confs/app3-service.yaml
k apply -f /data/confs/ingress.yaml
