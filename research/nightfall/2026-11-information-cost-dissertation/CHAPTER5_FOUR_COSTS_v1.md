# Chapter 5 — Four information costs on structured product systems

**Status:** analytic derivations for the explicitly scoped finite cases, no end-to-end Lean, no external mathematical refereeing, and no established global originality. Classical coding/Fano/search facts are historical background. This is a self-contained working note, not an independent publication claim.

## 1. Access games; do not substitute one oracle for another

**TEST:** value-oracle access to a bounded unknown `h`, plus ability to sample `X,Y~μ` and evaluate coordinate-wise hybrids; distinguish degree `≤2` from squared `L²(μ)` distance `≥ε` from that class. **OBSERVE:** `f` and `μ` are known; only an unknown fresh random input `X` can be read one coordinate at a time. **IDENTIFY:** `f∈H` is unknown; query full chosen model inputs and output an estimator/model in specified loss. **CERTIFY:** determine an exact universal safety property under explicit black-box or certified source access. Sampling and input construction cost are separate from query count.

## 2. An exact addressed quadratic family

Let `n≥2`, `K~Uniform([n])`, independent `Z_1,...,Z_n~Uniform({±1})`, and `θ∈{±1}^n`. Write

```text
f_θ(K,Z) = θ_K Z_K, |f_θ|=1, Var(f_θ)=1.
```

The Efron–Stein expansion is
`f_θ(K,Z)=Σ_j (θ_j/n) Z_j + Σ_j θ_j(1_{K=j}−1/n)Z_j`; every summand has support size at most 2, hence degree `≤2`. The output rank is 1.

**Exact adaptive observation.** With the function/model `θ` already known, query the fresh state's `K` then `Z_K` and output `θ_KZ_K`. Two coordinate reads give zero risk.

**Exact minimax classical identification.** A full-input model query at address `k` reveals `θ_k` and no other sign. With `q` adaptive, possibly randomized, exact value queries (hard cap) and arbitrary real-valued `L²` estimator, the worst-case expected risk has the identity

```text
R_q = inf_algorithm sup_θ E_algorithm ||f_θ−fhat||²_L2(μ)
    = 1 − min(q,n)/n .
```

*Proof:* Under the uniform prior on `θ`, all unqueried signs remain independent fair bits. Their posterior mean is zero, so each unqueried address contributes one unit of conditional pointwise squared error; queried addresses contribute zero. Averaging `K` gives Bayes risk at least `(n−q)/n`. Query `min(q,n)` distinct addresses and return `θ_k z_k` on known addresses, zero elsewhere; its risk is **exactly** `1−min(q,n)/n` for every `θ`. Minimax equality follows. In particular, for `η<1`, risk `≤η` demands `q≥ceil((1−η)n)`. Exact identification needs `n` queries.

