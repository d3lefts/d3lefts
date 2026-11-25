"""Exact finite checks of the projection transfer; not a general proof."""
from fractions import Fraction as F
from itertools import combinations, product


def mat(n, fn):
    return [[F(fn(i, j)) for j in range(n)] for i in range(n)]


def add(a, b, c=1):
    return [[x + c*y for x,y in zip(u,v)] for u,v in zip(a,b)]


def scale(a, c):
    return [[c*x for x in row] for row in a]


def mul(a,b):
    return [[sum(x*y for x,y in zip(u,v)) for v in zip(*b)] for u in a]


def psd(a):
    a=[row[:] for row in a]
    assert all(a[i][j]==a[j][i] for i in range(len(a)) for j in range(len(a)))
    for i in range(len(a)):
        p=a[i][i]
        if p<0: return False
        if p==0:
            if any(a[i][j] for j in range(i+1,len(a))): return False
        else:
            for j in range(i+1,len(a)):
                for k in range(i+1,len(a)):
                    a[j][k]-=a[j][i]*a[i][k]/p
    return True


def average_projection(xs,w,m):
    n=len(xs); N=len(xs[0]); js=list(combinations(range(N),m))
    def entry(i,j):
        return sum(F(w[j],sum(w[t] for t in range(n) if all(xs[t][s]==xs[i][s] for s in J)))
                   for J in js if all(xs[i][s]==xs[j][s] for s in J))/len(js)
    return mat(n,entry)


def check(xs,w):
    n=len(xs); N=len(xs[0]); I=mat(n,lambda i,j:i==j)
    D=mat(n,lambda i,j:w[i] if i==j else 0)
    K=[average_projection(xs,w,m) for m in range(N+1)]
    count=0
    for m in range(1,N+1):
        A=K[m]; A2=mul(A,A); R=add(I,A,-1)
        for M in range(m,N+1):
            for k in range(1,M//m+1):
                B=add(I,K[M],-1)
                V=scale(add(A,A2,-1),F(1,k))
                assert psd(mul(D,add(V,mul(mul(A,B),A),-1)))
                assert psd(mul(D,add(add(mul(R,R),V),B,-1)))
                count+=2
    return count


def main():
    total=0; laws=0
    for N in (2,3,4):
        cube=list(product((0,1),repeat=N))
        fixtures=[(cube,[1]*len(cube)),(cube,[1+(i*i+3*i)%7 for i in range(len(cube))]),
                  (cube[::2]+[cube[-1]],[1+3*i%5 for i in range(len(cube[::2])+1)]),
                  ([x for x in cube if sum(x)%2==0],[1]*(len(cube)//2))]
        for xs,w in fixtures:
            total+=check(xs,w); laws+=1
        # On the uniform cube, parity is invisible to every proper coordinate subset.
        for m in range(N):
            P=average_projection(cube,[1]*len(cube),m)
            y=[(-1)**sum(x) for x in cube]
            assert all(sum(a*b for a,b in zip(row,y))==0 for row in P)
    print(f'{laws} laws; {total} exact PSD inequalities; parity blindness N=2,3,4 passed')


if __name__=='__main__': main()
