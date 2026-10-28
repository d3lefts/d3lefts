# NIGHTFALL Werner-state bounds — complete 4–20 comparison and 1–100 scoped registry

**Research lead:** Devin J. Wright, NIGHTFALL / PHASESHIFT. AI-assisted computation, source assembly and verification. **Checkpoint:** October 28, 2026. Latest approved 4–20 comparison and separate 21–24 final refinement. **Scope:** Every statement is a sufficient undistillability threshold under the declared hypotheses; no optimality claim. **Peer-review status:** external source-operator and mathematical-priority review open.

[Public research home](../../README.md) · [Copy-by-copy CSV](bounds_1_to_24.csv) · [Analytic finite-copy continuation](ANALYTIC_CONTINUATION.md) · [Review and asset manifest](REVIEW_AND_ASSETS.md) · [Independent review assignment](../../../../docs/review.html#werner)

## Read this first: evidence boundaries

1. **Published sharp input:** in the convention below, one-, two-, and three-copy threshold `t=1/2` is established in the cited literature. Further published lower-copy inequalities are imported by the constructions.
2. **Exact downstream, source-theorem-only:** valid rational coefficient decompositions are reported at selected counts, including 19–24. The complete checker/witness archives were examined in prior work sessions; **their primary JSON and code have not yet been mirrored in this GitHub tree**. These numerical rows depend on the validity and correct applicability of external theorems.
3. **Exact downstream, quantitative-source-margin dependent:** the stronger 4–18 qutrit rows additionally import two numerically quantified four-/five-copy inequalities inferred from printed source SDP/error summaries; the primary upstream SDP witnesses **have not undergone an independent complete replay**. This is a strictly weaker evidence category than proving the source margins from published complete data.
4. **Analytic finite-copy construction:** an explicit positive margin above the NPT boundary is proposed for each finite copy count in all dimensions, and a sharper qutrit continuation is seeded at 24 copies. The derivations are written down for scrutiny; external mathematical review remains open.
5. **Rejected:** a tempting floating-point 25-copy bound `t=0.34` failed rational reconstruction (negative exact margin and negative row weight). It is excluded from this atlas.

**No unrestricted fixed NPT parameter is established for arbitrarily many copies.** A bound depending on each finite copy count is a materially different proposition. The unrestricted four-copy qutrit endpoint `t=1/2` is also open within this work.

## Convention and certification identity

For `d≥3`, `k≥1`, and any complex matrix `C` on `(ℂ^d)^{⊗k}` of rank at most two, define

```text
Q_k(t,C) = Σ_{J⊆{1,…,k}} (-t)^|J| ‖Tr_J C‖_F²
α = −t ;  state ρ(d,α) = (I + α F)/(d² + α d)
```

A proved inequality `Q_k(t,C)≥0` for **every** such `C` is a sufficient k-copy undistillability statement. Larger positive `t` is stronger. The qutrit state is NPT when `t>1/3`; in dimension `d` the boundary is `1/d`. An archive certificate expands the target vector `(1-tz)^k` into a strictly positive rational constant plus nonnegative rational multiples of mathematically admissible source-profile rows. That formal vector identity is useful only after all source rows have genuine rank-two positivity justifications.

## NIGHTFALL Werner bounds: 4–20 copies

**Current approved registry · October 28, 2026 · all 17 copy counts.** Convention: `α=−t`; a larger positive `t` gives a stronger sufficient undistillability threshold. Qutrit NPT starts at `t>1/3`; at dimension `d` the boundary is `t>1/d`.

| Copies | Best qutrit | Theorem-only qutrit | Best all-dimension |
|---:|---:|---:|---:|
| 4 | **0.49791** | 0.49790 | 0.49375 |
| 5 | **0.47189** | 0.47000 | 0.45000 |
| 6 | **0.44819** | ≥0.36872 | 0.36872 |
| 7 | **0.43140** | 0.42980 | 0.31429 |
| 8 | **0.41889** | 0.41750 | 0.27973 |
| 9 | **0.40920** | 0.40800 | 0.24932 |
| 10 | **0.40148** | 0.40030 | 0.22472 |
| 11 | **0.39500** | 0.39420 | 0.20441 |
| 12 | **0.38980** | 0.38900 | 0.18744 |
| 13 | **0.38540** | 0.38470 | 0.17304 |
| 14 | **0.38160** | 0.38090 | 0.16067 |
| 15 | **0.37849** | 0.37752 | 0.14996 |
| 16 | **0.37564** | 0.37492 | 0.14059 |
| 17 | **0.37313** | 0.37226 | 0.13176 |
| 18 | **0.37089** | 0.37007 | 0.12444 |
| 19 | **0.36812** | 0.36812 | 0.11789 |
| 20 | **0.36636** | 0.36636 | 0.11200 |

**Evidence:** Qutrit best values at 4–18 import quantitative four-/five-copy source margins conservatively inferred from rounded published SDP/error figures; their upstream witness replay is pending. The theorem-only column uses published source theorem statements and downstream exact-certificate claims without those extra quantitative premises. The six-copy entry `≥0.36872` means an available theorem-only floor, not a sharp endpoint. The leading 19–20-copy values already belong to the theorem-only tier. The all-dimension column combines published results and corrected dimension-uniform exact source-conditional 8–16 constructions. The latter are NPT only in dimensions with `t>1/d`. The full independent certificate JSON and checkers remain outside this GitHub tree.

[Download the exact 17-row comparison CSV](werner_registry_4_to_20.csv) · [See the 1–24 exact-fraction ledger](bounds_1_to_24.csv) · [See the complete 1–100 registry](bounds_1_to_100.csv).

### Historical higher six-to-nine-copy alternatives

The [October 27 direct-margin working note](../werner-direct-margin/README.md) and [correlated spectator working note](../werner-correlated-6-9/RESEARCH_NOTE.md) report higher conditional alternatives: k6 **0.448760**, k7 **0.432280**, k8 **0.419900**, k9 **0.409600**. They remain published as **historical alternative source-dependent claims**, outside the latest user-confirmed 4–20 comparison registry. Independently reconcile the exact premise scope, source-margin provenance and certificate lineage before combining numerical tiers. This is a provenance distinction, not a finding that the older certificates are mathematically false.

## Later refinements: 21–24 copies

The separate final October 28 refinement reports:

| Copies | Qutrit bound `t` | Claim scope |
|---:|---:|---|
| 21 | **0.36119** | Published-theorem-transfer claim; exact archive checker reported |
| 22 | **0.36119** | Published-theorem-transfer claim; exact archive checker reported |
| 23 | **0.35151** | Published-theorem-transfer claim; exact archive checker reported |
| 24 | **0.34001** | Published-theorem-transfer claim; exact archive checker reported |

Copy 21 inherits copy 22 via traceless rank-one padding. The final 22–24 approximate positive margins are respectively `1.4254464548e−7`, `3.4514193376e−7`, and `9.7811538998e−7`. Original `refined_k22–24.json` and independent checker bytes still await public mirroring. The earlier preliminary 22–24 values `0.36110,0.35100,0.34000` were refined in the final report.

## Full 1–100-copy registry

The [100-row public CSV](bounds_1_to_100.csv) distinguishes 1–3 published sharp values, 4–20 current approved three-column values, 21–24 source-theorem-transfer rational claims, and 25–100 symbolic qutrit finite-copy continuations. The latter use `B24`, whose original exact numerator/denominator and dependencies need a public mirror. This is a **symbolic analytic guarantee, not 76 additional finite-copy exact LP certificates**. The all-dimension 25–100 column uses a separately published general-dimensional fallback.

## All-dimension construction audit

The 8–16-copy extensions depend on correct published source inequalities. An earlier exploratory generator used trace-difference coefficient `−1` where the published theorem required `−1/2`; those invalid early candidates were excluded. Only corrected downstream certificate claims appear in this registry. All-dimension values 4–7 and 17–20 use published source/theorem fallback checkpoints.

## Finite-k analytical results — qualitative scope

A stand-alone projector-coercivity argument reports an explicit **all-dimension, every-finite-k** NPT interval, with a copy-dependent threshold. A sharper **qutrit-only** recurrence starts from the archived 24-copy certificate seed `B24≈7.236960476971373×10⁻⁷`. In the latter family `C₀=121/20` and

```text
b_k = C₀ (B24/C₀)^(2^(k−24)),  k≥25
t_k = 1/3 + b_k/(6k)  > 1/3.
```

At 25 copies, the reported `t_25−1/3≈5.7711952557×10⁻¹⁶`: positive in symbolic rational form, extremely small in absolute size. The exact seed numerator/denominator (`B24_exact.txt`) and its source-margin dependencies must be publicly mirrored before independent numerical replay. See [the proof-oriented continuation note](ANALYTIC_CONTINUATION.md) for details and review caveats. Earlier literature already established qualitative finite-k NPT intervals; **no novelty claim follows solely from that existence statement**.

## Restricted all-copy witness sector — separate theorem class

The 28 October *Separable-Order Compression and Scalable Witness Sectors* manuscript analyzes a rank-preserving separable compression of tensor blocks, yielding a fixed NPT parameter over arbitrarily many copies **for a restricted, explicitly encoded family of rank-two witnesses**. It reports at 21 copies a `27·4^9` versus `27·3^9` Alice-side support dimension ratio `(4/3)^9≈13.319`. This is **restricted-witness coverage**, not a gain in unrestricted undistillability thresholds. The source manuscript and full independent proof review await public mirroring; keep this claim separate from both the 1–24 ledger and the unrestricted all-copy question.

## Reviewed sources and attribution

- Tejasvi Singh Tomar, [*Undistillability of Werner states from three, four and five copies*](https://www.mefyi.com/papers/werner-states-copies/) (posted 23 October 2026; DOI 10.5281/zenodo.23604343 as recorded in research checkpoints): imported sharp three-copy theorem, dimension-uniform and qutrit lower-copy results.
- Pablo Costa Rico, [*New partial trace inequalities and distillability of Werner states*](https://doi.org/10.1007/s11005-025-01935-y) (2025): trace-reduction and trace-difference principles. The half-coefficient source correction is mandatory.
- Independent 2026 sharp two-copy works, including Bharti–Gajjala–Haug, arXiv:2607.24479 and Fraser–Huber–Pozsgay–Vona, arXiv:2607.24309.
- NIGHTFALL archived [six–eight direct-margin construction](../werner-direct-margin/README.md) and [six–nine correlated spectator note](../werner-correlated-6-9/RESEARCH_NOTE.md).
- NIGHTFALL October 28 private research checkpoints: `NIGHTFALL_WERNER_COMPLETE_ITERATION_20261028.pdf`, `NIGHTFALL_WERNER_ALL_BOUNDS_20261028.xlsx`, `RESEARCH_NOTE(20261028-061347).md` and `NIGHTFALL_WERNER_LEVERAGE_MANUSCRIPT_20261028.pdf`. **Named private checkpoint files are provenance descriptions, not public download links.**

The research direction and authorship are led by Devin J. Wright; AI tools assisted derivation and checking. Published external source theorems belong to their original authors. Numerical results and novelty claims remain subject to complete external source and priority audit.
