#!/usr/bin/env python3
"""Cheap independent stress tests of the unconditional additive upper-tail hole theorem."""
from itertools import product

def audit(D,q):
    v=(2*D-1,D+1);w=(-1,D+1)
    T={((x+a*v[0]+b*w[0])%q,(y+(a+b)*(D+1))%q)
       for x,y,a,b in product(range(D),range(D),(0,1),(0,1))}
    assert len(T)==4*D*D,(D,q,len(T))
    target=((2*D-2)%q,(2*D+1)%q)
    I=range(2*D-1)
    for a,b in product(range(3),repeat=2):
        X={(x+a*v[0]+b*w[0])%q for x in I}
        Y={(y+(a+b)*(D+1))%q for y in I}
        assert target not in set(product(X,Y)),(D,q,a,b)
    return True

def main():
    n=0
    for D in (8,16,32):
        for q in range(4*D-3,7*D+1):
            assert audit(D,q)
            n+=1
    assert n==sum(3*D+4 for D in (8,16,32))
    print(f'PASS: {n} integral moduli, all nine sumset rectangles, disjoint 4-tile cube')

if __name__=='__main__':main()
