"""Independent Python audit of exact 3-port replacement obstructions.

Separate graph6 parser (NetworkX), cycle oracle (simple paths between two
neighbors of a deleted root), and vectorized subset enumeration (NumPy).
All calculations are integers. Requires networkx and numpy.
"""
from itertools import combinations
from pathlib import Path
import hashlib
import json
import sys
import networkx as nx
import numpy as np

HERE = Path(__file__).resolve().parent
G6 = (HERE / 'markstrom_24_and_26.g6').read_text().splitlines()


def root_path_cycle_masks(graph):
    # Different from C++ DFS: delete the root and all lower-labeled vertices;
    # paths between two of its remaining neighbors uniquely determine cycles.
    ans = {}
    for root in graph:
        H = graph.subgraph(v for v in graph if v > root)
        nbrs = sorted(set(graph.neighbors(root)) & set(H))
        for a, b in combinations(nbrs, 2):
            for p in nx.all_simple_paths(H, a, b, cutoff=14):
                L = len(p) + 1
                if 3 <= L <= 16:
                    mask = 1 << root
                    for v in p:
                        mask |= 1 << v
                    ans.setdefault(L, set()).add(mask)
    return ans


def violates(L, m, targets, lo, hi):
    return any(L + lo*m <= t <= L + hi*m for t in targets)


def solve(graph, lo, hi):
    n = graph.number_of_nodes()
    cycle_masks = root_path_cycle_masks(graph)
    assert not cycle_masks.get(4) and not cycle_masks.get(8)
    constraints = [(L, m) for L, masks in cycle_masks.items() for m in masks]
    # Evaluate most selective short-cycle constraints first, using only
    # a simple finite-population calculation to choose the order.
    from math import comb
    def rank(item):
        L, _ = item
        return sum(comb(L, m) for m in range(L+1) if violates(L, m, (4, 8), lo, hi)) / (2**L)
    short = sorted((p for p in constraints if any(violates(p[0], m, (4,8), lo, hi) for m in range(p[0]+1))), key=rank, reverse=True)
    arr = np.arange(1 << n, dtype=np.uint32)
    for L, mask in short:
        m = np.bitwise_count(np.bitwise_and(arr, np.uint32(mask)))
        ok = np.ones(L+1, dtype=np.bool_)
        for k in range(L+1):
            ok[k] = not violates(L, k, (4,8), lo, hi)
        arr = arr[ok[m]]
    survivor48 = len(arr)
    long = [(L, mask) for L, mask in constraints if any(violates(L, m, (16,), lo, hi) for m in range(L+1))]
    long.sort(key=lambda item: sum(comb(item[0], m) for m in range(item[0]+1) if violates(item[0], m, (16,), lo, hi))/(2**item[0]), reverse=True)
    for L, mask in long:
        m = np.bitwise_count(np.bitwise_and(arr, np.uint32(mask)))
        ok = np.ones(L+1, dtype=np.bool_)
        for k in range(L+1):
            ok[k] = not violates(L, k, (16,), lo, hi)
        arr = arr[ok[m]]
        if len(arr) == 0:
            break
    return survivor48, len(arr), {str(L): len(v) for L,v in sorted(cycle_masks.items())}


def main():
    gadget7 = (len(sys.argv)>1 and sys.argv[1]=="--gadget7")
    lo,hi = (2,6) if gadget7 else (1,2)
    if gadget7:
        gadget = nx.from_graph6_bytes(b"FhcYG")
        ports=[v for v,d in gadget.degree() if d==2]
        assert len(ports)==3 and set(dict(gadget.degree()).values())=={2,3}
        for a,b in combinations(ports,2):
            assert {len(p)-1 for p in nx.all_simple_paths(gadget,a,b)}==set(range(2,7))
        assert not root_path_cycle_masks(gadget).get(4)
    results=[]
    for idx, line in enumerate(G6,1):
        graph = nx.from_graph6_bytes(line.encode('ascii'))
        assert graph.number_of_nodes() == (24 if idx<=4 else 26)
        assert set(dict(graph.degree()).values()) == {3}
        assert nx.to_graph6_bytes(graph,header=False).decode().strip() == line
        n48, nall, lengths = solve(graph,lo,hi)
        print(f'base={idx} n={len(graph)} survivor_C4_C8={n48} survivor_C4_C8_C16={nall}',flush=True)
        results.append({'base':idx,'n':len(graph),'survivors_4_8':n48,'survivors_4_8_16':nall,'cycle_vertex_masks_by_length':lengths})
    (HERE/('independent_gadget7_results.json' if gadget7 else 'independent_audit_results.json')).write_text(json.dumps(results,indent=2)+'\n')
    print('input_sha256',hashlib.sha256((HERE/'markstrom_24_and_26.g6').read_bytes()).hexdigest())
    assert all(x['survivors_4_8_16']==0 for x in results)

if __name__=='__main__': main()
