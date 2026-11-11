# NIGHTFALL Lean certificate provenance / quarantine — 2026-11-11

## Decision
The repo contains 39 Lean source files at main commit `f005704b50c35819ff32c703e1ce5f2f72106fd5`. Classification: **28 quarantine**, **10 scoped dependent transfers**, **1 distinct finite construction**. Frozen historical eleven are unchanged. Site inventory is `docs/lean-certificate-provenance.json`; the accompanying static HTML renders all 39.

**Quarantine preserves valid proof code.** A known identity or an explicit-premise reformulation can be correctly kernel-compiled without being a new mathematical result. The cost is mistaken novelty attribution, not Lean soundness. We therefore remove *originality claims*, not source, logs, or checks.

## Category boundaries
- Quarantine: Hoeffding/Efron–Stein decomposition and finite conditional expectation; independent-sign moments; Cauchy and sorted tails; Nisan-style packing and certificate complexity; simple phase/odd-cycle arithmetic; abstract posterior drift. Dependencies remain available for proof replay but cannot be counted as independent discoveries.
- Derived transfer: Turturean's `AaronsonAmbainis` machinery plus source-specific finite competing-symbol rows, two-draw mass weighting, arbitrary-marginal product influence, and concrete finite certificate/posterior sampling. These have existing site passports, with *priority not cleared* and imported components credited.
- Distinct finite construction: the `F16` three-query phase block and its literal 81-state no-collision certificate. Adds one source-specific public passport. Historical global originality not established.

## External checked prior-art anchors
1. W. Hoeffding (1948) and ANOVA decomposition: https://encyclopediaofmath.org/index.php?title=Hoeffding_decomposition
2. B. Efron and C. Stein, *The Jackknife Estimate of Variance* (1981): https://doi.org/10.1214/aos/1176345462
3. Nisan/decision-tree and block sensitivity prior art: https://www.sciencedirect.com/science/article/pii/S030439750100144X
4. Chugh–Podder–Sanyal, FSTTCS 2023: https://drops.dagstuhl.de/doi/10.4230/LIPIcs.FSTTCS.2023.27
5. David Turturean, *A proof of the Aaronson–Ambainis conjecture* (2026): https://arxiv.org/abs/2611.09773

No exhaustive global search of all related abstract theorems was performed. These references justify the conservative inherited classification, not a claim of exhaustive priority adjudication.

## Failure conditions and checker
Fail closed if any `.lean` file on main has no ledger row, if source routes do not exist, if a quarantined item is called a globally original theorem, or if the historical registry changes. Run `node scripts/test_lean_certificate_provenance.cjs` in the repo; this is editorial certification only. Lean CI receipts are linked in the manifest. Replaying each source's exact theorem type and axiom dependency is a separate proof operation.

## Further independent review
Request an author-unrelated mathematical prior-art review for both the heterogeneous finite influence transfer and the F16 block, particularly identical query model and categorical law assumptions. Do not promote either to global novelty before review.
