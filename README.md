# Draco: Visualization Constraints Weight Learning for Visualization Recommendations [![Build Status](https://travis-ci.org/domoritz/draco.svg?branch=master)](https://travis-ci.org/domoritz/draco) [![Coverage Status](https://coveralls.io/repos/github/domoritz/draco/badge.svg?branch=master)](https://coveralls.io/github/domoritz/draco?branch=master)

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

### Guides

* The Algorithm is wirren up in https://hackmd.io/s/H1RYJ5RRW
* https://github.com/potassco/guide/releases/

## Developer setup

### Install clingo.

On Linux, run `apt get install gringo`. On MacOS, you can run `brew install gringo`.

### Install node dependencies

`yarn` or `npm install`

### Python setup

`pip install -r requirements.txt`

Install draco in editable mode

`pip install -e .`

Now you can call the command line tool `draco`. For example `draco --version` or `draco --help`.

### Tests

You should also be able to run the tests (and coverage report)

`python setup.py test`

#### Run only ansunit tests

`ansunit asp/tests.yaml`

#### Run only python tests

`pytest -v`

### Running Draco

To run draco on a partial spec

`sh run_pipeline.sh spec`

The output would be a .vl.json file (for Vega-Lite spec) and a .png file to preview the visualization (by default, outputs would be in folder `__tmp__`).
