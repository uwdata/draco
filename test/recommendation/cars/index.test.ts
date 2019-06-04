import { readdirSync } from "fs";
import "jest-extended";
import path from "path";
import { Data, Draco, Result } from "../../../src";

describe("Cars", () => {
  readdirSync(path.resolve(__dirname, "./")).forEach(file => {
    const [name, ext] = file.split(".");
    if (ext === "lp") {
      test(name, () => {
        const input = path.resolve(__dirname, file);
        const output = `${name}.json`;
        const expected = require(path.resolve(__dirname, output));

        const result = Draco.run(DATA.asp, null, [input]);
        const specs = Result.getBestVegaLiteSpecDictionary(result);

        expect(specs).toBeOneOf(expected);
      });
    }
  });
});

const CARS = require(path.resolve(__dirname, "../../../data/cars.json"));

const DATA = Data.fromArray(CARS);
