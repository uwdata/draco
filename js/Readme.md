# Draco Core

JavaScript module with the Draco knowledge base and helper functions to convert from Draco ASP to Vega-Lite and vice-versa as well as a function to convert from CompassQL to Draco ASP.

If you wish to run Draco in a web browser, consider using draco-vis, which bundles the Clingo solver as a WebAssembly module. The Draco-Core API does not include this functionality by itself. It merely handles the logic of translating between the various interface languages.

## Draco-Core API (Typescript / Javascript)
    
**vl2asp** *(spec: TopLevelUnitSpec): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/vl2asp.ts)

>Translates a Vega-Lite specification into a list of ASP Draco facts.

**cql2asp** *(spec: any): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/cql2asp.ts)

>Translates a CompassQL specification into a list of ASP Draco constraints.

**asp2vl** *(facts: string[]): TopLevelUnitSpec* [<>](https://github.com/uwdata/draco/blob/master/js/src/asp2vl.ts)

>Interprets a list of ASP Draco facts as a Vega-Lite specification.

**data2schema** *(data: any[]): Schema* [<>](https://github.com/uwdata/draco/blob/master/js/src/data2schema.ts)

>Reads a list of rows and generates a data schema for the dataset. `data` should be given as a list of dictionaries.

**schema2asp** *(schema: Schema): string[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/schema2asp.ts)

>Translates a data schema into an ASP declaration of the data it describes.

**constraints2json** *(constraintsAsp: string, weightsAsp?: string): Constraint[]* [<>](https://github.com/uwdata/draco/blob/master/js/src/constraints2json.ts)

>Translates the given ASP constraints and matching weights (i.e. for soft constraints) into JSON format.

**json2constraints** *(constraints: Constraint[]): ConstraintAsp* [<>](https://github.com/uwdata/draco/blob/master/js/src/json2constraints.ts)

>Translates the given JSON format ASP constraints into ASP strings for definitions and weights (if applicable, i.e. for soft constraints).

## Examples

You can run vl2asp, aps2vl, and cql2asp on the command line.

```sh
cat ../examples/ab.json  | ./bin/vl2asp | clingo
```
