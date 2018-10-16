<p align="center">
   <a href="https://uwdata.github.io/draco/">
      <img src="logos/dark/logo-dark.png" width=260></img>
   </a>
</p>

# Draco: Visualization Constraints Weight Learning for Visualization Recommendations [![Build Status](https://travis-ci.org/uwdata/draco.svg?branch=master)](https://travis-ci.org/uwdata/draco) [![Coverage Status](https://coveralls.io/repos/github/uwdata/draco/badge.svg?branch=master)](https://coveralls.io/github/uwdata/draco?branch=master)

Draco is a formal framework for representing design knowledge about effective visualization design as a collection of constraints. You can use Draco to find effective visualization designs in Vega-Lite. Draco's constraints are implemented in based on Answer Set Programming (ASP) and solved with the Clingo constraint solver. We also implemented a way to learn weights for the recommendation system directly from the results of graphical perception experiment.

Try Draco in the browser at https://uwdata.github.io/draco-editor. The code for the editor is at https://github.com/uwdata/draco-editor.

## Status

**There Be Dragons!** This project is in active development and we are working hard on cleaning up the repository and making it easier to use the recommendation model in Draco. If you want to use this right now, please talk to us. More documentation is forthcoming.

For a TypeScript version of Draco with some overlapping functionality see https://github.com/uwdata/draco-vis. 

## Overview

This repository currently contains:

* The ASP programs with soft and hard constraints.
* A Python API that
    * translates from Compassql and Vega-Lite to ASP
    * translates the output from the Clingo ASP solver to Vega-Lite
    * Runs a learning to rank method on results of perception experiments
* UI tools to create annotated datasets of pairs of visualizations, look at the recommendations, and to explore large datasets of example visualizations.
* Notebooks to analyze the results

## Installation

### Install Clingo.

You can install Clingo with conda: `conda install -c potassco clingo`. On MacOS, you can alternatively run `brew install clingo`.

### Install node dependencies

`yarn` or `npm install`

You might need to activate a Python 2.7 environment to compile the canvas module.

### Python setup

`pip install -r requirements.txt` or `conda install --file requirements.txt`

Install Draco in editable mode. We expect Python 3. 

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

### End to end example

To run Draco on a partial spec.

`sh run_pipeline.sh spec`

The output would be a .vl.json file (for Vega-Lite spec) and a .png file to preview the visualization (by default, outputs would be in folder `__tmp__`).

### Use CompassQL to generate examples

Run `yarn build_cql_examples`.

### Run Draco directly on a set of ASP constraints

You can use the helper file `asp/_all.lp`.

`clingo asp/_all.lp test.lp`

Alternatively, you can invoke Draco with `draco -m asp test.lp`.

### Run APT example

`clingo asp/_apt.lp examples/example_apt.lp --opt-mode=optN --quiet=1 --project -c max_extra_encs=0`

This only prints the relevant data and restricts the extra encodings that are being generated.

## Resources

### Related Repositories

Previous prototypes

* https://github.com/uwdata/vis-csp
* https://github.com/uwdata/vis-constraints

Related software

* https://github.com/uwdata/draco-vis
* https://github.com/vega/compassql
* https://github.com/potassco/clingo

### Guides

* https://github.com/potassco/guide/releases/
