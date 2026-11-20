#!/usr/bin/env python3
"""NIGHTFALL finite adversarial witnesses, no theorem certification.
Reproducibly verifies sparse invertible parity encodings, exact ranks,
and the algebraic rank/low-Wyner mixture gap. Python stdlib only.
"""
from fractions import Fraction as F
from math import log2

def parity_encoder(z: int, m: int) -> int:
    return sum(((((z >> i) & 1) ^ (((z >> (i-1)) & 1) if i else 0)) << i) for i in range(m))

def rank_mod(A, prime=1000003):
    A=[[v % prime for v in row] for row in A]
    n=len(A); r=0
    for c in range(len(A[0])):
        k=next((j for j in range(r,n) if A[j][c]), None)
        if k is None: continue
        A[r],A[k]=A[k],A[r]
        inv=pow(A[r][c],-1,prime)
        for j in range(r+1,n):
            if A[j][c]:
                factor=A[j][c]*inv % prime
                for h in range(c,len(A[j])):
                    A[j][h]=(A[j][h]-factor*A[r][h])%prime
        r+=1
        if r==n:break
    return r

def apply_rows(z, masks):
    return sum((((z & mask).bit_count() & 1) << i) for i,mask in enumerate(masks))

def check_entangled_block():
    L=(3,5,7,9); Li=(7,6,5,15)
    R=(6,10,11,14); Ri=(6,11,10,9)
    assert len(set(L+R))==8
    assert all(2 <= mask.bit_count() <= 3 for mask in L+R)
    for z in range(16):
        a=apply_rows(z,L); b=apply_rows(z,R)
        assert apply_rows(a,Li)==z
        assert apply_rows(b,Ri)==z
    assert max(x.bit_count() for x in Li)==4
    assert max(x.bit_count() for x in Ri)==3
    print('LOCAL_4X4_NO_RAW_BITS_OR_DUPLICATED_FORMS_PASS')

def check(m):
    assert m>=2
    K=1<<m
    code=[parity_encoder(z,m) for z in range(K)]
    assert len(set(code))==K
    for z in range(K):
        assert z == sum(((sum((code[z]>>j)&1 for j in range(i+1))%2)<<i) for i in range(m))
        for i in range(m):
            asserted=((z>>i)&1)^(((z>>(i-1))&1) if i else 0)
            assert ((code[z]>>i)&1)==asserted
    P=[[int(code[a]==b) for b in range(K)] for a in range(K)]
    assert rank_mod(P)==K
    # The rare diagonal mixture has P(A,B)=((m-1)J+K I)/(m K^2).
    # Its determinant after multiplying by m K^2 is m*K^K (rank K).
    rare=[[m-1+(K if a==b else 0) for b in range(K)] for a in range(K)]
    assert rank_mod(rare)==K
    for a in range(K):
        assert sum(rare[a])==m*K
    assert sum(map(sum,rare))==m*K*K
    assert K**(K-1)*(K+(m-1)*K)==m*(K**K)
    eta=1/m
    wyner_upper=-(eta*log2(eta)+(1-eta)*log2(1-eta))+eta*m
    assert wyner_upper<=2.0000000001
    return (m,K,rank_mod(P),rank_mod(rare),wyner_upper)

if __name__=='__main__':
    check_entangled_block()
    for m in (2,3,4,5):
        print('CHECK',*check(m))
    print('ORACLE_RELATIVE_STRUCTURAL_INFORMATION_EXACT_REPLAY_PASS')
