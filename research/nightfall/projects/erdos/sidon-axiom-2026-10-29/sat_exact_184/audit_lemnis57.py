#!/usr/bin/env python3
"""Independent audit of three-port replacement lemma; enumerates 5-vertex gadgets,
then compares literal cycle enumeration with transfer prediction on K4 base.
Does NOT rerun the 3.2 billion subset configurations of PR #57.
"""
from itertools import combinations
from collections import defaultdict
import json
import networkx as nx

def cycle_lengths(G,maximum=16):
    adj={v:set(G.neighbors(v)) for v in G}; answer=set()
    for s in G:
        def dfs(v,path):
            if len(path)>=3 and s in adj[v]:answer.add(len(path))
            if len(path)>=maximum:return
            for w in adj[v]:
                if w<=s or w in path:continue
                dfs(w,path+(w,))
        dfs(s,(s,))
    return answer

def path_lengths(G,u,v):
    out=set()
    def rec(p,seen):
        a=p[-1]
        if a==v:out.add(len(p)-1);return
        for b in G[a]:
            if b not in seen:rec(p+[b],seen|{b})
    rec([u],{u});return out

def extend(base,S,gadget,ports):
    G=nx.Graph(); edges={};
    for u in base:
        if u in S:
            for v in gadget:G.add_node((u,v))
            for v,w in gadget.edges():G.add_edge((u,v),(u,w))
            for v,w in zip(ports,sorted(base[u])):edges[(u,w)]=(u,v)
        else:
            G.add_node((u,'single'))
            for v in base[u]:edges[(u,v)]=(u,'single')
    for u,v in base.edges():G.add_edge(edges[(u,v)],edges[(v,u)])
    return G

def base_cycles(base):
    # Canonical minimum-root DFS yields each unoriented simple cycle twice.
    result=set()
    def rec(root,v,path):
        if len(path)>=3 and root in base[v]:
            result.add(frozenset(path))
        for w in base[v]:
            if w>root and w not in path:rec(root,w,path+(w,))
    for root in base:rec(root,root,(root,))
    # This vertex-mask representation is sound for K4 (every cycle is unique on its vertex support except K4 cycles on all 4),
    # and we independently retain only a length-spectrum comparison on K4 below.
    return result

def transfer_test(base,S,gadget):
    ports=sorted(u for u in gadget if gadget.degree[u]==2)
    assert len(ports)==3
    pathsets=[path_lengths(gadget,a,b) for a,b in combinations(ports,2)]
    internal=cycle_lengths(gadget,16)
    H=extend(base,S,gadget,ports)
    actual=cycle_lengths(H,16)
    expected=set(internal if S else [])
    for C in base_cycles(base):
        m=len(C&set(S));L=len(C)
        if m==0:expected.add(L)
        else:
            possible={0}
            for _ in range(m):possible={x+v for x in possible for v in pathsets[0]}
            expected.update(L+x for x in possible)
    assert {x for x in expected if x<=16}==actual,(S,pathsets,expected,actual)
    return {'S':sorted(S),'actual':sorted(actual),'internal':sorted(internal),'ports':ports,'pathsets':[sorted(x) for x in pathsets]}

def main():
    # Enumerate every labeled simple 5-vertex graph, select degree sequence exactly
    # (3,3,2,2,2) and connected. All must contain a C4.
    E=list(combinations(range(5),2));valid=0
    for mask in range(1<<len(E)):
        G=nx.Graph();G.add_nodes_from(range(5));G.add_edges_from(e for idx,e in enumerate(E) if mask>>idx&1)
        if sorted(dict(G.degree()).values())!=[2,2,2,3,3] or not nx.is_connected(G):continue
        valid+=1; assert 4 in cycle_lengths(G,5),(mask,G.edges())
    tri=nx.cycle_graph(3);g7=nx.from_graph6_bytes(b'FhcYG')
    assert sorted(dict(g7.degree()).values())==[2,2,2,3,3,3,3]
    assert 4 not in cycle_lengths(g7,7)
    assert all(path_lengths(g7,a,b)=={2,3,4,5,6} for a,b in combinations([u for u in g7 if g7.degree[u]==2],2))
    base=nx.complete_graph(4)
    cases=[]
    for H in [tri,g7]:
        for S in [set(),{0},{0,1},{0,2,3},set(range(4))]:
            cases.append(transfer_test(base,S,H))
    print(json.dumps({'five_vertex_labeled_candidates_checked':valid,'all_5_vertex_gadgets_contain_C4':True,'gadget7_properties':'PASS','literal_transfer_cases':len(cases),'all_transfer_cases':'PASS','cases':cases},sort_keys=True))
if __name__=='__main__':main()

