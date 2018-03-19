#!/usr/bin/env node

const cql = require('compassql');
const dl = require('datalib');
const fs = require('fs');

var path = require('path');

// the folder containing input partial specs
const inputDir = 'data/compassql_examples/input/';
// the folder for output full specs
const outputDir = 'data/compassql_examples/output/';

files = fs.readdirSync(inputDir);

for (var i = 0; i < files.length; i ++) {

  console.log('[OK] Processing ' + files[i]);

  input = path.join(inputDir, files[i]);
  output = path.join(outputDir, files[i]);

  // read spec
  var raw_spec = fs.readFileSync(input, 'utf8');
  var spec = JSON.parse(raw_spec);

  // compile data schema for compassql
  var data = dl.json(spec.data.url);
  var schema = cql.schema.build(data);

  const query = {
    spec,
    chooseBy: 'effectiveness',
    config: { autoAddCount: true }
  };

  const recommendation = cql.recommend(query, schema);

  const vlSpec = recommendation.result.items[0].toSpec();

  fs.writeFileSync(output, JSON.stringify(vlSpec, null, 2), 'utf8');
}

