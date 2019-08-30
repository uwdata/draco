import { Constraint, } from './constraint';
import { doesMatchRegex } from './util';
export class ConstraintDictionary {
    static isSoftConstraintDictionary(dict) {
        if (Object.entries(dict).length === 0) {
            return false;
        }
        const [firstName, firstConstraint] = Object.entries(dict)[0];
        return Constraint.isSoftConstraint(firstConstraint);
    }
    static isHardConstraintDictionary(dict) {
        if (Object.entries(dict).length === 0) {
            return false;
        }
        const [firstName, firstConstraint] = Object.entries(dict)[0];
        return Constraint.isHardConstraint(firstConstraint);
    }
    static fromAsp(prefAsp, weightAsp) {
        const prefMatches = doesMatchRegex(prefAsp, PREF_REGEX);
        let weightDictionary;
        if (!!weightAsp) {
            const weightMatches = doesMatchRegex(weightAsp, WEIGHT_REGEX);
            if (!weightMatches) {
                throw new Error(`Weight ASP: ${weightAsp} does not match weight regex.`);
            }
            const singleWeightAsps = weightAsp.match(WEIGHT_REGEX);
            weightDictionary = singleWeightAsps.reduce((dict, asp) => {
                const [fullMatch, subtype, name, weight] = WEIGHT_REGEX.exec(asp);
                WEIGHT_REGEX.lastIndex = 0;
                const uniqueName = `soft-${subtype}-${name}`;
                dict[uniqueName] = +weight;
                return dict;
            }, {});
        }
        if (!prefMatches) {
            throw new Error(`Pref ASP: ${prefMatches} does not match pref regex.`);
        }
        const singlePrefAsps = prefAsp.match(PREF_REGEX);
        const result = singlePrefAsps.reduce((dict, asp) => {
            const constraint = Constraint.fromPrefAsp(asp);
            const uniqueName = Constraint.getUniqueName(constraint);
            if (!!weightDictionary) {
                constraint.weight = weightDictionary[uniqueName];
            }
            dict[uniqueName] = constraint;
            return dict;
        }, {});
        return result;
    }
}
const PREF_REGEX = /%\s*@constraint(?:(?:.+)\n?)+/g;
const WEIGHT_REGEX = /soft_weight\((\w+),(\w+),(\d+)\).*/g;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiY29uc3RyYWludC1kaWN0aW9uYXJ5LmpzIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vLi4vc3JjL21vZGVsL2NvbnN0cmFpbnQtZGljdGlvbmFyeS50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQSxPQUFPLEVBQ0wsVUFBVSxHQUlYLE1BQU0sY0FBYyxDQUFDO0FBQ3RCLE9BQU8sRUFBRSxjQUFjLEVBQUUsTUFBTSxRQUFRLENBQUM7QUFNeEMsTUFBTSxPQUFPLG9CQUFvQjtJQUMvQixNQUFNLENBQUMsMEJBQTBCLENBQy9CLElBQWdDO1FBRWhDLElBQUksTUFBTSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxNQUFNLEtBQUssQ0FBQyxFQUFFO1lBQ3JDLE9BQU8sS0FBSyxDQUFDO1NBQ2Q7UUFFRCxNQUFNLENBQUMsU0FBUyxFQUFFLGVBQWUsQ0FBQyxHQUFHLE1BQU0sQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDLENBQUM7UUFDN0QsT0FBTyxVQUFVLENBQUMsZ0JBQWdCLENBQUMsZUFBZSxDQUFDLENBQUM7SUFDdEQsQ0FBQztJQUVELE1BQU0sQ0FBQywwQkFBMEIsQ0FDL0IsSUFBZ0M7UUFFaEMsSUFBSSxNQUFNLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLE1BQU0sS0FBSyxDQUFDLEVBQUU7WUFDckMsT0FBTyxLQUFLLENBQUM7U0FDZDtRQUVELE1BQU0sQ0FBQyxTQUFTLEVBQUUsZUFBZSxDQUFDLEdBQUcsTUFBTSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUMsQ0FBQztRQUM3RCxPQUFPLFVBQVUsQ0FBQyxnQkFBZ0IsQ0FBQyxlQUFlLENBQUMsQ0FBQztJQUN0RCxDQUFDO0lBRUQsTUFBTSxDQUFDLE9BQU8sQ0FBQyxPQUFlLEVBQUUsU0FBa0I7UUFDaEQsTUFBTSxXQUFXLEdBQUcsY0FBYyxDQUFDLE9BQU8sRUFBRSxVQUFVLENBQUMsQ0FBQztRQUV4RCxJQUFJLGdCQUFnQixDQUFDO1FBQ3JCLElBQUksQ0FBQyxDQUFDLFNBQVMsRUFBRTtZQUNmLE1BQU0sYUFBYSxHQUFHLGNBQWMsQ0FBQyxTQUFTLEVBQUUsWUFBWSxDQUFDLENBQUM7WUFDOUQsSUFBSSxDQUFDLGFBQWEsRUFBRTtnQkFDbEIsTUFBTSxJQUFJLEtBQUssQ0FBQyxlQUFlLFNBQVMsK0JBQStCLENBQUMsQ0FBQzthQUMxRTtZQUVELE1BQU0sZ0JBQWdCLEdBQUcsU0FBUyxDQUFDLEtBQUssQ0FBQyxZQUFZLENBQUMsQ0FBQztZQUN2RCxnQkFBZ0IsR0FBRyxnQkFBZ0IsQ0FBQyxNQUFNLENBQ3hDLENBQUMsSUFBSSxFQUFFLEdBQUcsRUFBRSxFQUFFO2dCQUNaLE1BQU0sQ0FBQyxTQUFTLEVBQUUsT0FBTyxFQUFFLElBQUksRUFBRSxNQUFNLENBQUMsR0FBRyxZQUFZLENBQUMsSUFBSSxDQUFDLEdBQUcsQ0FBQyxDQUFDO2dCQUNsRSxZQUFZLENBQUMsU0FBUyxHQUFHLENBQUMsQ0FBQztnQkFFM0IsTUFBTSxVQUFVLEdBQUcsUUFBUSxPQUFPLElBQUksSUFBSSxFQUFFLENBQUM7Z0JBQzdDLElBQUksQ0FBQyxVQUFVLENBQUMsR0FBRyxDQUFDLE1BQU0sQ0FBQztnQkFFM0IsT0FBTyxJQUFJLENBQUM7WUFDZCxDQUFDLEVBQ0QsRUFBUyxDQUNWLENBQUM7U0FDSDtRQUVELElBQUksQ0FBQyxXQUFXLEVBQUU7WUFDaEIsTUFBTSxJQUFJLEtBQUssQ0FBQyxhQUFhLFdBQVcsNkJBQTZCLENBQUMsQ0FBQztTQUN4RTtRQUVELE1BQU0sY0FBYyxHQUFHLE9BQU8sQ0FBQyxLQUFLLENBQUMsVUFBVSxDQUFDLENBQUM7UUFDakQsTUFBTSxNQUFNLEdBQUcsY0FBYyxDQUFDLE1BQU0sQ0FDbEMsQ0FBQyxJQUFJLEVBQUUsR0FBRyxFQUFFLEVBQUU7WUFDWixNQUFNLFVBQVUsR0FBRyxVQUFVLENBQUMsV0FBVyxDQUFDLEdBQUcsQ0FBQyxDQUFDO1lBQy9DLE1BQU0sVUFBVSxHQUFHLFVBQVUsQ0FBQyxhQUFhLENBQUMsVUFBVSxDQUFDLENBQUM7WUFFeEQsSUFBSSxDQUFDLENBQUMsZ0JBQWdCLEVBQUU7Z0JBQ3JCLFVBQW1DLENBQUMsTUFBTSxHQUFHLGdCQUFnQixDQUFDLFVBQVUsQ0FBQyxDQUFDO2FBQzVFO1lBRUQsSUFBSSxDQUFDLFVBQVUsQ0FBQyxHQUFHLFVBQVUsQ0FBQztZQUM5QixPQUFPLElBQUksQ0FBQztRQUNkLENBQUMsRUFDRCxFQUFnQyxDQUNqQyxDQUFDO1FBRUYsT0FBTyxNQUFNLENBQUM7SUFDaEIsQ0FBQztDQUNGO0FBRUQsTUFBTSxVQUFVLEdBQUcsZ0NBQWdDLENBQUM7QUFDcEQsTUFBTSxZQUFZLEdBQUcscUNBQXFDLENBQUMifQ==