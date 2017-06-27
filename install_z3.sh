#!/usr/bin/env bash

set -x
set =e

wget https://github.com/Z3Prover/z3/archive/master.zip
unzip -q master.zip
cd z3-master
python scripts/mk_make.py --python
cd build
make
make install
cd ../..
