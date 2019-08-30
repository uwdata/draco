import { DataObject } from "./data";
import { FactsObject } from "./model";
import { ConstraintDictionary } from "./model/constraint-dictionary";
import { ResultObject } from "./model/result";
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
export declare const DEFAULT_OPTIONS: {
    strictHard: boolean;
    generate: boolean;
    generateExtraEncodings: boolean;
    optimize: boolean;
    generateData: boolean;
};
export declare class Draco {
    static run(program?: string, options?: DracoOptions, files?: string[]): ResultObject;
    static runDebug(program?: string, options?: DracoOptions, files?: string[]): FactsObject;
    static getProgram(data: DataObject, query: string): string;
    static getSoftConstraints(): ConstraintDictionary;
}
