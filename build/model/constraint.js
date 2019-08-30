import { doesMatchRegex } from './util';
export class Constraint {
    static isHardConstraint(constraint) {
        return constraint.type === Constraint.HARD_TYPE;
    }
    static isSoftConstraint(constraint) {
        return constraint.type === Constraint.SOFT_TYPE;
    }
    static getUniqueName(constraint) {
        return `${constraint.type}-${constraint.subtype}-${constraint.name}`;
    }
    static fromPrefAsp(asp) {
        const matches = doesMatchRegex(asp, PREF_ASP_REGEX);
        if (!matches) {
            throw new Error(`ASP (${asp}) does not match constraint regex.`);
        }
        const [fullMatch, description, code, type, subtype, name, view, parameters,] = PREF_ASP_REGEX.exec(asp);
        const definitions = code
            .trim()
            .split('\n')
            .map(line => {
            const [fullMatch, definition] = PREF_DEFINITION_REGEX.exec(line);
            return definition;
        });
        return {
            subtype,
            name,
            view,
            parameters,
            description,
            definitions,
            type: type,
        };
    }
    static toPrefAsp(c) {
        const description = `% @constraint ${c.description}`;
        const head = `${c.type}(${c.subtype},${c.name},${c.view},${c.parameters})`;
        const code = c.definitions
            .map(def => {
            return `${head} :- ${def}`;
        })
            .join('\n')
            .trim();
        return `${description}\n${code}`;
    }
}
Constraint.HARD_TYPE = 'hard';
Constraint.SOFT_TYPE = 'soft';
const PREF_ASP_REGEX = /%\s*@constraint (.*)\n((?:(hard|soft)\((\w+),(\w+),(\w+),(\w+)\).*\n?)+)/;
const PREF_DEFINITION_REGEX = /:-\s*(.*)/;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiY29uc3RyYWludC5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbIi4uLy4uL3NyYy9tb2RlbC9jb25zdHJhaW50LnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE9BQU8sRUFBRSxjQUFjLEVBQUUsTUFBTSxRQUFRLENBQUM7QUFrQnhDLE1BQU0sT0FBTyxVQUFVO0lBSXJCLE1BQU0sQ0FBQyxnQkFBZ0IsQ0FBQyxVQUE0QjtRQUNsRCxPQUFPLFVBQVUsQ0FBQyxJQUFJLEtBQUssVUFBVSxDQUFDLFNBQVMsQ0FBQztJQUNsRCxDQUFDO0lBRUQsTUFBTSxDQUFDLGdCQUFnQixDQUFDLFVBQTRCO1FBQ2xELE9BQU8sVUFBVSxDQUFDLElBQUksS0FBSyxVQUFVLENBQUMsU0FBUyxDQUFDO0lBQ2xELENBQUM7SUFFRCxNQUFNLENBQUMsYUFBYSxDQUFDLFVBQTRCO1FBQy9DLE9BQU8sR0FBRyxVQUFVLENBQUMsSUFBSSxJQUFJLFVBQVUsQ0FBQyxPQUFPLElBQUksVUFBVSxDQUFDLElBQUksRUFBRSxDQUFDO0lBQ3ZFLENBQUM7SUFFRCxNQUFNLENBQUMsV0FBVyxDQUFDLEdBQVc7UUFDNUIsTUFBTSxPQUFPLEdBQUcsY0FBYyxDQUFDLEdBQUcsRUFBRSxjQUFjLENBQUMsQ0FBQztRQUNwRCxJQUFJLENBQUMsT0FBTyxFQUFFO1lBQ1osTUFBTSxJQUFJLEtBQUssQ0FBQyxRQUFRLEdBQUcsb0NBQW9DLENBQUMsQ0FBQztTQUNsRTtRQUVELE1BQU0sQ0FDSixTQUFTLEVBQ1QsV0FBVyxFQUNYLElBQUksRUFDSixJQUFJLEVBQ0osT0FBTyxFQUNQLElBQUksRUFDSixJQUFJLEVBQ0osVUFBVSxFQUNYLEdBQUcsY0FBYyxDQUFDLElBQUksQ0FBQyxHQUFHLENBQUMsQ0FBQztRQUU3QixNQUFNLFdBQVcsR0FBRyxJQUFJO2FBQ3JCLElBQUksRUFBRTthQUNOLEtBQUssQ0FBQyxJQUFJLENBQUM7YUFDWCxHQUFHLENBQUMsSUFBSSxDQUFDLEVBQUU7WUFDVixNQUFNLENBQUMsU0FBUyxFQUFFLFVBQVUsQ0FBQyxHQUFHLHFCQUFxQixDQUFDLElBQUksQ0FBQyxJQUFJLENBQUMsQ0FBQztZQUNqRSxPQUFPLFVBQVUsQ0FBQztRQUNwQixDQUFDLENBQUMsQ0FBQztRQUVMLE9BQU87WUFDTCxPQUFPO1lBQ1AsSUFBSTtZQUNKLElBQUk7WUFDSixVQUFVO1lBQ1YsV0FBVztZQUNYLFdBQVc7WUFDWCxJQUFJLEVBQUUsSUFBc0I7U0FDN0IsQ0FBQztJQUNKLENBQUM7SUFFRCxNQUFNLENBQUMsU0FBUyxDQUFDLENBQW1CO1FBQ2xDLE1BQU0sV0FBVyxHQUFHLGlCQUFpQixDQUFDLENBQUMsV0FBVyxFQUFFLENBQUM7UUFDckQsTUFBTSxJQUFJLEdBQUcsR0FBRyxDQUFDLENBQUMsSUFBSSxJQUFJLENBQUMsQ0FBQyxPQUFPLElBQUksQ0FBQyxDQUFDLElBQUksSUFBSSxDQUFDLENBQUMsSUFBSSxJQUFJLENBQUMsQ0FBQyxVQUFVLEdBQUcsQ0FBQztRQUMzRSxNQUFNLElBQUksR0FBRyxDQUFDLENBQUMsV0FBVzthQUN2QixHQUFHLENBQUMsR0FBRyxDQUFDLEVBQUU7WUFDVCxPQUFPLEdBQUcsSUFBSSxPQUFPLEdBQUcsRUFBRSxDQUFDO1FBQzdCLENBQUMsQ0FBQzthQUNELElBQUksQ0FBQyxJQUFJLENBQUM7YUFDVixJQUFJLEVBQUUsQ0FBQztRQUVWLE9BQU8sR0FBRyxXQUFXLEtBQUssSUFBSSxFQUFFLENBQUM7SUFDbkMsQ0FBQzs7QUE5RE0sb0JBQVMsR0FBVyxNQUFNLENBQUM7QUFDM0Isb0JBQVMsR0FBVyxNQUFNLENBQUM7QUFrRXBDLE1BQU0sY0FBYyxHQUFHLDBFQUEwRSxDQUFDO0FBQ2xHLE1BQU0scUJBQXFCLEdBQUcsV0FBVyxDQUFDIn0=