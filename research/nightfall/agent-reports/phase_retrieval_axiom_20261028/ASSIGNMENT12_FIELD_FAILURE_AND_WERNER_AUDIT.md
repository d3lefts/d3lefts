# AXIOM — 2026-10-28 Issue #12 field failures and Werner cross-audit

Research lead: Devin J. Wright. Executable research / audit contributor: Axiom (GPT-6). Standing theorem campaign issue #15. **Statuses:** finite exact tests PASS, general field theorem manuscript independent referee INCONCLUSIVE, imported Werner nine-word theorem INCONCLUSIVE, originality / priority INCONCLUSIVE.

## Source-frozen contract

The archived October 15 systematic fourth-power decoder uses `A=[I;B]`, `m=2k`, large `q=p^r` with odd `p ≡ 1 (mod 4)`, and ambiguity `mu4`. Axiom's distinct model is IID uniform fully random sensing `A ∈ F25^(m×k)`, with fourth-power readings and a Frobenius-linearized **2k-column** kernel. Its uniform theorem candidate requires `m ≥ ceil(2941*k/500)+s`; the present *failure-classification* experiment intentionally uses `m=2k` where this worst-case guarantee gives no promise. Confusing the two models would invalidate a comparative claim.

Field representation: `F25=F5[u]/(u²−2)`, characteristic 5, `x=e1`. Source algorithm `failed_sample_audit.py`; seed `1729`; exactly 200 iid uniformly random designs for each `k=3,4`, drawing each coefficient independently from 25 elements. Measurements `y_j=(a_j·x)^4`. Every design is frozen in `failures_seed1729.json`. Kernel classification uses rank over `F25` of the rows `(a_j^5, -y_j a_j)`. If rank < 2k−1, a separate independently coded **packed** `F25` arithmetic implementation enumerates every vector in `F25^k` and counts exact preimages. All 625 multiplication and addition table entries are cross-compared across the two field representations. `k=3` has 25^3=15,625 candidates; `k=4` has 25^4=390,625 candidates.

## Exact outcomes

| Dimension | Trials | Rank = 2k−1 | Rank < 2k−1 | Real non-uniqueness | Rank-only defect | Frozen failure trial IDs |
|---|---:|---:|---:|---:|---:|---|
| k=3 | 200 | 193 | 7 | 7 | 0 | 35,79,91,116,128,170,184 |
| k=4 | 200 | 191 | 9 | 3 | 6 | 6,17,27,47,54,58,75,77,152 |

Class definitions: a **genuine ambiguity** means at least one signal outside the four-element `mu4` orbit of `e1` yields identical complete readings. A **rank-only defect** means the Frobenius lift has an extra kernel dimension yet the exact nonlinear preimage is precisely that four-element orbit. The latter does *not* establish a decoder bug: a kernel-line-only decoder may report `inconclusive` when a less restrictive complete-list decoder still succeeds.

Two exact fixtures confirmed independently by the no-Numpy `axiom_failure_fixtures.py` using the packed field: `k=3` trial 35 has rank 4 of 6 columns, **8** exact preimages, and a genuine extra signal; `k=4` trial 17 has rank 6 of 8 columns, exactly **4** preimages, hence a rank-only failure. The self-contained script enumerates every signal and checks the phase orbit, without relying on a saved list or the NumPy classifier. The full 200-design arrays are supplied separately in the frozen JSON.

### Historical failed-sample boundary

The earlier quoted `192/200` and `194/200` figures did not include archived random seeds, sampled matrices, field model version, nor any result JSON identified in the accessible handoff. Consequently no exact reconstruction of those particular failed samples is claimed. The new **193/200 and 191/200** study is source-frozen and demonstrates a mechanism that can be rigorously audited. A 200-trial denominator should never be presented as a field-wide failure probability proof.

## Independent Lemnis cross-review

The 4,209-dimensional Lemnis extension is on the four-qutrit Werner **restricted** witness class. Vesper's PR #17 independently reconstructed the projection ranks `728,272,1` and established `729+3368+112=4209` under the encoded nine-word positivity premise. The actual coordinate projector is `C -> P_S C P_T`, and **rank(P_S C P_T) ≤ rank(C)** for all matrices by the rank-of-product inequality. Therefore the general 3×3 diagonal-projection rank-inflation example from issue #15 is inapplicable to this particular map. The imported nine-word positivity assumption remains a separate dependency.

Freshly coded `werner_cross_audit.py` independently enumerates the 72 outside old 9 syndrome-sector pairs, chooses the old block with the same syndrome difference, and scans every one of the 81×81 off-sector matrix-unit coefficients by direct 16-subset partial-trace inclusion-exclusion. Exact 16-scaled max-entry histogram: **16 cases at 4 (1/4), 56 cases at 8 (1/2)**. An explicit collision fixture is included in `werner_cross_audit.json`, with rank-two matrix-unit sums exhibiting nonzero cross interaction. This reproduces Vesper's **obstruction to vanishing cross-terms**, not a negative Werner witness and not a new positivity threshold.

## External technical neighbors checked on 2026-10-28

- Kopparty, *Recovering polynomials over finite fields from noisy character values*, January 2026, arXiv:2601.07137 — different polynomial-character observation model, related finite-field recovery.
- Bartusel, Führ and Oussa, *Phase retrieval for affine groups over prime fields*, Linear Algebra and its Applications 677 (2023) — complex group-frame measurement model, rather than powered `F25` linear observations.
- Gow and McGuire, *Linearization of polynomials in prime characteristic*, Designs, Codes and Cryptography 93 (2025) — established linearized-polynomial technique. The Frobenius method alone is established background.

These sources do not settle exact novelty of the **fixed-field uniform random powered-sensing theorem**, since a targeted exhaustive historical survey remains outstanding.

## Integrity / checker commands

```bash
python3 failed_sample_audit.py > failures_seed1729.json
python3 axiom_failure_fixtures.py
python3 werner_cross_audit.py > werner_cross_audit.json
sha256sum *.py *.json
```

The script `failed_sample_audit.py` uses Numpy only to vectorize exhaustive finite-state enumeration; all field operations are exact bounded integer table operations. `axiom_failure_fixtures.py` independently reruns two decisive controls without Numpy. The full Werner audit is pure Python integer arithmetic. Randomness is seeded and fully reproducible; no prospective experiment claim is assigned to the historical unsourced 8/200 and 6/200 measurements.

## Handoff / next decisive experiment

The field program should attack the coupling of extra Frobenius-kernel vectors to actual powered-measurement ambiguities, as evidenced by 6 rank-only defects among 9 failure cases at k=4. A structured list-decoder may rescue such inputs while preserving fixed-field algebraic runtime. For the Werner cross-review, inspect and independently prove the archived nine-word positivity premise before promoting the 4,209 extension beyond conditional scope; then seek a rank-two-aware nonzero-cross-term inequality that strictly enlarges the current class.