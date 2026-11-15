#!/usr/bin/env python3
"""Independent security-oracle audit of source-bound authority transitions.

The expected acceptance truth tables are written here without importing
the production 'sign', 'verify', 'digest' or verifier helper functions.
Production system under test: authority_service.process.
This tests a bounded control-state model, not full real-world provenance.
"""
import copy
import hashlib
import hmac
import itertools
import json
import os
from collections import Counter
from pathlib import Path

import authority_service as service
from test_source_baseline_binding import fixtures, POLICY


def canonical(obj):
    return (json.dumps(obj,sort_keys=True,separators=(',',':'),ensure_ascii=True)+'\n').encode('ascii')


def hash_object(obj):
    return hashlib.sha256(canonical(obj)).hexdigest()


def independently_signed(body,key,corrupt=False):
    result=hmac.new(key,canonical(body),hashlib.sha256).hexdigest()
    return '0'*64 if corrupt else result


def initial_state(baseline):
    source='a'*64
    return {
        'epoch':1, 'version':'initial',
        'source_hash':source,
        'policy':copy.deepcopy(POLICY),
        'policy_hash':hash_object(POLICY),
        'baseline':copy.deepcopy(baseline),
        'baseline_hash':hash_object(baseline),
        'baseline_source_hash':source,
        'baseline_source_version':'initial',
        'revoked':False,
        'nonces':[], 'committed':None,
    }


def test_promote_truth_table():
    baseline,good=fixtures()
    key=b'I'*32
    counts=Counter()
    flags=('bound','revoked','stale','replay','bad_template',
           'bad_hash','bad_signature','bad_peer')
    for settings in itertools.product((False,True), repeat=len(flags)):
        case=dict(zip(flags,settings))
        state=initial_state(baseline)
        if not case['bound']:
            state['baseline_source_hash']=None
            state['baseline_source_version']=None
        state['revoked']=case['revoked']
        if case['replay']: state['nonces']=['x'*20]
        candidate=copy.deepcopy(good)
        if case['bad_template']:
            candidate['Resources']['AppliedInterpretabilityOU']['Properties']['Name']='Unauthorized'
        body={'op':'promote','ticket':{
            'epoch':(state['epoch']-1 if case['stale'] else state['epoch']),
            'version':state['version'],
            'source_hash':state['source_hash'],
            'policy_hash':state['policy_hash'],
            'baseline_hash':state['baseline_hash'],
            'template_hash':('0'*64 if case['bad_hash'] else hash_object(candidate)),
            'nonce':'x'*20
        },'template':candidate}
        message={'__peer_uid__':(os.getuid()+100000 if case['bad_peer'] else os.getuid()),
                 'body':body,'signature':independently_signed(body,key,case['bad_signature'])}
        old=copy.deepcopy(state)
        changed,reply=service.process(state,message,os.getuid(),key)
        expect=(case['bound'] and
                not any(case[x] for x in flags if x!='bound'))
        assert bool(reply['ok'])==expect,(case,reply)
        if expect:
            assert changed['committed']['template']==candidate
            assert changed['committed']['authority_epoch']==old['epoch']
            assert changed['committed']['template_hash']==hash_object(candidate)
            assert changed['committed']['ticket']['source_hash']==old['source_hash']
            assert 'x'*20 in changed['nonces']
            assert changed['baseline_source_hash']==old['source_hash']
            counts['accepted']+=1
        else:
            assert changed is state and state==old,(case,reply)
            counts['rejected']+=1
    assert counts==Counter(accepted=1,rejected=255),counts
    return counts


def test_rebaseline_truth_table():
    baseline,_=fixtures()
    key=b'I'*32
    counts=Counter()
    flags=('source_match','version_match','safe_baseline','not_revoked',
           'good_signature','good_peer')
    for settings in itertools.product((False,True),repeat=len(flags)):
        case=dict(zip(flags,settings))
        state=initial_state(baseline)
        state['baseline_source_hash']=None
        state['baseline_source_version']=None
        state['revoked']=not case['not_revoked']
        proposed=copy.deepcopy(baseline) if case['safe_baseline'] else {'Resources':{}}
        body={'op':'rebaseline',
              'source_hash':state['source_hash'] if case['source_match'] else 'b'*64,
              'version':state['version'] if case['version_match'] else 'other-version',
              'baseline':proposed}
        message={'__peer_uid__':os.getuid() if case['good_peer'] else os.getuid()+100000,
                 'body':body,
                 'signature':independently_signed(body,key,not case['good_signature'])}
        old=copy.deepcopy(state)
        changed,reply=service.process(state,message,os.getuid(),key)
        expect=all(case.values())
        assert bool(reply['ok'])==expect,(case,reply)
        if expect:
            assert changed['epoch']==old['epoch']+1
            assert changed['nonces']==[]
            assert changed['baseline_hash']==hash_object(proposed)
            assert changed['baseline_source_hash']==old['source_hash']
            assert changed['baseline_source_version']==old['version']
            counts['accepted']+=1
        else:
            assert changed is state and changed==old,(case,reply)
            counts['rejected']+=1
    assert counts==Counter(accepted=1,rejected=63),counts
    return counts


def main():
    promote=test_promote_truth_table()
    refresh=test_rebaseline_truth_table()
    result={'status':'passed',
            'promote_truth_table':dict(promote),
            'rebaseline_truth_table':dict(refresh),
            'total_cases':sum(promote.values())+sum(refresh.values()),
            'scope':'exact pure control-state transitions; no external attestation'}
    Path('source-baseline-truth-table-results.json').write_text(
        json.dumps(result,sort_keys=True,indent=2)+'\n')
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':
    main()
