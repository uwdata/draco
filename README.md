<p align="center">
   <a href="https://uwdata.github.io/draco/">
      <img src="logos/dark/logo-dark.png" width=260></img>
   </a>
</p>

# Formalizing Visualization Design Knowledge as Constraints

[![Build Status](https://travis-ci.org/uwdata/draco.svg?branch=master)](https://travis-ci.org/uwdata/draco)
[![Coverage Status](https://coveralls.io/repos/github/uwdata/draco/badge.svg?branch=master)](https://coveralls.io/github/uwdata/draco?branch=master)
[![PyPi](https://img.shields.io/pypi/v/draco.svg)](https://pypi.org/project/draco/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/ambv/black)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=rounded)](https://github.com/prettier/prettier)

Draco is a formal framework for representing design knowledge about effective visualization design as a collection of constraints. You can use Draco to find effective visualization visual designs in Vega-Lite. Draco's constraints are implemented in based on Answer Set Programming (ASP) and solved with the Clingo constraint solver. We also implemented a way to learn weights for the recommendation system directly from the results of graphical perception experiment.

Read our introductory [blog post about Draco](https://medium.com/@uwdata/draco-representing-applying-learning-visualization-design-guidelines-64ce20287e9d) and our [research paper](https://idl.cs.washington.edu/papers/draco/) for more details. Try Draco in the browser at https://uwdata.github.io/draco-editor.

## Status

**There Be Dragons!** This project is in active development and we are working hard on cleaning up the repository and making it easier to use the recommendation model in Draco. If you want to use this right now, please talk to us. More documentation is forthcoming.

## Overview

This repository currently contains:

* [**draco**](https://pypi.org/project/draco/) (pypi) The ASP programs with soft and hard constraints, a python API for [running Draco](https://github.com/uwdata/draco/blob/master/draco/run.py), the [CLI](https://github.com/uwdata/draco/blob/master/draco/cli.py), and the [python wrapper](https://github.com/uwdata/draco/blob/master/draco/js.py) for the **draco-core** API. Additionally includes some [helper functions](https://github.com/uwdata/draco/blob/master/draco/helper.py) that may prove useful.
* [**draco-core**](https://www.npmjs.com/package/draco-core) (npm) Holds a Typescript friendly copy of the ASP programs, and additionally, a Typescript API for all the translation logic of Draco, as described below.
    
### Draco-Core API
    
**vl2asp** *(spec: TopLevelFacetedUnitSpec): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/vl2asp.ts)

>Translates a Vega-Lite specification into a list of ASP Draco facts.

**cql2asp** *(spec: any): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/cql2asp.ts)

>Translates a CompassQL specification into a list of ASP Draco constraints.

**asp2vl** *(facts: string[]): TopLevelFacetedUnitSpec* [<>](https://github.com/uwdata/draco/blob/master/js/src/asp2vl.ts)

>Interprets a list of ASP Draco facts as a Vega-Lite specification.

**data2schema** *(data: any[]): Schema* [<>](https://github.com/uwdata/draco/blob/master/js/src/data2schema.ts)

>Reads a list of rows and generates a schema for the dataset. `data` should be given as a list of dictionaries.

**schema2asp** *(schema: Schema): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/schema2asp.ts)

>Translates a schema into an ASP declaration of the data it describes.

**constraints2json** *(constraintsAsp: string, weightsAsp?: string): Constraint[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/constraints2json.ts)

>Translates the given ASP constraints and matching weights (i.e. for soft constraints) into JSON format.

### Sibling Repositories

Various functionality and extensions are in the following repositories

* [draco-vis](https://github.com/uwdata/draco-vis)
   * A TypeScript/JavaScript version of Draco for use in web applications.

* [draco-learn](https://github.com/uwdata/draco-learn)
   * Runs a learning-to-rank method on results of perception experiments.
   
* [draco-tools](https://github.com/uwdata/draco-tools)
   * UI tools to create annotated datasets of pairs of visualizations, look at the recommendations, and to explore large datasets of example visualizations.
   
* [draco-analysis](https://github.com/uwdata/draco-analysis)
   * Notebooks to analyze the results.

## Installation

### Install Clingo.

You can install Clingo with conda: `conda install -c potassco clingo`. On MacOS, you can alternatively run `brew install clingo`.

### Install node dependencies

`yarn` or `npm install`

You might need to activate a Python 2.7 environment to compile the canvas module.

### Build JS module

`yarn build`

### Python setup

`pip install -r requirements.txt` or `conda install --file requirements.txt`

Install Draco in editable mode. We expect Python 3.

`pip install -e .`

Now you can call the command line tool `draco`. For example `draco --version` or `draco --help`.


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

## Releases

* Make sure everything works!
* Update `__version__` in `draco/__init__.py` and use the right version below.
* `git commit -m "bump version to 0.0.1"`
* Tag the last commit `git tag -a v0.0.1`.
* `git push` and `git push --tags`
* Run `python setup.py sdist upload`.

## Resources

### Related Repositories

Previous prototypes

* https://github.com/uwdata/vis-csp
* https://github.com/domoritz/vis-constraints

Related software

* https://github.com/uwdata/draco-vis
* https://github.com/vega/compassql
* https://github.com/potassco/clingo

### Guides

* https://github.com/potassco/guide/releases/
