import { Witness } from "./witness";
export class Result {
    static toWitnesses(result) {
        return (result.Call || []).reduce((arr, el) => {
            el.Witnesses.forEach((d, i) => {
                const facts = d.Value; // add line terminator period.
                let costs;
                if (result.Models.Costs) {
                    costs = result.Models.Costs[i];
                }
                arr.push({
                    costs,
                    facts
                });
            });
            return arr;
        }, []);
    }
    static getBestVegaLiteSpecDictionary(result) {
        const witnesses = Result.toWitnesses(result);
        return Witness.toVegaLiteSpecDictionary(witnesses[0]);
    }
    static isSat(result) {
        return result.Result === "OPTIMUM FOUND" || result.Result === "SATISFIABLE";
    }
}
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicmVzdWx0LmpzIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vLi4vc3JjL21vZGVsL3Jlc3VsdC50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFDQSxPQUFPLEVBQUUsT0FBTyxFQUFpQixNQUFNLFdBQVcsQ0FBQztBQUluRCxNQUFNLE9BQU8sTUFBTTtJQUNqQixNQUFNLENBQUMsV0FBVyxDQUFDLE1BQW9CO1FBQ3JDLE9BQU8sQ0FBQyxNQUFNLENBQUMsSUFBSSxJQUFJLEVBQUUsQ0FBQyxDQUFDLE1BQU0sQ0FBQyxDQUFDLEdBQVUsRUFBRSxFQUFPLEVBQUUsRUFBRTtZQUN4RCxFQUFFLENBQUMsU0FBUyxDQUFDLE9BQU8sQ0FBQyxDQUFDLENBQU0sRUFBRSxDQUFTLEVBQUUsRUFBRTtnQkFDekMsTUFBTSxLQUFLLEdBQUcsQ0FBQyxDQUFDLEtBQUssQ0FBQyxDQUFDLDhCQUE4QjtnQkFFckQsSUFBSSxLQUFLLENBQUM7Z0JBRVYsSUFBSSxNQUFNLENBQUMsTUFBTSxDQUFDLEtBQUssRUFBRTtvQkFDdkIsS0FBSyxHQUFHLE1BQU0sQ0FBQyxNQUFNLENBQUMsS0FBSyxDQUFDLENBQUMsQ0FBQyxDQUFDO2lCQUNoQztnQkFFRCxHQUFHLENBQUMsSUFBSSxDQUFDO29CQUNQLEtBQUs7b0JBQ0wsS0FBSztpQkFDTixDQUFDLENBQUM7WUFDTCxDQUFDLENBQUMsQ0FBQztZQUVILE9BQU8sR0FBRyxDQUFDO1FBQ2IsQ0FBQyxFQUFFLEVBQUUsQ0FBQyxDQUFDO0lBQ1QsQ0FBQztJQUVELE1BQU0sQ0FBQyw2QkFBNkIsQ0FDbEMsTUFBb0I7UUFFcEIsTUFBTSxTQUFTLEdBQUcsTUFBTSxDQUFDLFdBQVcsQ0FBQyxNQUFNLENBQUMsQ0FBQztRQUM3QyxPQUFPLE9BQU8sQ0FBQyx3QkFBd0IsQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDLENBQUMsQ0FBQztJQUN4RCxDQUFDO0lBRUQsTUFBTSxDQUFDLEtBQUssQ0FBQyxNQUFvQjtRQUMvQixPQUFPLE1BQU0sQ0FBQyxNQUFNLEtBQUssZUFBZSxJQUFJLE1BQU0sQ0FBQyxNQUFNLEtBQUssYUFBYSxDQUFDO0lBQzlFLENBQUM7Q0FDRiJ9