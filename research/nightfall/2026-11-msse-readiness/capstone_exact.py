#!/usr/bin/env python3
"""Synthetic modular fault-monitoring case, exact rational decision-tree audit.
No real operational reliability data. No academic grade, novel theorem or system certification.
"""
from fractions import Fraction as F
from itertools import product
from functools import lru_cache
import json

STATES = tuple(product((0,1), repeat=3))
SENSORS = {'power': lambda x:x[0], 'branch1':lambda x:x[1],
           'branch2':lambda x:x[2], 'either_branch':lambda x:x[1]|x[2]}
TASKS = {'alarm':lambda x:x[0] & (x[1]|x[2]),
         'repair_branch1':lambda x:x[1], 'repair_branch2':lambda x:x[2]}
A = ('power','branch1','branch2')
B = ('power','branch1','branch2','either_branch')
MISSION = {'alarm':F(3,4),'repair_branch1':F(1,8),'repair_branch2':F(1,8)}


def product_masses(probabilities):
    weights = tuple((__import__('functools').reduce(
        lambda a,v:a*v,(probabilities[j] if state[j] else 1-probabilities[j]
                      for j in range(3)),F(1))) for state in STATES)
    assert sum(weights)==1 and all(v>0 for v in weights)
    return weights


def minimum_expected_reads(architecture, task, weights):
    @lru_cache(None)
    def E(rows):
        if len({task(STATES[i]) for i in rows})<=1:
            return F(0)
        total=sum(weights[i] for i in rows)
        candidates=[]
        for sensor in architecture:
            groups={}
            for i in rows:
                groups.setdefault(SENSORS[sensor](STATES[i]),[]).append(i)
            if len(groups)<=1:
                continue
            candidates.append(F(1)+sum((sum(weights[i] for i in group)/total)*E(tuple(group))
                                       for group in groups.values()))
        assert candidates, 'architecture does not observe task'
        return min(candidates)
    return E(tuple(range(len(STATES))))


def direct_alarm_with_aggregate(state, stuck_zero):
    # power is always read first, then either_branch if necessary.
    if state[0]==0:
        return 0,1
    return (0 if stuck_zero else (state[1]|state[2])),2


def robust_alarm_with_fallback(state, stuck_zero):
    if state[0]==0:
        return 0,1
    aggregate = 0 if stuck_zero else (state[1]|state[2])
    if aggregate:
        return 1,2
    if state[1]:
        return 1,3
    return state[2],4


def run():
    checks=0
    uniform=product_masses((F(1,2),)*3)
    expected={}
    for label, arch in [('A',A),('B',B)]:
        expected[label]={mission:minimum_expected_reads(arch,task,uniform)
                          for mission,task in TASKS.items()}
    assert expected['A']=={'alarm':F(7,4),'repair_branch1':F(1),'repair_branch2':F(1)}
    assert expected['B']=={'alarm':F(3,2),'repair_branch1':F(1),'repair_branch2':F(1)}
    checks+=2
    avg_A=sum(MISSION[m]*d for m,d in expected['A'].items())
    avg_B=sum(MISSION[m]*d for m,d in expected['B'].items())
    assert avg_A==F(25,16) and avg_B==F(11,8)
    assert F(3)/(avg_A-avg_B)==16
    assert 3+24*avg_A==F(81,2) and 6+24*avg_B==39
    checks+=3
    for s0 in [F(1,4),F(1,2),F(3,4)]:
        for s1 in [F(1,4),F(1,2),F(3,4)]:
            for s2 in [F(1,4),F(1,2),F(3,4)]:
                weights=product_masses((s0,s1,s2))
                for m,task in TASKS.items():
                    a=minimum_expected_reads(A,task,weights)
                    b=minimum_expected_reads(B,task,weights)
                    assert b<=a
                    assert a>=1 and b>=1
                    checks+=2
    q=F(1,20)
    false_negative=F(0)
    fallback_error=F(0)
    fallback_healthy_reads=F(0)
    for i,state in enumerate(STATES):
        for failed,pf in [(False,1-q),(True,q)]:
            output,n=direct_alarm_with_aggregate(state,failed)
            target=TASKS['alarm'](state)
            if output!=target:
                false_negative+=uniform[i]*pf
            restored,n2=robust_alarm_with_fallback(state,failed)
            if restored != target:
                fallback_error+=uniform[i]*pf
            if not failed:
                fallback_healthy_reads+=uniform[i]*n2
            checks+=3
    assert false_negative==F(3,160)
    assert fallback_error==0
    assert fallback_healthy_reads==F(7,4) # E[queries | aggregate healthy]
    checks+=3
    result={'status':'SYNTHETIC_CAPSTONE_EXACT_CHECK_PASSED',
            'assertion_groups':checks,
            'uniform_minimum_expected_queries':{k:{m:str(v) for m,v in val.items()} for k,val in expected.items()},
            'mission_mix_queries_A':str(avg_A),'mission_mix_queries_B':str(avg_B),
            'break_even_missions':16,'cost_24_missions_A':'81/2','cost_24_missions_B':'39',
            'stuck_zero_probability':str(q),'direct_policy_alarm_false_negative':str(false_negative),
            'fallback_policy_alarm_error':str(fallback_error),
            'note':'No empirical calibration, university credit, or faculty evaluation.'}
    print(json.dumps(result,indent=2))


if __name__=='__main__':
    run()
