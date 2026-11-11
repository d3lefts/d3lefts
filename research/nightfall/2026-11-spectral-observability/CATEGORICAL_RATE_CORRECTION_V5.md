# NIGHTFALL v5 — Exact repair of the categorical nonadaptive minimax exponent

**Research checkpoint:** 2026-11-10 America/New_York (2026-11-11 UTC)  
**Source under review:** `NIGHTFALL_Spectral_Observability_Synthesis_v5.pdf`, pages 2 and 5–7; user-supplied Library copy dated 2026-11-11 UTC. Original v5 PDF/source are **not** silently copied into this repository.  
**Status:** Self-contained analytic quantitative correction and independently replayed exact finite identities; full spectral theorem remains **unrefereed, not Lean-certified, and not globally priority-cleared**.

## 1. The exponent mismatch in the printed v5 statement

The printed Theorem 1.2 / 4.1 takes

[
L_{mathrm{old}}=m+1,qquad
C_{d,L}=2d^2,3^{d-1},T_{d-1}(L),
]

and proves a fixed-set residual squared-error upper bound

[
R_q leq 	au_r+rac{C_{d,L}^{,2}B^2}{4a_r^2 q},
quad a_r=rac{Gamma(r/2)}{sqrtpi,Gamma((r+1)/2)}.
]

For fixed degree `d` and large `m`, `T_{d-1}(m+1)=\Theta_d(m^{d-1})`. **Squaring the constant leads only to the weaker upper bound `O_d(r m^{2d-2} B²/η)`**, whereas v5 advertises a matching `Theta_d(r m^{d-1}/η)` bound. The argument as printed therefore does not justify the claimed exponent of `m`.

## 2. Repair with the stronger bound already implicit in v5

For a categorical law `p=(p_s)` on `m` positive-mass atoms with `Σ_s p_s=1`, take independent fair signs `ε_s` and put

[
S=sum_ssqrt{p_s},arepsilon_s,qquad
Z_s=p_s+sqrt{p_s},arepsilon_s-p_sS.
]

Then `Σ_s Z_s=1`, `E Z_s=p_s`, and `E[Z_s Z_t]=p_s 1_{s=t}`. These are **exact** identities, not approximations.

More importantly, direct expansion gives

[
sum_srac{Z_s^2}{p_s}
  =1+sum_s(arepsilon_s-sqrt{p_s}S)^2
  =1+m-S^2.
]

Weighted Cauchy–Schwarz yields the **pointwise** improvement

[
oxed{|Z|_1^2
       leqBigl(sum_sp_sBigr)
             Bigl(sum_s Z_s^2/p_sBigr)
       =m+1-S^2le m+1.}
]

Thus choose

[
oxed{L_{mathrm{corrected}}=sqrt{m+1}.}
]

The signed-to-probability Jordan decomposition and common Chebyshev extrapolation line in v5 use **only** `ΣZ_s=1` and a common upper bound `||Z||_1≤L`. This replacement is therefore admissible *without altering that argument*, subject to independent review of the extrapolation itself.

For `x≥1`, `T_k(x)=\cosh(k\operatorname{arcosh}x)≤(2x)^k`; hence

[
C_{d,mathrm{corrected}}
 =2d^2,3^{d-1}T_{d-1}(sqrt{m+1})
 le 2d^2,6^{d-1}(m+1)^{(d-1)/2}.
]

Substituting into the printed squared-risk inequality gives

[
oxed{
R_qleq	au_r+
rac{d^4,36^{d-1}(m+1)^{d-1}B^2}{a_r^2q}.
}
]

As `a_r^{-2}=\Theta(r)`, this proves the **claimed order of the nonadaptive upper bound** `O_d(r m^{d-1} B²/η)` *conditional on the remaining v5 analytic argument*. The matching lower construction is independent of this correction and was not re-certified in this PR.

**Numerical significance:** At `d=3, m=16`, the old extrapolation factor is `T_2(17)=577`, whereas the corrected factor is `T_2(√17)=33`. The squared query-budget constant improves by exactly `(577/33)^2≈305.72`.

## 3. Correct countable-alphabet Rényi-effective-support bound

For a countable alphabet, define

[
h=left(sum_ssqrt{p_s}ight)^2<infty.
]

For absolutely summable `√p_s`, the same proxy is well-defined and

[
|Z|_1
leqsum_sp_s+sum_ssqrt{p_s}+|S|sum_sp_s
leq 1+2sum_ssqrt{p_s}
=oxed{1+2sqrt h}.
]

**Not** `1+2h` as printed. The corrected `L=1+2√h` gives `C_{d,L}^2=O_d(h^{d-1})` for `h≥1`; combined with the conditional v5 sampling argument, this restores the stated `O_d(r h^{d-1} B²/η)` upper-bound order. For `h≥2`, the lower construction with a uniform alphabet of size `⌊h⌋` has the matching order. The countably infinite proxy and its moment identities require the indicated absolute summability; the original manuscript's remaining infinite-product proof steps still need independent analytic review.

## 4. Independent replay

Run

```bash
python3 -I research/nightfall/2026-11-spectral-observability/check_categorical_proxy_v5.py
```

The exact `fractions.Fraction` checker:
- Uses independently generated positive **rational unit-sphere** weights, hence rational `√p_s`, and exhaustively tests all sign patterns for `2≤m≤8` (508 patterns).
- Checks the mass-one identity, weighted quadratic identity, improved `L_1` bound and countable-surrogate bound **exactly**.
- Independently checks `E Z_s=p_s` and `E[Z_sZ_t]=p_s1_{s=t}` with exact fractions.
- Tests an independent three-coordinate categorical multilinear conditional-variance proxy identity for `2≤m≤4`, including all sign patterns of the other two coordinate blocks.
- Tests the sharp elementary `A^2/(4q)` sorted-tail bound with exact fractions and an equality witness on `2q` equal weights.

**Checker outputs falsification evidence for finite instances; the all-law inequalities above follow from the displayed symbolic argument.** A reviewer must independently verify the Chebyshev common-line/Jordan decomposition, vector norm interpolation, spectral projection, and finite-to-measurable-product passage before treating the full categorical observability statement as certified.

## 5. Claim and priority gates

- **Proved as algebraic statements:** the finite signed-proxy identities, corrected pointwise `√(m+1)` bound, and the corrected Rényi parameter `1+2√h`.
- **Conditional analytic upgrade:** the original v5 nonadaptive squared-risk theorem, with corrected constants and exponents, *assuming* all its independent Chebyshev/interpolation and measure-theoretic steps are valid.
- **Not established here:** globally original minimax theorem, Lean-compiled all-degree categorical result, efficient predictor, general-alphabet nonadaptive bound, unrestricted degree-three squared-influence bound, or any publication precedence.
- **Attribution:** Source derivation by the NIGHTFALL research team under Devin J. Wright, with antecedents in classical Chebyshev extrapolation, Bonami hypercontractivity, Hoeffding decomposition and categorical moment matching. This is a quantitative audit/repair, not a claim of independent origination of those tools.
