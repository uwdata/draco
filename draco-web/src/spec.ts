import {TopLevelSpec} from 'vega-lite';

export function asp2vl(asp: any): TopLevelSpec[] {
    let specs: TopLevelSpec[] = [];

    const witnesses = getWitnesses(asp);
    if (witnesses) {
        specs = witnesses.map((witness: any) => {
            let mark = '';
            let encoding = {
                scale: {},
            };

            // filter out soft constraint violations because we only need spec
            const specValues = witness.Value.filter((s: string) => !s.startsWith('violation'));

            specValues.forEach((value: string) => {
                const valueType = value.split('(')[0];
                switch(valueType) {
                    case 'mark':
                        mark = value.replace('mark(', '').replace(')', '');
                        break;
                    
                    case 'channel':
                        const mapping = value.replace('channel(', '').replace(')', '').split(',');
                        const enc = mapping[0];
                        const ch = mapping[1];
                        encoding[ch] = {aspEncoding: enc};

                    default:
                        break;

                }
            });

            specValues.forEach((value: string) => {
                const valueType = value.split('(')[0];
                switch(valueType) {
                    case 'field':
                    case 'type':
                    case 'zero':
                        console.log(value);
                    default:
                        break;
                }
            })

            return {
                '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
                data: {url: 'data/cars.json'},
                mark,
                encoding
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
