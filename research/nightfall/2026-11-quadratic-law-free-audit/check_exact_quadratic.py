#!/usr/bin/env python3
"""Independent exact-rational audit of finite arbitrary-law degree-two influence.
All moments/influences use fractions.Fraction; no product-influence package imports.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from math import isqrt, prod
import json


SCALE=10**18

def sqrt_interval(q):
    """Exact rational enclosure: lo^2 <= q < hi^2, width 1e-18."""
    assert q>=0
    k=isqrt((q.numerator*SCALE*SCALE)//q.denominator)
    lo=Q(k,SCALE); hi=Q(k+1,SCALE)
    assert lo*lo<=q<hi*hi
    return lo,hi

def construct(rng, n, rare=False):
    weights = []
    for i in range(n):
        k=rng.choice([2,3])
        counts=[rng.randint(1,8) for _ in range(k)]
        if rare and i==0: counts=[1,47] if k==2 else [1,1,47]
        weights.append([Q(v,sum(counts)) for v in counts])
    singles={}
    pairs={}
    for i in range(n):
        raw=[Q(rng.randint(-4,4)) for _ in weights[i]]
        avg=sum((v*w for v,w in zip(raw,weights[i])),Q(0))
        singles[i]=[v-avg for v in raw]
    for i,j in combinations(range(n),2):
        if rng.random()<0.22: continue
        raw=[[Q(rng.randint(-5,5)) for _ in weights[j]] for _ in weights[i]]
        a=weights[i]; b=weights[j]
        row=[sum((raw[x][y]*b[y] for y in range(len(b))),Q(0)) for x in range(len(a))]
        col=[sum((a[x]*raw[x][y] for x in range(len(a))),Q(0)) for y in range(len(b))]
        mean=sum((a[x]*row[x] for x in range(len(a))),Q(0))
        pairs[i,j]=[[raw[x][y]-row[x]-col[y]+mean for y in range(len(b))] for x in range(len(a))]
    return weights,singles,pairs


def verify(seed, n, rare):
    rng=Random(seed*1949+17)
    spaces,h,e=construct(rng,n,rare)
    coords=list(range(n))
    domain=list(product(*[range(len(x)) for x in spaces]))
    probs={x:prod([spaces[i][a] for i,a in enumerate(x)]) for x in domain}
    def f(x): return sum((h[i][x[i]] for i in coords),Q(0))+sum((tab[x[i]][x[j]] for (i,j),tab in e.items()),Q(0))
    B=max(abs(f(x)) for x in domain)
    if B==0: return {'trivial':True}
    ev=lambda fn:sum((probs[x]*fn(x) for x in domain),Q(0))
    hi2={i:sum((spaces[i][a]*h[i][a]**2 for a in range(len(spaces[i]))),Q(0)) for i in coords}
    ep2={}
    for (i,j),tab in e.items():
        ep2[i,j]=sum((spaces[i][a]*spaces[j][b]*tab[a][b]**2 for a in range(len(spaces[i])) for b in range(len(spaces[j]))),Q(0))
    V=sum(hi2.values(),Q(0))+sum(ep2.values(),Q(0))
    mean=ev(f)
    assert mean==0
    assert ev(lambda x:f(x)**2)==V
    influences={i:hi2[i]+sum((val for ij,val in ep2.items() if i in ij),Q(0)) for i in coords}
    M=max(influences.values())
    assert V>0 and M>0
    gmax=max(abs(sum((h[i][x[i]] for i in coords),Q(0))) for x in domain)
    assert gmax<=7*B
    assert sum((sqrt_interval(hi2[i])[1] for i in coords),Q(0)) <= 7*B
    # Total pointwise range/oscillation lemma from independent maximizing/minimizing replacements.
    for x in domain:
        widths=[]
        for i in coords:
            values=[f(x[:i]+(a,)+x[i+1:]) for a in range(len(spaces[i]))]
            widths.append(max(values)-min(values))
        assert sum(widths,Q(0)) <=16*B
    bij={ij:max(abs(v) for row in tab for v in row) for ij,tab in e.items() if any(v for row in tab for v in row)}
    # Universal matching bound: every matching, not just the chosen greedy matching.
    matchings=0
    for flags in product([0,1],repeat=len(bij)):
        edges=[ij for flag,ij in zip(flags,bij) if flag]
        if len(set(v for ij in edges for v in ij))==2*len(edges):
            assert sum((bij[ij] for ij in edges),Q(0)) <=4*B
            # Explicit independent even/odd two-point couplings on the matching.
            # Every off-matching pair must cancel from the expectation difference.
            local_plus=[]; local_minus=[]; ds=[]
            for (i,j) in edges:
                tab=e[i,j]
                a,b=max(product(range(len(spaces[i])),range(len(spaces[j]))),key=lambda ab:abs(tab[ab[0]][ab[1]]))
                aa,bb=max(product(range(len(spaces[i])),range(len(spaces[j]))),key=lambda ab:abs(tab[a][b]-tab[ab[0]][b]-tab[a][ab[1]]+tab[ab[0]][ab[1]]))
                delta=tab[a][b]-tab[aa][b]-tab[a][bb]+tab[aa][bb]
                assert abs(delta)>=bij[i,j]
                even=[(a,b),(aa,bb)]; odd=[(a,bb),(aa,b)]
                if delta<0: even,odd=odd,even
                local_plus.append(even); local_minus.append(odd); ds.append(abs(delta))
            def coupled_expected(blocks):
                if not edges: return f(tuple([0]*n))
                acc=Q(0)
                for picks in product((0,1),repeat=len(edges)):
                    xx=[0]*n
                    for edge,block,choice in zip(edges,blocks,picks):
                        xx[edge[0]],xx[edge[1]]=block[choice]
                    acc+=f(tuple(xx))
                return acc/Q(2**len(edges))
            expect_plus=coupled_expected(local_plus)
            expect_minus=coupled_expected(local_minus)
            assert expect_plus-expect_minus==sum(ds,Q(0))/2
            assert abs(expect_plus)<=B and abs(expect_minus)<=B
            matchings+=1
    assigned={i:[] for i in coords}; c={i:Q(0) for i in coords}
    taken=set(); c={i:Q(0) for i in coords}
    for (i,j),b in sorted(bij.items(),key=lambda item:(-item[1],item[0])):
        if i not in taken and j not in taken:
            taken.update([i,j]); c[i]=c[j]=b
    assert sum(c.values(),Q(0))<=8*B
    for (i,j),b in bij.items():
        assert max(c[i],c[j])>=b
        owner=i if c[i]>=b else j
        assigned[owner].append((i,j))
    ZL1_hi=Q(0); quad=Q(0); sumUiL1_hi=Q(0)
    for i in coords:
        others=[j for j in coords if j!=i]
        def hin(i,j,a,b):
            return e[i,j][a][b] if i<j else e[j,i][b][a]
        def norm2vector(v): return sum((spaces[i][a]*v[a]**2 for a in range(len(spaces[i]))),Q(0))
        # Pointwise Ui norm as a Hilbert-space vector indexed by the i-coordinate.
        ui_norms=[]
        for x in domain:
            vec=[h[i][a]+sum((hin(i,j,a,x[j]) for j in others if (min(i,j),max(i,j)) in e),Q(0)) for a in range(len(spaces[i]))]
            ui_norms.append((probs[x],norm2vector(vec)))
        uiL1lo=sum((p*sqrt_interval(q)[0] for p,q in ui_norms),Q(0))
        uiL1hi=sum((p*sqrt_interval(q)[1] for p,q in ui_norms),Q(0))
        sumUiL1_hi+=uiL1hi
        eds=assigned[i]; neigh=[j if j!=i else a for a,j in eds for j in [j]] # overwritten next
        neigh=sorted({(j if i==a else a) for a,j in eds})
        z4=Q(0); z2=Q(0); z1lo=Q(0); z1hi=Q(0)
        zvals={}
        for ys in product(*[range(len(spaces[j])) for j in neigh]):
            yy=dict(zip(neigh,ys)); pr=prod(spaces[j][a] for j,a in yy.items())
            vec=[sum((hin(i,j,a,yy[j]) for j in neigh),Q(0)) for a in range(len(spaces[i]))]
            sq=norm2vector(vec)
            lo,hi=sqrt_interval(sq); z1lo+=pr*lo; z1hi+=pr*hi
            z2+=pr*sq; z4+=pr*sq**2
            zvals[ys]=sq
        si=sum((ep2[edge] for edge in eds),Q(0))
        assert z2==si and si<=influences[i] and si<=M
        assert z4 <= c[i]**2*si + 3*si**2
        # Independently reconstruct the EXACT Hilbert fourth-moment identity.
        yy2=[]
        for j in neigh:
            Y={a:[hin(i,j,b,a) for b in range(len(spaces[i]))] for a in range(len(spaces[j]))}
            yy2.append((j,Y))
        second={}; fourth={}
        for j,Y in yy2:
            second[j]=sum((spaces[j][a]*norm2vector(v) for a,v in Y.items()),Q(0))
            fourth[j]=sum((spaces[j][a]*norm2vector(v)**2 for a,v in Y.items()),Q(0))
        explicit=sum(fourth.values(),Q(0))
        for j,k in combinations(neigh,2):
            cross=Q(0)
            for aj in range(len(spaces[j])):
                for ak in range(len(spaces[k])):
                    dot=sum((spaces[i][a]*hin(i,j,a,aj)*hin(i,k,a,ak) for a in range(len(spaces[i]))),Q(0))
                    cross+=spaces[j][aj]*spaces[k][ak]*dot**2
            explicit+=2*second[j]*second[k]+4*cross
        assert explicit==z4
        # Rational enclosures, not floating point, audit interpolation and triangle.
        assert si*sqrt_interval(si)[0] <= z1hi*sqrt_interval(z4)[1]
        assert z1lo <= uiL1hi +sqrt_interval(hi2[i])[1]
        ZL1_hi+=z1hi; quad+=si
    assert quad==sum(ep2.values(),Q(0))
    assert sumUiL1_hi<=8*B
    assert ZL1_hi<=15*B
    # Squared form avoids symbolic radicals; use the certified bound sqrt(3)<7/4.
    assert V<=Q(15)*(1+Q(7,4))*B*sqrt_interval(M)[1]
    # For the exact claimed D=15(1+sqrt3), enclose sqrt3 from below.
    assert V<=Q(15)*(1+sqrt_interval(Q(3))[0])*B*sqrt_interval(M)[0]
    return {'seed':seed,'n':n,'rare':rare,'matching_count':matchings,'edges':len(bij),'V':str(V),'M':str(M),'B':str(B),'ratio':float(V**2/(B**2*M))}


def main():
    cases=[]
    for seed in range(1,34): cases.append(verify(seed,5,seed%3==0))
    print(json.dumps({'status':'PASS','cases':len(cases),'matching_families':sum(x['matching_count'] for x in cases),'max_normalized_ratio':max(x['ratio'] for x in cases),'sample_rare':cases[2]},sort_keys=True))

if __name__=='__main__': main()

