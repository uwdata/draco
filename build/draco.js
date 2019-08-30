import { Facts } from "./model";
import { ConstraintDictionary } from "./model/constraint-dictionary";
import { Result } from "./model/result";
const tmp = require("tmp");
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");
tmp.setGracefulCleanup();
export const DEFAULT_OPTIONS = {
    strictHard: true,
    generate: true,
    generateExtraEncodings: true,
    optimize: true,
    generateData: false
};
export class Draco {
    static run(program, options, files) {
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
    static runDebug(program, options, files) {
        const result = Draco.run(program, { strictHard: false }, files);
        if (!Result.isSat(result)) {
            return [];
        }
        const witness = Result.toWitnesses(result)[0];
        return Facts.getHardViolations(witness.facts);
    }
    static getProgram(data, query) {
        return `${data.asp}
${query}`;
    }
    static getSoftConstraints() {
        const softDir = path.resolve(__dirname, "../model/view/soft");
        const subtypeDirs = fs
            .readdirSync(softDir)
            .filter(f => fs.statSync(path.join(softDir, f)).isDirectory());
        const result = subtypeDirs.reduce((dict, dir) => {
            const prefFile = path.resolve(softDir, dir, "pref.lp");
            const prefContents = fs.readFileSync(prefFile, "utf8");
            const weightFile = path.resolve(softDir, dir, "weight.lp");
            const weightContents = fs.readFileSync(weightFile, "utf8");
            const constraints = ConstraintDictionary.fromAsp(prefContents, weightContents);
            return {
                ...dict,
                ...constraints
            };
        }, {});
        return result;
    }
}
function runClingoSync(files, options) {
    return spawnSync("clingo", ["--outf=2", "--quiet=1,2,2", ...options, ...files], {
        encoding: "utf-8"
    });
}
function resolvePathToModelProgram(file) {
    return path.resolve(__dirname, "../model/program", file);
}
function resolvePathToModelView(file) {
    return path.resolve(__dirname, "../model/view", file);
}
function getFilesFromOptions(options) {
    const result = [];
    const resolvedOptions = options
        ? Object.assign(Object.assign({}, DEFAULT_OPTIONS), options)
        : DEFAULT_OPTIONS;
    const { generate, generateExtraEncodings, strictHard, optimize, generateData } = resolvedOptions;
    if (generate && generateExtraEncodings && strictHard && optimize) {
        result.push(resolvePathToModelProgram("default.lp"));
    }
    else {
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
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZHJhY28uanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyIuLi9zcmMvZHJhY28udHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQ0EsT0FBTyxFQUFFLEtBQUssRUFBZSxNQUFNLFNBQVMsQ0FBQztBQUM3QyxPQUFPLEVBQUUsb0JBQW9CLEVBQUUsTUFBTSwrQkFBK0IsQ0FBQztBQUNyRSxPQUFPLEVBQUUsTUFBTSxFQUFnQixNQUFNLGdCQUFnQixDQUFDO0FBRXRELE1BQU0sR0FBRyxHQUFHLE9BQU8sQ0FBQyxLQUFLLENBQUMsQ0FBQztBQUMzQixNQUFNLEVBQUUsR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7QUFDekIsTUFBTSxJQUFJLEdBQUcsT0FBTyxDQUFDLE1BQU0sQ0FBQyxDQUFDO0FBQzdCLE1BQU0sRUFBRSxTQUFTLEVBQUUsR0FBRyxPQUFPLENBQUMsZUFBZSxDQUFDLENBQUM7QUFDL0MsR0FBRyxDQUFDLGtCQUFrQixFQUFFLENBQUM7QUFhekIsTUFBTSxDQUFDLE1BQU0sZUFBZSxHQUFHO0lBQzdCLFVBQVUsRUFBRSxJQUFJO0lBQ2hCLFFBQVEsRUFBRSxJQUFJO0lBQ2Qsc0JBQXNCLEVBQUUsSUFBSTtJQUM1QixRQUFRLEVBQUUsSUFBSTtJQUNkLFlBQVksRUFBRSxLQUFLO0NBQ3BCLENBQUM7QUFFRixNQUFNLE9BQU8sS0FBSztJQUNoQixNQUFNLENBQUMsR0FBRyxDQUNSLE9BQWdCLEVBQ2hCLE9BQXNCLEVBQ3RCLEtBQWdCO1FBRWhCLElBQUksYUFBYSxHQUFHLEtBQUssQ0FBQyxDQUFDLENBQUMsS0FBSyxDQUFDLENBQUMsQ0FBQyxFQUFFLENBQUM7UUFFdkMsYUFBYSxHQUFHLGFBQWEsQ0FBQyxNQUFNLENBQUMsbUJBQW1CLENBQUMsT0FBTyxDQUFDLENBQUMsQ0FBQztRQUVuRSxNQUFNLE1BQU0sR0FBRyxHQUFHLENBQUMsUUFBUSxDQUFDLEVBQUUsT0FBTyxFQUFFLEtBQUssRUFBRSxDQUFDLENBQUM7UUFFaEQs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