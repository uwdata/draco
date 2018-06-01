import Clingo_ from 'wasm-clingo';
import * as constraints from './constraints';
import { getModels, models2vl } from './spec';
const Clingo: typeof Clingo_ = (Clingo_ as any).default || Clingo_;

export * from './constraints';

/**
 * Options for Draco.
 */
export interface Options {
  /**
   * Empty means all.
   */
  constraints?: string[];

  /**
   * Weight for the soft constraints.
   */
  weights?: Array<{
    name: string;
    value: number;
  }>;

  /**
   * Number of models.
   */
  models?: number;
}

/**
 * Draco is a solver that recommends visualization specifications based off
 * partial specs.
 */
class Draco {
  public initialized = false;

  private Module: any;

  /**
   * @param url The base path of the server hosting this.
   * @param updateStatus Optional callback to log updates for status changes.
   */
  constructor(url: string, updateStatus?: (text: string) => void) {
    this.Module = {
      // Where to locate clingo.wasm
      locateFile: (file: string) => `${url}/${file}`,

      // Status change logger
      setStatus: updateStatus || console.log,

      // Dependencies
      totalDependencies: 0,
      monitorRunDependencies(left: number) {
        this.totalDependencies = Math.max(this.totalDependencies, left);
        this.setStatus(
          left
            ? 'Preparing... (' + (this.totalDependencies - left) + '/' + this.totalDependencies + ')'
            : 'All downloads complete.'
        );
      },

      printErr(err: Error) {
        this.setStatus('Error. See console for errors.');
        console.error(err);
      },
    };
  }

  /**
   * Initializes the underlying solver.
   *
   * @returns {Promise} A promise that resolves when the solver is ready.
   */
  public init() {
    return new Promise((resolve: (draco: Draco) => void, reject: () => void) => {
      this.Module.setStatus('Downloading...');
      this.Module.onRuntimeInitialized = () => {
        this.initialized = true;
        resolve(this);
      };
      Clingo(this.Module);
    });
  }

  /**
   * Solves with the given constraints.
   *
   * @param program The constraint to solve (e.g. the partial specification in ASP)
   * @param options Options for solving.
   *
   * @returns The solution from Clingo as JSON.
   */
  public solve(program: string, options: Options = {}): any {
    if (!this.initialized) {
      throw Error('Draco is not initialized. Call `init() first.`');
    }

    this.Module.setStatus('Running Draco Query...');

    const programs = options.constraints || Object.keys(constraints);

    program += programs.map((name: string) => (constraints as any)[name]).join('\n\n');

    const opt = [
      '--outf=2', // JSON output
      '--opt-mode=OptN', // find multiple optimal models
      '--quiet=1', // only output optimal models
      '--project', // every model only once
      options.models === undefined ? 1 : options.models,
    ]
      .concat((options.weights || []).map(d => `-c ${d.name}=${d.value}`))
      .join(' ');

    let resultText = '';
    this.Module.print = (text: string) => {
      resultText += text;
    };

    this.Module.ccall('run', 'number', ['string', 'string'], [program, opt]);

    const result = JSON.parse(resultText);
    const models = getModels(result);

    if (models.length > (options.models || 1)) {
      throw new Error('Too many models.');
    }

    const specs = models2vl(models);

    // done
    this.Module.setStatus('');

    return { specs, result, models, programs };
  }
}

export default Draco;
