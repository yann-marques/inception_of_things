#!/bin/sh

cd /$(whoami)
echo "$PWD"

npx create-next-app@latest $APP_NAME --yes

cd $APP_NAME

cd app

rm -fr page.tsx
mv /data/src/page.txt .
cd ..

npm run build

npm run start
