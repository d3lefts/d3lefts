# Exact consecutive five-shuffle forcing length N5=31 — source-scoped certificate

**Status:** Author-side exact finite proof and 11 November 2026 package replay. The full source/code/JSON are in the 61-entry original publication ZIP, not yet mirrored in the GitHub tree. No external non-author referee or comprehensive historical priority determination.

## Definition

A consecutive factor of a permutation is a five-shuffle if its positions partition into five equal-size subsequences (size at least 2) whose standardized order patterns agree. The least length forcing such a factor is N5=31, in the original finite computation.

## Upper certificate (as replayed)

- Five-shuffles of the short monotone patterns 12 and 21 are exactly perfect matchings of the ascending or descending pair graph on ten positions; this characterization and the factor graph are imported from Bevan–Elvey Price–Felsner (Oberwolfach 2024).
- Of 10!=3,628,800 patterns, 132,764 form admissible edges on the 9!=362,880 standardized nine-state vertices; ordered pattern FNV-1a checksum: 204ce443a5a61b1f.
- Every length-31 permutation avoiding short monotone five-shuffles induces one of exactly 107,480 admissible 22-edge walks.
- For 107,472 walks, comparisons fixed by the overlapping ten-windows force a length-fifteen common-pattern five-triple partition.
- The remaining eight walks force length-twenty five-quadruple partitions using transitive closure of *known* pair comparisons. Their machine-checked five-by-four position sets and six-sign patterns are in the package-only EXCEPTION_WITNESSES.json.
- Every allowed walk is thus forced to contain a five-shuffle factor of length 10, 15 or 20. The original graph/forced-comparison code was replayed in the publication preflight; a distinct independent reimplementation remains a referee gate.

## Explicit length-30 avoiding permutation

(1,26,2,25,24,10,11,12,13,23,
 22,16,15,14,9,17,18,19,20,21,
 8,7,6,5,27,28,29,4,30,3)

Its *every* eligible consecutive factor was tested by unrestricted exact cover, not only monotone matching: length 10 (21 windows), 15 (16), 20 (11), 25 (6), 30 (1), total 55. No five-shuffle appeared.

## Original source and completeness requirements

Original primary manuscript SHA-256: 6340f7b031d4ef6940e8bd480a306972d3130711daa10e9daea0985fe228710a.

Original package paths:
- 04_Shuffle_Thresholds/Exact_Four_Five_Shuffle_Thresholds.tex
- 04_Shuffle_Thresholds/Multiscale_Hypermatching_Certificate_Calculus.tex
- 04_Shuffle_Thresholds/repro/verify_graph_independent.cpp
- 04_Shuffle_Thresholds/repro/verify_upper_forced15.cpp
- 04_Shuffle_Thresholds/repro/poset_comparisons.py
- 04_Shuffle_Thresholds/repro/verify_exceptions20.py
- 04_Shuffle_Thresholds/repro/audit_exception_witnesses.py
- 04_Shuffle_Thresholds/repro/EXCEPTION_WITNESSES.json
- 04_Shuffle_Thresholds/repro/verify_lower_cpp.cpp and verify_lower_python.py
- 04_Shuffle_Thresholds/repro/run_all.sh

Command in the **unpacked original package**, not this checkout: bash 04_Shuffle_Thresholds/repro/run_all.sh. Preflight reported PASS for all N4/N5 certificates. This source note is not a substitute for those files. Deposit those bytes and run a GitHub CI replay before claiming repository-complete reproducibility.

## Prior art and excluded claims

Bouvel posed the all-k conjecture; Bevan, Elvey Price and Felsner developed the graph and matching method in Oberwolfach Reports 21 (2024), pp.305–306. The current note does not prove the all-k conjecture, establish worldwide firstness, or claim the graph method as new.
