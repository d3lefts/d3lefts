#!/usr/bin/env python3
"""Independent brute-force adversarial tests for the Q7 face-join matching oracle."""
from itertools import combinations
import matching

# Embed the complete 3-dimensional cube in the low eight vertices of Q6.
small_edges=[i for i,(v,w,d) in enumerate(matching.E6) if v < 8 and w < 8 and d < 3]
assert len(small_edges)==12
checks=0
for bits in range(1<<12):
    selected={small_edges[j] for j in range(12) if bits & (1<<j)}
    mask=sum(1<<e for e in selected)
    size,indep,cover=matching.matching_cover(mask)
    assert len(cover)==size
    # Independent, separately implemented exhaustive eight-vertex minimum cover.
    min_cover=9
    for state in range(1<<8):
        candidate={v for v in range(8) if state & (1<<v)}
        if all(u in candidate or v in candidate
               for e in selected for u,v,d in [matching.E6[e]]):
            min_cover=min(min_cover,len(candidate))
    assert min_cover==size,("dual mismatch",bits,min_cover,size)
    assert len(indep)==64-size
    checks+=1

# Deliberately add two crossing edges whose common face-edge completes a square.
faces=matching.source_faces()
a=faces[0]
b=next(f for f in faces[1:] if a["mask"] & f["mask"])
common=(a["mask"] & b["mask"])
e=(common & -common).bit_length()-1
u,v,d=matching.E6[e]
try:
    matching.witness(a,b,{u,v})
except AssertionError:
    pass
else:
    raise AssertionError("Invalid crossing square was accepted")

# A matching-derived independent set must reconstruct an actual C4-free Q7 graph.
size,indep,cover=matching.matching_cover(a["mask"]&b["mask"])
valid=matching.witness(a,b,indep)
assert valid["edges"]==a["count"]+b["count"]+64-size
assert valid["edges"]<=308

print("PASS:",checks,"exhaustive Q3 subgraphs (12 edges) match exact Q6 matching/cover dual;",
      "tampered cross square rejected; valid reconstructed Q7 witness checked against 672 squares.")
