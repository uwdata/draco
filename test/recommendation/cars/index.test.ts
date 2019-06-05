import { readdirSync } from "fs";
import "jest-extended";
import path from "path";
import { Data } from "../../../src";
import { testFile } from "../util";

describe("Cars", () => {
  readdirSync(path.resolve(__dirname, "./")).forEach(file => {
    const [name, ext] = file.split(".");
    if (ext === "lp") {
      test(name, () => {
        testFile(name, __dirname, DATA);
      });
    }
  });
});

const CARS = require(path.resolve(__dirname, "../../../data/cars.json"));

const DATA = Data.fromArray(CARS);
