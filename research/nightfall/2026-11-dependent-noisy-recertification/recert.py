#!/usr/bin/env python3
"""Exact finite Bayesian adaptive mission recertification. Research prototype.

All input probabilities/costs rational. Sensor outputs may be dependent even
conditional on mission variables (shared noise is part of a complete world).
No cryptographic validity, source/model correctness or implementation correctness
is implied by this optimizer.
"""
from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction as Q
from functools import lru_cache
from itertools import product
from typing import NamedTuple

class World(NamedTuple):
    b: int
    u: int
    a: int
    n: int
    z: int

@dataclass(frozen=True)
class Test:
    name: str
    cost: Q
    field: str

# Shared N means noisy A/B sensors are NOT conditionally independent given A,B.
TESTS = (
    Test('noisy_a', Q(1), 'noisy_a'),
    Test('noisy_b', Q(1), 'noisy_b'),
    Test('read_b', Q(3), 'b'),
    Test('read_u', Q(4), 'u'),
    Test('read_a', Q(3), 'a'),
    Test('gold', Q(7), 'safe'),
)

def obs(w: World, name: str) -> int:
    if name == 'noisy_a': return w.a ^ w.n
    if name == 'noisy_b': return w.b ^ w.n
    if name == 'safe' or name == 'gold': return int(w.a == w.u)
    if name.startswith('read_'): name=name[5:]
    return getattr(w, name)

def joint(prior_b_1=Q(1,3), pa_1_given_b=(Q(3,4), Q(1,4)),
          pu_1_given_b=(Q(1,4), Q(3,4)), p_noise=Q(1,4),
          p_cache_error=Q(1,4)):
    """Return exact complete-world law including correlated noisy outcomes."""
    vals={}
    for b,u,a,n,z in product((0,1),repeat=5):
        pb=prior_b_1 if b else 1-prior_b_1
        pu=pu_1_given_b[b] if u else 1-pu_1_given_b[b]
        pa=pa_1_given_b[b] if a else 1-pa_1_given_b[b]
        pn=p_noise if n else 1-p_noise
        pz=(1-p_cache_error) if z==u else p_cache_error
        vals[World(b,u,a,n,z)]=pb*pu*pa*pn*pz
    assert sum(vals.values())==1
    assert all(v>0 for v in vals.values())
    return vals

class Solver:
    def __init__(self, law, available=TESTS, cache=None, delta=Q(1,10), eta=Q(1,10)):
        self.law=law
        self.tests={t.name:t for t in available}
        assert len(self.tests)==len(available)
        self.names=tuple(sorted(self.tests))
        self.cache=cache or {}
        self.delta=Q(delta);self.eta=Q(eta)
        assert 0<=self.delta<1 and 0<=self.eta<1
        self.record={}
        self.root=tuple(sorted(self.cache.items()))
        # Precondition: cache must have passed provenance/source/epoch checks externally.
        assert self.mass(self.root)>0

    @lru_cache(None)
    def mass(self, history):
        return sum((p for w,p in self.law.items() if all(obs(w,k)==v for k,v in history)),Q(0))

    def unsafe(self, history):
        mass=self.mass(history)
        assert mass>0
        return sum((p for w,p in self.law.items() if w.a!=w.u and all(obs(w,k)==v for k,v in history)),Q(0))/mass

    def outcomes(self, history, name):
        p0=self.mass(history)
        result=[]
        for v in (0,1):
            h=tuple(sorted(history+((name,v),)))
            pv=self.mass(h)
            if pv:result.append((v,pv/p0,h))
        assert sum(p for _,p,_ in result)==1
        return tuple(result)

    @lru_cache(None)
    def value(self, history):
        reached={k for k,v in history}
        p=self.unsafe(history)
        terminal=[]
        if p<=self.delta:terminal.append(('authorize', Q(0)))
        if 1-p<=self.eta:terminal.append(('deny', Q(0)))
        candidates=list(terminal)
        alternatives=[]
        for name in self.names:
            if name in reached:continue
            child=self.outcomes(history,name)
            v=self.tests[name].cost+sum((pr*self.value(nex) for _,pr,nex in child),Q(0))
            candidates.append((name,v));alternatives.append((name,v))
        assert candidates, 'Infeasible history: no terminal decision and no tests'
        choice,cost=min(candidates,key=lambda x:(x[1],x[0]))
        self.record[history]={'value':cost, 'choice':choice, 'unsafe':p,
                              'alternatives':dict(candidates), 'available_terminal':dict(terminal)}
        return cost

    def solve(self):
        result=self.value(self.root)
        return result

    def root_detail(self):
        v=self.solve()
        return dict(value=v, first=self.record[self.root]['choice'],
                    initial_risk=self.record[self.root]['unsafe'],
                    visited_states=len(self.record),cache=self.cache)

    def check_certificate(self):
        # Bellman lower bounds on all reachable beliefs; selected action attains.
        self.solve()
        for h,r in self.record.items():
            assert r['value'] == min(r['alternatives'].values())
            assert r['value'] == r['alternatives'][r['choice']]
            p=self.unsafe(h)
            if 'authorize' in r['alternatives']: assert p<=self.delta
            if 'deny' in r['alternatives']: assert 1-p<=self.eta
            for name,v in r['alternatives'].items():
                if name not in self.tests: assert v==0
                else:
                    rhs=self.tests[name].cost+sum((pr*self.record[h2]['value'] for _,pr,h2 in self.outcomes(h,name)),Q(0))
                    assert v==rhs and r['value']<=rhs
        return True

def format_q(q):
    q=Q(q)
    return f'{q.numerator}/{q.denominator}' if q.denominator!=1 else str(q.numerator)

if __name__=='__main__':
    for prior in (Q(1,2),Q(1,3)):
      law=joint(prior_b_1=prior)
      for cache in ({},{'z':1}):
        so=Solver(law,cache=cache)
        print('prior_b1',prior,'cache',cache,'policy',so.root_detail(), 'certificate',so.check_certificate())

