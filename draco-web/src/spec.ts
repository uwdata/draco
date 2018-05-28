import {TopLevelSpec} from 'vega-lite';

export default function asp2vl(asp: any): TopLevelSpec {
    // TODO: query.to_vega_lite: mark, encoding

    return {
        '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
        data: {url: 'data/cars.json'},
        mark: 'bar',
        encoding: {}
    }
}
