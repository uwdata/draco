import { readFileSync } from "fs";
import path from "path";
import { Data, Draco, Result } from "../../../src";

describe("Cars", () => {
  test("scatterplot", () => {
    const program = Draco.getProgram(DATA, SCATTER.query);

    const result = Draco.run(program);
    const specs = Result.getBestVegaLiteSpecDictionary(result);

    expect(specs).toBeOneOf(SCATTER.specs);
  });
});

const CARS = require(path.resolve(__dirname, "../../../data/cars.json"));

const DATA = Data.fromArray(CARS);

const SCATTER = {
  query: readFileSync(path.resolve(__dirname, "./scatter.lp")).toString(),
  specs: [
    {
      view1: {
        mark: "point",
        encoding: {
          x: {
            field: "Horsepower",
            type: "quantitative",
            scale: { zero: true }
          },
          y: {
            field: "Acceleration",
            type: "quantitative",
            scale: { zero: true }
          }
        }
      }
    },
    {
      view1: {
        mark: "point",
        encoding: {
          x: {
            field: "Acceleration",
            type: "quantitative",
            scale: { zero: true }
          },
          y: {
            field: "Horsepower",
            type: "quantitative",
            scale: { zero: true }
          }
        }
      }
    }
  ]
};
