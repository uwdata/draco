#!/usr/bin/env bash

set -e
set -x

mkdir -p __tmp__
temp="__tmp__"

draco examples/scatter.json --out "$temp/scatter.vl.json"
npm run vl2png --silent -- "$temp/scatter.vl.json" > "$temp/scatter.png"
