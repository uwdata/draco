// USAGE:
// node time_cql.js <nfields> <nencodings>

const cql = require('compassql');
const fs = require('fs');

const FIELD_NAMES = [
  'Candidate_Identification',
  'Candidate_Name',
  'Incumbent_Challenger_Status',
  'Party_Code',
  'Party_Affiliation',
  'Total_Receipts',
  'Transfers_from_Authorized_Committees',
  'Total_Disbursements',
  'Transfers_to_Authorized_Committees',
  'Beginning_Cash',
  'Ending_Cash',
  'Contributions_from_Candidate',
  'Loans_from_Candidate',
  'Other_Loans',
  'Candidate_Loan_Repayments',
  'Other_Loan_Repayments',
  'Debts_Owed_By',
  'Total_Individual_Contributions',
  'Candidate_State',
  'Candidate_District',
  'Contributions_from_Other_Political_Committees',
  'Contributions_from_Party_Committees',
  'Coverage_End_Date',
  'Refunds_to_Individuals',
  'Refunds_to_Committees'
]

// These are the encoding enumerations that draco supports
const ENCODING = {
  "channel": "?",
  "field": "?",
  "type": "?",
  "aggregate": "?",
  "bin": "?",
  "stack": "?"
}

const BASE_QUERY = {
  "spec": {
    "mark": "?"
  },
  "chooseBy": "effectiveness",
  "config": {
    "autoAddCount": true
  }
}

const NUM_TRIALS = 20;

const OUT_FILE = 'cql_runtimes.json';

const nfields = parseInt(process.argv[2]);
const nencodings = parseInt(process.argv[3]);

function main() {
  // warmup
  run_set(1)

  // actual
  const results = []
  run_set(NUM_TRIALS, nfields, nencodings,results);

  let existing = []
  if (fs.existsSync(OUT_FILE)) {
    existing = JSON.parse(fs.readFileSync(OUT_FILE));
  }

  const all_results = existing.concat(results);
  fs.writeFileSync('cql_runtimes.json', JSON.stringify(all_results, null, 2), 'utf-8');
}

function run_set(numTrials, nfields, nencodings, results = null) {
  const data = JSON.parse(fs.readFileSync('../data/weball26.json'));

  for (const datum of data) {
    for (let i = FIELD_NAMES.length - 1; i >= nfields; i--) {
      delete datum[FIELD_NAMES[i]];
    }
  }

  const schema =  cql.schema.build(data);

  encodings = [];
  for (let i = 0; i < nencodings; i++) {
    const enc = Object.assign({}, ENCODING);
    encodings.push(enc);
  }

  const query = Object.assign({}, BASE_QUERY);
  query['spec']['encodings'] = encodings;

  let totalTime = 0;
  for (let i = 0; i < numTrials; i++) {
    const startTime = new Date().getTime();
    const recommendation =  cql.recommend(query, schema);
    const endTime = new Date().getTime();

    const delta = endTime - startTime;
    totalTime += delta;

    if (results !== null) {
      results.push({
        'fields': nfields,
        'encodings': nencodings,
        'runtime': delta,
        'system': 'cql'
      });
    }
  }

  const avgTime = totalTime * 1.0 / numTrials / 1000;

  if (results !== null) {
    console.log('CQL  :: fields=' + nfields + ' encodings=' + nencodings + ' avg_query_time: ' + avgTime + 's');
  }
}

main();
