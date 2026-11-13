# Oracle-implementable quadratic observation — scoped algorithmic corollary

**NIGHTFALL / Wright, 12 November 2026.** Publication-supporting derivation, **conditional** on the currently author-analytic degree-two product influence theorem. This is not a new proof of that theorem, a Lean certificate, or a priority claim. This document is intended as a proposed appendix for `papers/sharp-influence-backdoors/` and must not supersede the existing proof passport.

## Claim and exact cost model

Let `n >= 1`, let `X=(X_1,...,X_n)` have an independent product law on arbitrary measurable coordinate spaces, and let `f` be a real function satisfying `|f| <= B` almost surely and Hoeffding degree at most two. Assume `B>0`, `0<eta<=B^2`. Available oracles are:

1. Independent exact samplers for each coordinate distribution, including conditional simulation of *unrevealed* product coordinates after observing actual values of other coordinates.
2. An exact real-valued evaluation oracle returning `f(x)` at arbitrarily chosen full product inputs generated from these samplers and previously observed coordinate values.
3. A state oracle that reveals a chosen entire coordinate of **one fixed fresh independent input** `X*`. This oracle is charged separately from the evaluation oracle.

**Conditional theorem.** Assuming the quadratic influence inequality

`Var(g)^2 <= K max_i I_i(g)` with `K = C_2 B^2` and `C_2 = (10+2sqrt(2))^2 (1+sqrt(3))^2`, for every bounded degree-two *posterior section* `g`, there is a randomized adaptive algorithm producing a real estimate `Yhat` with

`E[(f(X*)-Yhat)^2] <= eta`

using at most

`q = min(n, ceil(32 K/(3 eta)))`

actual state-coordinate reads, and at most `2 n q s + t` model-evaluation calls, where, writing `u=eta/2`,

`eps = u^2/(64 K)`, `rho = u^2/(32 K B^2)`,

`s = ceil((2 B^4/eps^2) log(2n/rho))`, `t = ceil(2B^2/eta)`.

The number of model evaluations is polynomial in `n` and in the dimensionless accuracy ratio `B^2/eta`, for fixed universal `C_2`. **This is not a polynomial-time theorem about arbitrary succinct representations of f**: each value oracle and product sample is treated as unit cost, no claim is made for evaluating a quantum acceptance probability from an arbitrary black-box quantum algorithm, and no bound is claimed on the bit-complexity of exact real oracle responses. The degree-two theorem is currently not independently refereed or end-to-end Lean-certified; thus this algorithmic theorem is at the same conditional analytic status.

## Algorithm

At each of at most `q` stages, given the actual previously exposed coordinates and their values, let `g` denote the corresponding section of `f` on the remaining independent coordinates. For each unobserved coordinate `i`, draw `s` independent pairs `(Z,Z^(i))`, where `Z` is sampled from the remaining product law and `Z^(i)` changes only coordinate `i` to an independent draw. Evaluate `g` at both configurations and set

`Ihat_i = (1/s) sum_j (g(Z_j)-g(Z_j^(i)))^2 / 2`.

Read the state coordinate maximizing `Ihat_i` (arbitrary deterministic tie-breaking). When the reading phase ends, independently sample `t` completions of the unobserved coordinates from the remaining product law, evaluate `f` at those completed inputs, and return their arithmetic mean. If all coordinates were revealed, one call to `f` gives the exact output.

## Proof, with all error terms explicit

For every posterior section `g` bounded by `B`, a resampling score `W_i=(g(Z)-g(Z^(i)))^2/2` takes values in `[0,2B^2]` and has expectation `I_i(g)`. The elementary bounded-variable Hoeffding estimate therefore gives

`Pr(|Ihat_i-I_i| > eps | transcript) <= 2 exp(-s eps^2/(2B^4))`.

With the above `s`, the chance (conditional on the *actual state transcript*) that any of the at most `n` influence scores is inaccurate by more than `eps` is at most `rho`. On the success event, the chosen coordinate has influence at least `M-2eps`, where `M=max_i I_i(g)`; on failure its influence is nonnegative. Since `M<=Var(g)<=B^2`, the conditional expected chosen influence obeys

`E_alg I_chosen >= M-2eps-rho B^2`.

Let `p(g)=sum_i I_i(g)` be the degree-weighted posterior Hoeffding energy, and let `v(g)=Var(g)`. Degree two gives `v<=p<=2v`. By the assumed quadratic inequality,

`M >= v^2/K >= p^2/(4K)`.

The **exact** posterior drift identity, taking expectation over the newly revealed *real state coordinate*, is

`E[p(g_after) | g, chosen i] = p(g)-I_i(g)`.

Hence for `P_j=E[p(g_j)]`, averaging over state and internal model-sampling randomness and using Jensen,

`P_{j+1} <= P_j - P_j^2/(4K) + e`, where `e=2eps+rho B^2=u^2/(16K)`.

In addition, `P_{j+1}<=P_j` holds without assuming estimator accuracy, because each selected influence is nonnegative. Whenever `P_j>=u`, the choice of `e` yields

`P_{j+1} <= P_j - 3 P_j^2/(16K)`.

For `P_j>0` the reciprocal increases by at least `3/(16K)`: since `P_j <=2B^2` and `K=C_2B^2`, the quantity `3P_j/(16K)` is strictly below 1, so `1/(1-z)>=1+z` applies. It follows that after `ceil(16K/(3u))=ceil(32K/(3eta))` stages, either the process earlier crossed below `u` and stays there by monotonicity, or the reciprocal growth forces `P_q<=u`. If all `n` coordinates were revealed earlier, the risk is exactly zero. Thus the Bayes risk of the *exact* posterior mean after the state reads is at most `E[v(g_q)]<=P_q<=eta/2`.

The final independent Monte Carlo average `Yhat` of `t` conditional completions has conditional mean `m=E[f(X*)|observed state coordinates]` and conditional variance at most `B^2/t<=eta/2`. Conditional orthogonality of `f(X*)-m` and `m-Yhat` gives

`E[(f(X*)-Yhat)^2] = E[v(g_q)] + E[(Yhat-m)^2] <= eta`.

All steps are finite-coordinate and hold almost surely for product sections induced by positive-probability transcripts (or regular conditional product sections where provided by the oracle); arbitrary-index and black-box quantum variants are **not** being claimed.

## Independence and failure tests

- The model-evaluation samples must be **independent of the unobserved target coordinates**. Using the hidden state as a simulated input would silently change the query model.
- Estimation success is a conditional probability statement at each node; **do not** condition the posterior dynamics on simultaneous global success. The proof uses unconditional expected decrement with an explicit failure penalty `rho B^2`.
- When a pure quadratic interaction remains, the immediate squared prediction error need not decrease upon observing one endpoint; it is the **degree-weighted posterior energy** whose expected decrement is `I_i(g)`.
- If evaluation or sampling is computationally difficult, the stated polynomial *oracle-call* bound does not imply a polynomial-time algorithm.
- Check against work on influence-estimation algorithms and greedy decision-tree induction, including Blanc–Lange–Tan et al.; none of these standard estimation tools is claimed to be newly invented.

## Decision for the flagship TCS paper

This is a **usable conditional algorithmic corollary**, not a discovery that independently qualifies as a landmark. Lead the paper with the author-side quadratic influence theorem; include this result only after its proof and categorical prior-art gates are met. The decisive remaining mathematical gate remains the actual-source global matching/assignment bridge plus an independent non-author validation of the whole quadratic argument. Exact finite checks of the drift identity can be replayed by `check_oracle_implementation_exact.py` but do not certify the influence inequality.
