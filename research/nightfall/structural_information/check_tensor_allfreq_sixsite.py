#!/usr/bin/env python3
"""Independent adversarial check of the six-active-site primitive XOR mechanism.

Tests *sets of tensor rows* over F2.  No quantum assumptions or imports from
other NIGHTFALL checkers. Exhaustive primitive tuples through L=3, sampled
L=4..7; also checks a deliberately constructed 8-row zero-sum circuit
with six active sites. This is NOT an all-L proof of Lovitz-Petrov or T2.
"""
from collections import Counter
from itertools import combinations, product
import random

def mask(words):
    xs = [0]
    for v in words:
        xs = [2*x+b for x in xs for b in
              ((0,1) if v==3 else ((0,) if v==1 else (1,)))]
    return sum(1 << t for t in xs)

def primitive(rows):
    if not rows:
        return False
    for k in range(1,len(rows)+1):
        for c in combinations(rows,k):
            z=0
            for r in c:z ^= r
            if z==0:return False
    return True

def xor(rows):
    z=0
    for r in rows:z ^= r
    return z

def active(circuit_words):
    size=len(next(iter(circuit_words)))
    return {j for j in range(size)
            if len({w[j] for w in circuit_words})>1}

def audit_pair(reference, candidate, word_to_mask):
    assert primitive(tuple(word_to_mask[w] for w in reference))
    assert primitive(tuple(word_to_mask[w] for w in candidate))
    assert xor(word_to_mask[w] for w in reference)==xor(word_to_mask[w] for w in candidate)
    left=set(reference); right=set(candidate)
    remains=set(left.symmetric_difference(right))
    u=set()
    partitions=0
    while remains:
        ordered=sorted(remains)
        found=None
        for k in range(1,len(ordered)+1):
            for grp in combinations(ordered,k):
                if xor(word_to_mask[w] for w in grp)==0:
                    found=set(grp);break
            if found is not None:break
        assert found, "Symmetric-difference XOR zero invariant failed"
        assert found & (left-right) and found & (right-left)
        v=active(found)
        assert len(v)<=len(found)-2, (len(found),len(v),found)
        u |= v
        remains -= found
        partitions += 1
    assert len(u)<=6,(len(u),reference,candidate)
    for a in candidate:
        assert any(all(a[j]==b[j] for j in range(len(a)) if j not in u)
                   for b in reference),(a,reference,u)
    return len(u), partitions

def generate(L):
    ws=list(product((1,2,3),repeat=L))
    return ws, {w:mask(w) for w in ws}

def check_level(L, n_random=22000):
    words, wt = generate(L)
    rng=random.Random(9812026+L)
    C={}
    tried=0
    hist=Counter()
    for k in (1,2,3,4):
        if L<=3:
            seq=combinations(words,k)
        else:
            seq=(tuple(sorted(rng.sample(words,k))) for _ in range(n_random//4))
        for rows in seq:
            if not primitive(tuple(wt[w] for w in rows)):
                continue
            z=xor(wt[w] for w in rows)
            assert z!=0
            if z in C:
                a,q=audit_pair(C[z],rows,wt)
                hist[a]+=1
                tried+=1
            else:
                C[z]=rows
    print(f'L={L} source_rows={len(words)} reference_freq={len(C)} '
          f'repeated_freq_pairs={tried} max_active={max(hist,default=0)} PASS')
    return tried

def hard_six_site():
    L=8
    wt=generate(L)[1]
    def c(triple):
        fs=((3,1,1),(2,3,1),(2,2,2),(2,2,3))
        ans=[]
        for row in fs:
            a=[1]*L
            for j,v in zip(triple,row):a[j]=v
            ans.append(tuple(a))
        return tuple(ans)
    a,b=c((0,1,2)),c((3,4,5))
    assert xor(wt[r] for r in a)==xor(wt[r] for r in b)==wt[(1,)*L]
    support,partitions=audit_pair(a,b,wt)
    assert support==6 and partitions==1,(support,partitions)
    print('HARD SIX-SITE: eight-row binary product circuit, exactly 6 active sites, PASS')

def main():
    for L in range(1,8):
        check_level(L)
    hard_six_site()
    print('PASS: independent six-site circuit decomposition finite tests only.')

if __name__=='__main__':main()
