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

const ENCODING = {
  "channel": "?",
  "field": "?",
  "type": "?"
}

const BASE_QUERY = {
  "spec": {
    "mark": "?"
  },
  "orderBy": "effectiveness",
  "config": {
    "autoAddCount": true
  }
}

const NUM_FIELDS = [5, 10, 15, 20, 25];
const NUM_ENCODINGS = [1, 2, 3, 4, 5];
const NUM_TRIALS = 20;

const INCLUDE = {
  5: {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
  },
  10: {
    1: true,
    2: true,
    3: true,
    4: true,
    5: false
  },
  15: {
    1: true,
    2: true,
    3: true,
    4: false,
    5: false,
  },
  20: {
    1: true,
    2: true,
    3: true,
    4: false,
    5: false,
  },
  25: {
    1: true,
    2: true,
    3: true,
    4: false,
    5: false,
  }
};

function main() {
  // warmup
  console.log('warming up...');
  run_set(1)

  // actual
  const results = []
  run_set(NUM_TRIALS, results);

  fs.writeFileSync('cql_runtimes.json', JSON.stringify(results, null, 2), 'utf-8');
}

function run_set(numTrials, results = null) {
  for (nfields of NUM_FIELDS) {
    const data = JSON.parse(fs.readFileSync('../data/weball26.json'));

    for (const datum of data) {
      for (let i = FIELD_NAMES.length - 1; i >= nfields; i--) {
        delete datum[FIELD_NAMES[i]];
      }
    }

    const schema =  cql.schema.build(data);

    for (nencodings of NUM_ENCODINGS) {
      if (INCLUDE[nfields][nencodings]) {
        encodings = [];
        for (let i = 0; i < nencodings; i++) {
          const enc = Object.assign({}, ENCODING);
          encodings.push(enc);
        }

        const query = Object.assign({}, BASE_QUERY);
        query['spec']['encodings'] = encodings;

        let total_time = 0;
        for (let i = 0; i < numTrials; i++) {
          const startTime = new Date().getTime();
          const recommendation =  cql.recommend(query, schema);
          const endTime = new Date().getTime();

          total_time += endTime - startTime;
        }

        const avg_time = total_time * 1.0 / numTrials / 1000;

        if (results !== null) {
          results.push({
            'fields': nfields,
            'encodings': nencodings,
            'runtime': avg_time,
            'system': 'cql'
          });

          console.log('fields=' + nfields + ' encodings=' + nencodings + ' query time: ' + avg_time + 's');
        }
      }
    }
  }
}

main();
