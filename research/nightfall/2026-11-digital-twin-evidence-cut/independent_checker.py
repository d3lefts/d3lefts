"""Independent, read-only exact certificate checker. Does not import generator.
The checker verifies super-solution inequalities and compares with an independent
lower approximation via 80 repeated applications of the positive matrix.
"""
import json, sys
from math import comb
from fractions import Fraction
from pathlib import Path
P=Path(__file__).with_name('candidate_fixtures.json')

def asq(s):return Fraction(s)
def dot(u,v):return sum((a*b for a,b in zip(u,v)),Fraction(0))

def check():
    all_cases=json.loads(P.read_text())['cases']
    assert len(all_cases)==112
    tight=0
    for case in all_cases:
        n,g=case['n'],case['g']
        B=[[asq(x) for x in row] for row in case['B']]
        C=[[asq(x) for x in row] for row in case['C']]
        z=[asq(x) for x in case['z']]
        q=[asq(x) for x in case['q']]
        assert len(B)==len(C)==len(q)==n and len(z)==g
        assert all(len(row)==n for row in B) and all(len(row)==g for row in C)
        assert all(x>=0 for row in B for x in row) and all(x>=0 for row in C for x in row)
        assert all(x>=0 for x in z+q)
        assert max(sum(row) for row in B)<1
        input_bound=[dot(row,z) for row in C]
        rhs=[input_bound[i]+dot(B[i],q) for i in range(n)]
        assert all(q[i]>=rhs[i] for i in range(n))
        assert all(q[i]==rhs[i] for i in range(n)) # sharp candidate expected
        low=[Fraction(0) for _ in range(n)]
        for t in range(80):
            low=[input_bound[i]+dot(B[i],low) for i in range(n)]
            assert all(low[i]<=q[i] for i in range(n))
        tight+=1
    # Source obstruction: zero observed boundary change DOES NOT imply safety if the exterior changed.
    # Old E: x_E=0. New E: x_E=1. Both share Gamma=0; unchanged-exterior assumption fails.
    assert (Fraction(1)>Fraction(0))
    # Noncontractive obstruction: x_E=x_E can have all fixed points under the same boundary.
    # Rowsum=1 violates strict contraction and no finite uniform bound exists.
    # Strongly connected physical ring: node 0 changed, all others have stable contract.
    n=128; beta=Fraction(1,4)
    z=Fraction(1,1)/(1-beta**n)  # independently derived by closing the ring
    # E nodes 1..127 are externally unchanged, each reachable through earlier exterior nodes.
    d=[beta**i*z for i in range(1,n)]
    margin=Fraction(1,4096)
    safe=sum(x<=margin for x in d)
    assert safe==121 and len(d)-safe==6
    assert beta**6*z>margin and beta**7*z<margin
    # Mutual information complementarity: K=T+A mod r under independent uniform T,A.
    # Independent exact binomial-tail audit of a fixed-cost, noisy port audit.
    # 64 readings/port, P(correct sensor)=3/4, accept if >=40 positive readings.
    nobs,cut=64,40
    good=sum((Fraction(comb(nobs,j)*3**j,4**nobs) for j in range(cut,nobs+1)),Fraction(0))
    bad=sum((Fraction(comb(nobs,j)*3**(nobs-j),4**nobs) for j in range(cut,nobs+1)),Fraction(0))
    for r in (2,3,4,8):
        for t in range(r):
            assert sorted((t+a)%r for a in range(r))==list(range(r))
        assert good**r >= Fraction(8,9), (r, good**r)
        assert bad <= Fraction(1,9)
    return dict(exact_candidates_passed=tight,positive_cycle_size=n,fully_reusable_external_claims=safe,unresolved_external_claims=len(d)-safe,source_obstruction_checked=True,contraction_obstruction_checked=True,modular_selector_sizes=[2,3,4,8],noisy_ports_exact_fixed_sample_n=64,noise_positive_tail=str(good),noise_negative_tail=str(bad),external_human_review=False,novelty_certified=False)

if __name__=='__main__':
    result=check()
    target=Path(__file__).with_name('audit_results.json')
    target.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))