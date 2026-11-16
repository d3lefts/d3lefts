// Pure, conservative change-impact analysis for externally VERIFIED evidence.
// This is NOT automatic re-authorization. Every identified impact is a review request.
import { invariant } from './codec.mjs';
export function dependencyRecord(payload) {
  invariant(payload?.institution?.id&&payload?.item?.id&&Array.isArray(payload.sourceDependencies),'INVALID_PASSPORT',400);
  const lock=payload.events?.findLast(e=>e.action==='LOCK');
  return {
    institutionId:payload.institution.id,itemId:payload.item.id,
    policyVersion:payload.item.lockedPolicyVersion,
    eligibilityVersion:payload.item.lockedEligibilityVersion,
    lockedRevision:payload.item.lockedRevision,
    evidenceHead:payload.events.at(-1)?.hash??null,
    authorityHead:payload.authorityJournal?.at(-1)?.hash??null,
    sources:payload.sourceDependencies.map(d=>({sourceId:d.sourceId,version:d.version,hash:d.hash})),
    sourceScopeComplete:!!lock&&Array.isArray(lock.details?.sources),
    synthetic:true,
  };
}
export function recertifyImpact(record,changes) {
  invariant(record?.institutionId&&record?.itemId&&Array.isArray(changes),'INVALID_RECERT_REQUEST',400);
  let affected=false,indeterminate=false;const reasons=[];
  for(const c of changes){
    if(c?.institutionId!==record.institutionId)continue;
    switch(c.type){
      case 'POLICY_CHANGED':
        if(!Number.isSafeInteger(c.version))indeterminate=true;
        else if(c.version!==record.policyVersion){affected=true;reasons.push('POLICY_VERSION_CHANGED');}break;
      case 'ELIGIBILITY_CHANGED':case 'ACTOR_REVOKED':case 'ACTOR_PROVISIONED':
        if(!Number.isSafeInteger(c.epoch))indeterminate=true;
        else if(c.epoch!==record.eligibilityVersion){affected=true;reasons.push('MEMBERSHIP_EPOCH_CHANGED');}break;
      case 'SOURCE_REVISED':{
        if(!record.sourceScopeComplete){indeterminate=true;reasons.push('SOURCE_GRAPH_INCOMPLETE');break;}
        const src=record.sources.find(x=>x.sourceId===c.sourceId);
        if(src && (!Number.isSafeInteger(c.version)||typeof c.hash!=='string')){indeterminate=true;reasons.push('SOURCE_COMPARISON_UNKNOWN');}
        else if(src && (c.version!==src.version||c.hash!==src.hash)){affected=true;reasons.push('REFERENCED_SOURCE_CHANGED');}
        break;
      }
      case 'PROJECTION_CORRECTED':
        if(c.itemId===record.itemId){affected=true;reasons.push('PUBLICATION_REVISION_CHANGED');}break;
      case 'SIGNER_REVOKED':
        affected=true;reasons.push('SIGNING_AUTHORITY_REVOKED');break;
      case 'IRRELEVANT_SOURCE':break;
      default:indeterminate=true;reasons.push('UNSUPPORTED_CHANGE_TYPE');
    }
  }
  return {status:affected?'RECHECK_REQUIRED':indeterminate?'UNKNOWN':'UNCHANGED_UNDER_DECLARED_DEPENDENCIES',
    reasons:[...new Set(reasons)],automaticRecertification:false,
    limitation:'Only declared signed dependencies are examined; rule interpretations and hidden dependencies require independent review.'};
}
