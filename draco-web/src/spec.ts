import {TopLevelSpec} from 'vega-lite';

export function asp2vl(facts: any): TopLevelSpec {
    let mark = '';
    const encoding: {[index: string]: any} = {};

    facts.forEach((value: string) => {
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
                encoding[enc] = {maxbins: argv[1]};
                break;

            case 'log':
                enc = getArgv(value, 'log')[0];
                encoding[enc].scale = {
                    ...encoding[enc].scale,
                    type: 'log'
                };
                break;

            case 'zero':
                enc = getArgv(value, 'zero')[0];
                encoding[enc].scale = {
                    ...encoding[enc].scale,
                    zero: true
                };
                break;

            case 'stack':
                enc = getArgv(value, 'stack')[0];
                encoding[enc].stack = getArgv(value, 'stack')[0];
                break;

            default:
                break;
        }
    });

    // post-process encodings
    ['x', 'y', 'color', 'size', 'shape', 'text', 'detail', 'row', 'column'].forEach((channel: string) => {
        if (encoding[channel]) {
            const e = encoding[channel].aspEncoding;
            encoding[channel] = encoding[e];
            delete encoding[e];
        }
    });

    // post-process zero: if quantitative encoding and zero is not set, set zero to false
    for (const channel in encoding) {
        if (encoding[channel].type === 'quantitative' &&
            (!encoding[channel].scale || encoding[channel].scale.zero !== true)) {
                encoding[channel].scale = {
                    ...encoding[channel].scale,
                    zero: false,
                }
        }
    }

    return {
        $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
        data: {url: 'data/cars.json'},
        mark,
        encoding
    } as TopLevelSpec;
}

export function result2vl(result: any) {
    const witnesses = getWitnesses(result);
    return witnesses.map(witness => asp2vl(witness.Value));
}

/**
 * Get the array of witnesses from clingo output.
 * Return undefined if no witnesses were found.
 */
function getWitnesses(result: any): Array<{Value: any[]}> {
    if (result.Call && result.Call.length > 0) {
        return result.Call[0].Witnesses;
    } else {
        return [];
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
