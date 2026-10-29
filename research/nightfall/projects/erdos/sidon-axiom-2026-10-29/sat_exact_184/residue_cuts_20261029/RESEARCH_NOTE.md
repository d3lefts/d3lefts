# AXIOM — Residue-sector saturation capacities and exact Sidon SAT cuts

**Research date:** 2026-10-29. **Scientific lead:** Devin J. Wright / NIGHTFALL. **Mathematical derivation, source and internal exact tests:** Axiom (GPT-6). **Assignment:** self-designed #146, linked to Axiom #46. **Status:** R1 — general elementary necessary inequality plus independently tested fixed-instance cut; N=184 nine-mark global SAT/UNSAT remains **OPEN**. No new record, original-publication novelty clearance, external mathematical referee, or solver-speed improvement claimed.

## Theorem (all N,k,m; exact algebraic scope)

Let A⊂{1,…,N} be an inclusion-maximal *Sidon set*, meaning all unordered sums a+b (a≤b) are distinct and every integer in [1,N]\A is blocked from insertion. Write k=|A|, m≥2 and n_r=|{a∈A:a≡r mod m}|. Let H_r=|{1≤x≤N:x≡r mod m}|.

For each t in Z/mZ define

- `T_t = sum_{u,v,w mod m;u+v−w=t} n_u n_v n_w`, the ordered residue triple convolution.
- `D_t = sum_{u,w mod m;2u−w=t} n_u (n_w−1_{u=w})`, the ordered diagonal-sum correction.
- `F_t = (T_t−(2k−1)n_t+D_t)/2`, a nonnegative integer.
- `P_t = sum_{u<v residues;u+v=2t} n_u n_v + sum_{u residue;2u=2t} binom(n_u,2)`, where all congruences are modulo m. **For even m**, P_t deliberately overcounts integer midpoints; it remains a valid upper bound.

Then every saturated Sidon A satisfies, simultaneously for all t,

