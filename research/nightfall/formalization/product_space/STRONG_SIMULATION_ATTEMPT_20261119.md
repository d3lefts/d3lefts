# Strong simulation (log 1/δ) — bounded attempt, 2026-11-19

**Target.** Blanc–Docter–Strassle–Tan (arXiv:2608.19158) reduce "PromiseBPP = PromiseBQP iff equal
relative to a random oracle" to a strong form of the simulation conjecture whose dependence on the
failure probability δ is only logarithmic (their Conjecture 2, stated with query weights). All known
simulators, including ours, cost `poly(1/δ)`. Goal of this session: either a `poly(T, 1/ε, log 1/δ)`
simulation or a clear account of what blocks the existing method.

**Outcome (paper level, not reviewed, not in Lean).**

1. An unconditional improvement of the δ-exponent: `δ^{−5/2} → δ^{−3/2}` (at the cost of one power of
   `T` and a log factor), by a tail-based stopping rule and a geometric potential.
2. A barrier: the natural route to `log 1/δ` — a *relative* influence inequality — is false, and the
   Aaronson–Ambainis influence-greedy simulator itself needs `2^{Ω(T)}` queries on an explicit
   instance where `O(T)` suffice. Strong simulation cannot come from influence-greedy plus a
   total-influence potential; it needs algorithm-aware weights (as in BDST's query-weight
   formulation) or a non-greedy query rule.
3. The precise open statement that would suffice, and why the obvious candidate fails.

Notation: product law `μ` on `Ω = ∏ Σ_i`; `f : Ω → [0,1]` of degree `≤ d` (`d = 2T` for a `T`-query
algorithm); `Inf_i` Efron–Stein influence; `I = ∑ Inf_i`; sections `f_ρ`, conditional law `μ_ρ`;
`m_ρ = E f_ρ`, `q_ρ = Pr_{μ_ρ}[ |f_ρ − m_ρ| > ε ]`.

## 1. Tail-stopped greedy: depth `O(d⁷ ε⁻³ δ^{−3/2} log(d/(εδ)))`

**Algorithm.** At node `ρ`: if `q_ρ ≤ δ`, stop and output `m_ρ`. Otherwise query a coordinate of
maximal influence `Inf_j(f_ρ)`. Cap the depth at `D`.

**Analysis.**

* *Leaf error.* At a stopped leaf, `Pr[ |f − Q̃| > ε | leaf ] = q_ρ ≤ δ` (the unqueried coordinates
  have law `μ_ρ`). Capped paths contribute `Pr[run > D]`.
* *Running nodes have variance.* `q_ρ > δ` and Chebyshev give `Var(f_ρ) ≥ ε² q_ρ > ε² δ`.
* *Relative gain.* The product-space influence theorem (`Influence.product_influence`, rescaled to
  `[0,1]`) gives `max_j Inf_j(f_ρ) ≥ κ Var(f_ρ)^{5/2}` with `κ = 4√15/(125 π⁶ d⁶)`. With
  `Var ≥ I/d` (Efron–Stein, degree `≤ d`) and `Var > ε²δ`:

      Inf_j(f_ρ) ≥ κ (ε²δ)^{3/2} Var(f_ρ) ≥ r · I(f_ρ),     r := κ (ε²δ)^{3/2} / d.

* *Geometric potential.* Querying `j` lowers the expected total influence by exactly `Inf_j`
  (Efron–Stein martingale identity; §2(E) of `SIMULATION_COROLLARY_PAPER_PROOF_20261118.md`). With
  `Z_t = I(f_{ρ_t}) · 1{running at t}`: `E Z_{t+1} ≤ (1 − r) E Z_t`, so `E Z_t ≤ (1 − r)^t d/4`.
* *Running is rare.* Running at `t` implies `I ≥ Var > ε²δ`, so
  `Pr[run > t] ≤ E Z_t / (ε²δ) ≤ e^{−rt} d/(4ε²δ)`. Take `D = r⁻¹ ln(d/(4ε²δ²))`.

Total failure `≤ 2δ` with depth

    D = (d / (κ ε³ δ^{3/2})) · ln(d / (4 ε² δ²)) = O(d⁷ ε⁻³ δ^{−3/2} log(d/(εδ))).

