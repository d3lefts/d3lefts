#!/usr/bin/env python3
"""RYEV #257 — independent quadratic-trace-basis square-oracle audit.

The producer represents F_(p^2) by t^2=n. This audit uses u=t+1/2,
where u^2=u+d and d=n-1/4, plus inverses by exponentiation rather
than inverse-table search. It independently checks the isomorphism,
all admissible input signals, and zero/phase/root/partial-block controls.
Finite evidence, not an all-k theorem or external mathematical review.
"""
from collections import Counter
from itertools import product
import hashlib
import json

SCOPES = ((3,2,4),(5,2,3),(7,3,3))

def run(p,n,k):
    assert p in (3,5,7) and pow(n,(p-1)//2,p)==p-1
    q=p*p
    half=pow(2,-1,p)
    d=(n-half*half)%p
    def pack(a,b):return (a%p)+p*(b%p)
    def unpack(x):return x%p,x//p
    def add(x,y):
        a,b=unpack(x);c,e=unpack(y)
        return pack(a+c,b+e)
    def mul(x,y):
        a,b=unpack(x);c,e=unpack(y)
        return pack(a*c+d*b*e,a*e+b*c+b*e)
    def power(x,m):
        z=1
        while m:
            if m&1:z=mul(z,x)
            x=mul(x,x);m//=2
        return z
    # The source generator t=u-1/2; verify the entire 2-coordinate field.
    def source_to_trace(x):
        a,b=unpack(x)
        return pack(a-b*half,b)
    def source_product(x,y):
        a,b=unpack(x);c,e=unpack(y)
        return pack(a*c+n*b*e,a*e+b*c)
    assert len({source_to_trace(x) for x in range(q)})==q
    for x in range(q):
        assert power(x,q)==x
        for y in range(q):
            assert source_to_trace(source_product(x,y))==mul(source_to_trace(x),source_to_trace(y))
            assert source_to_trace(add(x,y))==add(source_to_trace(x),source_to_trace(y))
    inverse={x:power(x,q-2) for x in range(1,q)}
    assert all(mul(x,inverse[x])==1 for x in inverse)
    square=[mul(x,x) for x in range(q)]
    roots={v:next(x for x in range(q) if square[x]==v) for v in set(square)}
    assert len(roots)==(q+1)//2
    neg=lambda x:mul(p-1,x)
    assert all({x for x in range(q) if square[x]==v}==
               ({0} if v==0 else {roots[v],neg(roots[v])}) for v in roots)
    # Different *valid* root choices MUST preserve the oracle reconstruction.
    alternate={v:(neg(x) if v else 0) for v,x in roots.items()}
    assert all(square[x]==v for v,x in alternate.items())
    corrupt=dict(roots);corrupt[1]=0
    assert any(square[x]!=v for v,x in corrupt.items())
    phase_group=(1,p-1)
    assert len({square[x] for x in range(q)})==(q+1)//2
    # Explicit phase code and inverse per supported block size.
    dictionaries={}
    for b in (1,2):
        lookup={}
        for eta in product(phase_group,repeat=b):
            total=0
            for j,e in enumerate(eta):
                total=add(total,mul(p**j,add(1,e)))
            observation=square[total]
            assert observation not in lookup,(p,b,eta,lookup.get(observation))
            lookup[observation]=eta
        assert len(lookup)==2**b
        dictionaries[b]=lookup
    # Deliberately changed oracle cannot use this theorem's six/five/... fibers.
    assert any(power(x,3)!=square[x] for x in range(1,q))
    # The unpowered first reading is NOT a legal branch selector.
    assert any(x!=neg(x) and square[x]==square[neg(x)] for x in range(1,q))
    histogram=Counter()
    partial=0
    sectors=0
    for x in product(range(q),repeat=k):
        data=[square[z] for z in x]
        S=[j for j,v in enumerate(data) if v]
        out=[0]*k
        if not S:
            histogram[k]+=1
            continue
        anchor=S[0]
        u={j:roots[data[j]] for j in S}
        out[anchor]=u[anchor]
        count=k
        # Simulate each legal query via its measured squared output.
        for start in range(1,len(S),2):
            group=S[start:start+2]
            raw=0
            anchor_phase=mul(x[anchor],inverse[u[anchor]])
            for j,i in enumerate(group):
                relative_phase=mul(x[i],inverse[u[i]])
                raw=add(raw,mul(p**j,add(anchor_phase,relative_phase)))
            y=square[raw]
            eta=dictionaries[len(group)][y]
            for i,e in zip(group,eta,strict=True):
                out[i]=mul(e,u[i])
            count+=1
            if len(group)==1:partial+=1
        assert tuple(out)==x or tuple(neg(z) for z in out)==x,(p,k,x,out)
        assert count==k+(len(S)//2)
        histogram[count]+=1
        sectors+=1
    expected={(3,4):{4:33,5:2432,6:4096},
              (5,3):{3:73,4:15552},
              (7,3):{3:145,4:117504}}[(p,k)]
    assert histogram==expected,(histogram,expected)
    assert partial>0
    assert sum(histogram.values())==q**k
    return {'characteristic':p,'field_size':q,'dimension':k,
            'trace_basis_relation':'u^2=u+d','d':d,
            'exhaustive_vectors':q**k,'nonzero_vectors':sectors,
            'queries':dict(sorted(histogram.items())),
            'strict_partial_blocks_exercised':partial,
            'field_isomorphism_pairs':q*q,
            'root_table_corruption_rejected':True,
            'legitimate_root_flip_preserves_square':True,
            'illegal_unpowered_branch_rejected':True}

def main():
    results=[run(*scope) for scope in SCOPES]
    assert [v['exhaustive_vectors'] for v in results]==[6561,15625,117649]
    print(json.dumps({'status':'PASS_FINITE_INTERNAL','role':'RYEV',
      'external_review':False,'all_dimensions_formalized':False,
      'oracle':'square of permitted linear forms; full all-signal global sign quotient',
      'results':results},indent=2,sort_keys=True))

if __name__=='__main__':main()
