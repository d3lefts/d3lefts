# Identify, Observe, Certify — dissertation research checkpoint v0.4

**Date:** 2026-11-12. **Status:** versioned research synthesis, not a submitted dissertation or a novel-theorem certificate. **Owner:** NIGHTFALL / Devin J. Wright. This note preserves the mathematical conclusions and explicit limits of the 12 November review. The editable working prospectus is [the Google Doc](https://docs.google.com/document/d/1DqkSiTqhY3Nfc9Zo4mwz43-aBs91U3U--_7JjhoGv8c/edit).

## Research objective and decision

Make a mathematics dissertation about **information-access limits of oversight** based primarily on existing NIGHTFALL observability work, rather than treating discovery of more theorems as a gate to writing. Keep the four different oracles and tasks separate:

- **TEST** whether an unknown bounded value-oracle function is close to a low-interaction class;
- **OBSERVE** a fresh random input through coordinate queries when the function and input law are already known;
- **IDENTIFY** the unknown model within a promised class by querying the model;
- **CERTIFY** an exact universal property under a specified black-box or white-box evidence regime.

The flagship mathematical candidate is **Theorem D**: rank-sensitive, dimension-free adaptive observation of known bounded Hoeffding-degree-two Hilbert observables. Chapter 2's scalar arbitrary-product exponent-two inequality is an essential analytic input, not an unrestricted solution of the Aaronson–Ambainis conjecture. Chapter 5 contributes a precise, analytically proved **restricted** separation and standard-style bounds; its elementary addressed-model example is not a novelty claim.

### Feasible set / assumptions / key notation

Independent product measure `μ=⊗ μ_i`; functions bounded in absolute value by `B` or in Hilbert norm by `B`; Hoeffding/Efron–Stein interaction degree `≤2` where explicitly stated. `V=Var(f)`; `I_i=E[(f−E_i f)²]` (conditional resampling influence); `M=sup_i I_i`. In vector scope, `r` is dimension of the chosen leading covariance output subspace and `τ_r` its spectral variance tail. **Model value queries and fresh-state coordinate queries are not interchangeable.** Existence of a dimension-free query budget is not a sublinear runtime assertion.

### Key deliverables in this checkpoint

1. [Chapter 2 dated comparison](CHAPTER2_TURTUREAN_SCOPE_AUDIT_20261112.md) against the exact text of Turturean's theorem, Girish–Mittal–Nehoran–Raz and adjacent prior art; tests of two naive cube reductions; precise source/Lean boundary.
2. [Chapter 5 proof package](CHAPTER5_FOUR_COSTS_v1.md): exact addressed-family risk formula and two-read observation; two-call property tester; constant-scale code packing; three-group degree tester; finite-class learning upper and information lower; threshold-vs-point counterexample to entropy-only classification; certification needles.
3. [Exact checker](check_addressed_family_exact.py) independently enumerates all `3^8=6561` trivalent value oracles on the `n=2` addressed domain and directly evaluates the two-sample rejection probability and distance to the four proper models.

The checker is falsification evidence for a limited finite case, not a proof of the general theorem. A separate independent equivalent exact-arithmetic enumeration **was executed in the authoring session** and returned `6561 cases / 0 violations`; the committed script itself still requires a repo/CI replay before a source-exact run receipt is claimed.

## Verified and conditional claim ledger

| Finding | Exact scope | Status at this checkpoint | Load-bearing next gate |
|---|---|---|---|
| Turturean, arXiv:2611.09773v1 | uniform Boolean cube; all degrees; influence `≥c Var^(5/2)/d^6` | external published preprint with public Lean formalization | don't misattribute to NIGHTFALL |
| NIGHTFALL finite all-degree product transfer | finite heterogeneous tables; inherited `(5/2,6)` exponent | scoped pinned Lean receipt; imports Turturean | no general measurable-product Lean inference |
| NIGHTFALL scalar quadratic v9.2 | arbitrary independent laws, degree ≤2, `V²≤C₂B²M`, `C₂≈1228.356` | analytic manuscript and internal critique; no end-to-end Lean; novelty open | exact v9.2 TeX, Cor. 6.2 repair, non-author proof & categorical-prior-art review |
| Theorem D | bounded Hilbert degree-two output, rank `r`, risk `≤τ_r+η` with `O(rB²/η)` adaptive reads | analytic proof, exact finite checks, scoped Lean dependencies | source scalar matching, Hilbert lift and posterior recursion audited externally |
| D3 lower family and address adaptive/nonadaptive gap | explicit finite inputs, fixed query models | independently checkable analytic arithmetic | clarify quantifiers and compare decision-tree prior art |
| Addressed family identification/test/observation | categorical address, `n` signs, exact classical value oracle | self-contained analytic proofs; small exhaustive tester stress | non-author proof and priority comparison |
| Generic finite-class learning and query splitting | finite separated candidate classes, stated oracle alphabets | elementary proof, not claimed new | use as background, never as discovery |
| Three-group degree tester | bounded degree ≤2 vs squared-`L²` `ε`-far under hybrid access | analytic candidate, prior art unreviewed | independent ANOVA calculation, literature |
| Exact safety needle lower bounds | unrestricted finite N-point black-box domain | established classical/quantum search theory | no blanket 'impossible by behavior' rhetoric |
| Quantum SLD/ANOVA, Paper A, Paper B, ASUA | differing models and evidence | source-specific, unreviewed as a unified chain | check scope and metrics before importing |

### Lean receipt correction as of main branch 2026-11-12

Do **not** use an obsolete blanket description saying there are only 13 relevant Lean declarations. The observability README's 11 November checkpoint lists 13 in that **particular batch**, while the wider repo has many additional scoped receipts. Main commit [#408, `1d3282e`](https://github.com/d3lefts/d3lefts/commit/1d3282e4c2a8b603fa102b95fd0cb2b3dc103587) adds eight strict-kernel source-derived Efron–Stein pair/rectangle declarations ([source ledger](../formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md)); #407 adds actual finite Hilbert section machinery. **The source-level terminal global matching parity lemma, full v9.2 bound, arbitrary measurable lift, Hilbert rank lift and hard-budget adaptive policy are still not jointly end-to-end Lean-certified.** Exact receipt statuses and upstream pins remain in their original source ledgers. No external non-author referee review was found for these main claims.

### Strongest checked external references this session

- Turturean (2026), [Theorem 1.1](https://arxiv.org/html/2611.09773v1), uniform-cube `5/2,d^6`; [Lean repository](https://github.com/physical-superintelligence/aaronson-ambainis).
- Girish–Mittal–Nehoran–Raz (2026), [distributional variants](https://arxiv.org/abs/2609.35327): equivalence for **fixed common** bias; not a quantitative arbitrary-categorical quadratic bound.
- [Blanc–Docter–Strassle–Tan exposition](https://arxiv.org/abs/2611.11626) and [Huffstutler–Miloschewsky–Podder short proof](https://arxiv.org/abs/2611.12795); these postdate the 7 November “no outside comparison” snapshot.

### Decisive next actions, stop rule and verification

1. **Stop adding unrelated theorem candidates to the dissertation.** Run a dated categorical Grothendieck, bilinear mixed-norm, DFKO/low-degree, decoupling, and completely bounded polynomial priority study that actually compares quantifiers.
2. Obtain source-exact **v9.2 LaTeX** and repair its Corollary 6.2 citation/constant; do not reconstruct files and claim original-byte custody.
3. Commission non-author proof attacks on actual matching coupling, fourth-moment ownership, finite-to-measurable passage, Hilbert/rank lift, measurable posterior greedy selection and hard stopping bound. A later failed check **demotes** dependent claims.
4. If no novel general classification theorem can be stated in quantifiers and defeated by a concrete test, leave it **open**. A pointer model with `Θ(n)` identification is an example, not a flagship.
5. Formalization is helpful but **not a mandatory gate to writing the dissertation**. Do not confuse Lean sublemmas, internal AI review, and external mathematical refereeing.

**Evidence tier:** analytical synthesis + independent spot calculation; not a kernel certificate, non-author review, global priority verdict, or authorized external publication. Historical source files and superseded constants are intentionally left untouched.
