"""Independent failure-list verifier + exhaustive controlled negative cases.
An independent implementation is NOT an independent human review.
"""
from dataclasses import replace
from itertools import product
from pathlib import Path
from dap_model import Passport, World, Effect, AtomicGuard, permit
import json


def independent_oracle(p, w, e):
    bad = []
    for field in ('institution', 'resolution_id'):
        if not (getattr(p,field)==getattr(w,field)==getattr(e,field)):
            bad.append(field)
    for field in ('proposal_hash', 'rule_hash', 'voter_roll_epoch',
                  'law_epoch', 'evidence_epoch', 'budget_epoch'):
        if getattr(p,field) != getattr(w,field): bad.append(field)
    for field in ('election_proof_checked','eligibility_uniqueness_attested',
                  'human_final_vote_attested','competent_authority_attested',
                  'procedure_attested','rights_attested','lawful_budget_attested'):
        if getattr(p,field) is not True: bad.append(field)
    if w.stayed or w.revoked: bad.append('stay-or-revocation')
    if not (w.authority_current and w.budget_current and w.rights_clear):
        bad.append('current-world-status')
    if w.now < p.issued_at or w.now > p.expires_at: bad.append('time')
    if e.kind not in p.allowed_kinds: bad.append('effect-kind')
    if not (0 <= e.amount <= p.ceiling): bad.append('amount')
    n = p.yes_count + p.no_count
    if not (p.electorate_count>=1 and
            0<=p.ballots_count<=p.electorate_count and
            all(x>=0 for x in [p.yes_count,p.no_count,p.abstain_count]) and
            n+p.abstain_count==p.ballots_count and
            0<=p.quorum_min<=p.electorate_count and
            p.ballots_count>=p.quorum_min and
            0<p.yes_fraction_num<=p.yes_fraction_den and n>0 and
            p.yes_count*p.yes_fraction_den>=p.yes_fraction_num*n):
        bad.append('ballot-tally-or-rule')
    return not bad


def base():
    p=Passport('school','r-17','proposal:abc','rule:xyz',5,11,13,7,100,200,
        10,8,6,2,0,6,1,2,True,True,True,True,True,True,True,True,
        frozenset({'purchase'}),1000)
    w=World('school','r-17','proposal:abc','rule:xyz',5,11,13,7,150,
        False,False,True,True,True)
    e=Effect('school','r-17','unique-1','purchase',500)
    return p,w,e


def main():
    p,w,e=base()
    assert permit(p,w,e) and independent_oracle(p,w,e)
    toggles=['election_proof_checked','eligibility_uniqueness_attested',
       'human_final_vote_attested','competent_authority_attested',
       'procedure_attested','rights_attested','lawful_budget_attested']
    wflags=['stayed','revoked','authority_current','budget_current','rights_clear']
    count=allow=0
    for bits in product([False,True],repeat=len(toggles)+len(wflags)):
        pp=replace(p,**dict(zip(toggles,bits[:len(toggles)])))
        ww=replace(w,**dict(zip(wflags,bits[len(toggles):])))
        for i in range(11):
            # Independent failure probes, one condition changed per variant.
            probes=[(pp,ww,e),
               (replace(pp,yes_count=4,no_count=4),ww,e),
               (replace(pp,ballots_count=5),ww,e),
               (pp,replace(ww,law_epoch=12),e),
               (pp,replace(ww,voter_roll_epoch=6),e),
               (pp,replace(ww,evidence_epoch=14),e),
               (pp,replace(ww,rule_hash='new rule'),e),
               (pp,replace(ww,proposal_hash='new proposal'),e),
               (pp,replace(ww,now=201),e),
               (pp,ww,replace(e,kind='wire-transfer')),
               (pp,ww,replace(e,amount=1001))]
            # Choose only one probe per iteration to avoid quadratic work.
            a,b,c=probes[i]
            v=permit(a,b,c)
            assert v == independent_oracle(a,b,c), (bits,i)
            sink=AtomicGuard()
            committed,receipt=sink.commit(a,b,c)
            assert committed == v
            assert len(sink.commits)==int(v)
            count+=1; allow+=int(v)
    s=AtomicGuard()
    assert s.commit(p,w,e)[0]
    assert not s.commit(p,w,e)[0] # replay forbidden
    # After any significant authority change a fresh passport is mandatory.
    for changed in (replace(w,law_epoch=12),replace(w,revoked=True),
                    replace(w,evidence_epoch=14),replace(w,stayed=True)):
        assert not AtomicGuard().commit(p,changed,e)[0]
    # Known insufficiency counterexample: same VOTE data, two legal worlds.
    legal=replace(w,authority_current=True)
    illegal=replace(w,authority_current=False)
    assert permit(p,legal,e) and not permit(p,illegal,e)
    assert (legal.proposal_hash,legal.rule_hash)==(illegal.proposal_hash,illegal.rule_hash)
    r={'model':'democratic-assurance-passport-v0.2',
       'cases':count,'pass_cases':allow,'reject_cases':count-allow,
       'single_use_replay_rejected':True,'legal_indistinguishability_pair':True,
       'status':'passed',
       'scope':'toy invariant only; trusted truthful attestations, atomic effect sink and complete mediation are assumptions; no ballot cryptography or US legal proof'}
    Path(__file__).with_name('dap_audit_receipt.json').write_text(json.dumps(r,indent=2,sort_keys=True)+'\n')
    print(json.dumps(r,sort_keys=True))

if __name__=='__main__': main()
