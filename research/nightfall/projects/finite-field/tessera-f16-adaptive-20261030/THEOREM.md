# Tessera: two-query adaptive F16 cube code and a sharp fixed-code obstruction

**2026-10-30 · Vesper assignment #251 / flagship #248 · Status: R1 internally verified candidate · Owner publication and external mathematical-priority review pending.**

## Exact model, unchanged

\(K=\mathbb F_{16}=\mathbb F_2[z]/(z^4+z+1)\), \(L=\mathbb F_4\subset K\), full phase group \(H=L^\times=\{1,6,7\}\) (four-bit polynomial encoding). A legal query receives **exactly** \((a\cdot x)^3\) for any adaptively selected K-linear form \(a\). Signal is determined up to one common multiplier in H. No side information, altered exponent, proper H, or uncharged oracle call is allowed.

## 1. Explicit two-adaptive-query / three-relative-phase block

For \(\eta=(\eta_1,\eta_2,\eta_3)\in H^3\), use the anchor-normalized vector \(v=(1,\eta_1,\eta_2,\eta_3)\).

First coefficient row: **(1,2,3,4)**. After observing \(y=(1+2\eta_1+3\eta_2+4\eta_3)^3\), choose the *second* coefficient row as follows:

| First observed cube y | 0 | 1 | 8 | 10 | 12 | 15 |
|---|---|---|---|---|---|---|
| Second row | (0,0,0,1) | (1,0,2,8) | (0,1,4,8) | (0,1,2,4) | (0,1,8,4) | (0,1,2,4) |
| Number of η in first fiber | 1 | 5 | 5 | 6 | 5 | 5 |

All **27** pairs of first and second cubed outputs are distinct; each second row separates its first-output fiber. Therefore two *sequential adaptive* cubing queries determine three anchored relative H phases. The row branch is a deterministic function only of the legally observed first cube value. For y=0, the second query is formally counted even though the fiber is already singleton, so the bound is uniform; early stopping is allowed.

**Not a fixed 2×4 matrix.** The first row's output explicitly chooses the next row. This adaptivity is essential and is the mechanism behind the improvement.

## 2. General three-stage decoder and exactly optimal k=4 and k=7

Query the k coordinate cubes. Determine support S, s=|S|, and choose canonical roots u_j with u_j³=x_j³, so x_j=λ_j u_j for λ_j∈H. Choose any supported anchor t and form relative unknown phases η_j=λ_j/λ_t. For each group of three nonanchor coordinates, ask first row with coefficients A_0/u_t, A_i/u_{j_i}. Because λ_t³=1, the powered output equals the block y above. Choose the second row from its measured output and make the corresponding powered query with the same denominators, recovering three η's. Handle final 1–2 phases separately with one query each of normalized form 1+zη, whose powered values are pairwise distinct since 1,z are L-independent. Reconstruct \(\widehat x_t=u_t\), \(\widehat x_j=\eta_j u_j\), then \(x=\lambda_t\widehat x\). The zero vector is detected from the coordinate readings.

This proves (subject to finite-table validation) for s≥1:

\[
m(k,s)\le k+2\left\lfloor\frac{s-1}{3}\right\rfloor
+\big((s-1)\bmod3\big).
\]

When s=0, k coordinate queries suffice. This is a **three-stage adaptive protocol** (coordinate cubes, first mixed cube, second mixed cube); the original 3×5 PR #243 code was only two-stage (coordinate cubes, three fixed mixed cubes).

Each cubing query has at most M=1+(16−1)/3=6 outputs. There are N_k=1+(16^k−1)/3 distinct global-H equivalence classes. Any adaptive decision tree of maximum depth d has at most 6^d leaves, including early termination. Exact inequalities:

- k=4: 6^5=7,776 < N_4=21,846, while the construction uses at most **6** queries.
- k=7: 6^10=60,466,176 < N_7=89,478,486, while the construction uses at most **11** queries.

Therefore the **worst-case query counts for k=4 and k=7 are exactly 6 and 11 in this specified oracle model**, as a mathematical implication of the exact finite gadget and the general decoder proof. This matches Vesper's 11-query k=7 objective by **adaptive** branching; it does not supply Axiom's still-open fixed **4×7** zero-collision coefficient matrix.

## 3. Fixed two-row theorem: ≥4 colliding pairs

For a fixed two-row, four-column matrix A over K, rescale each nonzero coefficient row to make its first nonzero entry 1. Row rescaling multiplies its entire cubed output by a nonzero constant, preserving equality/collision sets. Every nonzero row is represented uniquely among

