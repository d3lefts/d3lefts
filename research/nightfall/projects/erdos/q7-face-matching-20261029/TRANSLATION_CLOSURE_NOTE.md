# RYEV #113 — exact Q7 face-join closure under all Q6 vertex translations

**State:** internally exact, source-scoped finite computational theorem; independent human mathematical and prior-art review open. This result **does not improve** the historical global extremal window `304 ≤ ex(Q7,C4) ≤ 308`.

## The mathematical statement

Let `F` be the **373 distinct C4-free Q6 faces with 131 or 132 edges** extracted from the *published* 180 Minamo Minamoto Q7 304-edge orbit representatives, in the canonical direction-major encoding (source SHA-256 `2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1`).

For every unordered `A,B∈F`, allowing `A=B`, and every relative vertex translation `τ_t(v)=v XOR t` with `t∈F₂⁶`, the **maximum** number of selected edges in a Q7 graph whose two coordinate-six half-faces are exactly `A` and `τ_t(B)`, with freely optimized crossing edges, is **at most 304**. Equality is achieved at zero relative translation by the previously independently verified fixed-alignment pair in parent PR #107. Thus the precise maximum of this translation-closed finite catalogue is 304.

The claim covers `373·374/2·64=4,464,064` different unordered pair/translation trials, **not** the full signed-permutation Q6 automorphism group (additional 720 coordinate permutations) and **not** unlisted Q6 faces.

## Exact proof reduction

For Q6 C4-free half-faces A,B, choose a subset I of the 64 vertices where Q7 *crossing edges* are included. A Q7 square using the new coordinate is complete exactly when it has two crossing edges at the endpoints of an edge belonging to both A and B. Hence I must be independent in the common-edge graph `H=A∩B`, and every independent set produces a valid Q7 join. As H is bipartite, König's theorem gives

```
maxJoinedEdges(A,B) = |A| + |B| + 64 − ν(A ∩ B)
```

where ν is maximum matching. Every Q6 translation preserves the cube and the C4-free property.

The necessary 305-edge thresholds on ν are:

| Sizes of faces | A join reaches 305 only if ν ≤ | 304 certified when ν ≥ |
| --- | ---: | ---: |
| 131 + 131 | 21 | 22 |
| 131 + 132 | 22 | 23 |
| 132 + 132 | 23 | 24 |

The independent C++ verifier enumerates the frozen source faces, explicitly maps all 192 Q6 edge slots under every one of the 64 XOR translations, builds the common-edge bipartite graph and searches for an explicit matching of size **22, 23, 24**, respectively. Each successful augmenting-path step constructs an actual matching and proves that the corresponding join has at most 304 edges. If any case fails the threshold, the verifier completes the matching, constructs a König minimum-cover independent set, writes the complete Q7 candidate edge list, and checks all 672 four-cycles. A separate Python script reconstructs every edge and every four-cycle before reporting an accepted 305 witness.

The optimized C++ implementation stops as soon as the necessary matching is found, so **it does not claim the full maximum-matching histogram**; the bound needs only this concrete lower bound on ν for each instance.

## Reproduced measurements

Completed first full CI: [run 40831635778](https://github.com/d3lefts/d3lefts/actions/runs/40831635778)

| Exact finite count | Value |
| --- | ---: |
| Published source Q7 seed graphs | 180 |
| High-density Q6 half-faces | 373 (253 × 131 edges; 120 × 132) |
| Unordered face pairs with repetition | 69,751 |
| Relative vertex translations | 64 |
| Face-translation trials | **4,464,064** |
| 131+131 trials | 2,056,384 |
| 131+132 trials | 1,943,040 |
| 132+132 trials | 464,640 |
| Instances with certified blocking matching | **4,464,064** |
| Instances permitting ≥305-edge join | **0** |

**Initial exploration:** a separate seed-1729 exploratory sample of 50,000 randomized orientation-and-translation trials among 120 high 132-edge source faces found minimum common-edge matching 24. That sample was inconclusive. The complete result above covers **only translations** and is not a claim that the 720 coordinate permutations were exhausted.

## Reproduce and falsify

From repository root on this draft PR branch:

```sh
echo '2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1  research/nightfall/projects/erdos/q7-global-face-20261029/canonical_180.txt' | sha256sum -c -
python3 research/nightfall/projects/erdos/q7-face-matching-20261029/test_matching.py
python3 research/nightfall/projects/erdos/q7-face-matching-20261029/test_translations.py
g++ -O3 -std=c++17 -Wall -Wextra -Werror research/nightfall/projects/erdos/q7-face-matching-20261029/q7_translation.cpp -o /tmp/q7_translation
/tmp/q7_translation research/nightfall/projects/erdos/q7-global-face-20261029/canonical_180.txt
```

- `test_matching.py` checks König matching/minimum-cover against **all 4,096 subgraphs of Q3** using an independent vertex-cover brute-force implementation, and confirms a deliberately invalid crossing-square is rejected.
- `test_translations.py` independently verifies the **4,096 translation-pair group compositions** across 192 Q6 cube edges, preserves face C4-free and cardinality under translation, and tests a deliberately invalid count-preserving Q6 face.
- CI also injects a changed source mask and demands the C++ verifier **reject** the corrupted catalogue.
- `verify_translated_candidate.py` is a distinct vertex-major 128/448/672 checker for any surprise candidate, including a separate two-step common-neighbor C4 check.

The SHA-locked source catalogue is attributed to Minamo Minamoto's public C4-free hypercube research; Q6 matching and König's theorem are standard mathematics. This is a finite computation within a new tested subfamily, **not** a new global C4-free hypercube record, exhaustive classification of Q6 faces, external scientific validation, or asserted novelty of the matching theorem.

**Stop rule:** no further isolated stochastic orientation tuning in this assignment. Reopen after an independently scoped plan for all 720 Q6 coordinate permutations, new Q6 face families, or proof-producing global SAT. Lemnis attacks the matching reduction, Axiom audits face normalization and translation action, Vesper controls priority/status, Devin controls research publication.
