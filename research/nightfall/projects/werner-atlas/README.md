# Werner-state undistillability — October 28 reconciled research atlas

**Research lead:** Devin J. Wright, NIGHTFALL / PHASESHIFT. AI-assisted computation, source assembly and verification. **Checkpoint:** 28 October 2026, after the 22–24-copy refinement. **Scope:** Every statement is a sufficient undistillability threshold under the declared hypotheses; no optimality claim. **Peer-review status:** external source-operator and mathematical-priority review open.

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

## Strongest retrieved qutrit thresholds, 1–24 copies

The table takes the maximum **within matching qutrit and source-assumption scopes** across the October 27 direct-margin and correlated archives, the October 28 sub-20 refinements, and the final October 28 22–24-copy reconciliation. The October 28 1–100 spreadsheet itself contains older **weaker** six-, seven-, eight-, and nine-copy numbers; the earlier stronger certificates are preserved here. Copy 21 inherits copy 22 by traceless rank-one padding.

| Copies `k` | Exact `t` | Decimal `t` | Evidence tier |
|---:|---:|---:|---|
| 1 | `1/2` | **0.500000** | Published sharp |
| 2 | `1/2` | **0.500000** | Published sharp |
| 3 | `1/2` | **0.500000** | Published sharp |
| 4 | `49791/100000` | **0.497910** | Quantitative-margin transfer |
| 5 | `47189/100000` | **0.471890** | Quantitative-margin transfer |
| 6 | `11219/25000` | **0.448760** | Quantitative-margin transfer |
| 7 | `10807/25000` | **0.432280** | Quantitative-margin transfer |
| 8 | `4199/10000` | **0.419900** | Quantitative-margin transfer |
| 9 | `256/625` | **0.409600** | Quantitative-margin transfer |
| 10 | `10037/25000` | **0.401480** | Quantitative-margin transfer |
| 11 | `79/200` | **0.395000** | Quantitative-margin transfer |
| 12 | `1949/5000` | **0.389800** | Quantitative-margin transfer |
| 13 | `1927/5000` | **0.385400** | Quantitative-margin transfer |
| 14 | `477/1250` | **0.381600** | Quantitative-margin transfer |
| 15 | `37849/100000` | **0.378490** | Quantitative-margin transfer |
| 16 | `9391/25000` | **0.375640** | Quantitative-margin transfer |
| 17 | `37313/100000` | **0.373130** | Quantitative-margin transfer |
| 18 | `37089/100000` | **0.370890** | Quantitative-margin transfer |
| 19 | `9203/25000` | **0.368120** | Theorem-only transfer |
| 20 | `9159/25000` | **0.366360** | Theorem-only transfer |
| 21 | `36119/100000` | **0.361190** | Theorem-only transfer |
| 22 | `36119/100000` | **0.361190** | Theorem-only transfer |
| 23 | `35151/100000` | **0.351510** | Theorem-only transfer |
| 24 | `34001/100000` | **0.340010** | Theorem-only transfer |

**Machine-readable:** [bounds_1_to_24.csv](bounds_1_to_24.csv) stores the exact rational value, the displayed decimal, source tier and originating checkpoint. These are *research ledger values*, with archived exact-checker results reported. The source JSON and checker files required for independent public execution are **pending publication**, not implicitly certified by the CSV. The qutrit table is not a complete table of theorem-only alternatives at k=4–18; it intentionally preserves the stronger conditional-margin tier.

For the three newest certified-source-transfer candidates, the final October 28 report gives positive rational margins approximately

| k | t | Reported positive residual |
|---:|---:|---:|
| 22 | 0.36119 | 1.4254464548 × 10⁻⁷ |
| 23 | 0.35151 | 3.4514193376 × 10⁻⁷ |
| 24 | 0.34001 | 9.7811538998 × 10⁻⁷ |

These figures come from the reported `refined_k22.json`, `refined_k23.json`, `refined_k24.json` and the independent `verify_B.py` audit in the preserved private research package. The **October 28 08:41** preliminary certificate checkpoint established weaker `0.36110, 0.35100, 0.34000`, superseded later that morning. The downstream exact-checker reports are distinct from external independent scientific certification.

## Separate dimension-uniform results

These constructions claim sufficient thresholds for every integer local dimension `d≥3` at the displayed count. Their quantitative gain refers to the cited conservative general-dimensional comparison, **not** to the qutrit-only table.

| k | Exact `t` | New `t` | Published comparison `t` |
|---:|---:|---:|---:|
| 8 | `27973/100000` | **0.279730** | 0.275000 |
| 9 | `6233/25000` | **0.249320** | 0.24888889 |
| 10 | `2809/12500` | **0.224720** | 0.224000 |
| 11 | `20441/100000` | **0.204410** | 0.20363636 |
| 12 | `2343/12500` | **0.187440** | 0.18666667 |
| 13 | `2163/12500` | **0.173040** | 0.17230769 |
| 14 | `16067/100000` | **0.160670** | 0.160000 |
| 15 | `3749/25000` | **0.149960** | 0.14933333 |
| 16 | `14059/100000` | **0.140590** | 0.140000 |

The nine exact rational identities use dimension-free sharp two-copy inequalities, the trace-difference inequality in its **correct** coefficient normalization, valid three-/four-/five-copy grouped sources, and admissible positive separable spectators. The dimension-uniform source note records the failed initial coefficient interpretation: a trace-difference term was encoded with `−1` where the source gave `−1/2`. The invalid early six-to-sixteen-copy certificates were demoted and excluded; the corrected eight-to-sixteen rows alone appear above. For NPT significance, `t>1/d` must additionally hold, which varies by dimension.

The underlying dimension-uniform JSON and pure-Python `Fraction` checker are preserved in the October 28 workspace. An independent referee must audit the source-to-row implications and compare priority against [Tomar's current published theorems](https://www.mefyi.com/papers/werner-states-copies/).

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
