# Werner finite-copy continuation — explicit proof and review boundaries

**Checkpoint:** 28 October 2026. **Status:** analytic derivation supplied; independent expert proof audit still open. This proof note is an exposition of the archived research, not a claim that all upstream source certificates have been publicly replayed.

## Canonical unrestricted qutrit finite-copy theorem — revision v1.1 (11 November 2026)

**Status:** exact downstream mathematical argument and rational arithmetic check; published sharp two-/three-copy endpoint theorems are imported; global originality and non-author proof audit remain open. This replaces the earlier weaker *qutrit uniform finite-copy continuation* below, while retaining that construction for history and the all-dimensional case. The November 11 ternary paper is an elaboration of this original October 28 construction, not a separate discovery.

Write `P=|Ω₃⟩⟨Ω₃|` with `|Ω₃⟩=|00⟩+|11⟩+|22⟩`, `S=I-P/3`, and for rank-at-most-two complex `C` on `(ℂ³)^⊗k` let

```text
Q_k(t,C) = ⟨vec(C),(I−tP)^⊗k vec(C)⟩
         = Σ_{J⊆[k]} (−t)^|J| ‖Tr_J(C)‖_F²
b_j = (4/27)^floor(j/3) × [1, 1/3, 2/9]_(j mod 3).
c = 7,760,249 / 25,000,000 = 0.31040996.
t_k = 1/3 + c/k.
```

**Theorem (unrestricted finite-copy protection).** For **every finite** `k≥3` and **every** complex `C≠0` of rank at most two,

```text
Q_k(t_k,C) ≥ b_k(1−Φ(c))‖C‖_F² > 0,

Φ(c) = 3c + 2 Σ_(j odd, j≥3) c^j/(j! b_j) < 1.
```

Therefore the three-dimensional Werner state `ρ_(3,t)=(I−tF)/(9−3t)` is `k`-copy undistillable for `0≤t≤t_k`. For `1/3<t≤t_k` this covers a genuinely NPT interval. This claim is **unrestricted in the rank-two witness** for each fixed `k`, but the state parameter depends on `k`. No fixed NPT parameter is thereby proved undistillable at all copy counts.

**Mechanism and exact proof chain.** The sharp three-site response, derived as a positive rational combination of the published two-/three-copy endpoint forms and the rank-two trace cap, is

```text
B₃ = Q₃(1/3,C)/‖C‖² = 1−a₁+a₂/3−a₃/27
D₃ = −∂_t Q₃(t,C)|_(t=1/3)/‖C‖² = 3a₁−2a₂+a₃/3
J₂ = 2−a₁−a₂+a₃/2 ≥ 0
J₃ = 1−3a₁/2+3a₂/4−a₃/8 ≥ 0
Jc = 2−a₃ ≥ 0

9 B₃ − D₃ = (2/3)J₂ + (68/9)J₃ + (1/18)Jc ≥ 0.
```

Equality occurs for `C=diag(1,1,0)⊗|0⟩⟨0|⊗|0⟩⟨0|`; thus 9 is sharp for three sites. The isotropic `S` is separable across Alice/Bob (from an `U⊗Ū` twirl of orthogonal product vectors). Tensoring the three-site inequality with `S` spectator operators preserves Schmidt rank two under *product* contractions. Summing over triples yields `D_k≤3k B_k`. The same separable spectator closure multiplies the known 1-, 2-, 3-site boundary margins `b₁=1/3`, `b₂=2/9`, `b₃=4/27` to give `B_k≥b_k`. For odd `j≥3`, the rank-two-positive operator `(2/b_j)S^⊗j−P^⊗j`, again tensor-lifted with `S`, bounds the odd perturbation term. Thus

```text
Q_k(1/3+δ,C) ≥ B_k[1−R_k(δ)]‖C‖²,

R_k(δ) = 3kδ + 2 Σ_(odd j≥3, j≤k) binom(k,j) δ^j/b_j.
R_k(c/k) ≤ Φ(c).
```

The step from `B_k` to `b_k` is used **only if** `R_k≤1`; outside that range the scalar-floor multiplication is not justified. All even powers in the expansion are positive semidefinite and may be discarded for a lower bound. The rational certificate evaluates the odd series through `j=17`, then upper-bounds its tail by

```text
2(3c)^19/[19!×(1−(3c)^2/420)].
```

At `c=7760249/25000000`, the resulting **exact rational upper bound** for `Φ(c)` is strictly below 1. The lower partial sum at `c=31040997/100000000` exceeds 1. Therefore the unique transition for **this particular sufficient certificate** obeys

```text
0.31040996 < c_* < 0.31040997,
```

not a bound on the optimal physical distillability threshold.

**Version history:** October 28 original `c=31/100=0.31`; November 11 elaboration `c=194/625=0.3104`; current revision `c=7760249/25000000=0.31040996`. The updated uniform constant does not overwrite stronger specialized 4–23-copy numerical thresholds, nor does it certify inherited SDP source margins. Independently checked within this same exact-rational certificate: `t₂₄=0.346368` and `t₂₅=0.345842`. These are threshold refinements, not new lower-copy proof inputs.

**Replay and audit:** Run [the stdlib-only checker](verify_three_block_uniform.py). It verifies the two linear identities, equality witness, explicit `b_j`, the infinite-series tail inequality and the 24/25-copy rational margins. It **does not** independently reprove the source theorems or establish global priority. Verify import applicability, especially the arbitrary-size two-block grouping in `J₂`, before external theorem certification. Preserve the earlier negative-result and source-margin caveats below.


## Universal elementary guarantee for every dimension d≥3 and finite k

