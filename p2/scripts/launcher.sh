#!/bin/sh

cd /$(whoami)
echo "$PWD"

npx create-next-app@latest $APP_NAME --yes

npm i dotenv
cd $APP_NAME

cd app

rm -fr page.tsx
cp /data/src/page.tsx .
cd ..

npm run build

npm run start
