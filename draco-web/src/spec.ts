import {TopLevelSpec} from 'vega-lite';

export default function asp2vl(asp: any): TopLevelSpec {
    // TODO
    return {
        mark: 'bar',
        data: {values: []},
        encoding: {}
    }
}
