#!/bin/bash -e

npm run build
bundle exec jekyll build

rsync -av _site/ app@frieden.wendig.io:/var/storage/host/frieden/current/
