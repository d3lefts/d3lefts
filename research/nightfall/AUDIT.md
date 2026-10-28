# Reproducibility / verification ledger

**Dated snapshot:** 2026-10-27 (original package); this GitHub text mirror began 2026-10-28.

| Track | Recorded validation | Status |
|---|---|---|
| Erdős minimum overlap | Recompiled C++ NTT with six moduli, regenerated and compared residue files, exact CRT shift maximum, dyadic fiber checks | **PASS in archived session**; 131,072-cell witness, Arena 100,000-entry cap exceeded |
| Werner 1–24 | Reconciled earlier 6–9 and later 10–24 qutrit exact-certificate reports; corrected dimension-uniform 8–16; analytic finite-k draft | **Archived exact rational checker results, conditional on source theorems and for 4–18 on un-replayed quantitative source margins.** Original Oct 28 JSON/checkers await a public GitHub mirror; external mathematical/source replay open. See [Werner atlas](projects/werner-atlas/README.md). |
| SAT degree-3 compiler | 1,050 random CNF comparisons (including 554 full edge enumerations) and 496 mode-count checks | **PASS in archived session**; faster runtime relies on external theorem |
| Sidon finite 30 | Exact C++ size-17 certificate, independent Python/MILP and max-plus transfer | **PASS in archived session** |
| SourceBound | Synthetic, browser, adversarial regression cases | **Engineering validation only**, no blind natural-web trial |
| Finite-field retrieval | AI-reviewed manuscript and executable decoder experiments | Mathematical external review still pending |

The complete 2026-10-27 master release contains the checker programs, exact rational inputs, full PDF archives, and SHA-256 manifest. The current GitHub connector permits authoring **UTF-8 text files**; this repository's published text sources alone do **not** constitute a complete reproduction of the original binary-heavy release. Avoid treating links to as-yet-unmirrored source subdirectories as existing executable artifacts.

Reproduction commands from the original release, **after extracting and verifying the master package**:

```bash
cd projects/werner-direct-margin && python3 verify_independent.py
cd ../werner-correlated-6-9 && python3 verify_independent.py
cd ../sat-network-compression && python3 verify_compilation.py && python3 verify_mode_bound.py
cd ../sidon-finite-30 && g++ -std=c++17 -O2 exact_cpp_audit.cpp -o checker && ./checker 2
```

Reported mathematical proof status and independently checked algebraic identities are separate labels. External source premises, source attribution, numeric certification, and competition eligibility must be independently reconciled before any record claim.