**Exact test of membership in this particular family.** Now allow an arbitrary oracle `h:[n]×{±1}^n→[−1,1]` (not promised degree two). Draw `K` uniform and `Z,Z'` independently; query twice at the same `K`. Put `G=Z_Kh(K,Z)`, `G'=Z'_Kh(K,Z')`, reject when `GG'<1`. For every `h=f_θ`, never reject. Let `m_k=E_Z[Z_kh(k,Z)]`; then `d²(h,H_n)=n^(−1)Σ_k[1+E_Zh(k,Z)²−2|m_k|]`, where `H_n={f_θ}` and `d²` is squared `L²) distance. Since `E h²≤1` and `1−m_k²≥1−|m_k|`,

```text
P(reject) >= d²(h,H_n)/4.
```

Indeed `L=2(1−GG')∈[0,4]`, `E L=(2/n)Σ_k(1−m_k²)≥d²(h,H_n)` and `P(L>0)≥E L/4`. Thus `t=ceil((4/ε)ln(1/δ))` independent trials, **2t value queries**, give one-sided `ε`-far rejection with failure at most `δ`. This is an elementary conditional-consistency tester and should not be advertised as new before a property-testing literature audit.

**Nonadaptive state-observation gap.** A predetermined read-set that includes `K` and `q` leaves yields squared Bayes risk `1−q/n`. One that does not include `K` but reads `q` leaves gives `1−q/n²`. For fixed `η<1`, fixed queries require `Ω(n)`, while the adaptive policy uses 2. These are exactly the conditional projection formulae, not a model-learning statement.

**Constant-scale packing:** `||f_θ−f_φ||²=4d_H(θ,φ)/n`. A Gilbert greedy packing with minimum Hamming distance `>n/4` has size at least `2^n/Σ_{j=0}^{floor(n/4)} binom(n,j)`, which is `2^{(1−H₂(1/4)−o(1))n}`. Therefore the class contains exponentially many models separated by *constant* squared `L²` distance `>1`. Each classical model query conveys one sign bit, so bounded-error identification of an unknown codeword still takes `Ω(n)` queries by counting/Fano; `n` gives a trivial matching order upper bound. The packing is a standard coding-theoretic argument, not standalone novelty.

## 3. General three-group interaction-degree tester (analytic candidate)

For any independent product `μ`, a bounded `|h|≤B`, `B>0`, and Hoeffding decomposition `h=Σ_S h_S`, take independent `X,Y~μ` and color each input coordinate independently uniformly in three colors. Form all 8 hybrids of `X,Y` by choosing which parent supplies each color-group; let `Δ_3h` be their alternating sum. Then by degenerate ANOVA orthogonality,

```text
E[(Δ_3h)²]
 = 8 Σ_{|S|≥3} [1−3(2/3)^|S|+3(1/3)^|S|] ||h_S||²
 >= (16/9) Σ_{|S|≥3} ||h_S||² .
```

The coefficient is the probability that all three colors hit `S`, minimized at `|S|=3`, when it is `2/9`. Every genuine degree-`≤2` function gives `Δ_3h=0`. Since `|Δ_3h|≤8B`, an `ε`-far (in *squared* `L²`) function is rejected per trial with probability at least `ε/(36B²)`. Thus `8ceil((36B²/ε)ln(1/δ))` oracle evaluations suffice for one-sided testing. This counts oracle evaluations **not** time to sample full vectors. Literature comparison to mixed-difference and low-degree testing remains open; do not assert novelty.

## 4. Generic identification bounds and why entropy alone is insufficient

Let `H` have `M≥2` functions with range `[-B,B]`, and pairwise squared `L²(μ)` distances at least `Δ>0`. Draw `q` i.i.d. inputs from `μ`, query their labels/values, and select any function in `H` consistent with all responses. For each false `g`, `μ{f≠g}≥Δ/(4B²)`. A union bound proves exact recovery with success probability `≥1−δ` whenever

```text
q >= (4B²/Δ) [ln(M−1)+ln(1/δ)].
```

This is a **standard finite-class sampling upper bound**, not a new quadratic theorem.

If all values belong to an alphabet of `a≥2` outcomes, a deterministic worst-case exact learning decision tree needs `q≥ceil(log_a M)`. Under a uniform prior and error probability `≤δ`, Fano gives `q log₂ a ≥ (1−δ)log₂ M−h₂(δ)`. Unrestricted exact real-valued oracle responses can carry more information; no universal finite-alphabet bound applies then.

**Counterexample to a packing-only upper:** On the uniform one-coordinate categorical space `[n]`, the point functions `p_i(x)=1_{x=i}` and threshold functions `t_i(x)=1_{x≤i}` have the same `M=n` and pairwise squared `L²` separation `≥1/n` (both Hoeffding degree `≤1`). Yet exact deterministic membership learning takes `n−1` worst-case queries for the points and `ceil(log₂ n)` for thresholds. Packing alone does not predict matching query complexity, even at degree one.

If every nontrivial residual version space `V` admits an admissible query with each response fiber of size `≤(1−γ)|V|`, `0<γ≤1/2`, greedy identification takes at most `ceil(ln M/[−ln(1−γ)])` queries. This is a direct counting bound in generalized binary-search style. **The new open research question** is whether a *nontrivial independently testable restriction* on quadratic interaction geometry forces such a splitting property; the point-family example rules out an unrestricted claim.

## 5. Certification limits and decision

On an unrestricted `N`-point input domain, a uniform hidden one-point violation of an exact universal property can be detected with probability `≤q/N` by `q` adaptive classical model queries, and unstructured quantum search has `Θ(sqrt(N))` bounded-error complexity in the coherent query model. Finite exhaustive classical access can certify exact membership; the obstruction is **sub-exhaustive black-box assurance**, not logical impossibility. Approximate property testing, model identification and exact safety certificates remain distinct.

**Dissertation choice:** Chapter 3's Theorem D is centerpiece. Chapter 2 is its load-bearing scalar foundation, with a strict Turturean and classical quadratic comparison. Chapter 5 is a useful mathematical framework and scope-check; a genuinely original interaction-to-query-splitting result would strengthen the thesis but is **not required to start writing**. AgentDojo/ASUA remain evidence about practical abstraction boundaries only at their actual measured scope; whether they are a full application chapter depends on the examining department.

## 6. Replay, review, and stop rule

Run `python3 research/nightfall/2026-11-information-cost-dissertation/check_addressed_family_exact.py`. Independently inspect its oracle sampling and test distance; agreement with an exact finite enumeration does not prove the universal formulas. Explicitly attempt counterexamples with `n≥3`, skewed coordinate distributions, larger output ranges and finite-precision/noisy oracle responses; these are **different scopes**, not automatic theorems. Novelty requires independent dated literature and proof review. If a claimed upper/lower fails, demote it and preserve the failing input.

**External foundation:** Turturean [arXiv:2611.09773](https://arxiv.org/abs/2611.09773); Girish et al. [arXiv:2609.35327](https://arxiv.org/abs/2609.35327); Grover/BBBV search; classical decision-tree/property-testing and generalized binary-search prior art.
