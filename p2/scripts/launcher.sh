#!/bin/sh

npm create next-app@latest $(whoami) --yes

cd $(whoami)

npm run build

npm run start
