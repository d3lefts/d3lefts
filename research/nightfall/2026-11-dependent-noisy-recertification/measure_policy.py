#!/usr/bin/env python3
"""Exact independent world-by-world replay of an acquired policy."""
from fractions import Fraction as Q
from recert import Solver, obs, joint, TESTS

def policy_report(s:Solver):
    s.solve()
    root=s.root
    root_mass=s.mass(root)
    cost=Q(0); allow_wrong=Q(0); deny_wrong=Q(0)
    safe_mass=Q(0); unsafe_mass=Q(0)
    terminals={}
    for w,p in s.law.items():
        if any(obs(w,k)!=v for k,v in root):continue
        mass=p/root_mass
        safe=(w.a==w.u)
        if safe:safe_mass+=mass
        else:unsafe_mass+=mass
        h=root; wc=Q(0)
        while True:
            choice=s.record[h]['choice']
            if choice=='authorize':
                if not safe:allow_wrong+=mass
                terminals[h]=choice
                break
            if choice=='deny':
                if safe:deny_wrong+=mass
                terminals[h]=choice
                break
            wc+=s.tests[choice].cost
            h=tuple(sorted(h+((choice,obs(w,choice)),)))
        cost+=mass*wc
    assert safe_mass+unsafe_mass==1 and cost==s.solve()
    assert all((s.record[h]['unsafe']<=s.delta if a=='authorize' else 1-s.record[h]['unsafe']<=s.eta)
               for h,a in terminals.items())
    return {
        'expected_cost':str(cost),
        'joint_unsafe_authorization':str(allow_wrong),
        'joint_false_denial':str(deny_wrong),
        'conditional_on_unsafe_authorization_rate':str(allow_wrong/unsafe_mass),
        'conditional_on_safe_denial_rate':str(deny_wrong/safe_mass),
        'terminal_histories_reached':len(terminals),
    }
if __name__=='__main__':
  for cache in ({},{'z':0},{'z':1}):
    s=Solver(joint(),cache=cache)
    print(cache,policy_report(s))
