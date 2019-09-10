import { DataObject } from "./data";
import { Facts, FactsObject } from "./model";
import { ConstraintDictionary } from "./model/constraint-dictionary";
import { Result, ResultObject } from "./model/result";

const tmp = require("tmp");
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");
tmp.setGracefulCleanup();

export interface DracoOptions {
  strictHard?: boolean;
  generate?: boolean;
  generateExtraEncodings?: boolean;
  optimize?: boolean;
  generateData?: boolean;
  models?: number;
  randomFreq?: number;
  randomSeed?: number;
}

export const DEFAULT_OPTIONS = {
  strictHard: true,
  generate: true,
  generateExtraEncodings: true,
  optimize: true,
  generateData: false
};

export class Draco {
  static run(
    program?: string,
    options?: DracoOptions,
    files?: string[]
  ): ResultObject {
    let resolvedFiles = files ? files : [];

    resolvedFiles = resolvedFiles.concat(getFilesFromOptions(options));

    const tmpObj = tmp.fileSync({ postfix: ".lp" });

    if (program) {
      fs.writeFileSync(tmpObj.name, program);
      resolvedFiles = resolvedFiles.concat([tmpObj.name]);
    }

    const opt = [];
    if (options) {
      if (options.models !== undefined) {
        opt.push(`--models=${options.models}`);
      }

      if (options.randomFreq !== undefined) {
        // opt.push(`--sign-def=3`);
        opt.push(`--rand-freq=${options.randomFreq}`);
      }

      if (options.randomSeed !== undefined) {
        opt.push(`--seed=${options.randomSeed}`);
      }
    }

    const out = runClingoSync(resolvedFiles, opt);

    const result = JSON.parse(out.output[1]);

    return result;
  }

  static runDebug(
    program?: string,
    options?: DracoOptions,
    files?: string[]
  ): FactsObject {
    const result = Draco.run(program, { ...options, strictHard: false }, files);
    if (!Result.isSat(result)) {
      return [];
    }

    const witness = Result.toWitnesses(result)[0];
    return Facts.getHardViolations(witness.facts);
  }

  static getProgram(data: DataObject, query: string): string {
    return `${data.asp}
${query}`;
  }

  static getSoftConstraints(): ConstraintDictionary {
    const softDir = path.resolve(__dirname, "../model/view/soft");
    const subtypeDirs = fs
      .readdirSync(softDir)
      .filter(f => fs.statSync(path.join(softDir, f)).isDirectory());

    const result = subtypeDirs.reduce((dict, dir) => {
      const prefFile = path.resolve(softDir, dir, "pref.lp");
      const prefContents = fs.readFileSync(prefFile, "utf8");

      const weightFile = path.resolve(softDir, dir, "weight.lp");
      const weightContents = fs.readFileSync(weightFile, "utf8");

      const constraints = ConstraintDictionary.fromAsp(
        prefContents,
        weightContents
      );

      return {
        ...dict,
        ...constraints
      };
    }, {});

    return result;
  }
}

function runClingoSync(files: string[], options: string[]): any {
  return spawnSync(
    "clingo",
    ["--outf=2", "--quiet=1,2,2", ...options, ...files],
    {
      encoding: "utf-8"
    }
  );
}

function resolvePathToModelProgram(file: string): string {
  return path.resolve(__dirname, "../model/program", file);
}

function resolvePathToModelView(file: string): string {
  return path.resolve(__dirname, "../model/view", file);
}

function getFilesFromOptions(options: DracoOptions): string[] {
  const result = [];

  const resolvedOptions = options
    ? Object.assign(Object.assign({}, DEFAULT_OPTIONS), options)
    : DEFAULT_OPTIONS;

  const {
    generate,
    generateExtraEncodings,
    strictHard,
    optimize,
    generateData
  } = resolvedOptions;

  if (generate && generateExtraEncodings && strictHard && optimize) {
    result.push(resolvePathToModelProgram("default.lp"));
  } else {
    result.push(resolvePathToModelProgram("../data/index.lp"));
    result.push(resolvePathToModelView("program/base.lp"));

    if (generate) {
      result.push(resolvePathToModelView("generate.lp"));
    }

    if (generateExtraEncodings) {
      result.push(resolvePathToModelView("generate_extra_encodings.lp"));
    }

    if (strictHard) {
      result.push(resolvePathToModelView("hard_integrity.lp"));
    }

    if (optimize) {
      result.push(resolvePathToModelView("optimize.lp"));
    }
  }

  if (generateData) {
    result.push(resolvePathToModelProgram("../data/generate.lp"));
    result.push(resolvePathToModelProgram("../data/grammar.lp"));
  }

  return result;
}