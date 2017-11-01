# Visualization constraints [![Build Status](https://travis-ci.org/domoritz/draco.svg?branch=master)](https://travis-ci.org/domoritz/draco)

Related repos:
* https://github.com/domoritz/vis-csp
* https://github.com/domoritz/vis-constraints

## Developer setup

## First, install clingo.

On Linux, run `apt get install gringo`. On MacOS, you can run `brew install gringo`.

## Python setup

`pip install -r requirements.txt`

Install draco in editable mode

`pip install -e .`

Now you can call the command line tool `draco`. For example `draco --version` or `draco --help`.

You should also be able to run the tests (and coverage report)

`python setup.py test`
