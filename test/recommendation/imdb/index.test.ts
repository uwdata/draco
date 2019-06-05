import { readdirSync } from "fs";
import "jest-extended";
import path from "path";
import { Data } from "../../../src";
import { testFile } from "../util";

const INPUTS = readdirSync(path.resolve(__dirname, "./"));

describe("IMDB", () => {
  INPUTS.forEach(file => {
    const [name, ext] = file.split(".");
    if (ext === "lp") {
      test(name, () => {
        testFile(name, __dirname, DATA);
      });
    }
  });
});

const MOVIES = require(path.resolve(__dirname, "../../../data/movies.json"));

const DATA = Data.fromArray(MOVIES);