Let `T_d(X)=X−tr(X)I_d/d` be the orthogonal projection from `d×d` matrices to traceless matrices, and set `P_k=T_d^{⊗k}`. For `rank(C)≤2`, we seek a constant `b_{d,k}>0` such that

```text
‖P_k C‖_F² ≥ b_{d,k} ‖C‖_F².
b_{d,1}=1−2/d ; b_{d,k}=b_{d,k−1}²/(2d+1)².
```

**Base.** `|tr(C)|²≤2‖C‖_F²` gives `‖T_d(C)‖_F²=‖C‖_F²−|tr C|²/d≥(1−2/d)‖C‖_F²`.

**Induction structure.** Write `c²=b_{d,k−1}`, `ε=‖P_k C‖_F`, and split `C` into `d×d` site blocks `C_{ij}`. Each block has rank at most two. The off-diagonal blocks contribute directly to the first-site traceless projection; the induction hypothesis gives `‖E‖_F≤ε/c` for their sum `E`. The block-diagonal `D=C−E` is within `ε/c` of a rank-two matrix, so its third singular value is at most `ε/c`. With `d≥3`, one diagonal block of `D` has operator norm at most `ε/c`; its Frobenius norm is then at most `√2 ε/c`. Comparing projected diagonal blocks and applying the same rank-two induction bound yields

```text
‖C‖_F ≤ [√(2d)/c² + (√(2d)+1)/c] ε
       ≤ (2√(2d)+1) ε/c²
       ≤ (2d+1) ε/c².
```

The last bound applies to `d≥3` and `0<c≤1`. This proves the stated recurrence. Its explicit expression is

```text
b_{d,k} = (1−2/d)^(2^(k−1)) / (2d+1)^[2(2^(k−1)−1)].
```

Let `A_d(t)=I−t|Ω_d⟩⟨Ω_d|` acting on the vectorized coefficient space. At the NPT boundary `t=1/d`, `A_d(1/d)=T_d`. For `δ≥0` with `dδ≤1`, the tensor product telescoping bound gives

```text
‖A_d(1/d+δ)^{⊗k} − P_k‖ ≤ kdδ.
Q_k(1/d+δ,C) ≥ (b_{d,k}−kdδ)‖C‖_F².
```

Choosing `δ=b_{d,k}/(2dk)` gives the explicitly positive, copy-dependent threshold

```text
t_{d,k} = 1/d + b_{d,k}/(2dk) > 1/d.
```

This proof establishes a **finite-k** quantitative claim, conditional on correctness of the displayed rank-two block argument (external review pending). The qualitative existence of finite-k intervals is already known in earlier literature. The formula is extremely weak and does not provide a fixed t for unbounded k.

## Qutrit specialization and the October 28 reseed

For d=3, the universal coefficient may be sharpened via `2√6+1<6`. From the one-copy seed this gives the elementary bound

```text
b_{3,k} = 36 / 108^(2^(k−1)),
t_{3,k} = 1/3 + 6/[k · 108^(2^(k−1))].
```

The stronger **source-dependent** approach first transports verified four-/five-copy source implications and the downstream seven-to-twenty-four-copy rational certificates to `t=1/3`. The final research checkpoint reports a rank-two gap seed

```text
‖P_24 C‖_F² ≥ B24 ‖C‖_F² ;
B24 ≈ 7.236960476971373 × 10⁻⁷.
```

This `B24` is a claimed positive rational number reconstructed from exact source-certificate margins in `B24_exact.txt`. The actual exact fraction and full source objects are absent from the present public tree. Consequently the October 28 *numerical* seed remains archive-reported pending a public independent replay.

A refined block step for `b≤10⁻⁶` yields

```text
‖C‖_F ≤ [√6/b + (√6+1)/√b]‖P_{k+1} C‖_F
      ≤ (49069/20000)‖P_{k+1} C‖_F / b.
```

Since `(49069/20000)²<121/20`, choose `C₀=121/20` and `b_{k+1}=b_k²/C₀`. Starting at `b_24=B24`, induction supplies

```text
b_k=C₀(B24/C₀)^(2^(k−24)),     k≥25 ;
t_k=1/3 + b_k/(6k) >1/3.
```

At `k=25`, `t_25−1/3≈5.771195255674462×10⁻¹⁶`, a strict positive symbolic increment. It remains *less useful numerically* than a hypothetically certified exact threshold `0.34` at 25 copies; that experiment **failed** exact feasibility, as described below.

## Negative result that must remain visible

The final 25-copy exploratory LP at `t=0.34` generated a floating-point residual around `1.36×10⁻⁵`. Its active-basis exact reconstruction instead yielded residual margin approximately `−2.37368913×10⁻⁴` and a negative positive-semidefinite row weight approximately `−3.88440664×10⁻³`. This is an invalid certificate, excluded from quantitative rows.

## Explicit open audit gates

1. Replay the original four-/five-copy SDP-based quantitative **margin** source from the original published witnesses and verify its physical qutrit rank-two scope.
2. Independently reconstruct all source-certified seven-to-twenty-four copy profile rows with correct physical copy budgets; ensure spectators attached to rank-two-positive sources are separable across the Alice–Bob cut.
3. Recompute the exact rational `B24` and the binomial coefficient transport step; the approximate decimal alone is insufficient to reproduce the stronger analytic continuation.
4. Audit the rank-two block-operator induction for general complex, potentially nonnormal matrices and all dimensions.
5. Compare against pre-existing finite-k existence results and record precisely what the recurrence improves.

**Scope firewall:** `t_k>1/d` for each finite k establishes neither a fixed `t>1/d` valid for all k nor unrestricted all-copy NPT bound entanglement. The distinct fixed-parameter encoded-witness manuscript concerns a restricted subset of witnesses only.
