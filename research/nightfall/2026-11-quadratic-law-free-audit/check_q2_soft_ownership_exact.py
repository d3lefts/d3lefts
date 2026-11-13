#!/usr/bin/env python3
"""Independent exact-rational falsifier for the soft-owner Q2 bridge.

Pure stdlib Fraction source enumerator. For soft weights lambda_ij =
c_i / sqrt(c_i^2+c_j^2), ALL second/fourth moment quantities are
polynomials in lambda^2 and can therefore be verified exactly in Q.
The Markov-source identity is checked independently for rational test
weights; its universal symbolic proof is in the companion note.
No Lean certification, originality, or global theorem is claimed.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
import hashlib
import json

SEED=20261113
rng=Random(SEED)
counts={k:0 for k in ('anovapoint','center','matching','coupling','greedy','softenergy','sourcemoment','momentbound','markov','variancebound')}


def fold_weights(items, ps):
    out=F(0)
    for ix in product(*items):
        weight=F(1)
        for j,a in enumerate(ix): weight*=ps[j][a]
        if weight: yield tuple(ix),weight


def test_case(n,asizes,ps,coeff):
    alph=[range(a) for a in asizes]
    allx=list(product(*alph))
    supp=[(x,p) for x,p in fold_weights(alph,ps) if p]
    def fun(x):
        y=coeff['c']
        for i in range(n): y+=coeff['u'][i][x[i]]
        for i,j in combinations(range(n),2):y+=coeff['p'][(i,j)][x[i]][x[j]]
        return y
    source={x:fun(x) for x in allx}
    B=max(abs(source[x]) for x,p in supp)
    av=sum((p*source[x] for x,p in supp),F(0))
    avg_i={}
    avg_ij={}
    # Recompute marginals via independent product averaging, including zero-mass replacements:
    for i in range(n):
        for a in alph[i]:
            avg_i[(i,a)]=sum((p*fun(tuple(a if k==i else x[k] for k in range(n))) for x,p in supp),F(0))
    for i,j in combinations(range(n),2):
        for a,b in product(alph[i],alph[j]):
            avg_ij[(i,j,a,b)]=sum((p*fun(tuple(a if k==i else b if k==j else x[k] for k in range(n))) for x,p in supp),F(0))
    hi={(i,a):avg_i[(i,a)]-av for i in range(n) for a in alph[i]}
    hij={(i,j,a,b):avg_ij[(i,j,a,b)]-avg_i[(i,a)]-avg_i[(j,b)]+av
         for i,j in combinations(range(n),2) for a,b in product(alph[i],alph[j])}
    def pair(i,j,a,b):
        if i<j: return hij[(i,j,a,b)]
        return hij[(j,i,b,a)]
    for x in allx:
        reconstructed=av+sum((hi[(i,x[i])] for i in range(n)),F(0))
        reconstructed+=sum((pair(i,j,x[i],x[j]) for i,j in combinations(range(n),2)),F(0))
        assert reconstructed==source[x]
        counts['anovapoint']+=1
    Ei={}; a2={}; influence={};w={}
    for i in range(n):
        a2[i]=sum((ps[i][a]*hi[(i,a)]**2 for a in alph[i]),F(0))
        assert sum((ps[i][a]*hi[(i,a)] for a in alph[i]),F(0))==0
        for j in range(i+1,n):
            for b in alph[j]:
                assert sum((ps[i][a]*pair(i,j,a,b) for a in alph[i]),F(0))==0
                counts['center']+=1
            for a in alph[i]:
                assert sum((ps[j][b]*pair(i,j,a,b) for b in alph[j]),F(0))==0
                counts['center']+=1
            Ei[(i,j)]=sum((ps[i][a]*ps[j][b]*pair(i,j,a,b)**2
                              for a,b in product(alph[i],alph[j])),F(0))
            w[(i,j)]=max(abs(pair(i,j,a,b)) for a,b in product(*[[a for a in alph[i] if ps[i][a]],[b for b in alph[j] if ps[j][b]]]))
        influence[i]=a2[i]+sum((Ei[min(i,j),max(i,j)] for j in range(n) if j!=i),F(0))
    V=sum((p*(source[x]-av)**2 for x,p in supp),F(0))
    assert V==sum(a2.values())+sum(Ei.values())
    # Genuine-source matching bound: all n<=5 disjoint graph edge subsets.
    edges=sorted(w)
    for mask in range(1<<len(edges)):
        chosen=[edge for k,edge in enumerate(edges) if mask>>k&1]
        vs=[i for e in chosen for i in e]
        if len(set(vs))==len(vs):
            assert sum((w[e] for e in chosen),F(0))<=4*B
            counts['matching']+=1
            # Independent even/odd global parity experiment, with true
            # source f and all other coordinates at supported base values.
            corners=[]
            for i,j in chosen:
                ai=[a for a in alph[i] if ps[i][a]>0]
                bj=[b for b in alph[j] if ps[j][b]>0]
                options=[(pair(i,j,a0,b0)-pair(i,j,a1,b0)-
                          pair(i,j,a0,b1)+pair(i,j,a1,b1),a0,a1,b0,b1)
                         for a0,a1,b0,b1 in product(ai,ai,bj,bj)]
                best=max(options)
                assert best[0]>=w[(i,j)]
                corners.append((i,j,best))
            base=[next(a for a in alph[i] if ps[i][a]>0) for i in range(n)]
            ev=F(0);od=F(0)
            for mask in product((0,1),repeat=len(chosen)):
                xplus=base.copy();xminus=base.copy()
                for bit,(i,j,(delta,a0,a1,b0,b1)) in zip(mask,corners):
                    xplus[i]=xminus[i]=a0 if bit==0 else a1
                    xplus[j]=b0 if bit==0 else b1
                    xminus[j]=b1 if bit==0 else b0
                ev+=fun(tuple(xplus));od+=fun(tuple(xminus))
            nmask=2**len(chosen)
            assert (ev-od)/nmask==sum((z[2][0] for z in corners),F(0))/2
            assert (ev-od)/nmask<=2*B
            counts['coupling']+=1
    order=sorted(edges,key=lambda e:(-w[e],e))
    chosen=[];used=set()
    for e in order:
        if not(set(e)&used):chosen.append(e);used.update(e)
    c={i:F(0) for i in range(n)}
    for i,j in chosen:c[i]=w[(i,j)];c[j]=w[(i,j)]
    assert sum(c.values())<=8*B
    for i,j in edges:assert w[(i,j)]<=max(c[i],c[j])
    counts['greedy']+=1
    # Squared soft-owner weight is rational. Zero amplitude edges carry zero energy.
    lij2={}
    for i,j in edges:
        d=c[i]**2+c[j]**2
        if d==0:
            assert w[(i,j)]==0 and Ei[(i,j)]==0
            lij2[i,j]=lij2[j,i]=F(0)
        else:
            lij2[i,j]=c[i]**2/d
            lij2[j,i]=c[j]**2/d
            assert lij2[i,j]+lij2[j,i]==1
            assert lij2[i,j]*w[(i,j)]**2<=c[i]**2
            assert lij2[j,i]*w[(i,j)]**2<=c[j]**2
        counts['softenergy']+=1
    s={i:sum((lij2[i,j]*Ei[(min(i,j),max(i,j))] for j in range(n) if j!=i),F(0)) for i in range(n)}
    assert sum(s.values())==sum(Ei.values())
    assert all(s[i]<=influence[i] for i in range(n))
    M=max(influence.values())
    for i in range(n):
        # Fourth moment: exact source-independent expansion of lambda-weighted
        # Hilbert vectors; lambda appears only to even power.
        ns=[j for j in range(n) if j!=i and lij2[i,j]>0]
        v={j:Ei[(min(i,j),max(i,j))] for j in ns}
        F4=sum((lij2[i,j]**2 *sum((ps[j][b]*(sum((ps[i][a]*pair(i,j,a,b)**2 for a in alph[i]),F(0)))**2
                                             for b in alph[j]),F(0)) for j in ns),F(0))
        for j,k in combinations(ns,2):
            inner2=sum((ps[j][b]*ps[k][d]*sum((ps[i][a]*pair(i,j,a,b)*pair(i,k,a,d)
                                                   for a in alph[i]),F(0))**2 for b,d in product(alph[j],alph[k])),F(0))
            F4+=lij2[i,j]*lij2[i,k]*(2*v[j]*v[k]+4*inner2)
        assert F4<=c[i]**2*s[i]+3*s[i]**2
        counts['sourcemoment']+=1
        counts['momentbound']+=1
        # Exact Markov-noise identity for rational tau, at EVERY supported
        # fixed input. The general lambda case follows from multilinearity.
        taus={j:c[i]/(c[i]+c[j]) if c[i]+c[j]>0 else F(0) for j in range(n) if j!=i}
        for x,p in supp:
            for a in alph[i]:
                Ui=fun(tuple(a if k==i else x[k] for k in range(n)))-sum((ps[i][b]*fun(tuple(b if k==i else x[k] for k in range(n))) for b in alph[i]),F(0))
                assert Ui==hi[i,a]+sum((pair(i,j,a,x[j]) for j in range(n) if j!=i),F(0))
                # Apply independent Markov kernels to the original source
                # section by expansion into retained/refresh configurations.
                calc=F(0)
                for mask in product((0,1), repeat=n-1):
                    others=[j for j in range(n) if j!=i]
                    prob=F(1)
                    refresh=[]
                    for j,keep in zip(others,mask):
                        prob*=taus[j] if keep else (1-taus[j])
                        if not keep:refresh.append(j)
                    if not prob:continue
                    for rs in product(*(alph[j] for j in refresh)):
                        q=prob;xx=list(x)
                        for j,b in zip(refresh,rs):q*=ps[j][b];xx[j]=b
                        if not q:continue
                        Ua=fun(tuple(a if k==i else xx[k] for k in range(n)))-sum((ps[i][b]*fun(tuple(b if k==i else xx[k] for k in range(n))) for b in alph[i]),F(0))
                        calc+=q*Ua
                wanted=hi[i,a]+sum((taus[j]*pair(i,j,a,x[j]) for j in range(n) if j!=i),F(0))
                assert calc==wanted
                counts['markov']+=1
    # Safe rational upper bound on author's stronger algebraic constant.
    #  K=(10+2sqrt(2))^2 (1+sqrt(3))^2 < 1229.
    assert V*V<=F(1229)*B*B*M
    counts['variancebound']+=1


def make_random(n,al):
    ps=[]
    for m in al:
        x=[rng.randrange(0,4) for i in range(m)]
        if sum(x)==0:x[0]=1
        s=sum(x);ps.append([F(k,s) for k in x])
    u=[[F(rng.randrange(-4,5),6) for a in range(al[i])] for i in range(n)]
    p={(i,j):[[F(rng.randrange(-5,6),7) for b in range(al[j])] for a in range(al[i])]
       for i,j in combinations(range(n),2)}
    return ps,{'c':F(rng.randrange(-3,4),5),'u':u,'p':p}


def address(m):
    n=m+1;al=[m]+[2]*m;ps=[[F(1,m)]*m]+[[F(1,2)]*2 for j in range(m)]
    u=[[F(0)]*s for s in al]
    p={(i,j):[[F(0) for b in range(al[j])] for a in range(al[i])] for i,j in combinations(range(n),2)}
    for j in range(1,n):
        for a in range(m):
            p[(0,j)][a]=[F(-1 if a==j-1 else 0),F(1 if a==j-1 else 0)]
    return al,ps,{'c':F(0),'u':u,'p':p}


def main():
    for n in (2,3,4,5):
        for case in range(4 if n==5 else 10):
            al=[rng.choice([2,3]) for _ in range(n)]
            ps,coeff=make_random(n,al)
            test_case(n,al,ps,coeff)
    for m in (2,3):
        al,ps,coeff=address(m)
        test_case(len(al),al,ps,coeff)
    assert counts['sourcemoment']>100 and counts['markov']>500
    print('PASS soft-ownership Q2 exact finite regression, seed',SEED)
    print(json.dumps(counts,sort_keys=True))
    print('STATUS: finite exact falsification, NOT universal proof, Lean or novelty verification')

if __name__=='__main__':main()
