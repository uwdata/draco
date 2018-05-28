import Clingo_ from 'wasm-clingo';
const Clingo: typeof Clingo_ = (Clingo_ as any).default || Clingo_;

import * as constraints from './all';

/**
 * Options for Draco.
 */
export interface Options {
  /**
   * Empty means all.
   */
  constraints?: string[];
}

/**
 * Draco is a solver that recommends visualization specifications based off
 * partial specs.
 */
class Draco {
  private Module: any;

  private initialized = false;

  /**
   * @param url The base path of the server hosting this.
   * @param updateStatus Optional callback to log updates for status changes.
   */
  constructor(url: string, updateStatus?: (text: string) => void) {
    this.Module = {
      locateFile: (file: string) => `${url}/${file}`,
      totalDependencies: 0
    };


    this.Module.monitorRunDependencies = function(left: number) {
      this.totalDependencies = Math.max(this.totalDependencies, left);
      this.setStatus(
        left
          ? 'Preparing... (' + (this.totalDependencies - left) + '/' + this.totalDependencies + ')'
          : 'All downloads complete.'
      );
    };

    if (updateStatus) {
      this.Module.setStatus = (text: string) => {
        updateStatus(text);
      };
    }
  }

  /**
   * Initializes the underlying solver.
   *
   * @returns {Promise} A promise that resolves when the solver is ready or rejects upon
   *    failure.
   */
  public init(): Promise<any> {
    this.initialized = true;
    return Clingo(this.Module);
  }

  /**
   * Solves with the given constraints.
   *
   * @param program The constraint to solve (e.g. the partial specification in ASP)
   * @param options Options for solving.
   *
   * @returns The solution from Clingo as JSON.
   */
  public solve(program: string, options?: Options): any {
    if (!this.initialized) {
      throw Error('Draco is not initialized. Call `init() first.`');
    }

    program += (options && options.constraints || Object.keys(constraints)).map((name: string) => (constraints as any)[name]).join('\n');

    const opt = ' --outf=2';  // JSON output

    let result = '';
    this.Module.print = (text: string) => {
      result += text;
    };

    this.Module.ccall('run', 'number', ['string', 'string'], [program, opt]);
    return JSON.parse(result);
  }
}

export default Draco;
