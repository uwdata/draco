import { TopLevelUnitSpec } from "vega-lite/src/spec/unit";
export declare type VegaLiteSpecDictionaryObject = {
    [name: string]: TopLevelUnitSpec;
};
export declare type FactsObject = string[];
export declare class Facts {
    static toVegaLiteSpecDictionary(facts: FactsObject): VegaLiteSpecDictionaryObject;
    static toViews(facts: FactsObject): string[];
    static getHardViolations(facts: FactsObject): FactsObject;
    static getSoftViolations(facts: FactsObject): FactsObject;
    static getViewFacts(facts: FactsObject): FactsObject;
}
