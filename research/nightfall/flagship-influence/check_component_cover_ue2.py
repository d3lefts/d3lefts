#!/usr/bin/env python3
"""Exact finite-product ANOVA/covers/real-influence audit (stdlib Fraction only).

Checks numerical instances of the author-side componentwise fractional-cover
influence theorem. Does NOT certify the universal conjecture, general theorem,
or independent peer review. Exact products may have heterogeneous alphabets.
"""
from fractions import Fraction as F
from itertools import product, combinations
from functools import reduce


def subsets(items):
    items = tuple(items)
    return (c for k in range(len(items) + 1) for c in combinations(items,k))


def audit(marginals, fn, proposed_covers, label):
    m = len(marginals)
    assert all(sum(p) == 1 and all(x > 0 for x in p) for p in marginals)
    states = list(product(*(range(len(p)) for p in marginals)))
    probs = {x: reduce(lambda a, b: a*b, (marginals[i][x[i]] for i in range(m)), F(1)) for x in states}
    assert sum(probs.values()) == 1
    vals = {x:F(fn(x)) for x in states}
    I = tuple(range(m))
    subsets_ = list(subsets(I))
    means = {}
    for S in subsets_:
        sums={}
        for x in states:
            key=tuple(x[i] for i in S)
            sums[key]=sums.get(key,F(0))+probs[x]*vals[x]
        means[S]={key:y/reduce(lambda a,b:a*b,(marginals[i][key[j]] for j,i in enumerate(S)),F(1)) for key,y in sums.items()}
    components={}
    energy={}
    for S in subsets_:
        fs={}
        for key in means[S]:
            fs[key]=sum(((-1)**(len(S)-len(T))*means[T][tuple(key[S.index(i)] for i in T)] for T in subsets(S)),F(0))
        components[S]=fs
        energy[S]=sum((probs[x]*fs[tuple(x[i] for i in S)]**2 for x in states),F(0))
    mean=means[()][()]
    V=sum((probs[x]*(vals[x]-mean)**2 for x in states),F(0))
    assert sum(energy[S] for S in subsets_ if S) == V
    influence={}
    for i in I:
        T=tuple(j for j in I if j!=i)
        projection_second=sum((probs[x]*means[T][tuple(x[j] for j in T)]**2 for x in states),F(0))
        I_i=sum((probs[x]*vals[x]**2 for x in states),F(0))-projection_second
        assert I_i == sum((energy[S] for S in subsets_ if i in S),F(0))
        influence[i]=I_i
    active=[S for S in subsets_ if S and energy[S] > 0]
    parent=list(range(m))
    def find(i):
        while parent[i]!=i:
            parent[i]=parent[parent[i]]
            i=parent[i]
        return i
    for S in active:
        for i in S[1:]:parent[find(i)]=find(S[0])
    groups={}
    for S in active:groups.setdefault(find(S[0]),[]).append(S)
    assert len(groups)==len(proposed_covers), (label,groups,proposed_covers)
    cover_costs=[]
    B_parts=[]
    for Slist in groups.values():
        coord=frozenset(i for S in Slist for i in S)
        covers=[cv for cv in proposed_covers if frozenset(cv)==coord]
        assert len(covers)==1,(label,coord,proposed_covers)
        cv=covers[0]
        assert all(v>=0 for v in cv.values())
        assert all(sum((cv[i] for i in S),F(0))>=1 for S in Slist)
        cost=sum(cv.values(),F(0))
        cover_costs.append(cost)
        gc=[sum((components[S][tuple(x[i] for i in S)] for S in Slist),F(0)) for x in states]
        B_parts.append((max(gc)-min(gc))/2)
        V_c=sum((energy[S] for S in Slist),F(0))
        assert V_c <= cost * max(influence.values())
        assert V_c <= B_parts[-1]**2
    B=(max(vals.values())-min(vals.values()))/2
    assert sum(B_parts,F(0)) == B,(label,B,B_parts)
    M=max(influence.values(),default=F(0))
    theta=max(cover_costs,default=F(0))
    assert V**2 <= theta*B**2*M, (label,theta,B,V,M)
    d=max((len(S) for S in active),default=0)
    print(f'PASS {label}: n={m}, degree={d}, components={len(groups)}, '
          f'theta={theta}, B={B}, V={V}, M={M}, ratio={V**2/(B**2*M) if B*M else 0}')
    return theta,V,B,M


def fair(n):return [[F(1,2),F(1,2)] for _ in range(n)]

def sign(x,i):return 2*x[i]-1

def main():
    n=8
    theta,V,B,M=audit(fair(n),lambda x:sum((F(sign(x,i),n) for i in range(n)),F(0)),
                        [{i:F(1)} for i in range(n)],'degree-one equality')
    assert theta==1 and V==F(1,n) and M==F(1,n*n) and B==1

    def hadamard(x):
        def block(o):
            a,b,c,d=[sign(x,o+i) for i in range(4)]
            return a*c+a*d+b*c-b*d
        return block(0)+block(4)
    theta,V,B,M=audit(fair(8),hadamard,[{0:F(1),1:F(1),2:F(0),3:F(0)},
                                               {4:F(1),5:F(1),6:F(0),7:F(0)}],
                        'two Hadamard blocks sharp theta=2')
    assert theta==2 and V**2==2*B**2*M

    audit(fair(3),lambda x:sign(x,0)*sign(x,1)+sign(x,1)*sign(x,2)+sign(x,0)*sign(x,2),
          [{0:F(1,2),1:F(1,2),2:F(1,2)}],'triangle fractional cover')

    audit(fair(6), lambda x:sum((F(((-1)**(i+j))*sign(x,0)*sign(x,i)*sign(x,j))
                                   for i in (1,2) for j in (3,4,5)),F(0)),
          [{i:(F(1) if i==0 else F(0)) for i in range(6)}],
          'dense anchored triples')

    marginal=[[F(1,2),F(1,3),F(1,6)],
              [F(2,3),F(1,3)],
              [F(1,4),F(3,4)],
              [F(2,5),F(3,5)],
              [F(1,3),F(1,3),F(1,3)]]
    def hetero(x):
        h=lambda i,j: F(int(x[i]==j))-marginal[i][j]
        return h(0,0)*h(1,1)*h(2,1)+h(0,0)*h(2,1)+2*h(3,1)*h(4,2)
    audit(marginal,hetero,[{0:F(1),1:F(0),2:F(0)},{3:F(1),4:F(0)}],
          'heterogeneous categorical independent components')
    print('ALL PASS: source-law ANOVA, true resampling influences, fractional-cover certificate, exact component range.')
    print('Finite tests do not prove the general theorem or N-UE2(2,1).')

if __name__=='__main__':main()
