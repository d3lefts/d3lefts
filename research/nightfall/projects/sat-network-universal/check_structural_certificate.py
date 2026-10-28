#!/usr/bin/env python3
"""Independent structural certificate checker for q-ary factor networks.
Checks the exact equality-wire quotient and the universal-polynomial proof
invariant, without trusting the compiler. Standard library only.
Usage: python3 check_structural_certificate.py example_graph.json
"""
import collections
import json
import sys
from pathlib import Path

def check(c):
    q,n=c["alphabet_size"],c["variable_count"]
    assert isinstance(q,int) and q>=2 and isinstance(n,int) and n>=0
    scopes=c["scopes"]
    assert isinstance(scopes,list)
    assert all(isinstance(sc,list) and all(isinstance(i,int) and 0<=i<n for i in sc) for sc in scopes)
    vertices=c["vertices"]; edges=c["edges"]
    assert isinstance(vertices,dict) and isinstance(edges,list)
    assert all(isinstance(e,list) and len(e)==2 and e[0] in vertices and e[1] in vertices for e in edges)
    assert len({tuple(e) for e in edges})==len(edges)
    incident={x:[] for x in vertices}
    for k,(a,b) in enumerate(edges):
        assert vertices[a]["role"]=="occurrence" and vertices[b]["role"] in ("factor","bridge")
        incident[a].append(k);incident[b].append(k)
    assert all(obj["ports"]==incident[x] for x,obj in vertices.items())
    expected={f"O{j}_{k}":i for j,scope in enumerate(scopes) for k,i in enumerate(scope)}
    factor_ids={f"F{j}" for j in range(len(scopes))}
    actual_occ={x for x,v in vertices.items() if v["role"]=="occurrence"}
    actual_fac={x for x,v in vertices.items() if v["role"]=="factor"}
    assert actual_occ==set(expected) and actual_fac==factor_ids
    bridge_count=0
    for name,obj in vertices.items():
        role=obj["role"]; ps=obj["ports"]
        if role=="occurrence":
            assert obj["var"]==expected[name] and 1<=len(ps)<=3
            assert sum(vertices[edges[e][1]]["role"]=="factor" for e in ps)==1
        elif role=="factor":
            j=int(name[1:]);assert name==f"F{j}" and len(ps)==len(scopes[j])
            for k,e in enumerate(ps):
                assert edges[e]==[f"O{j}_{k}",name]
        elif role=="bridge":
            bridge_count+=1
            assert len(ps)==2
            a,b=[edges[e][0] for e in ps]
            assert a!=b and expected[a]==expected[b]==obj["var"]
        else:raise AssertionError("unknown tensor role")
    L=len(expected); active=set(expected.values());v=len(active)
    assert bridge_count==L-v and len(edges)==3*L-2*v
    parent=list(range(len(edges)))
    def root(x):
        while parent[x]!=x:
            parent[x]=parent[parent[x]]
            x=parent[x]
        return x
    for obj in vertices.values():
        if obj["role"] in ("occurrence","bridge"):
            for e in obj["ports"][1:]:
                parent[root(e)]=root(obj["ports"][0])
    components=collections.defaultdict(set)
    for j,scope in enumerate(scopes):
        for k,i in enumerate(scope):
            e=vertices[f"F{j}"]["ports"][k]
            components[root(e)].add(i)
    assert len(components)==v
    assert set.union(*components.values())==active if components else not active
    assert all(len(x)==1 for x in components.values())
    assert all(root(e) in components for e in range(len(edges)))
    return {"result":"PASS","q":q,"n":n,"active_variables":v,
            "factor_count":len(scopes),"occurrences":L,"wires":len(edges),
            "equality_components":len(components),
            "universal_identity":"Z(original)=(q*1_R)^(n-v)*Z(network) for every commutative semiring R",
            "proof_boundary":"Checks structural certificate; global bijection is proved in THEOREM_AND_SCOPE.md"}

if __name__=="__main__":
    if len(sys.argv)!=2:raise SystemExit("Provide network certificate JSON path")
    print(json.dumps(check(json.loads(Path(sys.argv[1]).read_text())),indent=2))
