#!/usr/bin/env python3
"""Exhaustive finite-state policy checks for the AURORA decision abstraction.

27 observable three-sensor states, not a proof about physical sensors, timing,
or the random process. Independent of aurora.py and audit.py.
"""
from itertools import product
import json

VALUES=('NA','0','1')

def policy(readings, which):
    if which not in ('any','quorum'): raise ValueError('unknown policy')
    minimum=1 if which=='any' else 2
    return (sum(r=='1' for r in readings)>=minimum,
            sum(r!='NA' for r in readings)>=minimum)

def verify(policy_impl=policy):
    states=list(product(VALUES,repeat=3))
    claims={'alarm_requires_operability':0,'quorum_implies_any':0,
            'full_outage_no_alarm':0,'quorum_requires_two_positives':0}
    witnesses=[]
    for state in states:
        any_alarm,any_operable=policy_impl(state,'any')
        quorum_alarm,quorum_operable=policy_impl(state,'quorum')
        if any_alarm and not any_operable or quorum_alarm and not quorum_operable:
            claims['alarm_requires_operability']+=1
        if quorum_alarm and not any_alarm: claims['quorum_implies_any']+=1
        if all(r=='NA' for r in state) and (quorum_alarm or any_alarm):
            claims['full_outage_no_alarm']+=1
        if quorum_alarm and sum(r=='1' for r in state)<2:
            claims['quorum_requires_two_positives']+=1
        if any_alarm and not quorum_alarm and len(witnesses)<2:
            witnesses.append(list(state))
    return {'scope':'all 3^3=27 finite observable states in {NA,0,1}^3',
            'tested_states':len(states),'violations':claims,
            'status':'PASS' if not any(claims.values()) else 'FAIL',
            'witnesses_any_alarms_but_quorum_does_not':witnesses,
            'limitation':('Exhaustive in the finite policy abstraction only. '
                          'No certification of sensor distributions, timing, semantics, '
                          'field performance, source-code equivalence, or external review.')}

if __name__=='__main__':
    report=verify()
    print(json.dumps(report,indent=2,sort_keys=True))
    raise SystemExit(0 if report['status']=='PASS' else 1)
