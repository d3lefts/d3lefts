# NIGHTFALL Proof Passport — Sharp Influence, Quadratic Backdoors and Cubic Observation

**Version:** 2.0, November 12, 2026.  
**Author:** Devin J. Wright (NIGHTFALL; AI-assisted mathematical drafting and finite arithmetic audit).  
**Primary artifact:** `Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex` (22-page compiled manuscript).  
**Status:** Author-side self-contained analytic manuscript; independent specialist review, complete categorical tensor-norm novelty audit, and end-to-end Lean certification **not completed**. No external submission is implied.

## Central problem / mathematical contract

- **Input:** independent product coordinates on arbitrary finite, countable, nonatomic or completed product laws (with finite-index observation results). Real/Hilbert-valued target bounded by `B`. Interaction degree is Hoeffding/Efron–Stein degree, not polynomial degree in an alphabet-specific coordinate encoding.
- **Influence:** `I_i(F)=E ||F - E_i F||²`, equal to half the expected squared two-draw replacement difference.
- **Variance:** `V(F)=E||F-EF||²`; `M=sup_i I_i(F)`.
- **Scalar quadratic constant:** `D_2=(10+2 sqrt(2))(1+sqrt(3))`, `C_2=D_2²=1228.356323...`.

## Claim → mechanism → certificate → limitation

| ID | Statement and exact scope | Mechanism and dependencies | What has been checked | Exclusions |
| --- | --- | --- | --- | --- |
| Q2 | `V(f)² ≤ C_2 B² M` for real degree ≤2 on arbitrary independent products | Matching even/odd coupling → additive and section oscillation → greedy edge assignment → independent Hilbert fourth moment → finite-cylinder limit | Written proof in paper; exact finite-model checker | No kernel or independent specialist certification; categorical prior art open |
| H2 | `V(F)² ≤ 3 C_2 r B² M` for bounded affine-rank ≤r Hilbert outputs of degree ≤2 | Random signs, fourth-moment interpolation, vector section budgets | Analytic proof; finite scalar/homogeneous tests | Does not claim a better constant for binary/Grothendieck regime |
| BT-W | If `H` of size t meets all order≥3 Hoeffding supports (any degree), `V≤D_2 B sqrt(M)+t M`; Hilbert rank variant | Average H; charge removed energy to `sum_{i∈H} I_i` | Written one-page reduction; 20 exact finite support models | This **weak** cover does not force low-degree posterior after actually observing H |
| BT-S | If **every** support satisfies `|S\H|≤2`, query H then use quadratic observer: `t+ceil(12 C_2 r B²/η)` for risk `τ_r+η` (scalar constant 4) | Sectionwise degree reduction, posterior quadratic observation, covariance projection | Written proof; exact structural sections and parity boundary check | Access is full classical coordinate symbols, not efficient computation or local quantum measurements |
| CB3 | Disjoint independent cubic blocks, each with cubic cover ≤t: `V²≤(D_2+t)²B² M`, `N≤ceil(9(D_2+t)²B²/η)` scalar whole-symbol reads | Sum independent block range widths ≤2B; per-block transfer; degree-weighted posterior drift | Written proof; exact cubic address/alphabet examples and 20 support models | Does not cover interlocking cubic hypergraphs without global bounded cover or disjoint blocks |
| RR | Quadratic rank-r and scalar query bounds, spectral oracle inequality | Exact expected decrement of degree-weighted posterior energy; reciprocal telescoping | 1477 exact posterior drift instances in original checker; analytic derivation | Query count, not runtime; covariance eigenvectors assumed theoretically available |
| SEP | Weak transversals cannot support dimension-free observation; cubic address separates adaptive from nonadaptive | High-degree parity with t=1; independent cubic address selectors | Exact symbolic identities, finite checked instances | Standard address mechanism; no claim of original invention |
| QVIS | Local quantum SLD terminal visibility `t_noise^4 a² V²/(2C_2B²)` and binary refinement | Product-average quantum ANOVA and Personick optimization + Q2 | Analytic proof in paper/source; pre-existing independent examples | Not quantum adaptive query theorem; SLD visibility, not geometric metric; no specialist review |

## Source and credit map

