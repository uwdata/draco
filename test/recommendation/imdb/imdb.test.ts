import { readFileSync } from "fs";
import path from "path";
import { Data, Draco, Result } from "../../../src";

describe("IMDB", () => {
  test("line", () => {
    const a = DATA;
    const program = Draco.getProgram(DATA, LINE.query);
    const result = Draco.run(program, { strictHard: false });
    const specs = Result.getBestVegaLiteSpecDictionary(result);

    expect(specs).toBeOneOf(LINE.specs);
  });
});

const MOVIES = require(path.resolve(__dirname, "../../../data/movies.json"));

const DATA = Data.fromArray(MOVIES);

const LINE = {
  query: readFileSync(path.resolve(__dirname, "./line.lp")).toString(),
  specs: [
    {
      view1: {
        mark: "bar",
        encoding: {
          x: {
            type: "quantitative",
            aggregate: "count",
            scale: {
              zero: true
            }
          },
          y: {
            type: "temporal",
            field: "Release_Date"
          }
        }
      }
    }
  ]
};
