# Certificate Engine v2: fractional certificates, influence, and observation on product spaces

**Status: candidate.** Complete written proofs, finite numerical checks passed. **No independent human review, no formal verification of the new statements, no dated prior-art clearance.** Do not promote any statement here to "original finding" without those gates (see `CONTRIBUTING.md`).

- `Wright_Certificate_Engine_v2.pdf` / `.tex`: 18-page manuscript, 10 Nov 2026.
- `checks/`: finite counterexample searches and exact recomputations (Python 3, NumPy, SciPy).

## Claims and their status

| Statement | Source | Status |
|---|---|---|
| All-pairs inequality on every finite product space (Thm 1.2) | two-draw transfer from Wright V6 + Turturean Thm 4.3 | proof written; imported statement matched to Turturean rev. `2a6ceae` |
| Localized weight removal (Lemma 4.1), localized two-sided inequality + Bhattacharyya form (Thm 1.3) | Claude | proof written; random search: max ratio 1.000 (equality cases) |
| Total influence from certificate spread (Cor 4.3) | Claude | one-line corollary |
| Real-function engine on product spaces, median factor H (Thm 1.4) | Turturean Thms 7.6/8.3 + Wright V6 | proof written |
| Separated-class transport, three median profiles, projected sampling (Sec 6) | ChatGPT draft "Where Influence Lives" | re-derived and checked; exact witness recomputed independently |
| Level-crossing theorem, exponents (2, 4) for mean crossings (Thm 1.7) | Claude | proof written; random search max ratio 0.250 (bound ≤ 1) |
| Adaptivity dichotomy (Thm 1.8), influence-greedy vs information-greedy (Prop 10.2) | Claude, using ChatGPT draft "Adaptive Observation" | proof written; binary pointer tree r=2 checked exhaustively |
| Aaronson–Ambainis on arbitrary product spaces (Thm 1.5), quantum corollary | Wright V6 constants, reproved | proof written |

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
3. Lean: the zero-weight case of localized weight removal (`LocalizedOptimization.lean` in PR #289 covers strictly positive weights only).

Prepared with Claude (Anthropic); Sections 6 and 10 build on drafts prepared with ChatGPT. The author is responsible for all claims.
