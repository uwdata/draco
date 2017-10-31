#!/usr/bin/env bash

set -e
set -x

draco examples/scatter.json --out scatter.vl.json
npm run vl2png --silent -- scatter.vl.json > scatter.png