\[
16^3+16^2+16+1=\boxed{4369}
\]

normalized rows. For each normalized row, enumerate all \(\binom{27}{2}=351\) unordered pairs of distinct anchored phases, setting a bit if their cubed readings agree. **Exactly 439 distinct 351-bit collision masks** occur. Exhaustively comparing all pairs of masks yields

\[
\min_{A\in K^{2\times4}}\#\{\{\eta,\eta'\}:\eta\ne\eta',\ C_A(\eta)=C_A(\eta')\}=\boxed4.
\]

The zero-row case cannot be injective (six possible outputs from the other row). Equality is attained by rows (1,5,1,13) and (1,6,3,3), with exactly four collision pairs:

(1,1,6)/(6,1,7); (1,6,7)/(6,6,1); (6,6,6)/(6,7,7); (7,6,7)/(7,7,1).

Two independent anchored one-phase forms 1+zη_j recover two phases in two fixed queries. Thus **P_fixed(4,2;2)=2** while **P_adaptive(4,2;2)=3**. Four phase variables cannot be recovered by any two-query (even adaptive) protocol because 3^4=81>6²=36.

The earlier [PR #243](https://github.com/d3lefts/d3lefts/pull/243) supplies a verified 3-fixed-query/four-phase block; 3^5=243>6³=216 prevents five phases in three queries. Hence the exact *anchored* capacity staircase for m=1,2,3 is **1,2,4 (fixed)** versus **1,3,4 (adaptive)**. Definition: these capacities apply to blocks after *already counted* first-round coordinate calibration and fixed anchor, not to globally uncharged signal queries.

A strict negative control shows the nonlinear oracle matters: two **unpowered** K-linear rows (0,1,2,0) and (0,0,0,1) separate the same 27 states, but their cubed outputs collide.

## 4. Cross-field and transfer boundaries

For *each field's own full-subfield* exponent q−1 in \(K=\mathbb F_{q^2}\):

| q | 2-query anchored phase capacity | Exact mechanism |
|---:|---:|---|
| 3 | 4 | two fixed 2-phase squares on independent GF3 basis; 2^5>5² forbids 5 |
| 4 | **3 adaptive / 2 fixed** | explicit 27-code table; exhaustive 4,369 normalized rows; 3^4>6² |
| 5 | 2 | 4³>7² forbids 3; two separate one-phase powered forms suffice |

There is no monotonic transfer in q here. A q3 square oracle is a **different exponent** from the q4 cube oracle, and a proper subgroup H<\(\mathbb F_q^\times\) is a different measurement model. This is a sharply specified counterexample to the naive idea that larger base fields automatically permit larger full-phase packing.

## 5. Exact certificate and independent attack

- **audit.py:** polynomial GF16 arithmetic; all 27 adaptive transcripts; 4,369 normalized rows and 439 collision masks; four-pair exact fixed minimum; prior 81-state PR #243 code; all 65,536 F16^4 vectors; 5,461 anchored 7D support-phase sectors plus zero; 12,000 random full-amplitude 7D inputs; information lower bounds.
- **audit_tower.py:** separate GF4 quadratic-tower arithmetic, algebraic isomorphism z↦α (α=4 in that encoding), independent 27-state adaptive transcript and normalized static collision-minimum reproduction. No imported producer arithmetic.
- **Complete frozen run bundle:** NIGHTFALL_Tessera_F16_Adaptive_Capacity_20261030.zip, also containing separate cross-field test, exact output and SHA256 manifests.
- **Review required:** Lemnis attack the adaptive/anchor transfer without reading the producer decoder; Ryev verify with independent GF4 tower and Lean support/branch/remainder if feasible; Axiom test the static obstruction's normalization and any possible stronger 4×7 code; Vesper check same-model literature and evidence stage.

This is a **mathematically meaningful finite-algebraic discovery candidate**, not yet an independently established original finding. Existing comparison literature inspected this session includes Bartusel–Führ–Oussa (2023) *Phase retrieval for affine groups over prime fields* (complex-valued group-frame setting) and 2024 projective Reed–Muller subfield codes; these are not proven same-oracle prior instances. A thorough dated same-model priority search remains open.

**Permission scope:** draft research PR only. No homepage promotion, external manuscript submission, or site claim upgrade without explicit human authorization and independent non-author mathematical and originality review.
