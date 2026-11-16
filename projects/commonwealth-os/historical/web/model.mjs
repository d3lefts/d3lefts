// Pure, browser-safe model for the synthetic Living Voter historical dashboard.
// Never maps a general issue response into a vote on a particular motion.
export const DATA_MODE = 'SYNTHETIC_ONLY';
export const PAGE_SIZE = 4;
export const RELATIONS = Object.freeze({
  EXACT_QUESTION: { label: 'Exact question in fixture', className: 'exact', explanation: 'The fictional issue proposition matches this recorded direct motion. This is only a fixture-level match, not a legal or semantic certification.' },
  SUBSTANTIVE_REVIEWED: { label: 'Reviewed, not equivalent', className: 'reviewed', explanation: 'A fictional reviewer identified a substantive relationship; the precise procedural question differs. Do not interpret the vote as a vote on the broader issue.' },
  TOPIC_ONLY: { label: 'Topic only', className: 'uncertain', explanation: 'This question shares a topic, but its recorded position does not establish support for the issue.' },
  UNREVIEWED: { label: 'Unreviewed candidate', className: 'uncertain', explanation: 'No reviewed semantic equivalence exists. No direct preference comparison is justified.' }
});
export const POSITIONS = Object.freeze({
  YEA: 'Yea', NAY: 'Nay', PRESENT: 'Present', NOT_VOTING: 'Not voting',
  NO_RECORDED_POSITION: 'No recorded position',
  VOICE_VOTE_NO_NAMED_POSITION: 'Voice vote — no named position',
  NO_MATCHING_TENURE: 'No matching tenure at vote date'
});
export const ISSUE_CHOICES = Object.freeze({
  SUPPORT: 'Support', OPPOSE: "Don't support", NO_PREFERENCE: 'No preference',
  NEED_MORE_INFORMATION: 'Need more information'
});
export const PRACTICE_CHOICES = Object.freeze({
  YEA: 'Yea', NAY: 'Nay', NO_PREFERENCE: 'No preference',
  NEED_MORE_INFORMATION: 'Need more information'
});
export function isSyntheticHealth(health) {
  return Boolean(health && health.data_mode === DATA_MODE &&
    health.real_government_data_connected === false &&
    health.external_source_adapters_enabled === false &&
    health.official_ballots_supported === false);
}
export function validateDashboard(payload) {
  if (!payload || payload.mode !== DATA_MODE || payload.official_data_connected !== false ||
      payload.historical_votes_are_user_ballots !== false ||
      payload.coverage?.complete_legislative_history !== false ||
      !Array.isArray(payload.entries) || !Number.isInteger(payload.total)) {
    throw new Error('This dashboard is not an approved synthetic-only historical response.');
  }
  return payload;
}
export function validIssueId(issueId) {
  return issueId === '' || /^fx-issue-[a-z0-9-]+$/.test(issueId);
}
export function dashboardPath(filters, offset=0) {
  const { issueId='', chamber='ALL', houseDistrict='07', municipalWard='02', asOf='2025-12-31' } = filters;
  if (!validIssueId(issueId) || !['ALL','HOUSE','SENATE','MUNICIPAL'].includes(chamber) ||
      !['07','08'].includes(houseDistrict) || !['02','03'].includes(municipalWard) ||
      !/^20\d\d-\d\d-\d\d$/.test(asOf) || !Number.isInteger(offset) || offset < 0) {
    throw new Error('Invalid fictional dashboard filters.');
  }
  const q=new URLSearchParams({house_district:houseDistrict,municipal_ward:municipalWard,
    as_of:asOf,limit:String(PAGE_SIZE),offset:String(offset)});
  if(issueId)q.set('issue_id',issueId);
  if(chamber!=='ALL')q.set('chamber',chamber);
  return '/api/v1/historical/dashboard?'+q;
}
export function relationInfo(entry) {
  return RELATIONS[entry?.relation] || {label: 'Unknown correspondence',className:'uncertain',explanation:'Unrecognized correspondence cannot support a comparison.'};
}
export function canCompare(entry) {
  return Boolean(entry && entry.relation === 'EXACT_QUESTION' &&
    ['FINAL_PASSAGE','MOTION'].includes(entry.kind) && entry.rollcall_type === 'RECORDED' &&
    entry.direct_vote_comparison_permitted === true &&
    Array.isArray(entry.representatives_at_vote_date) &&
    entry.representatives_at_vote_date.some(person => person.direct_vote_comparison_permitted === true &&
      Boolean(person.vote_record_id) && ['YEA','NAY','PRESENT','NOT_VOTING'].includes(person.position)));
}
export function namedPositions(entry) {
  if(!Array.isArray(entry.representatives_at_vote_date))return [];
  return entry.representatives_at_vote_date.map(person=>({
    name: person.name || 'No recorded seat occupant',
    position: POSITIONS[person.position] || 'Unknown position',
    rawStatus: person.position,
    seat: person.seat || 'Unmatched seat',
    tenure: person.valid_from && person.valid_to ? `${person.valid_from} to ${person.valid_to} (end exclusive)` : 'No matching tenure',
    recordId: person.vote_record_id || null,
    digest: person.vote_digest || null,
    eligibleForDirectComparison: canCompare(entry) && person.direct_vote_comparison_permitted === true
  }));
}
export function coverageLabel(payload) {
  if (!payload || !payload.coverage) return 'Incomplete fictional sample; coverage is unknown.';
  return 'Curated fictional subset only — not comprehensive. No record does not mean no vote. No inferred electorate or constituent positions.';
}
