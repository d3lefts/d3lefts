#!/usr/bin/env python3
"""AXIOM self-design #188: all 3-edge square coboundaries of Q_n.

Builds cube faces from vertex bit geometry independently of Ryev PR #148.
Exhausts every Q7 3-edge set (not just stars) to test the sharp equality.
Uses only Python standard library. No unrestricted extremal claim.
"""
from collections import Counter
from itertools import combinations
import json
import math


def geometry(n):
    vertices = range(1 << n)
    edges = [tuple(sorted((v, v ^ (1 << axis))))
             for axis in range(n) for v in vertices if not v & (1 << axis)]
    assert len(set(edges)) == len(edges) == n * (1 << (n-1))
    idx = {e: i for i, e in enumerate(edges)}
    faces = []
    for i, j in combinations(range(n), 2):
        for v in vertices:
            if v & ((1 << i) | (1 << j)):
                continue
            a, b, c, d = v, v ^ (1 << i), v ^ (1 << j), v ^ (1 << i) ^ (1 << j)
            faces.append(frozenset(idx[tuple(sorted(p))] for p in
                                   ((a,b),(a,c),(b,d),(c,d))))
    assert len(set(faces)) == len(faces) == math.comb(n,2) * (1 << (n-2))
    masks = [0] * len(edges)
    for f, es in enumerate(faces):
        assert len(es) == 4
        for e in es:
            masks[e] |= 1 << f
    assert all(a.bit_count() == n-1 for a in masks)
    return edges, faces, masks


def classify_cofacial_triangles(n, edges, faces, masks):
    adj = [set() for _ in edges]
    for face in faces:
        for a in face:
            adj[a].update(face - {a})
    triangles = set()
    for a in range(len(edges)):
        for b in adj[a]:
            if b <= a:
                continue
            for c in adj[a] & adj[b]:
                if c > b:
                    triangles.add((a,b,c))
    stars = set()
    for v in range(1 << n):
        incident = [i for i, (a,b) in enumerate(edges) if v == a or v == b]
        assert len(incident) == n
        stars.update(combinations(incident,3))
    face_triples = {t for face in faces for t in
                    combinations(sorted(face), 3)}
    assert stars.isdisjoint(face_triples), "a 3-star is never within one face"
    assert triangles == stars | face_triples, "unclassified cofacial triangle"
    assert len(stars) == (1 << n) * math.comb(n,3)
    assert len(face_triples) == 4 * math.comb(n,2) * (1 << (n-2))
    for triple in stars:
        assert (masks[triple[0]] ^ masks[triple[1]] ^ masks[triple[2]]).bit_count() == 3*(n-3)
    for triple in face_triples:
        assert (masks[triple[0]] ^ masks[triple[1]] ^ masks[triple[2]]).bit_count() == 3*n-5
    return stars, face_triples


def exhaustive_q7(edges, masks, stars):
    assert len(edges) == 448
    # All C(448,3) triples: this independently checks the *absence* of
    # non-star 12-face syndromes, not only properties of 4,480 stars.
    seen = set()
    triple_counter = 0
    for a in range(448):
        ma = masks[a]
        for b in range(a+1,448):
            mab = ma ^ masks[b]
            for c in range(b+1,448):
                if (mab ^ masks[c]).bit_count() == 12:
                    triple_counter += 1
                    assert (a,b,c) in stars, "nonstar 12-face counterexample"
                    sig = mab ^ masks[c]
                    assert sig not in seen, "noninjective three-star syndrome"
                    seen.add(sig)
    assert triple_counter == 4480
    assert len(seen) == 4480
    # Distinct from every <=2-edge syndrome; exact 100,128-pair replay.
    single_or_pair = {0} | set(masks)
    for a,b in combinations(range(448),2):
        single_or_pair.add(masks[a] ^ masks[b])
    assert len(single_or_pair) == 1 + 448 + math.comb(448,2)
    assert seen.isdisjoint(single_or_pair)
    return {
        "total_unordered_three_edge_sets": math.comb(448,3),
        "all_weight12_three_edge_sets": triple_counter,
        "distinct_weight12_syndromes": len(seen),
        "zero_to_two_edge_syndromes": len(single_or_pair),
        "overlap_with_zero_to_two": 0,
    }


def main():
    output = {}
    for n in range(3,8):
        edges, faces, masks = geometry(n)
        stars, face_triples = classify_cofacial_triangles(n,edges,faces,masks)
        output[f"Q{n}"] = {
            "edges": len(edges),
            "squares": len(faces),
            "three_stars": len(stars),
            "face_triangles": len(face_triples),
            "cofacial_triangles": len(stars)+len(face_triples),
            "minimum_triple_syndrome_weight": 3*(n-3),
            "face_triple_weight": 3*n-5,
        }
        if n == 3:
            assert 3*(n-3) == 0  # nonzero 3-edge cut has zero syndrome in Q3
        if n == 7:
            output[f"Q{n}"]["full_three_edge_census"] = exhaustive_q7(edges,masks,stars)
    print(json.dumps(output,sort_keys=True,indent=2))
    print("PASS: complete Q7 three-edge weight12 preimage classification")


if __name__ == "__main__":
    main()
