#!/usr/bin/env bash

wget https://github.com/Z3Prover/z3/archive/master.zip -o z3.zip
unzip z3.zip
cd z3
python scripts/mk_make.py --python
cd build
make
make install
cd ../..
