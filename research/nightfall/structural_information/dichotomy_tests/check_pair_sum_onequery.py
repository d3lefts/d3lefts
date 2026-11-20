#!/usr/bin/env python3
"""Exact integer/rational falsifier for one-query XOR-collision simulation.
No quantum kernel proof, no general theorem certified by finite replay.
"""
from collections import Counter
from fractions import Fraction
from random import Random
from itertools import combinations

counts = Counter()
def check(label, condition):
    counts[label] += 1
    if not condition:
        raise AssertionError((label, counts[label]))

def subcube(L):
    rows=[0]
    for code in range(3**L):
        c=code; digits=[]
        for _ in range(L):
            c, r = divmod(c, 3);digits.append(r)
        val=0
        for s in range(1<<L):
            if all(r == 2 or ((s>>j)&1) == r for j,r in enumerate(digits)):
                val|=1<<s
        rows.append(val)
    check('subcube_distinct', len(set(rows))==len(rows))
    return rows

def grid(L):
    rows=[0]
    for y in range(L):
        for x in range(L):
            u=y*L+x
            if x+1<L: rows.append((1<<u)|(1<<(u+1)))
            if y+1<L: rows.append((1<<u)|(1<<(u+L)))
    check('grid_distinct',len(set(rows))==len(rows))
    return rows

def collisions(rows):
    C=Counter(a^b for a,b in combinations(rows,2))
    check('nonzero_pair_sums',0 not in C)
    return C

def in_span(v,rows):
    piv={}
    for row in rows:
        while row:
            j=row.bit_length()-1
            if j in piv:row^=piv[j]
            else:piv[j]=row;break
    while v:
        j=v.bit_length()-1
        if j not in piv:return False
        v^=piv[j]
    return True

def psd_moments(rows,mu,seed):
    # E=I/4+(uu^t+vv^t)/(8N), so 0<=E<=I/2<=I.
    # P=diag(p), p_i=w_i^2/K, H=P^(1/2) E P^(1/2).
    N=len(rows)
    weights=[(1+(7*i+seed)%6)*(13 if (i+2*seed)%17 == 0 else 1)
             for i in range(N)]
    K=sum(w*w for w in weights)
    u=[1 if (i*5+seed)%3 else -1 for i in range(N)]
    v=[1 if (i*7+seed)%5 else -1 for i in range(N)]
    numerator=Counter()
    for i,j in combinations(range(N),2):
        val=weights[i]*weights[j]*(u[i]*u[j]+v[i]*v[j])
        numerator[rows[i]^rows[j]]+=val
    den=4*N*K
    # Claude's initial row-norm influence: for one-query spectra, norm is 1
    # for a queried row and 2 otherwise (all nonzero spectra are <=2R).
    # Exact integer theorem: max Inf >= Var^3 / (64 mu^2).
    R=set(rows)-{0}
    varnum=sum(a*a for a in numerator.values())
    if varnum:
        maxinf=0
        for g in R:
            infnum=numerator[g]**2
            for b in R:
                gamma=g^b
                if gamma and gamma not in R:
                    infnum+=numerator[gamma]**2
            maxinf=max(maxinf,infnum)
        check('row_influence_bound',
              64*mu*mu*maxinf*den**4 >= varnum**3)
    for eta in (Fraction(1,500),Fraction(1,80),Fraction(1,20),
                Fraction(1,5),Fraction(3,5)):
        S=[rows[i] for i in range(N)
           if Fraction(weights[i]**2,K)>=eta]
        captured={g for g in numerator if in_span(g,S)}
        tail=sum(a*a for g,a in numerator.items() if g not in captured)
        check('exact_mse_tail',Fraction(tail,den*den) <= 4*mu*eta)
        check('query_count',len(S)<=1/eta)
        bits=max(rows).bit_length()
        if bits<=9 and len(rows)<=20:
            coeff={g:a for g,a in numerator.items() if g not in captured}
            sq=0
            for s in range(1<<bits):
                err=sum(a*(1 if ((g&s).bit_count()&1)==0 else -1)
                        for g,a in coeff.items())
                sq+=err*err
            check('explicit_parseval',sq==(1<<bits)*tail)


def span_words(gens):
    V={0}
    for x in gens:
        V |= {v^x for v in tuple(V)}
    return V

def quotient_audit():
    rng=Random(20261119)
    for m in range(3,8):
        for trial in range(40):
            R=rng.sample(list(range(1<<m)),rng.randrange(2,min(20,1<<m)+1))
            A=sorted(set(R)|{0})
            C=collisions(A)
            mu=max(C.values(),default=0)
            for q in range(min(4,m)+1):
                W=span_words(rng.sample(R,min(q,len(R))))
                canon=lambda x:min(x^w for w in W)
                Q=sorted({canon(a) for a in A})
                counts_Q=Counter(canon(a^b) for a,b in combinations(Q,2))
                mu_Q=max(counts_Q.values(),default=0)
                check('quotient_transfer',mu_Q<=len(W)*mu)
                for freq,num in counts_Q.items():
                    check('quotient_coset_injection',
                          num<=sum(C[freq^w] for w in W))

def main():
    table=[]
    for L in range(1,7):
        R=subcube(L);C=collisions(R);mu=max(C.values())
        check('subcube_exact_mu',mu==max(L+1,3) if L>=2 else mu==2)
        for r in R[1:]:check('subcube_rankone_multiplicity',C[r]==L+1)
        if L<=5:psd_moments(R,mu,L)
        table.append(('subcube',L,len(R),mu))
    for L in range(2,8):
        R=grid(L);C=collisions(R);mu=max(C.values())
        check('grid_exact_mu',mu==2)
        if L<=5:psd_moments(R,mu,L+20)
        table.append(('grid',L,len(R),mu))
    for n in range(2,11):
        R=[0]+[1<<i for i in range(1,n+1)]+[(1<<i)|1 for i in range(1,n+1)]
        C=collisions(R)
        check('paired_latent_exact_mu',max(C.values())==n and C[1]==n)
        table.append(('paired-latent',n,len(R),n))
    for m in range(1,6):
        R=list(range(1<<m));C=collisions(R);mu=max(C.values())
        check('BV_exact_mu',mu==2**(m-1))
        psd_moments(R,mu,m+50)
        table.append(('BV',m,len(R),mu))
    quotient_audit()
    print('PASS finite one-query pair-sum PSD/frequency/Parseval audit')
    for row in table: print('FAMILY',*row)
    print('COUNTS',dict(sorted(counts.items())))

if __name__=='__main__':main()
