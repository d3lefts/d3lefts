import { createHash } from 'node:crypto';
import { policyValid, tallyCheck } from './policy.mjs';

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
export const policyOK = policyValid;
export function tallyOK(policy, votes, ctx = {}) {
  const value=tallyCheck(policy,votes,ctx.presentCount ?? votes.length,ctx.eligibleCount ?? (ctx.presentCount ?? votes.length));
  invariant(value!==null, 'INVALID_TALLY_CONTEXT');
  return value;
}
