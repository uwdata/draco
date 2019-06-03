import { WitnessObject } from "./witness";

export type ResultObject = any;

export class Result {
  static toWitnesses(result: ResultObject): WitnessObject[] {
    return (result.Call || []).reduce((arr: any[], el: any) => {
      el.Witnesses.forEach((d: any, i: number) => {
        const facts = d.Value; // add line terminator period.
        const costs = result.Models.Costs[i];

        arr.push({
          costs,
          facts
        });
      });

      return arr;
    }, []);
  }

  static isSat(result: ResultObject): boolean {
    return result.Result === "OPTIMUM FOUND" || result.Result === "SATISFIABLE";
  }
}
