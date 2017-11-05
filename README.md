# Draco: Visualization Constraints Weight Learning for Visualization Recommendations [![Build Status](https://travis-ci.org/domoritz/draco.svg?branch=master)](https://travis-ci.org/domoritz/draco) [![Coverage Status](https://coveralls.io/repos/github/domoritz/draco/badge.svg?branch=master)](https://coveralls.io/github/domoritz/draco?branch=master)

Related repos:
* https://github.com/domoritz/vis-csp
* https://github.com/domoritz/vis-constraints

## Developer setup

## Install clingo.

On Linux, run `apt get install gringo`. On MacOS, you can run `brew install gringo`.

## Install node dependencies

`yarn` or `npm install`

## Python setup

`pip install -r requirements.txt`

Install draco in editable mode

`pip install -e .`

Now you can call the command line tool `draco`. For example `draco --version` or `draco --help`.

## Tests

You should also be able to run the tests (and coverage report)

`python setup.py test`

### Run only ansunit tests

`ansunit asp/tests.yaml`

### Run only python tests

`pytest -v`

## Running Draco

To run draco on a partial spec

`sh run_pipeline.sh spec`

The output would be a .vl.json file (for Vega-Lite spec) and a .png file to preview the visualization (by default, outputs would be in folder `__tmp__`).
