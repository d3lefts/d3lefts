# Dimension-controlled transfer of low-degree query risk: a dichotomy and the right certificate

*NIGHTFALL, 2026-11-22. Follows PR #988 (exact local-moment conservation). Audit:
`scripts/check_upstream_dimension_transfer.py`. Status: paper-level proofs plus exact or enumerated
finite checks; no Lean certificate. Prior-art status is given in §6.*

PR #988 closed with this target: *"a dimension-controlled, additive approximate-moment transfer theorem
for bounded low-degree observables and shallow query trees."* This note settles what such a theorem can
and cannot say.

- **Degree 1 works without dimension.** Closeness of 2-marginals and of (q+1)-query leaf laws
  transfers squared risk with an absolute constant (Theorem 1).
- **Degree 2 already fails for local certificates.** There are laws whose every k-marginal, and every
  k-query adaptive leaf law, is O_k(1/√n)-close to uniform. Yet a bounded degree-2 function moves by
  √(2/π) − o(1), and the squared risk of a depth-0 tree moves by a constant (Theorem 2). No transfer
  bound of the form Φ(d, q, k)·(local distance) can hold.
- **The right additive certificate is level-wise.** It is the distortion of each homogeneous
  Efron–Stein level against bounded test functions; on the cube this is a dual injective norm of the
  moment tensors. It characterizes the worst-case risk transfer up to constants depending only on
  (d, q) (Theorem 3).
- **A multiplicative certificate gives scale-aware transfer:**
  Risk_ν ≤ Risk_Q + √(Risk_Q)·LD_K, with LD_K the truncated χ² (Theorem 4). This is the
  approximate form of #988's exact theorem.
- **For Simon, Theorem 4 pays for rare collisions (LD_4 ≳ N^{3/2}); Theorem 3 does not.** Whether
  Theorem 3's certificate is O_K(1/N) for Simon is left as Conjecture S.

Throughout, ν is an arbitrary law and Q a product law on α^n with α finite. Here f takes values in
[0,1] and has interaction degree ≤ d; T is a deterministic adaptive decision tree of depth ≤ q with
outputs in [0,1]. The risk is Risk_μ(f,T) = E_μ(f − T)², and K = max(2d, d+q) is the locality
threshold from #988. The local distances are:

- δ_k = max_{|U| ≤ k} TV(ν_U, Q_U), the worst k-marginal distance;
- A_k = sup over depth-k adaptive trees of TV(leaf law under ν, leaf law under Q).

Since δ_k ≤ A_k, and A_k ≤ (|α|^k/2)·δ_k because leaves are cylinders on ≤ k coordinates, the two are
equivalent up to |α|^k.

## 1. Degree 1: dimension-free

**Theorem 1.** If d = 1, then
|Risk_ν(f,T) − Risk_Q(f,T)| ≤ (9/4)·A_q + 3·A_{q+1} + ½·δ_2 ≤ 6·A_{max(q+1, 2)}.
There is no dependence on n.

*Proof.* Write f = c + Σ_i g_i(x_i), where each g_i takes values in [−o_i/2, o_i/2]. Oscillation is
additive over separable sums, so Σ o_i = osc f ≤ 1, |G| ≤ ½ where G = Σ g_i, and |c − T| ≤ 3/2. Expand

(f − T)² = (c − T)² + 2(c − T)G + G².

Use the following fact: if a function with values in [−M, M] is computed by a tree, its expectations
under ν and Q differ by at most 2M times the leaf-law TV.

- (c − T)² lies in [0, 9/4] and is computed by T, so it contributes at most (9/4)·A_q.
- Each 2(c − T)g_i lies in [−(3/2)o_i, (3/2)o_i] and is computed by T followed by a query of x_i.
  Together these contribute at most 3·Σ_i o_i·A_{q+1} ≤ 3·A_{q+1}.
- Each g_i g_j depends on two coordinates and is bounded by o_i o_j/4. Together these contribute at
  most ½(Σ o_i)²·δ_2 ≤ ½·δ_2. ∎

The audit checks the termwise inequality, before the last maximisation, on 60 random instances: 2–3
letters, 3–5 coordinates, arbitrary ν, random product Q, random adaptive trees of depth 0–2.

## 2. Degree 2: local certificates must pay dimension

Fix n = 2^m and let H be the n×n Sylvester–Hadamard matrix. Define ν_n on {±1}^n × {±1}^n as follows:
x is uniform, and y_j = sign((Hᵀx)_j), with ties broken by independent fair coins. Let

f_n(x, y) = n^{−3/2}·xᵀHy.

This is a bilinear form, so its degree is 2.

