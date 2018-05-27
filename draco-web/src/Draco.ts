import Clingo_ from 'wasm-clingo';
const Clingo: typeof Clingo_ = (Clingo_ as any).default || Clingo_;

import * as constraints from './all';

export interface Options {
  constraints: string[] | string;
};

export interface Constraints {
  [key: string]: string;
}

class Draco {
  Module: any;
  static constraints: Constraints = constraints;

  constructor() {
    this.Module = {};
  }

  public init(url: string, updateStatus?: (text: string) => void): Promise<any> {
    this.Module.locateFile = (file: string) => { return `${url}/${file}`; } ;
    this.Module.totalDependencies = 0;
    this.Module.monitorRunDependencies = function(left: number) {
        this.totalDependencies = Math.max(this.totalDependencies, left);
        this.setStatus(left ? 'Preparing... (' + (this.totalDependencies-left) + '/' + this.totalDependencies + ')' : 'All downloads complete.');
    };

    if (updateStatus) {
      this.Module.setStatus = (text: string) => {
        updateStatus(text);
      }
    }

    return new Promise((resolve: () => void, reject: () => void) => {
      this.Module.onRuntimeInitialized = resolve;
      Clingo(this.Module);
    });
  }

  public solve(constraints: string, options: Options): Promise<any> {
    if (options.constraints === 'all') {
      for (const name in Draco.constraints) {
        const set = Draco.constraints[name];
        constraints += `\n${set}`;
      }
    } else {
      for (const name of options.constraints) {
        const set: string = Draco.constraints[name];
        constraints += `\n${set}`;
      }
    }

    return new Promise((resolve: (value: string) => void, reject: (value: string) => void) => {
      let opt = " --outf=2";
      let result = '';
      this.Module.print = (text: string) => {
        result += text;
      };

      this.Module.ccall('run', 'number', ['string', 'string'], [constraints, opt]);
      try {
        const json = JSON.parse(result);
        resolve(json);
      } catch (error) {
        reject(result);
      }
    });
  }
}

export default Draco;
