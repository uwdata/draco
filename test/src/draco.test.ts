import "jest-extended";
import path from "path";
import { Draco, Result } from "../../src";

describe("Draco Node Runner", () => {
  describe("Options", () => {
    test("default options", () => {
      const result = Draco.run(null, null, [EXAMPLE_PATH]);
      const specs = Result.getBestVegaLiteSpecDictionary(result);

      expect(specs).toBeOneOf(EXAMPLE_OUTPUT_DEFAULT);
    });

    test("weak hard", () => {
      const result = Draco.run(null, { strictHard: false }, [EXAMPLE_PATH]);
      const specs = Result.getBestVegaLiteSpecDictionary(result);

      expect(specs).toBeOneOf(EXAMPLE_OUTPUT_DEFAULT);
    });

    test("no extra encoding generation", () => {
      const result = Draco.run(null, { generateExtraEncodings: false }, [
        EXAMPLE_PATH
      ]);

      const witness = Result.toWitnesses(result)[0];
      const facts = witness.facts.filter(f => f.includes("encoding("));

      expect(facts.length).toBe(2);
    });
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
