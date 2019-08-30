export interface DataObject {
    data: any[];
    numRows: number;
    fields: string[];
    schema: any;
    asp: string;
}
export declare class Data {
    static fromArray(arr: any): DataObject;
    static getNumRowsDeclaration(numRows: number): string;
    static getFieldDeclaration(fieldName: string, fieldType: FieldTypeType): string;
    static getCardinalityDeclaration(fieldName: string, cardinality: number): string;
    static getExtentDeclaration(fieldName: string, min: number, max: number): string;
}
export interface SchemaObject {
    [field: string]: FieldDescriptorObject;
}
export interface FieldDescriptorObject {
    type: FieldTypeType;
    cardinality: number;
    extent?: [number, number];
}
export declare class FieldType {
    static STRING: "string";
    static BOOLEAN: "boolean";
    static INTEGER: "integer";
    static NUMBER: "number";
    static DATE: "date";
}
export declare type FieldTypeType = typeof FieldType.STRING | typeof FieldType.BOOLEAN | typeof FieldType.INTEGER | typeof FieldType.NUMBER | typeof FieldType.DATE;