Compared with the certified `simulation_degree` (`O(d⁶ ε⁻³ δ^{−5/2})`): better in δ, worse by `d` and a
log. The same argument applies verbatim to any product law (all ingredients are measure-uniform).
Not yet extended to mixtures; not formalized.

## 2. Barrier: influence-greedy cannot give `log 1/δ`

**Instance (uniform cube).** Bits `y_1..y_k` and `x_1..x_n`;

    f(x, y) = a · AND_k(y) + b · (1/n) ∑ x_i,     a = 3ε, b = 1/2,  p := 2^{−k}.

`f` is the acceptance probability of a `k`-query classical (hence quantum) algorithm (with
probability `a` compute `AND_k`, with probability `b` sample one random `x_i`), so `T = k`, `d ≤ k`.

* **Optimal is cheap.** Target failure `δ' = p/4`. Query `y_1, …, y_k` (stop at the first 0) to
  resolve the rare event; the average term needs no queries when `2 e^{−8nε²} ≤ δ'/2`. Depth `≤ k = T`.
* **Greedy is expensive.** `Inf(y_j) = a² p / 2` and `Inf(x_i) = b²/(4n²)`. For
  `n < b / (a √(2p))` every `x_i` is more influential than every `y_j`; querying `x`'s does not change
  any influence, and the stopping rule never fires while `AND_k` is unresolved (its tail `p > δ'`).
  So max-influence greedy queries all `n ≈ 0.9 b/(a √(2p)) = Θ(2^{k/2}/ε)` `x`-bits first.
  Numerically (`ε = 0.1`): `k = 16, n = 271`; `k = 24, n = 4344`; `k = 32, n = 69511`, with the average
  term concentrated far below `δ'` in each case.

Greedy depth `2^{Ω(T)}/ε` against an optimum of `T`: no `poly(T, 1/ε, log 1/δ)` bound is possible for
this algorithm.

**Corollary: the relative influence inequality is false.** The natural sufficient condition for
`log 1/δ` via §1 would be

    (R)  Pr[ |f − E f| > ε ] > δ  ⟹  max_j Inf_j(f) ≥ Var(f) · poly(ε / (d log(1/δ))).

On the instance, `Var ≈ a²p + b²/(4n)` and `max Inf / Var ≈ 1/n = Θ(ε √p)`, exponentially small in
`d ≈ log(1/δ)`. (A degree-1 version with one rare symbol on a product space breaks (R) the same way.)
So the geometric argument of §1 cannot be pushed to `log 1/δ` by improving the influence inequality
alone.

## 3. What could still work

* **Algorithm-aware weights.** In the instance, the query weight of `y_1` in the algorithm is `a`
  (constant), while each `x_i` has weight `b/n`. BDST's Conjecture 2 asks for a heavy variable in this
  query-weight sense with weight `poly(1/(t log(1/δ)))`; the barrier above does not touch it. A
  polynomial-only proof (using just `f`) must therefore use more than influences: e.g. choose queries
  by their effect on the *tail mass* `q_ρ` rather than on variance, or decompose `f` into a rare-event
  part and a concentrated part.
* **Tail-aware potential.** A candidate replacing (R): non-concentration implies a coordinate whose
  query lowers the expected tail mass `E q` by `≥ q · poly(ε/(d log 1/δ))`. On the instance, querying
  `y_1` halves the rare-event mass, consistent with this. Unproved; no counterexample known.

## Budget and stop

Stopped at the planned checkpoint: §1 proved on paper, §2 barrier with explicit instance and numeric
check, §3 open. Next gates if pursued: second reader for §1–2; decide whether to formalize §1 (small:
reuses `ProductSimulation` with a new stopping rule) and whether the tail-aware potential is worth a
second budget.

## 4. Priority correction: BBBV hybrid + Talagrand is already BDST

