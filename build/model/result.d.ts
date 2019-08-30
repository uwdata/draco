import { VegaLiteSpecDictionaryObject } from "./facts";
import { WitnessObject } from "./witness";
export declare type ResultObject = any;
export declare class Result {
    static toWitnesses(result: ResultObject): WitnessObject[];
    static getBestVegaLiteSpecDictionary(result: ResultObject): VegaLiteSpecDictionaryObject;
    static isSat(result: ResultObject): boolean;
}
