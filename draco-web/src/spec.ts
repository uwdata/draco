import {TopLevelSpec} from 'vega-lite';

export function asp2vl(asp: any): TopLevelSpec[] {
    let specs: TopLevelSpec[] = [];

    const witnesses = getWitnesses(asp);
    if (witnesses) {
        specs = witnesses.map((witness: any) => {
            // filter out soft constraint violations because we only need spec
            const specValues = witness.Value.filter((s: string) => !s.startsWith('violation'));
    
            return {
                '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
                data: {url: 'data/cars.json'},
                mark: parseMark(specValues),
                encoding: {}
            };
        });
    }
    console.log('specs', specs);
    return specs;
}

/** 
 * Get the array of witnesses from clingo output. 
 * Return undefined if no witnesses were found. 
 */
function getWitnesses(asp: any) {
    const result = JSON.parse(asp);

    if(result.Call && result.Call.length > 0) {
        return result.Call[0].Witnesses;
    } else {
        return undefined;
    }
}

/**
 * Parse clingo output to get mark for vegalite spec
 */
function parseMark(values: string[]) {
    const markValue = values.find((s: string) => s.startsWith('mark'));
    if (markValue) {
        return markValue.replace('mark(', '').replace(')', '');
    }
    return undefined;
}