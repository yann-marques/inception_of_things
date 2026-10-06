#!/bin/sh

echo "<========================= Installing k3s server =========================>"

curl -sfL https://get.k3s.io | sh -s - server

echo "<========================= Installing k3s server =========================>"

alias k="sudo k3s kubectl"

k apply -f /data/confs/app1-deployment.yaml -f /data/confs/app1-service.yaml
