/**
 * Returns true iff a and be are equal (deep equality).
 *
 * @param {Object} a
 * @param {Object} b
 */
export function equals(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}
