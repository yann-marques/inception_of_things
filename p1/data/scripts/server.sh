#!/bin/sh

echo "<========================= Installing k3s server =========================>"

curl -sfL https://get.k3s.io | sh -s - server --disable traefik

echo "<========================= Writing k3s token =========================>"

sudo cat /var/lib/rancher/k3s/server/node-token > /data/.k3s-token

echo "<========================= Giving rights for ks3 file =========================>"

sudo chmod 600 "/data/.k3s-token"
