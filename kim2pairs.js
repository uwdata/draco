const fs = require("fs");
const path = require("path");
const { Facts, Draco, Result } = require(path.resolve(
  __dirname,
  "build/bundle.js"
));

const kim = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "kim2018.json"))
);

process.stdout.write("Converting...");

const pairs = kim.data.map((yh, i) => {
  process.stdout.clearLine();
  process.stdout.cursorTo(0);

  process.stdout.write(`${i} / ${kim.data.length}`);
  const { negative, positive } = Facts.fromYH(yh);

  const negProg = negative.join(".\n") + ".";
  const negRes = Draco.run(negProg, {
    generate: false,
    models: 1,
    generateData: false,
    optimize: false
  });

  const posProg = positive.join(".\n") + ".";
  const posRes = Draco.run(posProg, {
    generate: false,
    models: 1,
    generateData: false,
    optimize: false
  });

  return {
    pair_id: i + 1,
    left: {
      draco: JSON.stringify(Result.toWitnesses(negRes)[0].facts)
    },
    right: {
      draco: JSON.stringify(Result.toWitnesses(posRes)[0].facts)
    },
    comparator: ">"
  };
});

fs.writeFileSync(
  path.resolve(__dirname, "kimpairs.json"),
  JSON.stringify(pairs)
);
