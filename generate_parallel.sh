#!/usr/bin/env bash

cat draco/generation/define/interactions.json | jq -r '.[] .name' | parallel --eta python draco/generation/run.py --interaction {}
