import { FactsObject, VegaLiteSpecDictionaryObject } from "./facts";
export interface WitnessObject {
    costs?: number[];
    facts: FactsObject;
}
export declare class Witness {
    static toVegaLiteSpecDictionary(witness: WitnessObject): VegaLiteSpecDictionaryObject;
}
