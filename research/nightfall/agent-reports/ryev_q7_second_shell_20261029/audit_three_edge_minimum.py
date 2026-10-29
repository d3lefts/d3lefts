#!/usr/bin/env python3
"""Independent Q7 three-edge square-syndrome audit; Python 3 standard library.

Does not import NIGHTFALL's earlier cube/checker code. A finite audit is not
an UNSAT certificate for the global 305-edge C4-free problem.
"""
from collections import Counter
from hashlib import sha256
from functools import reduce
from itertools import combinations

N = 7
V = 1 << N
edges = sorted((v, v ^ (1 << d)) for d in range(N)
               for v in range(V) if not (v & (1 << d)))
edge_id = {edge: i for i, edge in enumerate(edges)}
assert len(edges) == len(edge_id) == 448

# First representation: literal four-cycles, generated from two coordinates.
faces = set()
for i, j in combinations(range(N), 2):
    for v in range(V):
        if v & ((1 << i) | (1 << j)):
            continue
        corners = (v, v ^ (1 << i), v ^ (1 << j),
                   v ^ (1 << i) ^ (1 << j))
        face = frozenset(edge_id[tuple(sorted((a, b)))]
                         for a, b in combinations(corners, 2)
                         if (a ^ b).bit_count() == 1)
        assert len(face) == 4
        faces.add(face)
assert len(faces) == 672

stars = [0] * len(edges)
for k, face in enumerate(sorted(faces, key=lambda s: tuple(sorted(s)))):
    for e in face:
        stars[e] |= 1 << k
assert all(s.bit_count() == 6 for s in stars)

# Second representation: geometric incidence, without face masks.
# Parallel edges share a square iff their lower endpoints differ in one bit.
# Nonparallel edges share a square iff they have a common endpoint.
def direction(edge):
    return (edge[0] ^ edge[1]).bit_length() - 1

def cofacial(a, b):
    ea, eb = edges[a], edges[b]
    if direction(ea) == direction(eb):
        return (ea[0] ^ eb[0]).bit_count() == 1
    return bool(set(ea) & set(eb))

for a, b in combinations(range(len(edges)), 2):
    assert bool(stars[a] & stars[b]) == cofacial(a, b)

pairs = {stars[a] ^ stars[b] for a, b in combinations(range(448), 2)}
assert len(pairs) == 100128
assert Counter(s.bit_count() for s in pairs) == {10: 4032, 12: 96096}

# Exhaust ALL 14,885,696 unordered triples, not only incident triples.
weights = Counter()
minimum = set()
nonstar_minimum = 0
for a, b, c in combinations(range(448), 3):
    syndrome = stars[a] ^ stars[b] ^ stars[c]
    w = syndrome.bit_count()
    weights[w] += 1
    if w == 12:
        minimum.add(syndrome)
        # Geometric adverse check: the three edges must meet at one vertex.
        if not (set(edges[a]) & set(edges[b]) & set(edges[c])):
            nonstar_minimum += 1
assert weights == {12: 4480, 14: 47040, 16: 1685376, 18: 13148800}
assert len(minimum) == 128 * 35 == 4480
assert nonstar_minimum == 0
assert minimum.isdisjoint(pairs)

# Every four-edge syndrome of weight 12 must have all six edge pairs
# cofacial. Enumerate ONLY those K4 cliques, not all C(448,4) sets.
neighbors = [set() for _ in edges]
for a, b in combinations(range(448), 2):
    if cofacial(a, b):
        neighbors[a].add(b)
        neighbors[b].add(a)
cliques = set()
for a in range(448):
    for b in neighbors[a]:
        if b <= a:
            continue
        for c, d in combinations(sorted(x for x in neighbors[a] & neighbors[b]
                                        if x > b), 2):
            if d in neighbors[c]:
                cliques.add((a, b, c, d))
assert len(cliques) == 5152
four_weights = Counter()
nonstar_four_minimum = 0
for q in cliques:
    w = (stars[q[0]] ^ stars[q[1]] ^ stars[q[2]] ^ stars[q[3]]).bit_count()
    four_weights[w] += 1
    if w == 12:
        common = set(edges[q[0]])
        for e in q[1:]:
            common &= set(edges[e])
        if not common:
            nonstar_four_minimum += 1
assert four_weights == {12: 4480, 20: 672}
assert nonstar_four_minimum == 0
# Four-star and complementary three-star are the same syndrome, since
# the full seven-edge vertex star is a zero-syndrome cut.
for v in range(V):
    incident = [e for e, (a, b) in enumerate(edges) if v in (a, b)]
    assert len(incident) == 7
    assert not reduce(int.__xor__,
                                               (stars[e] for e in incident), 0)
    for chosen in combinations(incident, 4):
        other = set(incident) - set(chosen)
        lhs = reduce(int.__xor__,
                                             (stars[e] for e in chosen), 0)
        rhs = reduce(int.__xor__,
                                             (stars[e] for e in other), 0)
        assert lhs == rhs and lhs in minimum

# Negative controls: a triple from one square is NOT a minimum triple;
# corruption of one incidence bit MUST invalidate the edge-star invariant.
face = next(iter(faces))
a, b, c = sorted(face)[:3]
assert (stars[a] ^ stars[b] ^ stars[c]).bit_count() == 16
assert (stars[0] ^ 1).bit_count() != 6

canonical = ('\n'.join(f'{a},{b}' for a, b in edges) + '\n--\n' +
             '\n'.join(','.join(map(str, sorted(face)))
                       for face in sorted(faces, key=lambda s: tuple(sorted(s)))) + '\n')
print('PASS Q7: vertices=128 edges=448 faces=672')
print('two-edge syndromes=100128; weight10=4032 weight12=96096')
print('three-edge counts=' + str(dict(sorted(weights.items()))))
print('minimum weight12=4480; all three-stars; disjoint from pairs')
print('four-edge cofacial K4=5152; weight12 four-stars=4480; weight20 faces=672')
print('geometry_sha256=' + sha256(canonical.encode()).hexdigest())
# Exploratory five-edge near-clique falsifier: 12-face five-edge patterns
# require >=9 cofacial pairs. Every 9/10-edge graph on five vertices
# contains a K4, so all candidates extend one of the enumerated cliques.
five_candidates=set()
for q in cliques:
    for e in set.union(*(neighbors[x] for x in q)) - set(q):
        if sum(e in neighbors[x] for x in q) >= 3:
            five_candidates.add(tuple(sorted((*q,e))))
five_counts=Counter()
new_five=set()
for q in five_candidates:
    syndrome=reduce(int.__xor__, (stars[e] for e in q), 0)
    w=syndrome.bit_count()
    five_counts[w]+=1
    if w==12 and syndrome not in pairs and syndrome not in minimum:
        new_five.add(syndrome)
print('five-near-cliques',len(five_candidates),'weights',dict(sorted(five_counts.items())))
assert len(five_candidates) == 2688
assert five_counts == {10: 2688}
assert not new_five
print('new five-edge weight12 syndromes',len(new_five))
print('conditional surviving 12-face syndromes require min edge support >=6')
