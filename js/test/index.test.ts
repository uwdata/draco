import { asp2vl, vl2asp } from '../src';
import { aspSpecs, vlSpecs } from './specs';

test('asp2vl and vl2asp work', () => {
  for (let i = 0; i < vlSpecs.length; i++) {
    const aspSpec = aspSpecs[i];
    const vlSpec = vlSpecs[i];
    expect([asp2vl(aspSpec), vl2asp(vlSpec).sort()]).toEqual([vlSpec, aspSpec.sort()]);
  }
});
