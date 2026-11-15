#!/usr/bin/env python3
"""Independent exhaustive audit of the source-epoch belief game.

No import of synthesize.py. Enumerates all loop-free history-dependent
contingent policies and verifies generated value/policy upper/lower claims.
Symbolic costs are illustrative, NOT measured service time or money.
"""
import hashlib
import json
from fractions import Fraction
from functools import lru_cache
from pathlib import Path


def game(path):
    raw=Path(path).read_bytes()
    m=json.loads(raw)
    ss=m['states']
    assert len(ss)==4 and len(set(ss))==4
    d={s:i for i,s in enumerate(ss)}
    goal=sum(1<<d[s] for s in m['goal_states'])
    init=sum(1<<d[s] for s in m['initial_belief'])
    actions={}
    for a in m['actions']:
        assert a['name'] not in actions and Fraction(a['cost'])>0
        actions[a['name']]=(Fraction(a['cost']),{
            s:tuple((label,d[t],safe) for label,t,safe in a['transitions'].get(s,[]))
            for s in ss})
    return raw,ss,goal,init,actions


def successors(b,action,states):
    outcome={}
    for k,s in enumerate(states):
        if b>>k&1:
            options=action[1][s]
            if not options or any(not ok for _,_,ok in options):
                return None
            for label,next_k,_ in options:
                outcome[label]=outcome.get(label,0)|(1<<next_k)
    return tuple(outcome.values()) if outcome else None


def independently_enumerated_optimum(states,goal,actions,start):
    @lru_cache(None)
    def rec(b,visited):
        if b & ~goal == 0:return Fraction(0)
        if visited & (1<<b):return None
        best=None
        for cost,move in actions.values():
            nexts=successors(b,(cost,move),states)
            if nexts is None:continue
            values=[rec(c,visited|(1<<b)) for c in nexts]
            if any(v is None for v in values):continue
            value=cost+max(values)
            if best is None or value<best:best=value
        return best
    return rec(start,0)


def check(model,certificate):
    raw,states,goal,start,actions=game(model)
    cert=json.loads(Path(certificate).read_text())
    assert cert['input_sha256']==hashlib.sha256(raw).hexdigest()
    assert cert['initial_mask']==start and cert['goal_mask']==goal
    V={int(k):None if v is None else Fraction(v) for k,v in cert['values'].items()}
    assert set(V)==set(range(1,16))
    assert cert['initial_cost']==str(V[start])=='4'
    assert cert['policy'][str(start)]=='status'
    upper=lower=0
    for b in range(1,16):
        if b&~goal==0:
            assert V[b]==0
            continue
        val=V[b]
        assert val is not None,('unexpected losing belief',b)
        action_name=cert['policy'][str(b)]
        assert action_name in actions
        price,move=actions[action_name]
        nexts=successors(b,(price,move),states)
        assert nexts is not None
        assert all(V[t] is not None and V[t]<val for t in nexts)
        assert val==price+max(V[t] for t in nexts)
        upper+=1
        for name,act in actions.items():
            dest=successors(b,act,states)
            if dest is None:continue
            assert val<=act[0]+max(V[t] for t in dest)
            lower+=1
        alternative=independently_enumerated_optimum(states,goal,actions,b)
        assert alternative==val,('exhaustive difference',b,val,alternative)
    return {'status':'passed','states':len(states),'beliefs':15,
            'initial_optimum':str(V[start]),
            'optimal_start_action':cert['policy'][str(start)],
            'upper_checks':upper,'lower_checks':lower,
            'full_history_dependent_exhaustive_compares':15,
            'cost_units':'illustrative exact rational action weights'}


if __name__=='__main__':
    import sys
    r=check(sys.argv[1],sys.argv[2])
    print(json.dumps(r,sort_keys=True))
    Path('source-epoch-game-audit.json').write_text(json.dumps(r,indent=2,sort_keys=True)+'\n')
