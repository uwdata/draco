
import { TopLevelFacetedUnitSpec } from 'vega-lite/build/src/spec';

/**
 * Convert from Vega-Lite to ASP.
 */
export default function vl2asp(spec: TopLevelFacetedUnitSpec): string[] {
  const facts = [`mark(${spec.mark})`];

  if ('data' in spec && 'url' in spec.data) {
    facts.push(`data("${spec.data.url}")`);
  }

  const encoding = spec.encoding || {};

  let i = 0;
  for (const channel of Object.keys(encoding)) {
    const eid = `e${i++}`;
    facts.push(`encoding(${eid})`);
    facts.push(`channel(${eid},${channel})`);

    let encFieldType = null;
    let encZero = null;
    let encBinned = null;

    // translate encodings
    for (const field of Object.keys(encoding[channel])) {
      const fieldContent = encoding[channel][field];
      if (field === 'type') {
        encFieldType = fieldContent;
      }
      if (field === 'bin') {
        encBinned = fieldContent;
      }
      if (field === 'scale') {
        // translate two boolean fields
        if ('zero' in fieldContent) {
          encZero = fieldContent.zero;
          if (fieldContent.zero) {
            facts.push(`zero(${eid})`);
          } else {
            facts.push(`:- zero(${eid})`);
          }
        }
        if ('log' in fieldContent) {
          if (fieldContent.log) {
            facts.push(`log(${eid})`);
          } else {
            facts.push(`:-log(${eid})`);
          }
        }
      } else if (field === 'bin') {
        facts.push(`${field}(${eid},${fieldContent.maxbins})`);
      } else if (field === 'field') {
        // fields can have spaces and start with capital letters
        facts.push(`${field}(${eid},"${fieldContent}")`);
      } else {
        // translate normal fields
        facts.push(`${field}(${eid},${fieldContent})`);
      }
    }

    if (encFieldType === 'quantitative' && encZero === null && encBinned === null) {
      facts.push(`zero(${eid})`);
    }
  }

  return facts;
}
