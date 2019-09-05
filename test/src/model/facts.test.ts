import { TopLevelUnitSpec } from "vega-lite/src/spec/unit";
import { Facts } from "../../../src";

describe("Facts", () => {
  describe("ASP -> VL", () => {
    test("Scatterplot", () => {
      expect(Facts.toVegaLiteSpecDictionary(SCATTER.facts)).toEqual(
        SCATTER.specs
      );
    });
  });

  describe("ASP -> Views", () => {
    test("One view", () => {
      expect(Facts.toViews(ONE_VIEW.facts)).toEqual(ONE_VIEW.views);
    });

    test("Two views", () => {
      expect(Facts.toViews(TWO_VIEWS.facts)).toEqual(TWO_VIEWS.views);
    });
  });

  describe("VL -> ASP", () => {
    test("Scatterplot", () => {
      expect(
        Facts.fromVl(SCATTER.specs.v1 as TopLevelUnitSpec, "v1").sort()
      ).toEqual(
        SCATTER.facts
          .filter(f => f.includes("v1") && !f.includes("soft("))
          .sort()
      );
    });
  });
});

const ONE_VIEW = {
  facts: ["view(v1)"],
  views: ["v1"]
};

const TWO_VIEWS = {
  facts: ["view(v1)", "view(v2)"],
  views: ["v1", "v2"]
};

const SCATTER = {
  facts: [
    "view(v1)",
    "view(v2)",
    'fieldtype("f1",number)',
    'fieldtype("f2",number)',
    "encoding(v1,e1)",
    "encoding(v1,e2)",
    "encoding(v2,e1)",
    "encoding(v2,e2)",
    "type(v1,e1,quantitative)",
    "type(v1,e2,quantitative)",
    "type(v2,e1,quantitative)",
    "type(v2,e2,quantitative)",
    'field(v1,e1,"f1")',
    'field(v1,e2,"f2")',
    'field(v2,e1,"f1")',
    'field(v2,e2,"f2")',
    "channel(v1,e1,x)",
    "channel(v1,e2,y)",
    "channel(v2,e1,x)",
    "channel(v2,e2,y)",
    "mark(v1,point)",
    "mark(v2,square)",
    "scale(v1,e1,zero)",
    "scale(v1,e2,zero)",
    "scale(v2,e1,zero)",
    "scale(v2,e2,zero)",
    "soft(subtype,name,v1,param)",
    "soft(subtype,name,v2,param)"
  ],
  specs: {
    v1: {
      mark: "point",
      encoding: {
        x: {
          field: "f1",
          type: "quantitative",
          scale: {
            zero: true
          }
        },
        y: {
          field: "f2",
          type: "quantitative",
          scale: {
            zero: true
          }
        }
      }
    },
    v2: {
      mark: "square",
      encoding: {
        x: {
          field: "f1",
          type: "quantitative",
          scale: {
            zero: true
          }
        },
        y: {
          field: "f2",
          type: "quantitative",
          scale: {
            zero: true
          }
        }
      }
    }
  }
};
