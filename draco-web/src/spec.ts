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

            witness.Value.forEach((value: string) => {
                const valueType = value.split('(')[0];
                switch(valueType) {
                    case 'mark':
                        mark = value.replace('mark(', '').replace(')', '');
                        break;
                    
                    case 'channel':
                        let argvs = value.replace('channel(', '').replace(')', '').split(',');
                        let enc = argvs[0];
                        let ch = argvs[1];
                        encoding[ch] = {aspEncoding: enc};
                        break;

                    case 'field':
                        argvs = value.replace('field(', '').replace(')', '').split(',');
                        enc = argvs[0];
                        encoding[enc] = {field: argvs[1]};
                        break;

                    case 'type':
                    case 'zero':
                        

                    default:
                        console.log(value);
                        break;

                }
            });

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
