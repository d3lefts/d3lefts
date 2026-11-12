# 12 November 2026 repository audit — significance, verification and housekeeping map

**Reviewer type:** author-internal, AI-assisted (Claude, Anthropic), at Devin J. Wright's request. Not external review, not priority clearance. **No claim status in [`CLAIMS.json`](CLAIMS.json) is promoted by this note**; it records what was checked and what should be repaired. Source snapshot: `main` at `ff4b597`.

## 1. What was independently re-derived or replayed

| Claim ID / source | Check | Result |
| --- | --- | --- |
| NF-PS-QUADRATIC (v9.2 PDF) | Full line-by-line proof read | No error; one corollary constant mismatch. See [`V9_2_INTERNAL_REVIEW_20261112.md`](../../papers/finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md) |
| NF-OBS-UNIVERSAL / Paper B | PSD sign moment `≤√2`, logarithmic inversion, Fubini drift identity, perspective Jensen, capped potential total `(40/3)U log(1+4U)`, Hölder allocation, §7 exponent transfer | No error found. With `q=2`, `a=1/C₂` the transfer reproduces v9.2's scalar `4C₂B²/η` |
| NF-FINITE-PALETTE-RECOVERY / Paper A | Switching lemma, hybrid degree, Tal `bs ≤ deg²`, endpoint Markov `|P′(0)| ≤ d²R`, degree-one Minkowski count, address example | No error found in the finite argument. Boolean `d³` is classical (Midrijanis); the contribution is the product-space and finite-real-palette transfer |
| NF-OBS-SPECIALIZED / Paper C, F16 code | Independent arithmetic: [`check_f16_independent_20261112.py`](../../papers/specialized-complexity/check_f16_independent_20261112.py) | All pass: `H={1,6,7}`, cube image size 6; 81-state block injective; adaptive table 27 distinct transcripts with fibres `{0:1,1:5,8:5,10:6,12:5,15:5}`; remainder code injective; exhaustive min collisions over 4369 normalized row pairs = 4; `D(4,5,7)=6,8,11` |
| NF-OBS-SPECIALIZED Thms 1–2 | Cauchy–Schwarz selector, row restriction, `T` contraction | Valid **given** imported localized inequality (7) |
| NF-WERNER-INVERSEK | Hand check of `9B₃−D₃ = (2/3)J₂ + (68/9)J₃ + (1/18)J_c`; [`verify_three_block_uniform.py`](../nightfall/projects/werner-atlas/verify_three_block_uniform.py) | Identity exact; checker PASS. **Everything rests on the imported two/three-copy inequalities** (not reproduced) |
| NF-BOUVEL-SHUFFLE45 (N₄) | Independent exact-cover search of all 24 windows of the length-19 witness | No four-shuffle factor: `N₄ ≥ 20` confirmed. Upper certificate not re-run here |
| NF-PS-FINITE (Lean) | Pinned file `ProductInfluence.lean` at `e67990d` | Statement matches; no `sorry` or custom axiom in `product_space/`; core bound is Turturean's Theorem 8.3 via imported `AaronsonAmbainis` library. Not recompiled |
| NF-EA36-UPPER (Erdős) | Exact fraction `= 0.38085637011802932…`, denominator `2¹⁵⁶ = (N/2)D²`; grid lemma | Correct. On 12 Nov the [optimization-constants page](https://teorth.github.io/optimizationproblems/constants/1b.html) lists Atris `0.3808585503…` as best upper bound and **does not list this witness**. It is smaller by ≈`2.18×10⁻⁶` |

## 2. Significance ranking (editorial judgement, not a status field)

1. Degree-two law-uniform influence and rank-optimal observation (v9.2).
2. Erdős C₁b exact upper witness: externally checkable and currently below the listed record. **Action:** file the fork-based PR described in the [referee packet](../nightfall/projects/erdos/EXTERNAL_REFEREE_PACKET_20261029.md).
3. Exact shuffle forcing lengths `N₄=20`, `N₅=31`. Confirm the problem source cited in the shuffle notes (Bevan–Elvey Price–Felsner, Oberwolfach 2024).
4. Werner `t_k = 1/3 + 0.3104/k` window. Potentially significant if the imported inequalities are confirmed by a specialist.
5. Papers A and B and the all-degree `c*` lift: solid generalizations with explicit credit to Midrijanis/Tal and Turturean.
6. Paper C, quantum SLD/ANOVA, restricted cubic transfer.

Not standalone contributions: Sidon 17/30 (below the known 5/9), Kaczmarz best-iterate, PAS retrospective, granularity baseline.

## 3. Stale degree-two constants (historical files preserved, not rewritten)

The canonical scalar constant is `D₂ = (10+2√2)(1+√3)` (`C₂ = D₂² ≈ 1228.36`; v8 and v9.2). Older values remain in historical notes and are **superseded, not errors in their time**:

- `16(1+√3)` (squared form `256(1+√3)²`): `research/nightfall/2026-11-principal-observability/PRINCIPAL_THEOREM.md`, `research/nightfall/observability-publication/PRINCIPAL_PAPER.md`, `research/new-moon/spectral-observability/*`, `research/nightfall/2026-11-leaf-spectral-transfer/LEAF_SPECTRAL_REDUCTION.md`, `research/nightfall/2026-11-fair-sign-quadratic/PROOF_NOTE.md`, `research/nightfall/formalization/observability/README.md`.
- `15(1+√3)` (v7): `research/nightfall/2026-11-quadratic-law-free-audit/*`, `research/nightfall/2026-11-quadratic-rank-optimal/FINITE_SIGN_CLOSURE_v2.md`.

Dated notes were added to the public paper-shelf entries that quoted them: Paper B §6, Paper C §4, and `papers/quadratic-observability/README.md`. Downstream results that use the quadratic premise (Paper C Proposition 4, restricted cubic cover `Var ≤ (D₂+t)B√M`, Θ(r/η) row) **remain conditional** in the catalogue until the premise has external review.

## 4. Source-custody gaps

- **Categorical nonadaptive `Θ(rm/η)`, `Θ_d(rm^{d−1}/η)`:** proof ZIP not in tree (see [`SOURCE_ACCESS.md`](../nightfall/observability-publication/SOURCE_ACCESS.md)); unassessable.
- **`N₅ = 31`:** source/code/JSON package-only.
- **F16 27-state adaptive block:** on closed, unmerged PRs #252 and #255.
- **v9.2 LaTeX:** PDF deposited here; `.tex` not supplied.
