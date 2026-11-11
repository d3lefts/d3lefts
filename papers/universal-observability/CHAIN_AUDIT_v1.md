# Full-chain closure audit — proof obligations and certified boundary

**Checkpoint:** 2026-11-11 · **Version:** 1.0 · **Claim ID:** NF-OBS-UNIVERSAL-20261111.

## Executive finding

The strongest mathematical dependency chain can be **composed analytically from the finite Lean theorem without assuming the open quadratic exponent-two inequality**. [The proof supplement](PROOF_SUPPLEMENT_v1.md) now states the full quantitative general-degree result and supplies named arguments for the finite-to-arbitrary-product scalar lift, Gaussian/Rademacher PSD trace compression, expected posterior influence drift, measurable coordinate choice and capped stopping potential.

**Do not confuse a self-contained author-side analytic proof with outside certification.** The source is suitable for independent proof attack; it has not been kernel checked end-to-end, independently human refereed, or priority cleared. The previously merged finite Lean theorem remains the only formal theorem imported.

## Dependency closure ledger

| Edge | What this supplement supplies | Scope / certificate |
| --- | --- | --- |
| Finite scalar influence | Exact named Lean theorem at c*=sqrt(3/12500)/pi^6 | Kernel-checked separately, Lean 4.33.0 / pinned source e67990df... |
| Finite common alphabet → heterogeneous finite alphabets | Disjoint union + coordinatewise retraction | Analytic proof, Lemma 1 |
| Finite alphabets → arbitrary independent product | Countable active support, finite positive atoms, commuting conditional projections, L² limit | Analytic proof, Lemma 2; independent measure specialist review pending |
| Scalar → Hilbert rank trace | Signed covariance eigenbasis, Gaussian sign-mgf ≤sqrt2, logarithmic inversion | Analytic proof, Lemmas 5–7; numerical falsifier only |
| Nonadaptive static bound → actual adaptive posterior | Exact E[T after Xi]=T-I_i, index-measurable maximizer, independent residual product, perspective Jensen | Analytic proof, Lemmas 3–4 and Section 4; exact rational checker |
| Posterior descent → hard query budget | Concave integral potential; cap exactly (40/3)U log(1+4U) | Analytic proof, Section 5 |
| Rank-r projected risk → original Hilbert risk | Fixed output orthogonal decomposition and covariance tail | Analytic proof, Section 6 |

**Not closed:** external non-author referee, end-to-end Lean composition, comprehensive novelty review, stronger degree-two exponent-two and unrestricted cubic theorem. Do not promote the paper's certification labels on a CI success alone.

## Reproduction

From repository root:

    python3 papers/universal-observability/checks/check_posterior_hilbert_exact.py
    python3 papers/universal-observability/checks/check_psd_log_stress.py
    python3 scripts/check_research_archive.py --self-test

The posterior script uses only Python Fraction and exhaustive finite categorical products; the PSD script enumerates signs on integer Gram matrices but uses floating exp/log. Both contain deterministic seeds, print input scope and counts and fail closed on an inconsistent assertion. The checked objects are **finite falsification families**, not the infinite theorem.

**Targeted 11 November literature comparison:** [prior-art audit](PRIOR_ART_CHECK_20261111.md), including Turturean's cube theorem, general-product influence precedent and 2026 completion-framework query results. Priority still unresolved.

## Independent reviewer challenge

1. Construct a nonstandard measurable product or zero-atom example violating the reduction in Lemma 2, especially the degree-preserving conditional projection.
2. Independently reproduce \(\mathbb E_\varepsilon e^{\varepsilon^\top A\varepsilon/(4\operatorname{tr}A)}\le\sqrt2\) and the constant-eight log inversion; attack singular and highly correlated PSD matrices.
3. Verify that the local posterior max inequality holds on a common full-probability set for all finite adaptive histories without invoking nonexistent regular conditional laws.
4. Check \(P_{t+1}=P_t-M_t\) and the concavity Jensen step under stochastic query paths.
5. Evaluate originality against Turturean and classical influence/active-observation results, **separately** from theorem validity.

A rigorous counterexample demotes this proof immediately. Report the precise failing equation, smallest counterexample and hash rather than replacing historical conclusions silently.
