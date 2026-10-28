"""Exact independent determinant/forest validator for saturated AP midpoint systems.
    Cited algorithm: Matrix-forest identity; audited on fixed test inputs.
"""
from itertools import product
from random import Random
from fractions import Fraction

def det_bareiss(a):
    a=[list(map(int,r)) for r in a]; n=len(a); denom=1; sign=1
    for k in range(n-1):
        if not a[k][k]:
            p=next((j for j in range(k+1,n) if a[j][k]),None)
            assert p is not None
            a[k],a[p]=a[p],a[k];sign=-sign
        x=a[k][k]
        for i in range(k+1,n):
            for j in range(k+1,n):
                numer=a[i][j]*x-a[i][k]*a[k][j]
                assert numer%denom==0
                a[i][j]=numer//denom
            a[i][k]=0
        denom=x
    return sign*a[-1][-1]

def system(pairs):
    n=len(pairs)+2
    a=[[0]*(n-2) for _ in range(n-2)]
    rhs=[0]*(n-2)
    for i,(l,r) in enumerate(pairs,1):
        assert 0<=l<i<r<n
        a[i-1][i-1]=2
        if l>0:a[i-1][l-1]-=1
        if r<n-1:a[i-1][r-1]-=1
        else:rhs[i-1]+=1
    return a,rhs

def replace_col(a,rhs,j):
    return [[rhs[i] if k==j else x for k,x in enumerate(row)] for i,row in enumerate(a)]

def forest_counts(pairs):
    n=len(pairs)+2; F=0; F17=[0]*(n-2)
    for choices in product((0,1),repeat=n-2):
        nxt={i:(pairs[i-1][choices[i-1]]) for i in range(1,n-1)}
        roots=[]
        for start in range(1,n-1):
            v=start; seen=set()
            while v not in (0,n-1) and v not in seen:
                seen.add(v);v=nxt[v]
            if v not in (0,n-1):break
            roots.append(v)
        else:
            F+=1
            for j,r in enumerate(roots):
                if r==n-1:F17[j]+=1
    return F,F17

# 14-point real examples from the independent public 9-type list.
EXAMPLES=[
(0,542,634,774,859,997,1006,1015,1084,1171,1268,1336,1452,1898),
(0,106,195,212,229,290,390,408,454,458,474,490,500,526),
]

def pairs_from_A(A):
    pairs=[]
    for i in range(1,len(A)-1):
        opt=[(l,r) for l in range(i) for r in range(i+1,len(A)) if A[l]+A[r]==2*A[i]]
        assert len(opt)==1,(i,opt)
        pairs.append(opt[0])
    return pairs

if __name__=='__main__':
    for idx,A in enumerate(EXAMPLES,1):
        ps=pairs_from_A(A)
        mat,rhs=system(ps)
        D=det_bareiss(mat)
        adj=[det_bareiss(replace_col(mat,rhs,j)) for j in range(len(ps))]
        F,F17=forest_counts(ps)
        assert D==F and adj==F17
        assert all(F*A[i]==F17[i-1]*A[-1] for i in range(1,len(A)-1))
        assert F<=2**len(ps)
        print('14-point example',idx,'det',D,'forest',F,'maxwidth',2**len(ps),'coordinates',F17)
    rng=Random(20261025)
    for i in range(6):
        ps=[(rng.randrange(j),rng.randrange(j+1,18)) for j in range(1,17)]
        mat,rhs=system(ps)
        D=det_bareiss(mat)
        adj=[det_bareiss(replace_col(mat,rhs,j)) for j in range(16)]
        F,F17=forest_counts(ps)
        assert D==F and adj==F17
        assert 0<F<=65536
        print('random n=18',i,'integer span',F,'increasing',all(a<b for a,b in zip([0]+F17,F17+[F])), 'forest==det',True)
    print('PASS')