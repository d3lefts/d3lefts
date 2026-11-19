#!/usr/bin/env python3
"""NIGHTFALL / Mira degree-two endpoint; exact finite replay only.

Author-side asymptotic theorem is in mira-latin-author-side-v23.md.
Pinned Mira source: 30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from collections import Counter
from fractions import Fraction
from itertools import combinations, product
from math import factorial

def coeffs(N):
    a = [[Fraction(1)], [Fraction(0)]]
    for n in range(1, N):
        previous, before = a[n], a[n-1]
        p = [Fraction(0)] * max(len(previous), len(before)+1)
        for k, v in enumerate(previous):
            p[k] += Fraction(n, n+1)*v
        for k, v in enumerate(before):
            p[k+1] += v/(n+1)
        a.append(p)
    return a

def evaluate(p,theta):
    return sum((c*theta**k for k,c in enumerate(p)),Fraction())

def direct(n):
    rows = [sum(1<<j for j in c) for c in combinations(range(n),2)]
    hist=Counter()
    for board in product(rows,repeat=n):
        if any(sum(bool(r>>j&1) for r in board)!=2 for j in range(n)):
            continue
        visited=set(); count=0
        for root in range(n):
            if root in visited:
                continue
            count+=1; visited.add(root); stack=[root]
            while stack:
                i=stack.pop()
                for j in range(n):
                    if not board[i]>>j & 1:continue
                    for k in range(n):
                        if board[k]>>j & 1 and k not in visited:
                            visited.add(k); stack.append(k)
        hist[count]+=1
    return hist

def main():
    a=coeffs(6)
    for n in range(2,6):
        hist=direct(n)
        count=sum(hist.values())
        assert count==factorial(n)**2*evaluate(a[n],Fraction(1,2))
        for k,v in hist.items():
            assert factorial(n)**2*a[n][k]/2**k==v
        mean=Fraction(sum(2**k*v for k,v in hist.items()),count)
        assert mean==evaluate(a[n],Fraction(1))/evaluate(a[n],Fraction(1,2))
        tv=Fraction(sum(v*abs(Fraction(2**k,mean)-1) for k,v in hist.items()),2*count)
        expected={2:Fraction(0),3:Fraction(0),4:Fraction(2,15),5:Fraction(30,187)}[n]
        assert tv==expected
        print(f'n={n} N_2={count} m_2={mean} t_2={tv} components={dict(hist)}')
    print('DEGREE_TWO_EXACT_CYCLE_SPECIES_REPLAY_PASS; asymptotic proof is separate')

if __name__=='__main__':main()
