# Four-shuffle N4=20 — independent proof and priority review

**Date:** November 13, 2026. **Research direction:** Devin J. Wright (NIGHTFALL). AI-assisted proof/code development. **Status:** Two independently authored, exact finite proof-checking programs; no human non-author review and no adjudicated worldwide priority.

## Exact mathematical claim

A four-shuffle is a permutation of length 4t, t>=2, whose positions partition into four equal-length increasing-index subsequences of identical relative order. A factor is consecutive. Let N4 be the minimum length at which *every* permutation has a four-shuffle factor.

**Theorem (complete finite computation):** N4=20. Every length-20 permutation contains a factor of size 8 or 12 that is a four-shuffle. A length-19 avoiding permutation is

    1 17 2 4 16 15 14 8 9 10 11 12 7 6 5 13 18 3 19

and avoids all eligible factors of length 8,12,16. In the 2024 paper's convention, in which all lengths n>n0(k) must contain the factor, our result is **n0(4)=19**.

## Exact proof mechanism and attributed prior methods

1. Mathilde Bouvel posed the k-shuffle question; Bevan, Elvey Price and Felsner (Oberwolfach 2024) introduced factor graphs and matching characterization. Those steps are PRIOR ART.
2. Build the 5040 standardized seven-element states and the 2632 length-eight nonshuffle transitions, using inversion/noninversion perfect-matchings of eight positions. The resulting directed graph is acyclic, with longest path length 18.
3. Exhaust all 302 length-13-edge graph paths. These represent the possible locally standardized length-20 sequences avoiding every eight-element four-shuffle. Record only comparisons between positions at distance at most seven. Leave all distant comparisons UNKNOWN.
4. For every one of those 302 paths, find a consecutive twelve-element factor admitting four disjoint triples with an identical order pattern using ONLY the fully known comparison pairs. Every completion of the comparison constraints therefore contains a length-twelve four-shuffle.
5. Check the explicit length-19 witness by an independent full exact-cover shuffle test over all 24 eligible windows.

## Independent source and exact replays

Original public code: verify_four_shuffle.py, Git blob SHA 1e939073e99223c029e1d2af82c6ec9009f61778.

An independently written checker, independent_four_shuffle_audit.py, uses recursive graph matching rather than the original explicit 105 pair partitions, new local-comparison pattern reconstruction, and independent exact cover. A direct local execution passed:

    states=5040
    bad_eight_edges=2632
    longest_edge_walk=18
    length20_walks_checked=302
    witness_length=19
    witness_windows=24
    status=EXACT PASS

The original independently executed 137-line file (which has minor comment differences from the normalized repository version) has SHA-256 d2b8d7dfbe2afeb2fdebe96f67a9f3ad8beefd8ac0ac7c3671e646f7bc6c5a51. Do not conflate file hashes of two source versions. A successful dedicated GitHub CI receipt on this branch is a separately required replay gate.

## External references and priority

2024 primary reference: Oberwolfach Report 6/2024, Mini-Workshop: Permutation Patterns, pp.287, 305–306, https://ems.press/content/serial-article-files/48646 . Bouvel reported n0(4)<=26; the workshop confirmed acyclicity through k=5 and introduced the graph/matching techniques. This source does NOT state our exact threshold n0(4)=19.

November 13 targeted searches across web and SciSpace scientific index for Bouvel four-shuffle, N4=20, consecutive four-shuffle factor, 19/20 thresholds, and named author combinations did not locate a previous exact value. Card shuffle groups and shuffled word squares are different objects. This negative search is **not a logically complete proof of historical priority**. Grey literature, unpublished notes, and direct communications may subsume the result.

**Novelty label:** likely previously unreported in the sources checked; still NOT certified as a worldwide first. No external human referee.

## Correct interpretation

- The result is a complete k=4 finite special case of an open general conjecture, not the all-k theorem.
- The graph representation and matching characterization are imported from the 2024 specialists.
- The exact threshold, 19-witness, and universal 302-case partial-comparison forcing certificate belong to the NIGHTFALL research record.
- The claimed five-shuffle N5=31 candidate cannot be promoted on incomplete source/CI evidence.
- Do not change the public approved-finding count or assert global-priority certification without non-author mathematical/historical review.

**Best next test:** referee both matching algorithms and the comparison-forcing logic; obtain specialist feedback on whether the exact value or a stronger equivalent statement appears in unindexed literature.
