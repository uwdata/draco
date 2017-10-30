#!/usr/bin/env bash

set -e
set -x

python3 main.py examples/scatter.json --out scatter.vl.json
npm run vl2png --silent -- scatter.vl.json > scatter.png
