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
        descriptor.type !== DataType.STRING &&
        descriptor.type !== DataType.BOOLEAN
      ) {
        descriptor["extent"] = extent(arr, d => d[f]);
      }

      schema[f] = descriptor;

      return schema;
    }, {});

    const numRows = arr.length;

    let asp = [`num_rows(${numRows}).`];

    asp = fields.reduce((asp, f) => {
      const field = `"${f}"`;
      asp.push(`fieldtype(${field},${schema[f].type}).`);
      asp.push(`cardinality(${field},${schema[f].cardinality}).`);

      // TODO: figure out how to handle non ints
      if (schema[f].extent && schema[f].type === DataType.INTEGER) {
        asp.push(
          `extent(${field},${schema[f].extent[0]},${schema[f].extent[1]}).`
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
  type: DataTypeType;
  cardinality: number;
  extent?: [number, number];
}

export class DataType {
  static STRING: "string" = "string";
  static BOOLEAN: "boolean" = "boolean";
  static INTEGER: "integer" = "integer";
  static NUMBER: "number" = "number";
  static DATE: "date" = "date";
}

export type DataTypeType =
  | typeof DataType.STRING
  | typeof DataType.BOOLEAN
  | typeof DataType.INTEGER
  | typeof DataType.NUMBER
  | typeof DataType.DATE;
