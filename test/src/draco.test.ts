import path from "path";
import { Draco, Result, Witness } from "../../src";

describe("Draco Node Runner", () => {
  describe("Options", () => {
    test("default options", () => {
      const result = Draco.run(null, null, [EXAMPLE_PATH]);
      const witnesses = Result.toWitnesses(result);
      const specs = Witness.toVegaLiteSpecDictionary(witnesses[0]);

      expect(specs).toBeOneOf(EXAMPLE_OUTPUT_DEFAULT);
    });

    test("weak hard", () => {});
  });
});

const EXAMPLE_PATH = path.resolve(__dirname, "../../examples/scatter.lp");

const EXAMPLE_OUTPUT_DEFAULT = [
  {
    view1: {
      mark: "point",
      encoding: {
        x: {
          field: "horsepower",
          type: "quantitative",
          scale: { zero: true }
        },
        y: {
          field: "acceleration",
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
          field: "acceleration",
          type: "quantitative",
          scale: { zero: true }
        },
        y: {
          field: "horsepower",
          type: "quantitative",
          scale: { zero: true }
        }
      }
    }
  }
];
