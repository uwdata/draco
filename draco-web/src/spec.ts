import {TopLevelSpec} from 'vega-lite';

export function asp2vl(facts: any): TopLevelSpec {
    let mark = '';
    const encoding: {[index: string]: any} = {};

    const regex = /(\w+)\((\w+)(,(\w+))?\)/

    facts.forEach((value: string) => {
        const [_, predicate, first, __, second] = regex.exec(value) as any;

        switch(predicate) {
            case 'mark':
                mark = first;
                break;

            case 'channel':
                encoding[second] = {aspEncoding: first};
                break;

            case 'field':
                encoding[first] = {field: second};
                break;

            case 'type':
                encoding[first] = {type: second};
                break;

            case 'aggregate':
                encoding[first] = {aggregate: second};
                break;

            case 'bin':
                encoding[first] = {maxbins: second};
                break;

            case 'log':
                encoding[first].scale = {
                    ...encoding[first].scale,
                    type: 'log'
                };
                break;

            case 'zero':
                encoding[first].scale = {
                    ...encoding[first].scale,
                    zero: true
                };
                break;

            case 'stack':
                encoding[first].stack = second;
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
