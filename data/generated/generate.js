#!/usr/bin/env node

const cql = require('compassql');
const dl = require('datalib');
const fs = require('fs')

// default schema: cars
const data = dl.csv('examples/data/cars.csv');
const schema = cql.schema.build(data);

// base query (just a shortcut so we don't have to write as much)
const base = {
  data: {url: 'examples/data/cars.csv'},
  mark: '?',
}

const specs = [{
    // should use a bar
    ...base,
    encodings: [
      {
        channel: 'x',
        aggregate: 'mean',
        field: 'horsepower',
        type: 'quantitative'
      }, {
        channel: 'y',
        field: 'cylinders',
        type: 'ordinal'
      }
    ]
  }, {
    // scatterplot
    ...base,
    encodings: [
      {
        channel: '?',
        field: 'horsepower'
      }, {
        channel: '?',
        field: 'acceleration'
      }
    ]
  }, {
    // bar chart with aggregation
    ...base,
    mark: '?',
    encodings: [
      {
        channel: '?',
        aggregate: 'mean',
        field: 'horsepower'
      }, {
        channel: '?',
        field: 'cylinders'
      }
    ]
  }, {
    // strip plot
    ...base,
    mark: '?',
    encodings: [
      {
        channel: '?',
        field: 'horsepower'
      }
    ]
  }
]

// generate recommendation for each spec above
let i = 0;
for (const spec of specs) {
  i++;

  console.info(`Processing "cql_${i}.json"`);

  // write the query spec
  fs.writeFileSync(`data/input/cql_${i}.json`, JSON.stringify(spec, null, 2), 'utf8');

  const query = {
    spec,
    chooseBy: 'effectiveness'
  };

  const recommendation = cql.recommend(query, schema, {
      defaultSpecConfig: null,
      autoAddCount: true
    });

  const vlSpec = recommendation.result.items[0].toSpec()

  // write recommendation
  fs.writeFileSync(`data/output/cql_${i}.json`, JSON.stringify(vlSpec, null, 2), 'utf8');
}
