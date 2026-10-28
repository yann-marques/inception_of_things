#!/bin/sh

cd /$(whoami)
echo "$PWD"

mkdir app
cd app

cp -r /data/src/.next .

node .next/standalone/server.js