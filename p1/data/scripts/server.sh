#!/bin/sh

echo "<========================= Installing k3s server =========================>"

curl -sfL https://get.k3s.io | sh -s - server --disable traefik --node-ip=192.168.56.110 --node-external-ip=192.168.56.110 --flannel-iface=192.168.56.110

echo "<========================= Writing k3s token =========================>"

sudo cat /var/lib/rancher/k3s/server/node-token > /data/.k3s-token

echo "<========================= Giving rights for ks3 file =========================>"

sudo chmod 600 "/data/.k3s-token"
