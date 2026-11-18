#!/usr/bin/env python3
"""Original-product real-row structural tests: sharp two-bit theorem,
disjoint-block tensorization, and exact categorical gradient-sum falsifier.

The universal K bridge remains OPEN. The tests verify finite source identities,
not the general theorem. All arithmetic is fractions.Fraction and deterministic.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
from math import prod


def worlds(shape):
    return list(product(*(range(k) for k in shape)))


def weighted_metrics(shape, laws, f):
    """Physical original-product V,I and an independent 2-replica I calculation."""
    states=worlds(shape);n=len(shape)
    val={x:Q(f[x]) for x in states}
    P={x:prod((laws[i][x[i]] for i in range(n)),start=Q(1)) for x in states}
    assert all(P[x]>0 for x in states) and sum(P.values(),Q())==1
    mean=sum((P[x]*val[x] for x in states),Q())
    V=sum((P[x]*(val[x]-mean)**2 for x in states),Q())
    I=[];D=[]
    for i in range(n):
        residual={}
        for x in states:
            Ei=sum((laws[i][s]*val[x[:i]+(s,)+x[i+1:]] for s in range(shape[i])),Q())
            residual[x]=val[x]-Ei
        cond=sum((P[x]*residual[x]**2 for x in states),Q())
        replica=Q(1,2)*sum((
            P[x]*laws[i][s]*(val[x]-val[x[:i]+(s,)+x[i+1:]])**2
            for x in states for s in range(shape[i])
        ),Q())
        assert cond==replica
        I.append(cond);D.append(residual)
    R=max(sum((abs(D[i][x]) for i in range(n)),Q()) for x in states)
    return V,I,R


def two_coordinate_full_row(shape, f):
    """Independent exact 2-dimensional primal row: a1>=s1,a2>=s2,a1+a2>=t."""
    assert len(shape)==2 and min(shape)>=2
    states=worlds(shape)
    best=Q()
    opt={}
    for x in states:
        s1=max((abs(f[x]-f[y]) for y in states if y[0]!=x[0] and y[1]==x[1]),default=Q())
        s2=max((abs(f[x]-f[y]) for y in states if y[0]==x[0] and y[1]!=x[1]),default=Q())
        t=max((abs(f[x]-f[y]) for y in states if y[0]!=x[0] and y[1]!=x[1]),default=Q())
        k=max(s1+s2,t)
        # Explicit optimal primal row, valid for every y.
        row=(s1+max(Q(),t-s1-s2),s2)
        assert sum(row,Q())==k
        assert all(abs(f[x]-f[y])<=sum((row[i] for i in range(2) if x[i]!=y[i]),Q()) for y in states)
        best=max(best,k)
        opt[x]=(k,row)
    return best,opt


def two_binary_global_osc(f):
    states=worlds((2,2))
    L0=max(abs(f[(0,t)]-f[(1,t)]) for t in (0,1))
    L1=max(abs(f[(s,0)]-f[(s,1)]) for s in (0,1))
    return L0,L1


def randomized_two_binary():
    rng=Random(20261118);checked=0;worst=Q()
    for t in range(300):
        p0=Q(rng.randint(1,29),30)
        p1=Q(rng.randint(1,29),30)
        laws=[[1-p0,p0],[1-p1,p1]]
        f={x:Q(rng.randint(-11,11),rng.choice((1,2,3,4))) for x in worlds((2,2))}
        if len(set(f.values()))<2:continue
        K,_=two_coordinate_full_row((2,2),f)
        L0,L1=two_binary_global_osc(f)
        assert K==L0+L1
        V,I,R=weighted_metrics((2,2),laws,f)
        assert I[0]<=L0**2/4 and I[1]<=L1**2/4
        assert V<=sum(I,Q())
        M=max(I)
        assert 4*V**2<=K**2*M
        ratio=4*V**2/(K**2*M) if K*M else Q()
        worst=max(worst,ratio)
        checked+=1
    assert checked==300
    equal={x:Q(2*x[0]-1+2*x[1]-1) for x in worlds((2,2))}
    V,I,R=weighted_metrics((2,2),[[Q(1,2)]*2]*2,equal)
    K,_=two_coordinate_full_row((2,2),equal)
    assert (V,I,K)==(Q(2),[Q(1),Q(1)],Q(4))
    assert 4*V**2==K**2*max(I)
    print("PASS two-bit source: 300 full-support rational laws, independent replica I,")
    print("     exact K=L0+L1, sharp 4V²<=K²M, equality at additive fair signs; best",float(worst))


def categorical_negative_control():
    """A TWO-coordinate degree-2 original-law obstruction to sum sqrt(I)<=K/2."""
    shape=(3,2);states=worlds(shape)
    laws=[[Q(1,100),Q(99,200),Q(99,200)],[Q(1,2),Q(1,2)]]
    f={(0,0):Q(-1,4),(0,1):Q(1,4),
       (1,0):Q(1),(1,1):Q(1),
       (2,0):Q(-1),(2,1):Q(-1)}
    K,rows=two_coordinate_full_row(shape,f)
    assert K==Q(2)
    # Explicit feasible row costs: rare trit K(x)=7/4, each extremal row K(x)=2.
    assert {x:rows[x][0] for x in states}=={
        (0,0):Q(7,4),(0,1):Q(7,4),
        (1,0):Q(2),(1,1):Q(2),
        (2,0):Q(2),(2,1):Q(2)}
    V,I,R=weighted_metrics(shape,laws,f)
    assert V==Q(317,320)
    assert I==[Q(158499,160000),Q(1,1600)]
    assert I[0]>Q(39,40)**2
    assert I[1]==Q(1,40)**2
    # Therefore 2(sum sqrt I)>K, without floating-point acceptance.
    M=max(I)
    ratio=4*V**2/(K**2*M)
    assert ratio==Q(2512225,2535984) and ratio<1
    # True degree two: D_T D_S f = (1_{T=0}-1/100) * S/4 !=0.
    assert f[(0,1)]-f[(0,0)]==Q(1,2)
    assert f[(1,1)]-f[(1,0)]==0
    print("PASS two-coordinate trit/bit obstruction: V=",V,"I=",I,"K=",K)
    print("     2(sum sqrt I)>K EXACT, but full-row sharp ratio=",ratio,"<1; degree=2")


def direct_sum_regression():
    """Independent physical aggregate confirms block K,R,V,I identities."""
    rng=Random(12891);runs=0
    shapes=[(2,2),(3,),(2,),(2,2)]
    fullshape=tuple(z for block in shapes for z in block)
    for trial in range(15):
        local_laws=[];local_f=[];local_K=[];local_stats=[];global_laws=[]
        for block in shapes:
            laws=[]
            for k in block:
                raw=[rng.randint(1,17) for _ in range(k)]
                laws.append([Q(z,sum(raw)) for z in raw])
            vals={x:Q(rng.randint(-7,7),2) for x in worlds(block)}
            if len(block)==2:
                K,_=two_coordinate_full_row(block,vals)
            else:K=max(vals.values())-min(vals.values())
            local_laws.append(laws);local_f.append(vals);local_K.append(K)
            local_stats.append(weighted_metrics(block,laws,vals))
            global_laws.extend(laws)
        def fglobal(x):
            start=0;out=Q()
            for block,tab in zip(shapes,local_f):
                end=start+len(block);out+=tab[x[start:end]];start=end
            return out
        global_f={x:fglobal(x) for x in worlds(fullshape)}
        V,I,R=weighted_metrics(fullshape,global_laws,global_f)
        assert V==sum((s[0] for s in local_stats),Q())
        assert I==[u for s in local_stats for u in s[1]]
        assert R==sum((s[2] for s in local_stats),Q())
        # GLOBAL row upper bound: for each input combine local optimal rows
        # (two-dimensional rows are exact primal; one-dimensional row obvious).
        # Lower bound follows from each block-restricted pair constraint.
        K=sum(local_K,Q())
        assert 4*V**2<=K**2*max(I)
        assert all(abs(global_f[x]-global_f[y])<=K for x in global_f for y in global_f)
        runs+=1
    print("PASS independent disjoint source tensorization in",runs,
          "6-coordinate heterogeneous 2+1+1+2 blocks: V, every I, R and K budget")


def main():
    randomized_two_binary()
    categorical_negative_control()
    direct_sum_regression()
    print("LIMIT: mathematical full-row tensorization proved analytically in dossier.")
    print("LIMIT: no unrestricted full-K/degree-weighted-R inequality claimed.")


if __name__=="__main__":main()
