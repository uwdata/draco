import "jest-extended";
import { DataObject, Draco, Result } from "../../src";
const path = require("path");

export function testFile(file: string, dir: string, data: DataObject) {
  const input = path.resolve(dir, `${file}.lp`);
  const outputName = `${file}.json`;
  const expected = require(path.resolve(dir, outputName));

  const result = Draco.run(data.asp, null, [input]);
  const specs = Result.getBestVegaLiteSpecDictionary(result);

  const facts = Result.toWitnesses(result)[0].facts;

  // console.log("Hard Violations", Facts.getHardViolations(facts));
  // console.log("Soft Violations", Facts.getSoftViolations(facts));
  // console.log("View Facts", Facts.getViewFacts(facts));

  expect(specs).toBeOneOf(expected);
}
