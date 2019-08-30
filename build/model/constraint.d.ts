export interface ConstraintObject {
    type: ConstraintType;
    subtype: string;
    name: string;
    view: string;
    parameters: string;
    description: string;
    definitions: string[];
}
export interface HardConstraintObject extends ConstraintObject {
}
export interface SoftConstraintObject extends ConstraintObject {
    weight?: number;
}
export declare class Constraint {
    static HARD_TYPE: 'hard';
    static SOFT_TYPE: 'soft';
    static isHardConstraint(constraint: ConstraintObject): constraint is HardConstraintObject;
    static isSoftConstraint(constraint: ConstraintObject): constraint is SoftConstraintObject;
    static getUniqueName(constraint: ConstraintObject): string;
    static fromPrefAsp(asp: string): ConstraintObject;
    static toPrefAsp(c: ConstraintObject): string;
}
export declare type ConstraintType = typeof Constraint.HARD_TYPE | typeof Constraint.SOFT_TYPE;
