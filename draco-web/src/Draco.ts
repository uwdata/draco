import Clingo from 'wasm-clingo';

import * as constraints from './all';

/**
 * Options for Draco.
 */
export interface Options {
  constraints: string[] | string;
};

/**
 * Sets of constraints for Draco (i.e. soft constraints, hard constraints, etc).
 */
export interface Constraints {
  [key: string]: string;
}

/**
 * Draco is a solver that recommends visualization specifications based off
 * partial specs.
 */
class Draco {
  Module: any;
  static constraints: Constraints = constraints;

  constructor() {
    this.Module = {};
  }

  /**
   * Initializes the underlying solver.
   *
   * @param {string} url The base path of the server hosting this.
   * @param {function} updateStatus Optional callback to log updates for initializationg
   *
   * @returns {Promise} A promise that resolves when the solver is ready or rejects upon
   *    failure.
   */
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
    } else {
      this.Module.setStatus = (text: string) => {};
    }

    return new Promise((resolve: () => void, reject: () => void) => {
      this.Module.onRuntimeInitialized = resolve;
      Clingo(this.Module);
    });
  }

  /**
   * Solves with the given constraints.
   *
   * @param {string} constraints The constraint to solve (e.g. the partial specification in ASP)
   * @param {Options} options Options for solving.
   *
   * @returns {Promise} A promise that resolves when the solver completes, or rejects upon error.
   */
  public solve(constraints: string, options: Options): Promise<any> {
    // add Draco's constraints
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