**Theorem 2.**
(a) |f_n| ≤ 1 everywhere, because |xᵀHy| ≤ ‖x‖‖H‖_op‖y‖ = n^{3/2}.
(b) E_U f_n = 0 and E_U f_n² = 1/n. Also
E_{ν_n} f_n = n^{−3/2}·E‖Hᵀx‖_1 = E|S_n|/√n = n^{1/2}·C(n, n/2)·2^{−n} → √(2/π),
where S_n is a sum of n independent signs. Each (Hᵀx)_j has the law of S_n by sign-flip symmetry, and
the tie convention does not affect xᵀHy = Σ_j |(Hᵀx)_j|.
(c) Every k-marginal of ν_n is within C·k²/√n of uniform in TV, and A_k ≤ 2^{k−1}·C·k²/√n.
(d) Let g = (1 + f_n)/2 ∈ [0,1] and T ≡ ½ (depth 0). Then Risk_U = 1/(4n), while
Risk_{ν_n} ≥ (E_ν f_n)²/4 → 1/(2π).

*Proof of (c).* Take a set of k coordinates: x-coordinates A and y-coordinates B. Let R = [n] \ A, and
set y′_j = sign(⟨h_j|_R, x_R⟩), where h_j is column j of H.

- Since |⟨h_j|_A, x_A⟩| ≤ |A|, we have y_j ≠ y′_j only if |⟨h_j|_R, x_R⟩| ≤ |A|. This has probability
  O(k/√n) for each j.
- y′_B is independent of x_A.
- The vectors (h_j|_R)_{j∈B} have Gram matrix (n − |A|)·I + E with |E_{jj′}| ≤ |A|, because the full
  columns are orthogonal.
- Multivariate Berry–Esseen for convex sets (Bentkus 2005) puts the orthant probabilities of y′_B
  within O(k^{7/4}/√n) of those of a Gaussian with correlations O(k/n). Those Gaussian orthant
  probabilities are within O(k³/n) of 2^{−|B|}. The fair-coin tie-break removes the lattice atoms.
- Adding the errors gives TV ≤ C·k²/√n. The bound on A_k follows by summing over the ≤ 2^k leaves. ∎

Enumerated data from the audit (n = 8 in exact rational arithmetic, n = 16 in floats):

| n | E_ν f_n | largest k-marginal TV | √n × largest |
|---|---|---|---|
| 8 | 0.773398 | k ≤ 3: 0.136719 | 0.387 |
| 16 | 0.785522 | k ≤ 2: 0.098190 | 0.393 |
| 64, 256 (Monte Carlo) | 0.7948, 0.7971 | k ≤ 3: 0.0521, 0.0272 | 0.42, 0.44 |

The limit of E_ν f_n is √(2/π) = 0.797885, and the 1-marginals are exactly uniform.

**Consequence.** Theorems 1 and 2 together give a sharp dichotomy. For degree-1 targets, local
certificates transfer risk with absolute constants. From degree 2 on, no function Φ(d, q, k) makes
|ΔRisk| ≤ Φ·A_k true uniformly in n. Here the depth is q = 0 and A_k → 0 for every fixed k, yet the risk
moves by a constant.

The mechanism: a bounded quadratic can carry ℓ₁ coefficient mass √n by cancelling against an operator
norm, and ν aligns its O(1/√n) pairwise correlations with that sign pattern. Entrywise closeness cannot
see this. The aggregate correlation does, since ⟨H, C_ν⟩·n^{−3/2} = Θ(1). The target in #988 therefore
needs a non-local certificate.

## 3. The right additive certificate

For the product law Q, let H_k(Q) be the span of the Efron–Stein components of exact order k. Define
the level-k distortion

Γ_k(ν, Q) = sup{ |E_ν g − E_Q g| : g ∈ H_k(Q), ‖g‖_∞ ≤ 1 },

and D_D(ν, Q) = sup{ |E_ν f − E_Q f| : deg f ≤ D, ‖f‖_∞ ≤ 1 }.

**Theorem 3.**
(i) max_{k ≤ D} Γ_k ≤ D_D ≤ C_D·Σ_{k=1}^{D} Γ_k. On the cube with uniform Q, C_D = (1+√2)^D; for a
general product Q, C_D = 3^D·(1+√2)^D.
(ii) Risk transfer:
½·max_{k ≤ d} Γ_k ≤ sup_{f,T} |Risk_ν(f,T) − Risk_Q(f,T)| ≤ ½·C_K·Σ_{k=1}^{K} Γ_k.
(iii) On the cube, Γ_k equals the dual of the injective norm ‖a‖_inj = sup_{x∈{±1}^n} |Σ_{|S|=k} a_S x^S|,
evaluated on the moment tensor (E_ν x^S)_{|S|=k}. For k = 2, Grothendieck's inequality and decoupling make Γ_2
computable by an SDP to within an absolute constant factor.

