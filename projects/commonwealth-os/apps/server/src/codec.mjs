import { createHash } from 'node:crypto';

// Portable, deterministic JSON canonicalization. Input domain: plain JSON only.
export function canon(value) {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return '[' + value.map(canon).join(',') + ']';
  return '{' + Object.keys(value).sort().map(k => JSON.stringify(k) + ':' + canon(value[k])).join(',') + '}';
}
export const sha = value => createHash('sha256').update(typeof value === 'string' ? value : canon(value), 'utf8').digest('hex');
export function invariant(condition, code, http = 409) {
  if (!condition) { const e = new Error(code); e.code = code; e.http = http; throw e; }
}
export function policyOK(p) {
  return p && Number.isSafeInteger(p.quorum) && p.quorum >= 1 &&
    Number.isSafeInteger(p.yesNumerator) && p.yesNumerator >= 1 &&
    Number.isSafeInteger(p.yesDenominator) && p.yesDenominator >= p.yesNumerator &&
    typeof p.strict === 'boolean';
}
export function tallyOK(p, votes) {
  const yes = votes.filter(v => v.choice === 'yes').length;
  const no = votes.filter(v => v.choice === 'no').length;
  const abstain = votes.filter(v => v.choice === 'abstain').length;
  const decisive = yes + no;
  const lhs = BigInt(yes) * BigInt(p.yesDenominator);
  const rhs = BigInt(decisive) * BigInt(p.yesNumerator);
  return { yes, no, abstain, accepted: decisive > 0 && (p.strict ? lhs > rhs : lhs >= rhs) };
}
