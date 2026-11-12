# v9.2 "Beyond the Boolean Cube" — internal line-by-line proof check (12 November 2026)

**Reviewer type:** author-internal, AI-assisted (Claude, Anthropic), requested by Devin J. Wright. This is **not** independent external peer review, a Lean certificate, or a priority determination. Claim statuses in `research/catalogue/CLAIMS.json` are unchanged by this record.

**Source:** [`NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf`](NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf), SHA-256 in [`SOURCE_SHA256SUMS_v9_2`](SOURCE_SHA256SUMS_v9_2). At the time of this internal review, the LaTeX source had **not** yet been supplied; this was a PDF-only custody deposit. On 12 November 2026 the source-exact [v9.2 LaTeX](NIGHTFALL_Beyond_Boolean_Cube_v9_2.tex), [original source checksum manifest](SHA256SUMS_NIGHTFALL_v9_2.txt), and [changelog](CHANGELOG_NIGHTFALL_v9_2.md) were added. This source recovery is not a new independent review.

## Scope checked step by step

| Statement | Check performed | Outcome |
| --- | --- | --- |
| Lemma 2.1 matching budget `Σ b_ij ≤ 4B` | Four-corner representation; even/odd two-point couplings have equal one-coordinate marginals; cross-block and additive terms cancel | No error found |
| Lemma 2.2 `Σ‖h_i‖₂ ≤ 2(1+√2)B`, `Σ E‖U_i‖ ≤ 8B` | Noise operator `T_t` is a Markov contraction; interpolation at `s=√2−1` gives `2B(1+s²)/(s(1−s)) = 4(1+√2)B`; `q′(0) = −3q(0)+4q(½)−q(1)` for quadratics gives `8B` | No error found |
| Lemma 2.3 quadratic energy | Greedy matching assignment `b_ij ≤ c_i`, `Σc_i ≤ 8B`; independent centered Hilbert increments give `E‖Z‖⁴ ≤ c²s + 3s²`; Hölder gives `s ≤ (c+√(3M))E‖Z‖`; conditional Jensen for `Z_i` | No error found |
| Theorem 1.1 constant | Sum `2(1+√2) + 8 + √3(10+2√2) = (10+2√2)(1+√3) = D₂` | Exact |
| Proposition 1.2 optimal exponent | `f_m = m⁻¹ Σ Z_{2k−1}Z_{2k}`: `Var = 1/m`, `I_i = 1/m²` | Correct |
| Lemma 3.1 / Theorem 1.3 rank-`r` | Fourth-moment Khintchine constant `1/√3`; sign averaging applied inside Lemmas 2.1–2.2 for vector kernels; constants combine to `V(G)² ≤ 3C₂ r B² M` | No error found; closes the gap noted in the 11 Nov review of the Interaction–Visibility paper |
| Lemma 4.1 / Theorem 1.4 | Degree-weighted energy drift `p_Q − E p_{Q∪i} = I_i`; `P_t − P_{t+1} ≥ P_t²/(4K_r)`; `P_t ≤ 4K_r/t`; output-orthogonal tail; lower family `r/(4η)` | No error found |
| Lemma 5.1, Proposition 5.2 | Support `≥ 2^{m−s}` induction; exact ratio `[1−(1−2p(1−p))ⁿ]/(4p(1−p)) ~ (1−e⁻²)n/4` | Correct |
| §9 correlated counterexample and (25) | `I¹ = 1−(1−ε)²`, `I² = 0`; variational change of measure | Correct |
| Proposition 9.1 | `Σ_{i>q} b_i² ≤ L²/(4q) = (3+2√2)B²/q` | Correct |
| Lemma 7.1 / §8 lift | Commuting product projections, degree preservation, influence contraction, attainment via finite superlevel sets; zero-mass padding for the Lean premise | Plausible as written; referee gate (iii) remains |

**Numerical stress (supplementary only):** 1,500 random degree-two functions on biased categorical products (atoms down to `1e−9`) gave `max V²/(B²M) = 0.83 ≪ C₂ ≈ 1228.36`.

## Issue found

- **Corollary 6.2 constant.** The displayed budget `⌈C₂/(δε²)⌉` uses the *scalar* rate `4C₂B²/η` from Theorem 1.1, but the proof cites Theorem 1.4, whose stated rate is `12C₂rB²/η` (yielding `3C₂/(δε²)` at `r=1`). Fix: state the scalar specialization `N ≤ min{n, ⌈4C₂B²/η⌉}` explicitly (it follows from Theorem 1.1 and Lemma 4.1 without Lemma 3.1), or cite it directly.

## Remaining gates (unchanged)

1. Independent non-author check of Lemmas 2.1–2.3 and 3.1 (v9.2 §10 gates i–iv).
2. **Main originality risk:** a short categorical Grothendieck / one-hot bilinear argument could subsume Theorem 1.1 with a better constant; the binary case already has `16K_G²`. Dated scope-matched literature search required (v9.2 gate v).
3. Deposit the v9.2 LaTeX source and rebuild before referee circulation.
4. Theorem 8.1 (`c_prod`) remains dependent on the v8 chain and should not be cited as established.


### Source availability update (12 November 2026)

The original *author-generated* v9.2 LaTeX source is now checked into the repo, and the source Git blob matches the extracted source capsule. The earlier review's main correctness/novelty gates remain outstanding; its documented scalar one-query citation issue is not retroactively repaired in the preserved historical v9.2. Consult the [separate v2 source](../sharp-influence-backdoors/README.md) for the newer presentation and scalar-query clarification. The original PDF/certificate roles remain separate.
