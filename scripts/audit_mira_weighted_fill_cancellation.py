#!/usr/bin/env python3
"""Exact finite cross-fill cancellation and exterior exchangeability test.

Tests a concrete valid target Latin square, balanced mark, real free fills,
rational soft factors. Does NOT prove the asymptotic error or sampler.
Pinned source Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from fractions import Fraction
from itertools import combinations
from math import prod,log

def row(n,i):
    return {(c,(c+i)%n) for c in range(n)}

def main():
    n,b,q=15,5,2
    colors=tuple(range(b))
    rows={i:row(n,i) for i in range(n)}
    owned={j: {c for c in range(n) if c%b==j} for j in colors}
    mark=set().union(*(set((c,(c+j)%n) for c in owned[j]) for j in colors))
    assert len(mark)==n and len({y for c,y in mark})==n
    cols=[{c for c,y in (mark&rows[j])} for j in colors]
    syms=[{y for c,y in (mark&rows[j])} for j in colors]
    s=[n-len(cols[j]) for j in colors]
    assert s==[12]*b
    boxes=[{(c,y) for c in range(n) if c not in cols[j]
                   for y in range(n) if y not in syms[j]} for j in colors]
    fill=[rows[j]-mark for j in colors]
    exterior=rows[5]|rows[6]
    hard=[]
    for j in colors:
        prev=set().union(*fill[:j])
        h=boxes[j]&(exterior|mark|prev)
        assert len(h)==len(boxes[j]&exterior)+s[j]+sum(len(fill[i]&boxes[j]) for i in range(j))
        assert fill[j] <= boxes[j]-h
        hard.append(h)
    direct=sum((Fraction(len(hard[j]),s[j]) for j in colors),Fraction())
    credit=sum((Fraction(len(fill[i]&boxes[j]),s[j]) for j in colors for i in range(j)),Fraction())
    ext=sum((Fraction(len(exterior&boxes[j]),s[j]) for j in colors),Fraction())
    assert direct-credit==b+ext and credit==5
    overlap=sum((Fraction(len(boxes[i]&boxes[j]),s[i]*s[j]) for i in colors for j in range(i+1,b)),Fraction())
    L=b+overlap
    assert L==Fraction(85,8)
    assert L>=Fraction(b*(b-1),2)+Fraction(1,2)+Fraction(1,2*b)
    for j in colors:
        phi=prod((1-Fraction(1,s[k]) for e in fill[j]
                  for k in range(j+1,b) if e in boxes[k]),start=Fraction(1))
        assert 0<phi<=1
        linear=sum((Fraction(len(fill[j]&boxes[k]),s[k]) for k in range(j+1,b)),Fraction())
        remainder=-log(float(phi))-float(linear)
        assert -1e-11<=remainder<=2*sum(len(fill[j]&boxes[k])/s[k]**2 for k in range(j+1,b))+1e-11
    remainder_colors=sorted(set(range(n))-set(colors))
    samples=list(combinations(remainder_colors,q))
    mean=sum((sum((Fraction(len((rows[i]|rows[k])&boxes[j]),s[j]) for j in colors),Fraction())
              for i,k in samples),Fraction())/len(samples)
    Tb=set().union(*(rows[i] for i in colors))
    formula=Fraction(q,n-b)*(sum(s)-sum((Fraction(len(Tb&boxes[j]),s[j]) for j in colors),Fraction()))
    assert mean==formula==8
    print(f'n={n} b={b} q={q} credit={credit} Lambda={L} extmean={mean}')
    print('WEIGHTED_FILL_FIRST_ORDER_EXACT_REPLAY_PASS; asymptotic proof is separate')

if __name__=='__main__':main()
