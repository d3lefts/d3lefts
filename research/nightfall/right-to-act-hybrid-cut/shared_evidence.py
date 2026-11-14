#!/usr/bin/env python3
"""A source-checked *shared evidence* effect-cover decision model.

One certification action can seal multiple possible unsafe paths at once. In the
parallel-path reduction, paths are indexed by U and tests by subsets S_j of U.
This model is exactly weighted set cover with optional singleton guards.
All tests are assumed sound, current, and to PASS before promotion.
"""
from __future__ import annotations
from fractions import Fraction
from dataclasses import dataclass

@dataclass(frozen=True)
class Test:
    name: str
    coverage: frozenset[str]
    acquisition: Fraction
    verification: Fraction

    __test__ = False  # pytest must not collect an evidence-action record as a test class

    @property
    def cost(self):return self.acquisition+self.verification


def is_laminar(tests:list[Test]):
    sets=[t.coverage for t in tests]
    return all(not(a&b) or a<=b or b<=a for i,a in enumerate(sets) for b in sets[i+1:])


def exact_enumeration(universe:set[str],tests:list[Test],guards:dict[str,Fraction]):
    """All tested subsets; guard uncovered elements independently. 2^m enumeration."""
    if len(tests)>23:raise ValueError('This exact reference solver has exponential time')
    assert all(i in guards for i in universe)
    best=None;chosen=None
    for mask in range(1<<len(tests)):
        covered=set()
        fee=Fraction(0)
        selected=[]
        for j,t in enumerate(tests):
            if mask>>j&1:
                covered.update(t.coverage);fee+=t.cost;selected.append(t.name)
        rem=universe-covered
        fee+=sum((guards[i] for i in rem),Fraction(0))
        if best is None or fee<best:
            best=fee;chosen=(selected, sorted(rem))
    return best,chosen


def laminar_dynamic_program(universe:set[str],tests:list[Test],guards:dict[str,Fraction]):
    """Exact polynomial-time DP for laminar test families and per-item guards.

    Nodes are distinct candidate test supports, all singletons, and universal U.
    The only options at a family node are buy its test or recursively cover its
    disjoint maximal proper descendants. No overlapping alternatives exist.
    """
    if not is_laminar(tests):raise ValueError('Not laminar')
    U=frozenset(universe)
    if not U:return Fraction(0),([],[])
    if not all(t.coverage and t.coverage<=U for t in tests):raise ValueError('Bad test coverage')
    if set(guards)!=set(universe):raise ValueError('Need a guard for every universe item')
    groups={U}|{frozenset({e}) for e in universe}|{t.coverage for t in tests}
    byset={g:[] for g in groups}
    for t in tests:byset[t.coverage].append(t)
    parent={}
    for g in groups:
        if g==U:continue
        containing=[k for k in groups if g<k]
        parent[g]=min(containing,key=lambda k:len(k))
    children={g:[] for g in groups}
    for g,p in parent.items():children[p].append(g)
    for x in children:children[x].sort(key=lambda y:(len(y),sorted(y)))
    memo={}
    def solve(g):
        if g in memo:return memo[g]
        available=[]
        for t in byset[g]:
            available.append((t.cost,[t.name],[]))
        if len(g)==1:
            element=next(iter(g))
            available.append((guards[element],[],[element]))
        else:
            amounts=[solve(k) for k in children[g]]
            available.append((sum((a for a,_,_ in amounts),Fraction(0)),
                              [x for _,tests,_ in amounts for x in tests],
                              [x for _,_,gs in amounts for x in gs]))
        assert available
        result=min(available,key=lambda y:(y[0],len(y[1])+len(y[2]),tuple(y[1]),tuple(y[2])))
        memo[g]=result
        return result
    value,test_names,guard_names=solve(U)
    return value,(sorted(test_names),sorted(guard_names))


def example():
    U={'audit','deployment','training'}
    tests=[Test('one-joint-evidence',frozenset(U),Fraction(1,2),Fraction(1,2)),
           Test('audit-and-deployment',frozenset({'audit','deployment'}),Fraction(3),Fraction(2))]
    guards={x:Fraction(4) for x in U}
    return U,tests,guards

if __name__=='__main__':
    U,tests,guards=example()
    val,witness=exact_enumeration(U,tests,guards)
    dp,dpw=laminar_dynamic_program(U,tests,guards)
    assert val==dp==1
    print({'set_cover_exact':str(val),'laminar_dp_exact':str(dp),
           'selected_tests':witness[0], 'edge_local_fallback':str(sum(guards.values()))})
