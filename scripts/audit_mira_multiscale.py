#!/usr/bin/env python3
"""Exact rational replay of conditional multiscale forward/reverse laws.
Tests finite witnesses, not the asymptotic Latin-square sampler theorem.
Original source Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253.
"""
from fractions import Fraction as F
from math import ceil, log2

def test(name, targets, H, M):
    m=2**ceil(log2(M));J=ceil(log2(M));u=F(1,64)
    total=sum((R*z/H for rows in targets.values() for R,z in rows),F(0))
    assert total<=1
    for s, rows in targets.items():
        assert sum((R for R,z in rows),F(0))==1
        assert sum((R*z for R,z in rows),F(0))>=1
        f=[]
        for j in range(J+1):
            mj=2**j
            forward=sum((R*z/H*F(mj,mj+z) for R,z in rows),F(0))
            reverse=sum((R*F(z*mj,mj+z) for R,z in rows),F(0))
            assert forward==reverse/H
            f.append(reverse)
        assert f[J]>=F(1,3),(name,s,f[J])
        r=[u/(u+fi) for fi in f]
        mass=F(0)
        for j in range(J+1):
            prefix=F(1)
            for i in range(j):prefix*=r[i]
            mass+=F(1,J+1)*(f[j]/H)*prefix*(r[j] if j<J else u/f[J])
        assert mass==u/(H*(J+1)),(name,s,mass)
        p=r[J];assert p<F(1,5)
        assert p/(1-p)==u/f[J]
    N=len(targets)
    assert sum((u/(H*(J+1)) for _ in targets),F(0))==F(N)*u/(H*(J+1))
    print(name,'targets',N,'J',J,'success_mass',F(N)*u/(H*(J+1)),'forward_mass',total)

def main():
    test('ordinary',{0:[(F(1,3),F(5)),(F(2,3),F(2))],1:[(F(1,2),F(3)),(F(1,2),F(4))],2:[(F(2,5),F(2)),(F(3,5),F(6))]},F(100),8)
    test('heavy-tail',{0:[(F(1,2),F(1,1000)),(F(1,2),F(1000000))],1:[(F(3,4),F(1,10)),(F(1,4),F(10**6))]},F(10**10),20)
    print('MIRA_MULTISCALE_EXACT_RATIONAL_REPLAY_PASS; full mean/cost proof separate')

if __name__=='__main__':main()
