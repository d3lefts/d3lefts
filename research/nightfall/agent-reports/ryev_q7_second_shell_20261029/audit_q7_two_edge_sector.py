#!/usr/bin/env python3
"""Independent integer-set Q7 1-/2-edge cochain sector enumerator, no solver.
Only audits finite geometry; the odd-square stability implication is analytic.
"""
from itertools import combinations
from collections import Counter
from hashlib import sha256
import json

def run():
    n=7
    vertices=range(1<<n)
    edges=sorted({tuple(sorted((v, v^(1<<i)))) for v in vertices for i in range(n)})
    assert len(edges)==448
    by_endpoints={frozenset(e):idx for idx,e in enumerate(edges)}
    squares=sorted({frozenset((v,v^(1<<i),v^(1<<j),v^(1<<i)^(1<<j)))
                    for v in vertices for i,j in combinations(range(n),2)},
                   key=lambda s:tuple(sorted(s)))
    assert len(squares)==672
    borders=[]
    for quad in squares:
        edges_of_quad=frozenset(by_endpoints[frozenset((a,b))]
            for a,b in combinations(sorted(quad),2) if (a^b).bit_count()==1)
        assert len(edges_of_quad)==4
        borders.append(edges_of_quad)
    edge_cofaces=[set() for _ in edges]
    for face_id,border in enumerate(borders):
        for e in border:edge_cofaces[e].add(face_id)
    assert all(len(faces)==6 for faces in edge_cofaces)
    cofacial={frozenset((i,j)) for border in borders for i,j in combinations(sorted(border),2)}
    assert len(cofacial)==4032
    syndrome_to_pair={}
    counts=Counter()
    for i,j in combinations(range(len(edges)),2):
        syndrome=frozenset(edge_cofaces[i]^edge_cofaces[j])
        k=len(syndrome)
        assert k in (10,12)
        assert (k==10)==(frozenset((i,j)) in cofacial)
        assert syndrome not in syndrome_to_pair, 'Two distinct pairs yielded same syndrome'
        syndrome_to_pair[syndrome]=(i,j)
        counts[k]+=1
    assert dict(counts)=={10:4032,12:96096}
    assert len(syndrome_to_pair)==100128
    # Canonical source-derived count digest; each pair is unique by construction.
    serial='\n'.join(f'{i},{j},{k}' for i,j,k in (
        (i,j,len(edge_cofaces[i]^edge_cofaces[j])) for i,j in combinations(range(len(edges)),2)))+'\n'
    result={'vertices':128,'edges':448,'squares':672,
            'forbidden_if_analytic_stability_holds':{'single_edge_stars':448,
            'two_edge_weight10':counts[10],'two_edge_weight12':counts[12]},
            'unique_two_edge_syndromes':len(syndrome_to_pair),
            'canonical_pair_weight_ledger_sha256':sha256(serial.encode()).hexdigest(),
            'status':'exact finite enumeration; analytic stability separately pending independent review'}
    print(json.dumps(result,sort_keys=True,indent=2))
if __name__=='__main__':run()
