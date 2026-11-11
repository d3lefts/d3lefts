# Proof Passport: NF-BOUVEL-4SHUFFLE-20261111

**Lifecycle:** NULL FIELD / active research · **Status:** finite computer-assisted theorem candidate; not externally refereed or novelty-certified.

**Claim:** The least N for which every N-permutation has a consecutive four-shuffle factor is 20. A four-shuffle consists of four disjoint equal-size (at least two) subsequences having an identical order pattern. Every 20-permutation has a qualifying factor of length 8 or 12.

**Upper proof:** 5,040 standardized seven-entry states; exactly 2,632 bad eight-entry edges; all 302 length-20 walks avoiding an eight-entry shuffle have a forced common-pattern four-triple partition inside a consecutive twelve-entry factor, using only locally known comparisons.

**Lower proof:** 19-entry witness 1,17,2,4,16,15,14,8,9,10,11,12,7,6,5,13,18,3,19; exact check of 24 eligible factors, no four-shuffle.

**Checker:** verify_four_shuffle.py (standard Python 3.10+, no external certificate input). GitHub CI reconstructs the graph and tests all claimed cases.

**Prior art:** Bouvel's conjecture; Bevan, Elvey Price and Felsner's 2024 factor-graph and perfect-matching method, Oberwolfach Report 6/2024, reported bound N4<=26.

**Provenance:** Source archive ZIP SHA-256 71e836af72ef0a5b4480f1aac7c704a80eb544f9dac3bfade4a1f4b9014ad759; PDF SHA-256 1abd05d18f40bd83350f1a634b95efdf61912163b2ed3e2748f2a7641c1d55c1. The original PDF/ZIP remain chat artifacts and are not claimed present in GitHub.

**Review gates:** Independently check inversion/noninversion perfect matching, all factor-graph edges, completeness of 302 paths, forced comparisons for the twelve-entry triples, and the lower-witness exhaustive search. Comprehensive dated originality and external mathematics referee reviews still required. The k-shuffle conjecture for arbitrary k is OPEN.

**Scientific boundaries:** finite exact certificate != outside peer review; specific k=4 threshold != general k theorem; a published graph method != a new graph method; repository merge != publication clearance.

Research led by Devin J. Wright, NIGHTFALL Constellation; AI-assisted proof discovery and internal checks.
