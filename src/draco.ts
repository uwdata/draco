import { ConstraintDictionary } from "./model/constraint-dictionary";
import { ResultObject } from "./model/result";

const tmp = require("tmp");
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");
tmp.setGracefulCleanup();

export interface DracoOptions {
  strictHard: boolean;
  generate: boolean;
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

    if (program) {
      fs.writeFileSync(tmpObj.name, program);
      resolvedFiles = resolvedFiles.concat([tmpObj.name]);
    }

    const result = spawnSync(
      "clingo",
      ["--outf=2", "--quiet=1,2,2", ...resolvedFiles],
      {
        encoding: "utf-8"
      }
    );

    return JSON.parse(result.output[1]);
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

function resolvePathToModelProgram(file: string) {
  return path.resolve(__dirname, "../model/program", file);
}