**Strong prior art:** Blanc–Docter–Strassle–Tan, *Quantum Speedups Require Structure or Depth*, arXiv:2608.19158, submitted 2026-08-19, https://arxiv.org/html/2608.19158v1 . Corollary 6.4 explicitly proves input-dependent weighted Talagrand concentration; Lemma 4.5 bounds individual future-round query weights from previous-round weights, Section 7 develops higher-order hitting-set machinery, and Lemma 10.1 implements greedy restrictions with estimated average query weights. Therefore the proposed hybrid-plus-Talagrand and average-to-pointwise regularity approach **already exists**. Their results leave the strong unrestricted sequential-round Conjecture 2 open.

**Every-input median lemma: recovered known consequence, not novel.** Let a normalized T-query algorithm have acceptance f and query weights W_i(x)>=0 with sum_i W_i(x)=T. BBBV hybrid plus an acceptance measurement gives

    |f(x)-f(y)| <= 4 sqrt(T * sum_{i:x_i!=y_i} W_i(x)).

For any finite product law (including biased and zero-mass atoms), any median m of f, and B>0, an x with f(x)>=m+u and sum_i W_i(x)^2<=B must have weighted distance from A={y:f(y)<=m} at least u²/(16T). Choose a Talagrand witness a_i=W_i(x)/sqrt(sum_i W_i(x)^2). This yields convex distance d_Tal(x,A)>=u²/(16T sqrt(B)). As mu(A)>=1/2, Talagrand's convex distance inequality implies

    mu{f(X)>=m+u AND sum_i W_i(X)^2<=B}
        <= 2 exp(-u^4/(1024 T^2 B)).

Likewise for the lower tail. If max_i W_i(x)<=w at every input, then B=Tw and

    mu{|f(X)-m|>=u} <= 4 exp(-u^4/(1024 T^3 w)).

More generally add mu{sum_i W_i(X)^2>B} if the cap is only typical. This derives precisely the suggested exp[-u^4/(C T^3 w)] scale, and shows it is already implicit in BDST Corollary 6.4. This is paper reasoning, not Lean certification. Full Conjecture 2 requires controlling the exceptional high-weight set from max_i E W_i alone with a polynomial in T and log(1/delta), without BDST's exponential losses in the number of adaptive rounds.

## 5. Exact falsification: one-step expected tail-mass contraction fails

Section 3's previously proposed tail-decrement condition is **FALSE**. Let f=AND_k of k independent fair bits for any k>=4. Fix epsilon=1/4, and set q_rho=Pr(|f-E[f|rho]|>epsilon | rho). At the root

    q_empty=2^(-k).

For every unqueried bit i, its zero branch makes f identically zero, hence q_{i=0}=0. Its one branch has a rare AND_(k-1) event with probability 2^(-(k-1))<=1/8<epsilon, so q_{i=1}=2^(-(k-1)). Consequently,

    E_{y_i} q_{y_i} = (0+2^(-(k-1)))/2 = q_empty,

even though q_empty>delta for any 0<delta<2^(-k). Thus max_i (q_empty-E q_after_i)=0, contradicting every proposed positive fractional one-step decrement.

**Independent exact checker:** Python itertools.product and fractions.Fraction enumerated all 64 inputs for k=6, epsilon=1/4 and delta=1/256. For all six i: q_root=1/64, q_{i=0}=0, q_{i=1}=1/32 and E q_after=1/64. No floating-point assumptions.

**General mechanism:** for f=1_E with conditional event probability p_rho<=epsilon<1/2, the conditional tail mass equals p_rho. If that remains true after revealing either value of a coordinate, then E q_child=q_rho exactly by the tower property. Therefore q itself is a martingale until the event is no longer rare. The claim in Section 3 that querying an AND-defining coordinate 'halves' rare-event mass neglects the one branch, where conditional mass doubles; it does NOT decrease in expectation. Demote that fallback potential unless replaced by a multi-step or nonlinear information witness.

## 6. Novelty and stop rule

BDST already contains the candidate concentration and average-query-weight restriction techniques. Do not claim them as NIGHTFALL discoveries. Only a structurally new way around the exponential adaptive-round loss in BDST Lemma 4.5 (or independently verified genuinely new mechanism) would be progress toward their full Conjecture 2. Require explicit assumptions, a decisive AND/address-function test, and external prior-art comparison before new claims.
