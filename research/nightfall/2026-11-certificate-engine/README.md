# Certificate Engine v2: fractional certificates, influence, and observation on product spaces

**Status: Lean-certified finite-product influence theorem; arbitrary-product principal manuscript remains a candidate.** The finite common-alphabet, heterogeneous-mass `(5/2,6)` inequality is proved at the exact weaker constant in [PR #317](https://github.com/d3lefts/d3lefts/pull/317) and [its proof passport](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md). The **arbitrary measurable/infinite-product extension**, stronger manuscript constant, and quantum consequence have **no end-to-end Lean proof, independent human referee, or dated originality clearance**. See the [10 November certification reconciliation](CERTIFICATION_UPDATE_20261110.md) for exact PR heads, scope, proof receipts, and the quantum-query correction. Do not promote an unreviewed manuscript claim to "original finding" without the gates in `CONTRIBUTING.md`.

- `Wright_Certificate_Engine_v2.pdf` / `.tex`: 18-page manuscript, 10 Nov 2026.
- `checks/`: finite counterexample searches and exact recomputations (Python 3, NumPy, SciPy).
- [Certification update](CERTIFICATION_UPDATE_20261110.md): original proof ledger, dated merge updates, current finite-proof scope and quantum caveat.
- [Full PR snapshot](../PR_RECONCILIATION_20261110.md): open research branches, explicit verification limitations and missing artifacts, frozen on 10 November 2026.

## Claims and their status

| Statement | Source | Status |
|---|---|---|
| All-pairs inequality on finite products (Thm 1.2) | two-draw transfer from Wright V6 + Turturean Thm 4.3 | **Lean-verified finite core** merged as #295; strict crossing-pair denominator positivity checked |
| Localized weight removal (Lemma 4.1), localized two-sided inequality + Bhattacharyya form (Thm 1.3) | Claude, NIGHTFALL transfer | abstract weight removal merged #293; **full finite product composition Lean-verified** and merged as #298; overlap-sampler algebra merged as #300 |
| Total influence from certificate spread (Cor 4.3) | Claude | one-line corollary |
| Real-function engine on finite products, median factor H (Thm 1.4) | Turturean's Level/Average machinery + NIGHTFALL transfer | **Full finite-product composition** Lean-compiled in merged #317; 19 named standard-axiom declarations, including `product_influence`; original proposed stronger constant still unproved |
| Separated-class transport, three median profiles, projected sampling (Sec 6) | ChatGPT draft "Where Influence Lives" | re-derived and checked; exact witness recomputed independently |
| Level-crossing theorem, exponents (2, 4) for mean crossings (Thm 1.7) | Claude | **finite off-range threshold lemma** Lean-verified and merged as #299; general mean crossing at attained thresholds and degree-cost input remain unformalized |
| Adaptivity dichotomy (Thm 1.8), influence-greedy vs information-greedy (Prop 10.2) | Claude, using ChatGPT draft "Adaptive Observation" | finite posterior and Markov lemmas merged #303, #307; concrete sampler/one-step gain merged #304, #308, #309, #312; **full state-to-policy MSE theorem remains unformalized** |
| Aaronson–Ambainis on arbitrary product spaces (Thm 1.5), quantum corollary | Wright V6 constants, finite port of Turturean | **finite-product theorem certified only** (common finite alphabet, indicator-monomial degree, constant `sqrt(3/12500)/π^6`) in #317; arbitrary measurable/infinite products, stronger manuscript coefficient and quantum corollary remain candidates |

## Quantum-query correction (10 November)

The v2 manuscript's `T^7 ε^{-3} δ^{-3/2}` corollary is **not certified by the audited total-influence descent argument**. The separate RC2 review develops the conditional `(2T)^7/[2^(3/2)c_prod ε^5 δ^(7/2)]` bound for absolute-error prediction of quantum acceptance probabilities under known product input laws. That derivation uses the exact total ANOVA-influence drop upon revealing one coordinate and a stopped policy; it **requires the full real-function influence theorem**, which remains under proof review. See [the detailed computation and counterexample](CERTIFICATION_UPDATE_20261110.md#quantum-query-bound-reconcile-two-manuscript-versions-before-release). The older formula is preserved in the versioned manuscript for provenance, **not endorsed as a verified result**.

## Corrections to the companion ChatGPT drafts

- *Adaptive Observation v0.1*: says the exponential nonadaptive gap is not established on fair coins. It is: the n = 2 pointer hierarchy uses one bit per coordinate (Prop 10.1). Its open question 7 is answered by the influence-greedy tree (Thm 1.8(a)). The ANOVA activation identity is classical (Hoeffding, Efron–Stein, Sobol).
- *Where Influence Lives rev. 1*: no errors found. The localization is for the **projected** function's profiles; the unprojected question remains open (stated as such in both drafts).

## Reproduce

```bash
cd research/nightfall/2026-11-certificate-engine
python3 checks/audit2.py          # exact witness, fair-bit pointer tree, level crossings
python3 checks/localized_test.py  # localized two-sided / third-moment searches
python3 checks/antipodal_stress.py
python3 checks/pointwise_lp.py
pdflatex Wright_Certificate_Engine_v2.tex && pdflatex Wright_Certificate_Engine_v2.tex
```

## Open targets

1. Turturean's question: max_j I_j(f) ≥ c Var(f)²/K² for real f. Thm 1.7 gives this for crossing probabilities; Remark 7.1 isolates the missing jump-size lemma. The [quartic antipodal audit](QUARTIC_ANTIPODAL_AUDIT_20261110.md) records a sharper proposed route, exact additive constant-3 lower bound, a corrected pair-versus-antipodal calculation, and a [replayable small-cube checker](checks/check_quartic_antipodal_exact.py). The unrestricted conjecture remains open.
2. Localization for the unprojected median profiles of f.
3. Formalization: weighted reciprocal transfer and localized removal compile on the main branch (#295, #298). The **finite common-alphabet competing-symbol row-cost bound** now compiles in #310. The merged #317 **now compiles the finite third-moment/median/averaging and influence chain**. The **remaining** gates are the general ANOVA-degree equivalence across representations (including null atoms), rigorous finite-to-arbitrary measurable-product lift, the stronger manuscript constant, the general level-tie or (2,4) squared-influence results, and the complete quantum corollary.

Prepared with Claude (Anthropic); Sections 6 and 10 build on drafts prepared with ChatGPT. The author is responsible for all claims.
