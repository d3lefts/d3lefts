# Certificate Engine v2: fractional certificates, influence, and observation on product spaces

**Status: candidate principal theorem; formally verified finite-product certificate core.** The complete influence bound and quantum consequence have written arguments but **no end-to-end Lean proof, independent human referee, or dated originality clearance**. See the [10 November certification reconciliation](CERTIFICATION_UPDATE_20261110.md) for exact PR heads, scope, proof receipts, and the quantum-query correction. Do not promote an unreviewed manuscript claim to "original finding" without the gates in `CONTRIBUTING.md`.

- `Wright_Certificate_Engine_v2.pdf` / `.tex`: 18-page manuscript, 10 Nov 2026.
- `checks/`: finite counterexample searches and exact recomputations (Python 3, NumPy, SciPy).
- [Certification update](CERTIFICATION_UPDATE_20261110.md): frozen original audit and subsequent merge reconciliation for #295, #297, #298, #299 and #300, all incorporated into `main` on 10 November 2026. The formalized finite core is now directly in the repository.
- [Cross-session PR/evidence registry](../PR_RECONCILIATION_20261110.md): merged #306, #309, #310 and #312, candidate finite-palette observability #313, witness-rank project #311 and listed uncommitted evidence packages. **The current theorem status is not equivalent to a manuscript publication clearance.**

## Claims and their status

| Statement | Source | Status |
|---|---|---|
| All-pairs inequality on finite products (Thm 1.2) | two-draw transfer from Wright V6 + Turturean Thm 4.3 | **Lean-verified finite core** merged as #295; strict crossing-pair denominator positivity checked |
| Localized weight removal (Lemma 4.1), localized two-sided inequality + Bhattacharyya form (Thm 1.3) | Claude, NIGHTFALL transfer | abstract weight removal merged #293; **full finite product composition Lean-verified** and merged as #298; overlap-sampler algebra merged as #300 |
| Total influence from certificate spread (Cor 4.3) | Claude | one-line corollary |
| Real-function engine on product spaces, median factor H (Thm 1.4) | Turturean Thms 7.6/8.3 + Wright V6 | proof written |
| Separated-class transport, three median profiles, projected sampling (Sec 6) | ChatGPT draft "Where Influence Lives" | re-derived and checked; exact witness recomputed independently |
| Level-crossing theorem, exponents (2, 4) for mean crossings (Thm 1.7) | Claude | **finite off-range threshold lemma** Lean-verified and merged as #299; general mean crossing at attained thresholds and degree-cost input remain unformalized |
| Adaptivity dichotomy (Thm 1.8), influence-greedy vs information-greedy (Prop 10.2) | Claude, using ChatGPT draft "Adaptive Observation" | written candidate; generic overlap-sampler and recurrence Lean-verified and merged as #300; **posterior policy and total ANOVA-influence identity not jointly formalized** |
| Aaronson–Ambainis on arbitrary product spaces (Thm 1.5), quantum corollary | Wright V6 constants, reproved | **candidate only:** real-function row cost, median/averaging, arbitrary measurable products and quantum reduction remain outside Lean; original query exponents require reconciliation below |

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

1. Turturean's question: max_j I_j(f) ≥ c Var(f)²/K² for real f. Thm 1.7 gives this for crossing probabilities; Remark 7.1 isolates the missing jump-size lemma.
2. Localization for the unprojected median profiles of f.
3. Formalization: #293 and #298 certify the finite localized/two-sided core, and **#310 now certifies the finite competing-symbol Chebyshev row bound** in a monomial-support degree representation. The **remaining** gates are the explicit equivalence with Hoeffding/ANOVA degree, integrated third-moment/median/averaging chain, the level-tie case, arbitrary measurable products, and the full quantum corollary.

Prepared with Claude (Anthropic); Sections 6 and 10 build on drafts prepared with ChatGPT. The author is responsible for all claims.
