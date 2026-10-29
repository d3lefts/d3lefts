"""Independently reproducible exact finite result: every AP edge is essential.
Run: python3 edge_essentiality.py [--json]
No numerical optimization, tolerances, network access, or imported proof results.
"""
from functools import lru_cache
from itertools import combinations
import json, hashlib, sys

A = (-19465109,0,3545689,5427075,6005963,7091378,7308461,
     7545719,7671611,7710347,7782977,7797503,7813379,
     7821803,7824395,7829255,7830227,7835411,7836059,
     7836707,7849019,7874975,7884659,7894343,8078339,
     8466237,8610959,8755681,11505399,19465109)

def edges(a=A):
    return tuple((i,j,k) for i in range(len(a)) for j in range(i+1,len(a))
                 for k in range(j+1,len(a)) if a[i]+a[k]==2*a[j])

def exact_cover(a, ee, limit):
    """Branch on first uncovered 3-AP. Every hitting set chooses one endpoint."""
    incidence = tuple(sum(1<<j for j,e in enumerate(ee) if i in e)
                      for i in range(len(a)))
    @lru_cache(None)
    def solve(uncovered, budget):
        if not uncovered: return 0
        if not budget: return None
        edge = (uncovered & -uncovered).bit_length()-1
        order = sorted(ee[edge],
                       key=lambda p:(incidence[p]&uncovered).bit_count(),
                       reverse=True)
        for v in order:
            rem = solve(uncovered & ~incidence[v], budget-1)
            if rem is not None: return rem | (1<<v)
        return None
    result = solve((1<<len(ee))-1, limit)
    return result, solve.cache_info().currsize

def verify_survivor(survivors, exception, ee):
    if (len(survivors)!=18 or len(set(survivors))!=18 or
        any(not 0<=i<len(A) for i in survivors)):
        raise AssertionError("18 distinct valid survivor indices required")
    active = {e for e in ee if set(e).issubset(survivors)}
    if active != {exception}:
        raise AssertionError(("Exactly omitted AP must survive", exception, active))

def certificate():
    if len(A)!=30 or list(A)!=sorted(set(A)): raise AssertionError("witness")
    ee = edges()
    if len(ee)!=28: raise AssertionError("expected 28 AP edges")
    # Independent four-distinct-pair-sum check of the weak (4,5) premise.
    for i,j,k,l in combinations(range(30),4):
        assert A[i]+A[j]!=A[k]+A[l]
        assert A[i]+A[k]!=A[j]+A[l]
        assert A[i]+A[l]!=A[j]+A[k]
    impossible,states = exact_cover(A,ee,12)
    assert impossible is None, "unexpected 18-point AP-free subset"
    rows=[]
    for i,exception in enumerate(ee):
        cover,_=exact_cover(A,ee[:i]+ee[i+1:],12)
        if cover is None: raise AssertionError("an edge is inessential")
        survivors = [v for v in range(30) if not ((cover>>v)&1)]
        verify_survivor(survivors,exception,ee)
        rows.append({"removed_ap_indices_0based":list(exception),
                     "surviving_18_indices_0based":survivors})
    return {"schema":"nightfall-sidon-edge-essentiality-v1",
            "scope":"One frozen 30-point weak (4,5) integer set; no asymptotic conclusion",
            "points":list(A), "point_count":30,"ap_edge_count":28,
            "minimum_ap_hitting_set_size":13,
            "full_no_12_cover_states":states,
            "theorem":"Each of the 28 three-term AP constraints is essential: deleting any one admits 18 survivors with only that AP, whereas all 28 forbid 18 AP-free survivors.",
            "edge_deletion_witnesses":rows}

def check(doc):
    assert doc["points"]==list(A) and doc["ap_edge_count"]==28
    ee=edges()
    assert len(doc["edge_deletion_witnesses"])==len(ee)
    for e,row in zip(ee,doc["edge_deletion_witnesses"]):
        assert row["removed_ap_indices_0based"]==list(e)
        verify_survivor(row["surviving_18_indices_0based"],e,ee)
    answer,states=exact_cover(A,ee,12)
    assert answer is None and states==doc["full_no_12_cover_states"]
    # Mutation negative control: a corrupted witness is rejected.
    broken=list(doc["edge_deletion_witnesses"][0]["surviving_18_indices_0based"])
    broken[0]=999
    try: verify_survivor(broken,ee[0],ee)
    except AssertionError: pass
    else: raise AssertionError("corrupted certificate was accepted")

if __name__=="__main__":
    doc=certificate()
    check(doc)
    raw=json.dumps(doc,sort_keys=True,indent=2,ensure_ascii=False)+"\n"
    print("PASS: all 28 AP constraints essential; exact no-12-cover states:",
          doc["full_no_12_cover_states"],file=sys.stderr)
    print("Certificate JSON SHA-256:",hashlib.sha256(raw.encode()).hexdigest(),file=sys.stderr)
    if "--json" in sys.argv: sys.stdout.write(raw)
