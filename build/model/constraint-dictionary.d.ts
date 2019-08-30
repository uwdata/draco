import { ConstraintObject, HardConstraintObject, SoftConstraintObject } from './constraint';
export declare type ConstraintDictionaryObject = {
    [name: string]: ConstraintObject;
};
export declare type SoftConstraintDictionaryObject = {
    [name: string]: SoftConstraintObject;
};
export declare type HardConstraintDictionaryObject = {
    [name: string]: HardConstraintObject;
};
export declare class ConstraintDictionary {
    static isSoftConstraintDictionary(dict: ConstraintDictionaryObject): dict is SoftConstraintDictionaryObject;
    static isHardConstraintDictionary(dict: ConstraintDictionaryObject): dict is SoftConstraintDictionaryObject;
    static fromAsp(prefAsp: string, weightAsp?: string): ConstraintDictionaryObject;
}
