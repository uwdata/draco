# Draco Core

JavaScript module with the Draco knowledge base and helper functions to convert from Draco ASP to Vega-Lite and vice-versa as well as a function to convert from CompassQL to Draco ASP.

**vl2asp** *(spec: TopLevelUnitSpec): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/vl2asp.ts)

>Translates a Vega-Lite specification into a list of ASP Draco facts.

**cql2asp** *(spec: any): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/cql2asp.ts)

>Translates a CompassQL specification into a list of ASP Draco constraints.

**asp2vl** *(facts: string[]): TopLevelUnitSpec* [<>](https://github.com/uwdata/draco/blob/master/js/src/asp2vl.ts)

>Interprets a list of ASP Draco facts as a Vega-Lite specification.

**data2schema** *(data: any[]): Schema* [<>](https://github.com/uwdata/draco/blob/master/js/src/data2schema.ts)

>Reads a list of rows and generates a schema for the dataset. `data` should be given as a list of dictionaries.

**schema2asp** *(schema: Schema): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/schema2asp.ts)

>Translates a schema into an ASP declaration of the data it describes.

**constraints2json** *(constraintsAsp: string, weightsAsp?: string): Constraint[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/constraints2json.ts)

>Translates the given ASP constraints and matching weights (i.e. for soft constraints) into JSON format.

## Examples

You can run vl2asp, aps2vl, and cql2asp on the command line.

```sh
cat ../examples/ab.json  | vl2asp | clingo
```
