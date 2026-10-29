# TESSERA / Singer 975 — exact finite Erdős Sidon checkpoint (2026-10-29)

**Status:** solver-free exact finite construction and fixed-template minimum-deletion proof; same-prefix improvement over NIGHTFALL PR #73. **No global Sidon record claim, asymptotic coefficient improvement, or solution of Erdős #44/#329.** Classical Singer difference-set mechanism; dated novelty review and independent external mathematical referee pending.

## Comparison

| Same fixed prefix A={1,2,4,8,13} | Marks | Endpoint | Normalized size |
|---|---:|---:|---:|
| Earlier Bose–Chowla witness, PR #73 | 977 | 1,766,378 | 0.7351106932 |
| Singer preliminary | 982 | 1,783,622 | 0.7352924007 |
| **Singer fixed-cut optimum** | **975** | **1,753,998** | **0.7361902625** |

**Gain over previous certified 977 baseline:** +0.146858% in normalized size, and endpoint -12,380 (two fewer marks). Exact squared-density cross-product margin 4,921,129,308 > 0. The new witness also beats the 982-element version on normalized size, with exact cross-product margin 4,133,296,398 > 0. Do not claim componentwise superiority: 982 contains more marks.

## Source representation

In F₁₀₀₉[X]/(X³+2), θ=2+X has projective order 1,019,091. The exponents e whose θᵉ has zero X² coefficient form a classical 1,010-element Singer difference set modulo 1,019,091. Its 1,019,090 ordered nonzero differences are all distinct (recomputed in the public checker).

Take 0-based cut index 386, exponent 363,760, sort Q={(e−363760) mod 1019091}, translate by T=734,950, and include the five prescribed prefix elements. The original 1,015-element union contains exactly 52 distinct collision hyperedges in integer pair sums. A written explicit **40-element deletion set** covers every edge, and an explicit **40-edge pairwise disjoint packing** forces any feasible deletion set to contain at least 40 source positions. Hence exactly 40 deletions is optimal for **this fixed source, cut and translation**, without relying on integer programming or solver tolerance. The 975 surviving marks have 475,800 distinct unordered sums including diagonals.

## Reproducibility

Run `python3 research/nightfall/projects/erdos/tessera-singer975-20261029/audit.py` from repository root. It requires Python standard library only and independently rebuilds the field orbit, checks all nonzero modular differences, enumerates the complete original integer collision hypergraph, verifies the matching/cover optimality proof, and enumerates every final sum. Canonical sorted `u\\n` witness SHA-256 is `a237ac6f1d246a58ae292c813c4c8b0daf72f67ef46f7b5baf7a01e47bd6ccc8`. Full frozen archive with explicit witness, standalone independent verifier and four adversarial tampering tests accompanies the originating research session: `NIGHTFALL_Tessera_Singer975_Certified_20261029.zip`.

## Search history and limitation

Bose–Chowla full 1,009-cut coarse sweep, endpoint-aware trimming, and fine-shift searches did not improve 977. Switched algebraic families to Singer; all 1,010 Singer cyclic cuts at nine translations found a 982-element numerical candidate; focused 7,749 coarse and subsequent integer-program tests produced the denser 975-element candidate. Another 2,758 tests around the top candidates found no stronger normalized size. Approximately 30 sampled Singer multiplicative automorphisms failed to improve the candidate before execution stopped. Finite search failures do not imply global optimality; they motivate moving to uniform-in-prefix structural estimates.

**Decisive open gap:** prove a uniform repair-density and endpoint bound that improves the known infinite Sidon limsup coefficient 1/√2, with compatibility across an unbounded sequence of growing prefixes. The finite certificate here does not meet that gate.

Sources: [Erdős #44](https://www.erdosproblems.com/44), [Erdős #329](https://www.erdosproblems.com/329), [prior NIGHTFALL finite witness PR #73](https://github.com/d3lefts/d3lefts/pull/73). Do not add this artifact to the website's approved Original Findings whitelist absent scientific and priority review.
