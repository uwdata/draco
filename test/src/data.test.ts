import { Data } from "../../src";

describe("Data", () => {
  describe("From array", () => {
    test("numRows", () => {
      const numRows = Data.fromArray(DATA.data).numRows;
      expect(numRows).toEqual(DATA.numRows);
    });
    test("fields", () => {
      const fields = Data.fromArray(DATA.data).fields;
      expect(fields).toEqual(DATA.fields);
    });
    test("schema", () => {
      const schema = Data.fromArray(DATA.data).schema;
      expect(schema).toEqual(DATA.schema);
    });
    test("asp", () => {
      const asp = Data.fromArray(DATA.data).asp;
      expect(asp).toEqual(DATA.asp);
    });
  });
});

const DATA = {
  data: [
    { string: "a", number: 1.1, integer: 1, boolean: true, date: "01/01/2019" },
    { string: "a", number: 1.1, integer: 1, boolean: true, date: "01/01/2019" },
    { string: "c", number: 1.5, integer: 2, boolean: false, date: "12/31/2019" }
  ],
  fields: ["string", "number", "integer", "boolean", "date"],
  numRows: 3,
  schema: {
    string: {
      type: "string",
      cardinality: 2
    },
    number: {
      type: "number",
      cardinality: 2,
      extent: [1.1, 1.5]
    },
    integer: {
      type: "integer",
      cardinality: 2,
      extent: [1, 2]
    },
    boolean: {
      type: "boolean",
      cardinality: 2
    },
    date: {
      type: "date",
      cardinality: 2,
      extent: ["01/01/2019", "12/31/2019"]
    }
  },
  asp: `num_rows(3).
fieldtype("string",string).
cardinality("string",2).
fieldtype("number",number).
cardinality("number",2).
fieldtype("integer",integer).
cardinality("integer",2).
extent("integer",1,2).
fieldtype("boolean",boolean).
cardinality("boolean",2).
fieldtype("date",date).
cardinality("date",2).`
};
