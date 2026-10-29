#!/usr/bin/env python3
"""Exact bipartite recombination of published Q7 near-optimal Q6 half faces.

The input is the attributed 180-mask Minamoto witness catalogue.  This script
proves a finite statement for its extracted source faces; it does not classify
all Q6 extremal faces, all cube orientations, or all C4-free Q7 graphs.
"""
from __future__ import annotations

from collections import Counter
from pathlib import Path
import hashlib
import json
import time

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT.parent / "q7-global-face-20261029" / "canonical_180.txt"
SOURCE_SHA256 = "2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1"

def cube(n):
    edges = [(v, v ^ (1 << d), d)
             for d in range(n) for v in range(1 << n) if not v & (1 << d)]
    edge_id = {(v, d): i for i, (v, w, d) in enumerate(edges)}
    squares = []
    for a in range(n):
        for b in range(a + 1, n):
            for v in range(1 << n):
                if v & ((1 << a) | (1 << b)):
                    continue
                squares.append((
                    edge_id[v, a], edge_id[v, b],
                    edge_id[v | (1 << b), a],
                    edge_id[v | (1 << a), b]
                ))
    assert len(edges) == n * (1 << (n - 1))
    assert len(set(tuple(sorted((v,w))) for v,w,d in edges)) == len(edges)
    assert len(squares) == (n * (n - 1) // 2) * (1 << (n - 2))
    return edges, squares, edge_id

E7, S7, I7 = cube(7)
E6, S6, I6 = cube(6)
LEFT = tuple(v for v in range(64) if v.bit_count() % 2 == 0)
RIGHT = tuple(v for v in range(64) if v.bit_count() % 2 == 1)

def source_faces():
    data = SOURCE.read_bytes()
    assert hashlib.sha256(data).hexdigest() == SOURCE_SHA256, "Source identity mismatch"
    lines = data.decode("ascii").splitlines()
    assert len(lines) == 180 and len(set(lines)) == 180
    distinct = {}
    source_faces_total = Counter()
    for source_id, hexmask in enumerate(lines):
        assert len(hexmask) == 112
        raw = bytes.fromhex(hexmask)
        chosen = [e for e in range(448) if raw[e >> 3] & (128 >> (e & 7))]
        assert len(chosen) == 304
        chosen_set = set(chosen)
        assert all(sum(e in chosen_set for e in sq) <= 3 for sq in S7), "Invalid source Q7 witness"
        for fixed in range(7):
            for bit in (0,1):
                ids = []
                for e in chosen:
                    v, w, d = E7[e]
                    if d == fixed or (v >> fixed) & 1 != bit:
                        continue
                    folded = (v & ((1 << fixed) - 1)) | ((v >> (fixed + 1)) << fixed)
                    dd = d - int(d > fixed)
                    ids.append(I6[folded, dd])
                if len(ids) < 131:
                    continue
                source_faces_total[len(ids)] += 1
                ids = tuple(sorted(ids))
                if ids not in distinct:
                    distinct[ids] = dict(ids=ids, count=len(ids), seed=source_id, fixed=fixed, bit=bit)
    faces = list(distinct.values())
    assert len(faces) == 373, len(faces)
    assert Counter(f["count"] for f in faces) == {131: 253,132: 120}
    assert source_faces_total == {131: 660,132:333}
    for f in faces:
        f["mask"] = sum(1 << i for i in f["ids"])
        assert all(sum(bool(f["mask"] & (1 << e)) for e in sq) <= 3 for sq in S6)
    return faces

def matching_cover(common_mask):
    """Exact maximum matching and minimum vertex cover of a Q6 bipartite graph.

    BFS not required: augmenting-path DFS from each left vertex finds maximum
    cardinality by the classical Berge augmenting-path criterion.
    """
    adj = [[] for _ in range(64)]
    m = common_mask
    while m:
        bit = m & -m
        e = bit.bit_length() - 1
        m ^= bit
        u, v, d = E6[e]
        if u.bit_count() & 1:
            u, v = v, u
        adj[u].append(v)
    mate_r = [-1] * 64
    def augment(u, seen):
        for v in adj[u]:
            if v in seen:
                continue
            seen.add(v)
            if mate_r[v] == -1 or augment(mate_r[v], seen):
                mate_r[v] = u
                return True
        return False
    matching = 0
    for u in LEFT:
        if augment(u, set()):
            matching += 1

    # Alternating reachability from unmatched left vertices.
    matched_left = {u for u in mate_r if u >= 0}
    seen_left = set(LEFT) - matched_left
    seen_right = set()
    pending = list(seen_left)
    while pending:
        u = pending.pop()
        for v in adj[u]:
            if mate_r[v] == u:
                continue
            if v in seen_right:
                continue
            seen_right.add(v)
            w = mate_r[v]
            if w >= 0 and w not in seen_left:
                seen_left.add(w)
                pending.append(w)
    cover = (set(LEFT) - seen_left) | seen_right
    independent = set(range(64)) - cover
    assert len(cover) == matching
    assert len(independent) == 64 - matching
    assert all(not (u in independent and v in independent)
               for u in LEFT for v in adj[u])
    return matching, independent, cover

def witness(fa, fb, independent):
    """Embed each face into bit6=0/1 and join selected matching-independent vertices."""
    selected = set()
    for e in fa["ids"]:
        u, v, d = E6[e]
        selected.add(I7[u, d])
    for e in fb["ids"]:
        u, v, d = E6[e]
        selected.add(I7[64 | u, d])
    for v in independent:
        selected.add(I7[v, 6])
    assert len(selected) == fa["count"] + fb["count"] + len(independent)
    # Independent direct square oracle:
    assert all(sum(edge in selected for edge in sq) <= 3 for sq in S7)
    edges = sorted((E7[i][0], E7[i][1]) for i in selected)
    blob = "".join(f"{u} {v}\n" for u,v in edges).encode()
    return dict(edges=len(edges),edgeListSha256=hashlib.sha256(blob).hexdigest(),
                witnessFirstEdges=edges[:10],crossEdges=sorted(independent),
                selectedSortedEdges=edges)

def run():
    start = time.monotonic()
    faces = source_faces()
    score_hist = Counter()
    pair_class = Counter()
    best_score = -1
    best_pair = None
    best_count = 0
    minima = {}
    total = 0
    for i, a in enumerate(faces):
        for j in range(i, len(faces)):
            b = faces[j]
            m, indep, cover = matching_cover(a["mask"] & b["mask"])
            score = a["count"] + b["count"] + 64 - m
            key = tuple(sorted((a["count"],b["count"])))
            pair_class[key] += 1
            score_hist[score] += 1
            total += 1
            minima[key] = min(minima.get(key, 64),m)
            if score > best_score:
                best_score = score
                best_pair = (i,j,indep,m)
                best_count = 0
            if score == best_score:
                best_count += 1
    assert total == 69751
    assert pair_class[(131,131)] == 32131
    assert pair_class[(131,132)] == 30360
    assert pair_class[(132,132)] == 7260
    assert best_score >= 304, "Unexpected failure to reproduce published 304 example"
    i,j,indep,m = best_pair
    best = witness(faces[i],faces[j],indep)
    assert best["edges"] == best_score
    result = dict(
      format="nightfall-q7-face-matching-catalogue-v1",
      sourceCatalogueSha256=SOURCE_SHA256,
      originalQ7Seeds=180,
      distinctQ6HighFaces=len(faces),
      sourceFaceCounts={"131":253,"132":120},
      facePairsTested=total,
      pairClasses={f"{a}+{b}":pair_class[a,b] for a,b in sorted(pair_class)},
      minimumMatching={f"{a}+{b}":minima[a,b] for a,b in sorted(minima)},
      scoreHistogram=dict(sorted(score_hist.items())),
      bestEdges=best_score,bestPairCount=best_count,
      bestSources=[dict(seed=faces[k]["seed"],fixed=faces[k]["fixed"],
                        half=faces[k]["bit"],faceEdges=faces[k]["count"]) for k in (i,j)],
      bestMatching=m,bestWitnessSha256=best["edgeListSha256"],
      bestCrossCount=len(best["crossEdges"]),
      timeSeconds=round(time.monotonic()-start,3),
      conclusion=("CATALOGUE_RECOMBINATION_UPPER_BOUND_304" if best_score==304
                  else "CANDIDATE_IMPROVEMENT_REQUIRES_PRIOR_ART_REVIEW"),
      scope="Only these 373 normalized 131/132-edge source Q6 faces with fixed common coordinate alignment; no claim about all Q6 faces or cube automorphism transforms",
      mathematicalMechanism="König: max cross edges 64 - maximum matching of common Q6 face edges."
    )
    print(json.dumps(result,indent=2))
    out=ROOT/"best_join_edges.txt"
    out.write_text("".join(f"{u} {v}\n" for u,v in best["selectedSortedEdges"]))
    assert hashlib.sha256(out.read_bytes()).hexdigest()==best["edgeListSha256"]
    assert best["edges"] <= 308
    return result

if __name__=="__main__":
    run()
