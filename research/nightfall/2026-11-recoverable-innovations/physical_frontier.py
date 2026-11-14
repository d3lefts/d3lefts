"""Exact tree-budget risk frontier for reconstructed edge innovations only.

For selected original state-vertex set S, edge e={u,v} is available exactly
when both endpoints lie in S. This is NOT the unrestricted state Bayes frontier.
"""
from fractions import Fraction as F

def maximum_reconstructed_energy(parent, weights, budget):
    n=len(parent)
    assert len(weights)==n-1 and 0<=budget<=n
    children=[[] for _ in range(n)]
    for v in range(1,n):
        assert 0<=parent[v]<v
        children[parent[v]].append(v)
    dp={}
    for v in range(n-1,-1,-1):
        for selected in (0,1):
            curr={selected:(F(0), (v,) if selected else ())}
            for c in children[v]:
                nxt={}
                for count,(gain,sites) in curr.items():
                    for selected_child in (0,1):
                        for sub_count,(sub_gain,sub_sites) in dp[c,selected_child].items():
                            count2=count+sub_count
                            if count2>budget: continue
                            gain2=gain+sub_gain+(
                                F(weights[c-1]) if selected and selected_child else 0)
                            sites2=sites+sub_sites
                            old=nxt.get(count2)
                            if old is None or gain2>old[0] or (
                                    gain2==old[0] and sites2<old[1]):
                                nxt[count2]=(gain2,sites2)
                curr=nxt
            dp[v,selected]=curr
    best=(F(0),())
    for selected in (0,1):
        for count,(gain,sites) in dp[0,selected].items():
            if gain>best[0] or (gain==best[0] and sites<best[1]):
                best=(gain,sites)
    return best

def frontier(parent,weights):
    total=sum((F(w) for w in weights),F(0))
    return [(r,total-maximum_reconstructed_energy(parent,weights,r)[0])
            for r in range(len(parent)+1)]
