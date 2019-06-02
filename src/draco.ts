import { ConstraintDictionary } from './constraint-dictionary';
import { ResultObject } from './result';

const tmp = require('tmp');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawnSync } = require('child_process');
tmp.setGracefulCleanup();

export class Draco {
  static run(program?: string, files?: string[]): Promise<ResultObject> {
    let resolvedFiles = files ? files.map(file => path.resolve(__dirname, '../model/', file)) : [];

    const tmpObj = tmp.fileSync({ postfix: '.lp' });

    if (program) {
      fs.writeFileSync(tmpObj.name, program);
      resolvedFiles = resolvedFiles.concat([tmpObj.name]);
    }

    const result = spawnSync('clingo', ['--outf=2', '--quiet=1,2,2', ...resolvedFiles], {
      encoding: 'utf-8',
    });

    return JSON.parse(result.output[1]);
  }

  static getSoftConstraints(): ConstraintDictionary {
    const softDir = path.resolve(__dirname, '../model/view/soft');
    const subtypeDirs = fs
      .readdirSync(softDir)
      .filter(f => fs.statSync(path.join(softDir, f)).isDirectory());

    const result = subtypeDirs.reduce((dict, dir) => {
      const prefFile = path.resolve(softDir, dir, 'pref.lp');
      const prefContents = fs.readFileSync(prefFile, 'utf8');

      const weightFile = path.resolve(softDir, dir, 'weight.lp');
      const weightContents = fs.readFileSync(weightFile, 'utf8');

      const constraints = ConstraintDictionary.fromAsp(prefContents, weightContents);

      return {
        ...dict,
        ...constraints,
      };
    }, {});

    return result;
  }
}