*Proof.*
(i) The lower bound is trivial. For the upper bound, write f = Σ_k f_k by level. The noise operator
T_ρ f = Σ_k ρ^k f_k is Markov: on the cube for ρ ∈ [−1, 1], for a general product for ρ ∈ [0, 1]. So
for each x, the polynomial ρ ↦ Σ_k ρ^k f_k(x) of degree D is bounded by ‖f‖_∞ on that interval.
Chebyshev's extremal property gives Σ_k |coefficient_k| ≤ |T_D(i)| ≤ (1+√2)^D on [−1, 1]. The affine
substitution to [0, 1] costs 3^D. So ‖f_k‖_∞ ≤ C_D, and |ΔE f| ≤ Σ_k ‖f_k‖_∞·Γ_k.
(ii) For the upper bound, note that (f − T)² lies in [0,1] and has degree ≤ K: f² has degree ≤ 2d,
fT has degree ≤ d+q because a depth-q tree has degree ≤ q, and T² is computed by T. For the lower
bound, ΔRisk(f, 0) − ΔRisk(f, 1) = 2·ΔE f, so one of the two depth-0 trees moves the risk by at least
|ΔE f|.
(iii) This is the definition, plus multilinearity, which lets the sup over [−1,1]^n be taken at the
vertices. ∎

In the obstruction, Γ_2(ν_n, U) ≥ E_ν f_n → √(2/π), so Theorem 3 detects it correctly. The certificate
is dimension-free in the precise sense that the only constants are exp(K).

## 4. Scale-aware multiplicative transfer

Let LD_K(ν‖Q) = ‖P_{≤K}(dν/dQ) − 1‖_{L²(Q)}, the degree-K truncated χ², also called the low-degree
likelihood-ratio norm.

**Theorem 4.**

Risk_ν(f,T) ≤ Risk_Q(f,T) + √(Risk_Q(f,T))·LD_K(ν‖Q).

*Proof.* Let g = (f − T)², which has degree ≤ K. Then
E_ν g − E_Q g = ⟨g, P_{≤K}(dν/dQ) − 1⟩_Q ≤ ‖g‖_2·LD_K.
Since |f − T| ≤ 1, ‖g‖_2 = (E_Q(f − T)⁴)^{1/2} ≤ Risk_Q^{1/2}. ∎

The guarantee scales with the risk: a simulator that is exact under Q stays exact under ν. At
LD_K = 0 this recovers the forward direction of #988. Combined with Markov's inequality, a Route 1 tree
built for Q satisfies

Pr_ν[|f − T| > ε] ≤ (Risk_Q + √(Risk_Q)·LD_K)/ε².

The audit checks Theorem 4 on 60 random cube instances: n = 6, d ≤ 2, depth ≤ 2, arbitrary ν, with
LD_K computed exactly from Fourier coefficients.

## 5. Simon

Let ν be Simon's 2-to-1 distribution on functions [N] → [N], and Q the uniform distribution on such
functions.

- **χ² pays for rare collisions.** Take the event E from #988 on a fixed 4-set: two address pairs with
  equal XOR difference, each pair colliding. It has Pr_ν(E) = 1/(N−1) and Pr_Q(E) = 1/N². So every such
  4-set carries χ²(ν_S‖Q_S) = Θ(1), while lower levels contribute O(N^{−3}) per pair. With Θ(N³) such
  sets, LD_4(ν‖Q) ≳ N^{3/2}, which makes Theorem 4 vacuous.
- **The additive certificate does not pay.** The same event contributes only |ΔPr(E)| ≤ 1/(N−1) to
  Γ_4. Collision-count statistics normalised to [0,1] also move by only O(1/N).

**Conjecture S.** For each fixed K, Γ_k(Simon_N, Q_N) ≤ C_K/N for all k ≤ K. By Theorem 3, Route 1
trees for fixed (d, q) would then transfer from Q to Simon with |ΔRisk| ≤ C′_{d,q}/N, with no
collision penalty.

The conjecture concerns bounded low-degree polynomials, which is the polynomial-method regime. The
known Ω(log N) quantum lower bounds for Simon via polynomials suggest the gap is small for
K ≪ log N, but they do not give this bound directly.

## 6. Prior art and status

- Losses polynomial in n between almost-k-wise and k-wise independence are known (Alon, Andoni,
  Kaufman, Matulef, Rubinfeld, Xie 2007; O'Donnell–Zhao, "On closeness to k-wise uniformity"). So the
  phenomenon behind Theorem 2 is not new; an explicit bounded-quadratic version is likely folklore.
- The fooling of bounded-degree PTFs by k-wise independence (Diakonikolas–Kane–Nelson) concerns
  exact k-wise independence. It does not contradict Theorem 2.
- Theorem 3 is duality plus a classical coefficient bound. Theorem 4 is Cauchy–Schwarz against the
  low-degree likelihood ratio, the standard object of the low-degree method.
- What is new here, for NIGHTFALL, is the following:
  - the risk-transfer formulation for adaptive simulators;
  - the sharp dichotomy between degree 1 and degree 2;
  - the identification of the level-wise distortion as the certificate that characterizes worst-case
    risk transfer up to exp(K) constants;
  - the observation that χ² certificates pay for Simon's collisions while the additive one does not;
  - Conjecture S as the precise remaining target.

**Next.**
1. Prove Conjecture S, or an O_K(N^{−c}) version, by symmetrising over the hidden shift s.
2. Lean-certify Theorems 1 and 4. Both are finite-dimensional and short.
3. Use the SDP for Γ_2 as a computable certificate on real NIGHTFALL instances.
