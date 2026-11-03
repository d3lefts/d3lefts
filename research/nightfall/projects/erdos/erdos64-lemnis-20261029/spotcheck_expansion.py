"""Construct expanded graphs literally, then search simple cycles independently."""
from pathlib import Path
import networkx as nx
from independent_audit import G6, root_path_cycle_masks

def expand(g, subset, gadget7=False):
    # Label ports by sorted neighbors, independently of cycle formula.
    new=nx.Graph()
    port={}
    gadget=nx.from_graph6_bytes(b"FhcYG") if gadget7 else None
    ports=sorted(v for v,d in gadget.degree() if d==2) if gadget7 else None
    for v in g:
        if v in subset:
            if gadget7:
                for j in gadget:new.add_node((v,j))
                for a,b in gadget.edges():new.add_edge((v,a),(v,b))
                for j,w in zip(ports,sorted(g[v])):port[(v,w)]=(v,j)
            else:
                for i in range(3):new.add_node((v,i))
                new.add_edges_from([((v,0),(v,1)),((v,1),(v,2)),((v,2),(v,0))])
                for i,w in enumerate(sorted(g[v])):port[(v,w)]=(v,i)
        else:
            new.add_node((v,0))
            for w in g[v]:port[(v,w)]=(v,0)
    for v,w in g.edges():new.add_edge(port[(v,w)],port[(w,v)])
    return nx.convert_node_labels_to_integers(new)

def contains_cycle(g,L):
    # Boolean root-based DFS, separate from both cycle-mask enumerators.
    adj={v:tuple(g[v]) for v in g}
    def dfs(s,v,depth,used):
        if depth==L:
            return s in adj[v]
        for w in adj[v]:
            if w<=s or w in used:continue
            used.add(w)
            if dfs(s,w,depth+1,used):return True
            used.remove(w)
        return False
    for s in g:
        if dfs(s,s,1,{s}):return True
    return False

def predict(g, S, gadget7=False):
    masks=root_path_cycle_masks(g)
    smask=sum(1<<v for v in S)
    return {L:any(any(base+(2 if gadget7 else 1)*m<=L<=base+(6 if gadget7 else 2)*m for mask in groups for m in [int((mask&smask).bit_count())]) for base,groups in masks.items()) for L in (4,8,16)}

def main():
    cases=[(0,set()),(0,{0}),(0,{0,1,2}),(1,set(range(24))), (2,{0,1,2,3,4}), (3,set(range(24))), (4,set()),(4,{0,1,2}), (18,set(range(26))),(26,{0,1,2,3})]
    for gadget7 in (False,True):
      for idx,S in cases:
        g=nx.from_graph6_bytes(G6[idx].encode())
        H=expand(g,S,gadget7)
        p=predict(g,S,gadget7)
        actual={L:contains_cycle(H,L) for L in (4,8,16)}
        assert p==actual,(idx,S,gadget7,p,actual)
        print('gadget7',gadget7,'base',idx+1,'expanded',len(S),'order',len(H),'predicted',p,'actual',actual,flush=True)
if __name__=='__main__':main()
