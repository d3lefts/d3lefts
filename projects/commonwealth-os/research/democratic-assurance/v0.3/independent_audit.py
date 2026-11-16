"""Separate, standard-library exhaustive oracle for the finite toy authority guard."""
import itertools
import json
import hashlib
from dataclasses import replace
from pathlib import Path
from governance_model import Authorization, Environment, Effect, GuardedSink, guard, change_law, change_source, change_text


def oracle(c, e, a):
    # Deliberately use failure-set semantics rather than the model's conjunctive formula.
    fail = set()
    if len({c.jurisdiction,e.jurisdiction,a.jurisdiction}) != 1: fail.add('jurisdiction')
    if len({c.ordinance_id,e.ordinance_id,a.ordinance_id}) != 1: fail.add('ordinance')
    if c.digest != e.digest: fail.add('digest')
    if c.version != e.version: fail.add('version')
    if c.source_epoch != e.source_epoch: fail.add('source_epoch')
    if c.law_epoch != e.law_epoch: fail.add('law_epoch')
    for name in ('human_adopted','quorum_verified','legal_reviewed','appropriation_valid'):
        if not getattr(c,name): fail.add(name)
    if c.stayed or c.revoked: fail.add('blocked')
    if a.kind not in c.permitted_kinds: fail.add('scope')
    if a.amount < 0 or a.amount > c.ceiling: fail.add('amount')
    return not fail


def test():
    base = Authorization('test-city','ord-1','digest-a',3,7,11,True,True,True,True,False,False,frozenset({'purchase'}),10)
    env = Environment('test-city','ord-1','digest-a',3,7,11)
    action = Effect('test-city','ord-1','purchase',8)
    keys = ['human_adopted','quorum_verified','legal_reviewed','appropriation_valid','stayed','revoked']
    checked=0; allowed=0; rejected=0
    for bools in itertools.product([False,True], repeat=len(keys)):
      changes=dict(zip(keys,bools))
      c=replace(base,**changes)
      for mismatch in itertools.product([False,True],repeat=6):
        ce=replace(c,
              jurisdiction='other' if mismatch[0] else base.jurisdiction,
              ordinance_id='other' if mismatch[1] else base.ordinance_id,
              digest='other' if mismatch[2] else base.digest,
              version=99 if mismatch[3] else base.version,
              source_epoch=99 if mismatch[4] else base.source_epoch,
              law_epoch=99 if mismatch[5] else base.law_epoch)
        for kind in ('purchase','delete'):
          for amt in (-1,0,10,11):
            a=replace(action,kind=kind,amount=amt)
            result=guard(ce,env,a)
            assert result == oracle(ce,env,a), (ce,env,a,result)
            sink=GuardedSink()
            assert sink.commit(ce,env,a)==result
            assert len(sink.committed)==int(result)
            checked+=1
            allowed+=int(result)
            rejected+=int(not result)
    # Explicit stale certificate / update tests, checked independently.
    assert guard(base,env,action)
    assert not guard(base,change_text(env,'digest-b'),action)
    assert not guard(base,change_source(env),action)
    assert not guard(base,change_law(env),action)
    assert not guard(replace(base,revoked=True),env,action)
    assert not guard(replace(base,stayed=True),env,action)
    assert not guard(base,env,replace(action,kind='delete'))
    assert not guard(base,env,replace(action,amount=11))
    assert not guard(base,env,replace(action,amount=-1))
    report={'model':'commonwealth2030-finite-guard-v0.1','tested_cases':checked,'allowed':allowed,'rejected':rejected,'explicit_adversarial_cases':9,'result':'pass','scope':'finite toy; assumes complete trusted effect mediation; no actual cryptographic or constitutional validity test'}
    out=Path(__file__).with_name('audit_receipt.json')
    out.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps(report,sort_keys=True))

if __name__=='__main__': test()
