#!/usr/bin/env python3
"""Exact sparse maintenance of signed-lag Erdős overlap certificates.

This is a toy-model finite falsifier for an algebraic lifecycle update law,
not a purported replay of a historical 131072-cell witness.
Python standard library integers; no third-party dependencies.
"""
from random import Random

def all_scores(A,D):
    n=len(A)
    return {k:sum(A[i]*(D-A[i-k]) for i in range(n) if 0<=i-k<n)
            for k in range(1-n,n)}

def sparse_delta(A,D,edits,k):
    """O(number of edits) arithmetic for one signed-lag score change."""
    n=len(A)
    change=0
    for i,di in edits.items():
        if 0<=i-k<n:
            change+=di*(D-A[i-k])
        if 0<=i+k<n:
            change-=A[i+k]*di
        if 0<=i-k<n:
            change-=di*edits.get(i-k,0)
    return change

def uniform_bound(D,edits):
    L1=sum(abs(d) for d in edits.values())
    Linf=max([0]+[abs(d) for d in edits.values()])
    return (2*D+Linf)*L1

def guaranteed_stable_peak(scores,edits,D):
    """Only a sufficient condition; False does NOT prove a change."""
    winner=max(scores,key=scores.get)
    second=max((v for k,v in scores.items() if k!=winner),
               default=-(10**100))
    gap=scores[winner]-second
    allowance=2*uniform_bound(D,edits)
    return winner,gap,allowance,gap>allowance

def main():
    R=Random(202611131921)
    tested=0
    shifts=0
    stable_checked=0
    for n in range(2,29,2):
        for trial in range(110):
            D=R.choice((2,5,16,128,1024))
            A=[R.randint(0,D) for _ in range(n)]
            changed=A[:]
            affected=R.sample(range(n),R.randint(0,min(6,n)))
            for i in affected:
                changed[i]=R.randint(0,D)
            edits={i:changed[i]-A[i] for i in range(n)
                   if A[i]!=changed[i]}
            original=all_scores(A,D)
            brute=all_scores(changed,D)
            for k,oldscore in original.items():
                dscore=sparse_delta(A,D,edits,k)
                assert oldscore+dscore==brute[k],(n,trial,k)
                assert abs(dscore)<=uniform_bound(D,edits)
                shifts+=1
            winner,gap,tolerance,stable=guaranteed_stable_peak(
                original,edits,D)
            if stable:
                assert winner==max(brute,key=brute.get)
                stable_checked+=1
            tested+=1

    # Validate feasibility and total mass conservation for a genuine input law.
    N,D=8,12
    original=[6]*N
    edits={0:1,1:-1}
    modified=[original[i]+edits.get(i,0) for i in range(N)]
    assert sum(original)==sum(modified)==(N//2)*D
    assert all(0<=a<=D for a in modified)
    for k in range(1-N,N):
        assert (all_scores(modified,D)[k]-all_scores(original,D)[k]
                ==sparse_delta(original,D,edits,k))
    print({
        "synthetic_models":tested,
        "exact_signed_lag_comparisons":shifts,
        "stability_certificates_checked":stable_checked,
        "mass_preserving_example":"PASS",
        "result":"PASS",
    })

if __name__=="__main__":
    main()
