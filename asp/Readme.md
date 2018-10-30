# Draco Knowledge Base

This directory contains the Draco knowledge base as [answer set programs](https://en.wikipedia.org/wiki/Answer_set_programming). These files can be used with the Draco Python and JavaScript Libraries.

## Draco ASP files

* `define.lp` declares the domains to visualization attributes and defines useful helper functions. You almost definitely want this file.
* `generate.lp` sets up the search space.
* `hard.lp` restricts the search space to only well-formed and expressive specifications.
* `soft.lp` defines soft constraints in the form of `violation/1` and `violation/2` predicates. By themselves, these predicates don't change the search.
* `weights.lp` declares default (hand tuned) weights similar to those in CompassQL. There is one constant for each rule in `soft.lp`. We use this file to generate `assign_weights.lp`.
* `learned_weights.lp` declares the weights learned form experimental data as described in the paper.
* `assign_weights.lp` uses `violation_weight/2` to assign every `violation` predicate a weight. These weights usually come from `weights.lp`. This file is generated from `weights.lp`.
* `optimize.lp` defined the minimization function.
* `output.lp` declares which predicates should be shown when an answer set is printed.

## Helper collections

* `_all.lp` collects all files necessary to find optimal encodings with Draco
* `_validate.lp` uses Draco to validate an encoding. Only applies hard constraints (well-formedness and expressiveness).
* `_violations.lp` uses Draco to find violations of soft constraints. This is essentially Draco without optimization.
* `_apt.lp` applies Draco-APT
* `_kim2018.lp` applies Draco-Learn to the visualization of the form that Kim et al. evaluated. Uses `weights_learned.lp` and `kim2018.lp`.
* `_saket2018.lp` applies Draco-Learn to the visualization of the form that Saket et al. evaluated. Uses `weights_learned.lp` and `saket2018.lp`.

## Usage

Call `clingo` on these files to use Draco for automated visualization design, validation, or exploring the space of possible encodings. You can either use the provided weight files (`weights.lp` or `learned_weights.lp`) or provide/override weights by passing `-c NAME=WEIGHT` to Clingo. Use `--quiet` to reduce noise in the output, `--project` to only show distinctively different encodings, `-n` to limit the number of generated encodings, and `--warn=no-atom-undefined` to silence warnings. For a full list of command line options, read the guide at https://github.com/potassco/guide/releases/download/v2.1.0/guide.pdf.

## Examples

### Encoding with two quantitative fields

Draco uses point marks for encoding with two quantitative fields. This creates a scatterplot.

```
$ clingo asp/_all.lp asp/examples/scatter.lp --quiet=1
clingo version 5.2.2
Reading from asp/_all.lp ...
Solving...
Answer: 55
violation(encoding,e0) violation(encoding,e1) violation(encoding_field,e0) violation(encoding_field,e1) field(e0,acceleration) field(e1,horsepower) channel(e0,x) channel(e1,y) type(e0,quantitative) type(e1,quantitative) zero(e0) zero(e1) mark(point) violation(c_c_point,_placeholder) violation(type_q,e0) violation(type_q,e1) violation(continuous_x,e0) violation(continuous_y,e1)
Optimization: 12
OPTIMUM FOUND

Models       : 55
  Optimum    : yes
Optimization : 12
Calls        : 1
Time         : 0.215s (Solving: 0.02s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.112s
```

### Strip plot from incomplete data

In this query, we only specify that we want to use a quantitative field. Draco synthesizes a strip plot with the tick mark.

```
$ clingo asp/_all.lp asp/examples/strip.lp --quiet=1
clingo version 5.2.2
Reading from asp/_all.lp ...
Solving...
Answer: 9
field(e0,horsepower) type(e0,quantitative) violation(encoding,e0) violation(encoding_field,e0) violation(type_q,e0) channel(e0,x) zero(e0) mark(tick) violation(c_d_tick,_placeholder) violation(continuous_x,e0)
Optimization: 6
OPTIMUM FOUND

Models       : 9
  Optimum    : yes
Optimization : 6
Calls        : 1
Time         : 0.194s (Solving: 0.02s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.117s
```

### Histogram from incomplete specification

In the query, we only specify that we want to use a binned field. Draco completes the rest.

```
$ clingo asp/_all.lp asp/examples/histogram.lp --quiet=1
clingo version 5.2.2
Reading from asp/_all.lp ...
Solving...
Answer: 4
channel(e0,x) field(e0,horsepower) violation(encoding,e0) violation(encoding_field,e0) bin(e0,10) channel(5,y) type(e0,quantitative) type(5,quantitative) aggregate(5,count) zero(5) mark(bar) violation(c_d_no_overlap_bar,_placeholder) violation(aggregate,5) violation(bin,e0) violation(encoding,5) violation(type_q,e0) violation(type_q,5) violation(continuous_y,5) violation(ordered_x,e0) violation(aggregate_count,5)
Optimization: 13
OPTIMUM FOUND

Models       : 4
  Optimum    : yes
Optimization : 13
Calls        : 1
Time         : 0.127s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.076s
```

### APT demo

```
$ clingo asp/_apt.lp asp/examples/apt.lp --opt-mode=optN --quiet=1 --project -c max_extra_encs=0 --warn=no-atom-undefined
clingo version 5.2.2
Reading from asp/_apt.lp ...
Solving...
Answer: 1
mark(point) channel(e0,x) channel(e1,y) channel(e2,color) channel(e3,size)
Optimization: 1 1 2 3
Answer: 2
mark(point) channel(e0,y) channel(e1,x) channel(e2,color) channel(e3,size)
Optimization: 1 1 2 3
OPTIMUM FOUND

Models       : 9
  Optimum    : yes
  Optimal    : 2
Optimization : 1 1 2 3
Calls        : 1
Time         : 0.127s (Solving: 0.01s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.080s
```

### Use Draco with learned weights

Instead of using Draco with default weights, we use Draco with learned weights.

#### Kim et al. 2018 demo

Here, we query for the optimal specification within the space that was studies by Kim et al.

```
$ clingo asp/_kim2018.lp asp/examples/kim2018.lp --opt-mode=optN --quiet=1 --project
clingo version 5.2.2
Reading from asp/_kim2018.lp ...
Solving...
Answer: 1
mark(point) channel(enc_n,x) channel(enc_q1,y) channel(enc_q2,color)
Optimization: -259
OPTIMUM FOUND

Models       : 6
  Optimum    : yes
Optimization : -259
Calls        : 1
Time         : 0.156s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.091s
```

#### Saket et al. 2018 demo

Similar to above but for Saket at al.

```
$ clingo asp/_saket2018.lp asp/examples/saket2018.lp --opt-mode=optN --quiet=1 --project
clingo version 5.2.2
Reading from asp/_saket2018.lp ...
Solving...
Answer: 1
channel(e0,y) channel(e1,x) mark(line)
Optimization: -1289
OPTIMUM FOUND

Models       : 4
  Optimum    : yes
Optimization : -1289
Calls        : 1
Time         : 0.120s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.105s
```

## Use Draco to find violations of soft constraints

```
$ clingo asp/_violations.lp asp/examples/valid.lp --warn=no-atom-undefined
clingo version 5.2.2
Reading from asp/_violations.lp ...
Solving...
Answer: 1
violation(c_c_point,_placeholder) violation(encoding,e0) violation(encoding,e1) violation(encoding_field,e0) violation(encoding_field,e1) violation(type_q,e0) violation(type_q,e1) violation(continuous_x,e0) violation(continuous_y,e1)
SATISFIABLE

Models       : 1
Calls        : 1
Time         : 0.050s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.044s
```

## Use Draco find validate an encoding

Here, we test an encoding that is invalid as it tries to encode a string field as quantitative.

```
$ clingo asp/_validate.lp asp/examples/invalid.lp --warn=no-atom-undefined
clingo version 5.2.2
Reading from asp/_validate.lp ...
Solving...
UNSATISFIABLE

Models       : 0
Calls        : 1
Time         : 0.019s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.018s
```

## Enumerate a design space

We can use Draco to enumerate all specifications within some space. For example, we might want to see all visualizations that could be created for some dataset with the space of the study from Kim et al. The command line option `-n 0` tells Clingo to print all answer sets.

```
$ clingo asp/_enumerate.lp asp/kim2018.lp asp/examples/data.lp -n 0 --project
clingo version 5.2.2
Reading from asp/_enumerate.lp ...
Solving...
Answer: 1
channel(3,x) channel(5,y) mark(point) type(3,quantitative) zero(3) type(5,quantitative) zero(5) type(4,nominal) channel(4,color) field(3,q1) field(5,q2) field(4,o1)
Answer: 2
channel(3,x) channel(5,y) mark(point) type(3,quantitative) zero(3) type(5,quantitative) zero(5) type(4,nominal) channel(4,color) field(5,q1) field(3,q2) field(4,o1)
Answer: 3
channel(3,x) channel(5,y) mark(point) type(3,quantitative) zero(3) type(5,quantitative) zero(5) type(4,nominal) channel(4,color) field(4,q1) field(5,q1) field(3,q2)
... [omitted output]
channel(5,x) channel(4,y) mark(point) type(4,quantitative) zero(4) type(5,quantitative) zero(5) type(3,nominal) channel(3,color) field(3,q1) field(4,q1) field(5,q2)
Answer: 490
channel(5,x) channel(4,y) mark(point) type(4,quantitative) zero(4) type(5,quantitative) zero(5) type(3,nominal) channel(3,row) field(3,q1) field(4,q1) field(5,q2)
Answer: 491
channel(5,x) channel(4,y) mark(point) type(3,quantitative) zero(3) type(4,quantitative) zero(4) type(5,nominal) channel(3,color) field(3,q1) field(4,q1) field(5,q2)
Answer: 492
channel(5,x) channel(4,y) mark(point) type(3,quantitative) zero(3) type(4,quantitative) zero(4) type(5,nominal) channel(3,size) field(3,q1) field(4,q1) field(5,q2)
SATISFIABLE

Models       : 492
Calls        : 1
Time         : 0.651s (Solving: 0.59s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.086s
```

## Benchmark

Here, we use Draco to find the optimal specification with 5 encodings for a dataset with 24 fields. On a 2014 MBP, Clingo finds the optimal answer in less than half a second.

```
$ clingo asp/_all.lp asp/examples/benchmark.lp --quiet=2 --warn=no-atom-undefined -c max_extra_encs=0
clingo version 5.2.2
Reading from asp/_all.lp ...
Solving...
OPTIMUM FOUND

Models       : 29
  Optimum    : yes
Optimization : 37
Calls        : 1
Time         : 0.216s (Solving: 0.12s 1st Model: 0.00s Unsat: 0.12s)
CPU Time     : 0.166s
```
