#!/usr/bin/env python3
"""Public lightweight verifier of the review series' finite, exact core.
This is a separate small checker from the 27,740-case frozen-ZIP checker.
It must not be described as that checker or as a general theorem proof.
"""
from itertools import product
from fractions import Fraction

def blocks(view):
    return [tuple(i for i,v in enumerate(view) if v==tag) for tag in sorted(set(view))]

def evaluate(n):
    total=0
    for view in product(range(n),repeat=n):
        b=blocks(view)
        for label in product((0,1),repeat=n):
            desc=all(len({label[i] for i in group})==1 for group in b)
            dec=any(all(dict(zip(sorted(set(view)),a))[view[i]]==label[i] for i in range(n))
                    for a in product((0,1),repeat=len(b)))
            assert desc==dec
            allowed={i for group in b if all(label[j] for j in group) for i in group}
            for mask in product((0,1),repeat=len(b)):
                got={i for flag,group in zip(mask,b) if flag for i in group}
                if all(label[i] for i in got): assert got<=allowed
            total+=1
    return total

def tv_check():
    count=0
    for x,y in product(range(1,4),repeat=2):
        a=(Fraction(x,x+1),Fraction(1,x+1))
        b=(Fraction(y,y+1),Fraction(1,y+1))
        tv=sum(map(lambda z:abs(z[0]-z[1]),zip(a,b)),Fraction(0))/2
        for decisions in product((0,1),repeat=2):
            ex=sum((a[i] for i in range(2) if decisions[i]),Fraction(0))
            ey=sum((b[i] for i in range(2) if not decisions[i]),Fraction(0))
            assert ex+ey>=1-tv
            count+=1
    return count

if __name__=="__main__":
    count=sum(evaluate(n) for n in range(1,5))
    print("PASS: ",count,"small view-label instances;",tv_check(),"two-world instances")
