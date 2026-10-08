#!/bin/sh

cd /$(whoami)
echo "$PWD"

npx create-next-app@latest $APP_NAME \
--typescript \
--no-tailwind \
--import-aliases "@/*" \
--no-eslint \
--app \

npm i dotenv
cd $APP_NAME

cd app

rm -fr page.tsx
cp /data/src/page.tsx .
cd ..

npm run dev
