# Draco: Visualization Constraints Weight Learning for Visualization Recommendations [![Build Status](https://travis-ci.org/domoritz/draco.svg?branch=master)](https://travis-ci.org/domoritz/draco) [![Coverage Status](https://coveralls.io/repos/github/domoritz/draco/badge.svg?branch=master)](https://coveralls.io/github/domoritz/draco?branch=master)

<img src="logos/dark/logo-dark.png" width=300></img>

Try Draco in the browser at https://domoritz.github.io/draco. Note that we use [Emscripten](https://github.com/kripken/emscripten) to compile the constraint solver for the web.

## Installation

### Install clingo.

You can install clingo with conda: `conda install -c potassco clingo`. On MacOS, you can alternatively run `brew install clingo`.

### Install node dependencies

`yarn` or `npm install`

You might need to activate a Python 2.7 environment to compile the canvas module.

### Python setup

`pip install -r requirements.txt` or `conda install --file requirements.txt`

Install draco in editable mode

`pip install -e .`

Now you can call the command line tool `draco`. For example `draco --version` or `draco --help`.

#### To run the notebook in a conda environment

`conda install nb_conda_kernels nb_conda`

### Tests

You should also be able to run the tests (and coverage report)

`python setup.py test`

#### Run only ansunit tests

`ansunit asp/tests.yaml`

#### Run only python tests

`pytest -v`

#### Test types

`mypy draco tests --ignore-missing-imports`

## Running Draco

## Run the Editor

See https://github.com/domoritz/draco/blob/master/draco-editor/Readme.md

### End to end example

To run draco on a partial spec.

`sh run_pipeline.sh spec`

The output would be a .vl.json file (for Vega-Lite spec) and a .png file to preview the visualization (by default, outputs would be in folder `__tmp__`).

### Use CompassQL to generate examples

Run `yarn build_cql_examples`.

### Run draco directly on a set of ASP constraints

You can use the helper file `asp/_all.lp`.

`clingo asp/_all.lp test.lp`

Alternatively, you can invoke draco with `draco -m asp test.lp`.

### Run APT example

`clingo asp/_apt.lp examples/example_apt.lp --opt-mode=optN --quiet=1 --project -c max_extra_encs=0`

This only prints the relevant data and restricts the extra encodings that are being generated.

## Resources

### Related repos

* https://github.com/domoritz/vis-csp
* https://github.com/domoritz/vis-constraints

### Related work

* http://www2.parc.com/istl/groups/uir/publications/items/UIR-1986-02-Mackinlay-TOG-Automating.pdf
* https://arxiv.org/pdf/1507.06566.pdf
* http://hci.stanford.edu/publications/2011/Bricolage/Bricolage-CHI2011.pdf
* https://www.cc.gatech.edu/~xzhang36/papers/mapl17.pdf
* https://www.cc.gatech.edu/~xzhang36/papers/popl16.pdf
* https://www.cc.gatech.edu/~xzhang36/papers/fse15a.pdf
* [Discriminative Training of Markov Logic Networks](https://homes.cs.washington.edu/~pedrod/papers/aaai05.pdf)
* [Markov Logic Network](https://homes.cs.washington.edu/~pedrod/papers/pilp.pdf)
* [Efficient Weight Learning for Markov Logic Networks](https://homes.cs.washington.edu/~pedrod/papers/pkdd07.pdf)
* [Combining Relational Learning with SMT
Solvers using CEGAR](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/main-25.pdf)
* [Convert ASP to MLN](http://reasoning.eas.asu.edu/lpmln/Tutorial.html)

### Guides

* The Algorithm is written up in https://hackmd.io/s/H1RYJ5RRW
* https://github.com/potassco/guide/releases/
