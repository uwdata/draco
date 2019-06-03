export function doesMatchRegex(s: string, regex: RegExp): boolean {
  const match = s.match(regex);
  return !!match;
}
