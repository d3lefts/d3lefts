// Institution-defined synthetic procedural rules. Rules are data, never legal grants.
export const BASES = Object.freeze(['DECISIVE', 'CAST', 'PRESENT', 'ELIGIBLE']);
export function policyValid(p) {
  if(!p || typeof p !== 'object' || Array.isArray(p)) return false;
  if(!Number.isSafeInteger(p.quorum) || p.quorum < 1) return false;
  if(!Number.isSafeInteger(p.yesNumerator) || p.yesNumerator < 1 ||
     !Number.isSafeInteger(p.yesDenominator) || p.yesDenominator < p.yesNumerator ||
     typeof p.strict !== 'boolean') return false;
  if(p.approvalBasis !== undefined && !BASES.includes(p.approvalBasis)) return false;
  if(p.quorumFraction !== undefined) {
    const q=p.quorumFraction;
    if(!q || !Number.isSafeInteger(q.numerator) || q.numerator < 1 ||
       !Number.isSafeInteger(q.denominator) || q.denominator < q.numerator ||
       typeof q.strict !== 'boolean' || q.basis !== 'ELIGIBLE')return false;
  }
  return Object.keys(p).every(k=>['quorum','yesNumerator','yesDenominator','strict','approvalBasis','quorumFraction','version','hash'].includes(k));
}
export function quorumCheck(p, presentCount, eligibleCount) {
  if(!policyValid(p) || !Number.isSafeInteger(presentCount) || !Number.isSafeInteger(eligibleCount) ||
     presentCount < 0 || eligibleCount < presentCount) return null;
  if(presentCount < p.quorum)return false;
  if(!p.quorumFraction)return true;
  const q=p.quorumFraction;
  const left=BigInt(presentCount)*BigInt(q.denominator);
  const right=BigInt(eligibleCount)*BigInt(q.numerator);
  return q.strict ? left>right : left>=right;
}
export function tallyCheck(p, votes, presentCount, eligibleCount) {
  if(!policyValid(p) || !Array.isArray(votes) || !votes.every(v=>['yes','no','abstain'].includes(v?.choice)) ||
     !Number.isSafeInteger(presentCount)||!Number.isSafeInteger(eligibleCount)||
     presentCount<0||eligibleCount<presentCount||votes.length>presentCount)return null;
  const counts={yes:0,no:0,abstain:0};
  for(const v of votes)counts[v.choice]++;
  const basis=p.approvalBasis??'DECISIVE';
  const denominator={DECISIVE:counts.yes+counts.no,CAST:votes.length,PRESENT:presentCount,ELIGIBLE:eligibleCount}[basis];
  if(denominator===0)return {...counts,denominator,basis,accepted:false};
  const left=BigInt(counts.yes)*BigInt(p.yesDenominator),right=BigInt(denominator)*BigInt(p.yesNumerator);
  return {...counts,denominator,basis,accepted:p.strict ? left>right : left>=right};
}
