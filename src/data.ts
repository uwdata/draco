import { extent } from "d3-array";
import { inferTypes } from "vega";

export interface DataObject {
  data: any[];
  numRows: number;
  fields: string[];
  schema: any;
  asp: string;
}

export class Data {
  static fromArray(arr: any): DataObject {
    const fields = getFieldsFromArr(arr);
    const inferredTypes = inferTypes(arr, fields);

    const schema = fields.reduce((schema, f) => {
      const descriptor = {
        type: inferredTypes[f],
        cardinality: getCardinalityFromArr(arr, f)
      };

      if (
        descriptor.type !== FieldType.STRING &&
        descriptor.type !== FieldType.BOOLEAN
      ) {
        descriptor["extent"] = extent(arr, d => d[f]);
      }

      schema[f] = descriptor;

      return schema;
    }, {});

    const numRows = arr.length;

    let asp = [Data.getNumRowsDeclaration(numRows)];

    asp = fields.reduce((asp, f) => {
      asp.push(Data.getFieldDeclaration(f, schema[f].type));
      asp.push(Data.getCardinalityDeclaration(f, schema[f].cardinality));

      // TODO: figure out how to handle non ints
      if (schema[f].extent && schema[f].type === FieldType.INTEGER) {
        asp.push(
          Data.getExtentDeclaration(f, schema[f].extent[0], schema[f].extent[1])
        );
      }

      return asp;
    }, asp);

    return {
      fields,
      schema,
      numRows,
      asp: asp.join("\n"),
      data: arr
    };
  }

  static getNumRowsDeclaration(numRows: number): string {
    return `num_rows(${numRows}).`;
  }

  static getFieldDeclaration(
    fieldName: string,
    fieldType: FieldTypeType
  ): string {
    return `fieldtype(${cleanFieldName(fieldName)},${fieldType}).`;
  }

  static getCardinalityDeclaration(
    fieldName: string,
    cardinality: number
  ): string {
    return `cardinality(${cleanFieldName(fieldName)},${cardinality}).`;
  }

  static getExtentDeclaration(
    fieldName: string,
    min: number,
    max: number
  ): string {
    if (!Number.isInteger(min) || !Number.isInteger(max)) {
      throw new Error(`Extent is yet supported for floats: ${min} ${max}`);
    }

    return `extent(${cleanFieldName(fieldName)},${min},${max}).`;
  }
}

function cleanFieldName(fieldName: string) {
  return `"${fieldName}"`;
}

function getFieldsFromArr(arr: any): string[] {
  if (!arr) {
    return [];
  }

  return Object.keys(arr[0]);
}

function getCardinalityFromArr(arr: any, field: string): number {
  const unique = arr.reduce((set, d) => {
    set.add(d[field]);
    return set;
  }, new Set());

  return unique.size;
}

export interface SchemaObject {
  [field: string]: FieldDescriptorObject;
}

export interface FieldDescriptorObject {
  type: FieldTypeType;
  cardinality: number;
  extent?: [number, number];
}

export class FieldType {
  static STRING: "string" = "string";
  static BOOLEAN: "boolean" = "boolean";
  static INTEGER: "integer" = "integer";
  static NUMBER: "number" = "number";
  static DATE: "date" = "date";
}

export type FieldTypeType =
  | typeof FieldType.STRING
  | typeof FieldType.BOOLEAN
  | typeof FieldType.INTEGER
  | typeof FieldType.NUMBER
  | typeof FieldType.DATE;
