const HOLE = '?';

export default function cql2asp(spec: any) {
  const mark = subst_if_hole(spec.mark);

  const facts = [];

  if (mark) {
    facts.push(`mark(${spec.mark}).`);
  }

  if ('data' in spec && 'url' in spec.data) {
    facts.push(`data("${spec.data.url}").`);
  }

  for (let i = 0; i < spec.encodings.length; i++) {
    const enc = spec.encodings[i];
    const eid = `e${i}`;
    facts.push(`encoding(${eid}).`);

    let encFieldType = null;
    let encZero = null;
    let encBinned = null;

    for (const field of Object.keys(enc)) {
      const fieldContent = subst_if_hole(enc[field]);

      if (!fieldContent) {
        continue;
      }

      if (!remove_if_star(fieldContent)) {
        continue;
      }

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
            facts.push(`zero(${eid}).`);
          } else {
            facts.push(`:- zero(${eid}).`);
          }
        }
        if ('log' in fieldContent) {
          if (fieldContent.log) {
            facts.push(`log(${eid}).`);
          } else {
            facts.push(`:-log(${eid}).`);
          }
        }
      } else if (field === 'bin') {
        if (fieldContent.maxbins) {
          facts.push(`${field}(${eid},${fieldContent.maxbins}).`);
        } else if (fieldContent) {
          facts.push(`:- not bin(${eid},_)`);
        } else {
          facts.push(`:- bin(${eid},_)`);
        }
      } else if (field === 'field') {
        // fields can have spaces and start with capital letters
        facts.push(`${field}(${eid},"${fieldContent}").`);
      } else {
        // translate normal fields
        if (field !== 'bin') {
          facts.push(`${field}(${eid},${fieldContent}).`);
        }
      }
    }

    if (encFieldType === 'quantitative' && encZero === null && encBinned === null) {
      facts.push(`zero(${eid}).`);
    }
  }

  return facts;
}

function subst_if_hole(v: any) {
  return v !== HOLE ? v : null;
}

function remove_if_star(v: any) {
  return v !== '*' ? v : null;
}
