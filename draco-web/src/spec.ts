import {TopLevelSpec} from 'vega-lite';

export function asp2vl(asp: any): TopLevelSpec[] {
    let specs: TopLevelSpec[] = [];

    const witnesses = getWitnesses(asp);
    if (witnesses) {
        specs = witnesses.map((witness: any) => {
            let mark = '';
            const encoding: {[index: string]: {}} = {
                'scale': {},
            };

            witness.Value.forEach((value: string) => {
                const valueType = value.split('(')[0];
                switch(valueType) {
                    case 'mark':
                        mark = getArgv(value, 'mark')[0];
                        break;
                    
                    case 'channel':
                        let argv = getArgv(value, 'channel');
                        let enc = argv[0];
                        const ch = argv[1];
                        encoding[ch] = {aspEncoding: enc};
                        break;

                    case 'field':
                        argv = getArgv(value, 'field');
                        enc = argv[0];
                        encoding[enc] = {field: argv[1]};
                        break;

                    case 'type':
                        argv = getArgv(value, 'type');
                        enc = argv[0];
                        encoding[enc] = {type: argv[1]};
                        break;
                        
                    case 'aggregate': 
                        argv = getArgv(value, 'aggregate');
                        enc = argv[0];
                        encoding[enc] = {aggregate: argv[1]};
                        break;
                    
                    case 'bin': 
                        argv = getArgv(value, 'bin');
                        enc = argv[0];
                        encoding[enc] = {bin: argv[1]};
                        break;
                    
                    case 'zero':
                        // console.log(value);
                        

                    default:
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

/**
 * Get arguments from an asp predicate
 * @param aspPredicate An ASP predicate that takes 1 or more arguments, e.g., channel(e0, x)
 * @param predicateType The type of predicate, e.g., mark, encoding, channel, type, field
 */
function getArgv(aspPredicate: string, predicateType: string): string[] {
    return aspPredicate.replace(predicateType, '').replace('(', '').replace(')', '').split(',');
}