- The quadratic proof and rank-sensitive posterior proof are adapted and tightened from the existing NIGHTFALL v8/v9.2 manuscript and the standalone degree-two manuscript v1. They stand **without importing the recently published Turturean Boolean-cube theorem**.
- The global cubic top-degree cover and independently covered block lemma are present in the NIGHTFALL November 10–11 research notes. This v2 synthesizes them and records the structural higher-degree extension.
- The distinction **averaging transversal** vs **sectional quadratic backdoor**, the arbitrary-degree transversal formulation, additive-backdoor query reduction and exact high-degree parity obstruction are explicit deductions in this manuscript. They have **not** been adjudicated as worldwide novel.
- Classical predecessor methods: Hoeffding (1948); Efron–Stein (1981); OSSS (2005) for influence/decision trees; Blais–O'Donnell–Wimmer (2008/2010) arbitrary product polynomial regression; Filmus–Hatami–Keller–Lifshitz (2016) bounded function L1 influences; O'Donnell–Zhao (2016) decoupling; Aaronson–Ambainis–Iraids–Kokainis–Smotrovs (2016) Grothendieck degree-two methods; Girish–Mittal–Nehoran–Raz (2026) fixed-bias variants; Turturean (2026) all-degree uniform Boolean cube. None of Turturean's proof machinery is imported here.

## Replay instructions and scoped outcomes

From this directory:

```sh
python3 -I check_quadratic_models.py > CHECK_QUADRATIC_EXACT.log
python3 -I check_structured_backdoors.py > CHECK_STRUCTURED_EXACT.log
latexmk -pdf -interaction=nonstopmode -halt-on-error Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex
sha256sum -c SHA256SUMS.txt
```

As of assembly, the finite-model checker passed **1477 exact posterior transition cases** and direct heterogeneous quadratic tests; the structured-backdoor checker passed **20 independently enumerated exact heterogeneous support models** (17 strong, 3 weak-only), the cubic address/fixed-risk algebra at five alphabet sizes, and the parity obstruction. These checks do **not** prove any universal theorem. The LaTeX compiles to **22 pages** with no unresolved citations or overfull boxes.

## Adversarial-review plan

1. Independently rederive the matching mass bound (especially arbitrary alphabets and even/odd coupling).
2. Check the `q'(0)` Markov interpolation constant, and independence required for the greedy-assigned Hilbert fourth moments.
3. Attack the distinction between weak and strong backdoors using degree-4 interactions sharing one observed coordinate; verify the parity limitation.
4. Reproduce posterior degree-weighted drift from direct conditional expectations, including post-backdoor sections with mixed lower-order energies.
5. Check the range-width budget for countably many independent blocks and preservation of the cover under transcripts.
6. Conduct a dated review of categorical Grothendieck/tensor-norm and low-degree learning prior art for exact, not merely approximate, implications.
7. Formalize Q2 and BT-S in Lean with the full source-function hypotheses; avoid promoting scoped finite lemmas to full end-to-end declarations.

## Open theorem and stop rule

The universal arbitrary-alphabet cubic `V²≤C B²M` theorem for **interlocking unrestricted triple supports** is not proved here. No experimental sampling can promote it. The next research target is a provably bounded link-overlap or large-atom certificate. Stop numerical tuning if finite searches produce only sub-tolerance gains without a structural operator.

## Supplementary conditional algorithmic corollary — 12 November 2026
**Q2-ORACLE (not independently certified):** [Complete proof and priced oracle model](ORACLE_IMPLEMENTABLE_OBSERVER_20261112.md). Under an exact sampling oracle for each independent coordinate and an independent exact evaluation oracle for known bounded scalar quadratic `f`, approximate posterior influences by resampling pairs; choose their estimated maximum; approximate the final posterior mean by independently sampled completions. Conditional on the author-side Q2 inequality, the expected squared loss is at most `eta` after `min(n,ceil(32 C_2 B^2/(3 eta)))` actual coordinate reads and at most `2nqs+t` model evaluations (exact `s,t` in the proof note). This is not known-function evaluation for free: **state reads, model evaluations and distribution samples are different resources**. It does not imply efficient implementation from a succinct circuit or a quantum black box. The independent [exact checker](checks/check_oracle_implementation_exact.py) tested 6,768 finite ANOVA and posterior-drift assertions, not the population Q2 inequality or Hoeffding's concentration theorem. Classical Monte Carlo influence estimation is acknowledged as prior art. Leave Q2 and Q2-ORACLE at author-analytic, pre-referee status.
