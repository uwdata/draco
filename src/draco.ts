import { DataObject } from "./data";
import { Facts } from "./model";
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
}

export const DEFAULT_OPTIONS = {
  strictHard: true,
  generate: true
};

export class Draco {
  static run(
    program?: string,
    options?: DracoOptions,
    files?: string[]
  ): ResultObject {
    let resolvedFiles = files ? files : [];
    const resolvedOptions = options
      ? Object.assign(Object.assign({}, DEFAULT_OPTIONS), options)
      : DEFAULT_OPTIONS;

    if (resolvedOptions.generate && resolvedOptions.strictHard) {
      resolvedFiles.push(resolvePathToModelProgram("default.lp"));
    } else if (!resolvedOptions.generate && !resolvedOptions.strictHard) {
      resolvedFiles.push(
        resolvePathToModelProgram("no_generation_weak_hard.lp")
      );
    } else if (resolvedOptions.generate && !resolvedOptions.strictHard) {
      resolvedFiles.push(resolvePathToModelProgram("weak_hard.lp"));
    } else if (!resolvedOptions.generate && resolvedOptions.strictHard) {
      resolvedFiles.push(resolvePathToModelProgram("no_generation.lp"));
    }

    const tmpObj = tmp.fileSync({ postfix: ".lp" });

    let programFile;
    if (program) {
      fs.writeFileSync(tmpObj.name, program);
      programFile = tmpObj.name;
      resolvedFiles = resolvedFiles.concat([tmpObj.name]);
    }

    const out = runClingoSync(resolvedFiles);

    const result = JSON.parse(out.output[1]);

    if (Result.isSat(result)) {
      return result;
    }

    const debugFiles = [programFile];

    if (resolvedOptions.generate && resolvedOptions.strictHard) {
      debugFiles.push(resolvePathToModelProgram("weak_hard.lp"));
    } else if (!resolvedOptions.generate && !resolvedOptions.strictHard) {
      debugFiles.push(resolvePathToModelProgram("no_generation_weak_hard.lp"));
    } else if (resolvedOptions.generate && !resolvedOptions.strictHard) {
      debugFiles.push(resolvePathToModelProgram("weak_hard.lp"));
    } else if (!resolvedOptions.generate && resolvedOptions.strictHard) {
      debugFiles.push(resolvePathToModelProgram("no_generation_weak_hard.lp"));
    }

    const debugOut = runClingoSync(debugFiles);
    const debugResult = JSON.parse(debugOut.output[1]);

    const debugWitness = Result.toWitnesses(debugResult)[0];
    const hardViolations = Facts.getHardViolations(debugWitness.facts);

    throw new Error(
      `Spec violates the following hard constraints
${JSON.stringify(hardViolations, null, 2)}`
    );
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

function runClingoSync(files: string[]): any {
  return spawnSync("clingo", ["--outf=2", "--quiet=1,2,2", ...files], {
    encoding: "utf-8"
  });
}

function resolvePathToModelProgram(file: string): string {
  return path.resolve(__dirname, "../model/program", file);
}
