# Consecutive four-shuffle forcing length: exactly 20

NIGHTFALL Constellation · Devin J. Wright · 11 November 2026

**Status:** computer-assisted finite mathematical theorem candidate, with a self-contained exact verifier. Not an externally refereed theorem, Lean formalization, comprehensive novelty clearance, or proof of the general k-shuffle conjecture.

## Precise statement

A four-shuffle is a permutation of length 4t (t >= 2) whose positions split into four disjoint increasing-index subsequences of equal size t and identical relative-order pattern. A factor is a consecutive block.

Let N4 be the smallest length such that every N4-permutation contains a four-shuffle factor. The finite computation establishes

    N4 = 20.

Every 20-permutation has a four-shuffle factor of length 8 or 12. The following 19-permutation avoids every eligible factor of lengths 8, 12, 16:

    1 17 2 4 16 15 14 8 9 10 11 12 7 6 5 13 18 3 19

## Upper proof certificate

1. An eight-entry four-shuffle is a shuffle of four copies of 12 or 21. These correspond to perfect matchings in the noninversion/inversion graph. The checker enumerates all 105 partitions of eight positions into four pairs.
2. Build the factor graph on all 7! = 5,040 standardized length-seven states. Each length-eight non-shuffle contributes an edge between its prefix and suffix patterns. Precisely 2,632 edges occur among all 8! = 40,320 eight-patterns.
3. The avoidance factor graph is acyclic, with a longest directed path of 18 edges. A length-20 permutation that avoids every eight-entry four-shuffle induces a path of length 13; there are exactly **302** such paths.
4. For each of these 302 paths, the checker reconstructs all comparisons of indices at distance <= 7, without assuming the remaining distant comparisons. In some consecutive length-twelve window, it finds four disjoint triples with the same relative order. Each triple has only forced comparisons. Therefore **every completion** of each path contains a twelve-entry four-shuffle.
5. Independently, exhaustive subsequence-pattern exact cover checks every one of the 24 eligible windows in the displayed length-19 witness. No such window is a four-shuffle. The two directions prove N4=20.

The proof does not rely on a heuristic search or floating-point tolerance.

## Public reproduction

From the repository root run:

    python3 -I research/nightfall/2026-11-four-shuffle/verify_four_shuffle.py

This standalone Python 3.10+ verifier requires no third-party dependencies or precomputed certificate JSON. Expected results: 5,040 states, 2,632 edges, 302/302 forced twelve-shuffle path certificates, 24/24 excluded factors of the 19-witness. A dedicated GitHub Actions workflow runs the same check. A finite executable proof must still be assessed for code correctness by an independent human referee.

## Original source and provenance

The original conversation archive contains a separately authored builder and independent verifier, all 302 explicit path certificates, LaTeX and compiled manuscript. The clean source ZIP passed 8/8 listed SHA-256 hashes; the included independent verifier completed successfully.

- Original source ZIP: BOUVEL_4SHUFFLE_EXACT_N20_20261111_SOURCE_AND_CERTIFICATE.zip, SHA-256 71e836af72ef0a5b4480f1aac7c704a80eb544f9dac3bfade4a1f4b9014ad759.
- Original manuscript PDF: BOUVEL_Four_Shuffle_Exact_Threshold_20.pdf, SHA-256 1abd05d18f40bd83350f1a634b95efdf61912163b2ed3e2748f2a7641c1d55c1.

These binary files are conversation attachments; **their mere names and hashes do not mean they are GitHub download assets.** The checked-in source note and verifier are public reproducibility material.

## Credit, historical boundary, and open gates

Mathilde Bouvel posed the k-shuffle conjecture. David Bevan, Andrew Elvey Price and Stefan Felsner introduced the 2024 factor graph and matching characterization: [Oberwolfach Report 6/2024](https://ems.press/content/serial-article-files/48646), especially the open-problem entry and Progress on k-shuffle conjecture (pp. 305-306). That report listed the k=4 upper bound 26; NIGHTFALL claims only the independently replayed exact threshold 20, **not the factor-graph method**.

A targeted 11 November 2026 web search located the workshop reference; it did not establish global priority against all subsequent mathematics. Separate gates: independent non-author review of graph completeness and forced local comparisons, dated novelty audit, source-archive deposition, and publication authorization. Do not add this candidate to the frozen 40-record library, eleven historical passports, or five approved findings.

**Proof graph:** Bouvel definition -> imported factor graph -> exact short shuffle classification -> every 20-avoidance path -> forced common-triple factor -> 19-entry witness -> N4=20 -> external review pending.
