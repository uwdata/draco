#!/usr/bin/env bash

set -e
set -x

python3 main.py -o foo.vl.json
npm run vl2png --silent -- foo.vl.json > foo.png
