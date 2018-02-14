#!/usr/bin/env node

const cql = require('compassql');
const dl = require('datalib');
const fs = require('fs')

// default schema: cars
const data = dl.csv('data/weather_data.csv');
const schema = cql.schema.build(data);

const inputDir = "__tmp__/cql_specs"
const outputDir = "__tmp__/compassql_out"

fs.readdir(inputDir, function(err, items) {
  for (var i = 0; i < items.length; i++) {
    fs.readFile(inputDir + '/' + items[i], 'utf8', function (err, data) {
      if (err) throw err; // we'll not consider error handling for now
      var spec = JSON.parse(data);
      const query = {
        spec,
        chooseBy: 'effectiveness'
      };
      const recommendation = cql.recommend(query, schema, {
        defaultSpecConfig: null,
        autoAddCount: true
      });

      console.log(recommendation)

      //const vlSpec = recommendation.result.items[0].toSpec();
      //console.log(vlSpec);
    });
    break;
  }
});

/*
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
}*/
