# NIGHTFALL strong simulation: exponential stopping-time tail

Checkpoint 2026-11-18 ET. Status: author-side paper derivation, NOT Lean certified, NOT human reviewed, NOT novelty checked. Baseline: merged Jensen mixture theorem PR #867. Quantum circuit composition is draft PR #878 with strict CI pending.

## Objective and source

Test the cheapest route to log(1/delta): replace root Markov truncation of the Jensen mixture decision tree by a geometric bound on the number of queries. Primary competing reference: Blanc, Docter, Strassle, Tan, Quantum Speedups Require Structure or Depth (arXiv:2608.19158v1), Conjecture 2, https://arxiv.org/html/2608.19158 . That conjecture is about quantum QUERY WEIGHTS and is NOT proved here.

## Proposed lemma and proof

At a reachable partial assignment, the current section g, posterior weights v_theta, and total mass V=sum_theta v_theta >0 carry the two existing potentials

Phi(v,g) = sum_theta v_theta L^{mu_theta}(g);
Sq(v) = sum_theta v_theta^2 / V;
Psi(v,g) = Phi(v,g)/g_a + (V-Sq(v))/g_b.

The existing Lean declaration Mixture.mexpected proves E_v[remaining queries] <= Psi(v,g) for every valid state and every remaining fuel. The invariant St_pres ensures that every section has a row certificate of cost K=pi^2 d^2/2. Thus for every positive-mass reachable state,

Phi(v,g)/V <= K, and 0 <= (V-Sq(v))/V <= 1.

Consequently its NORMALIZED conditional expected remaining depth is bounded by the SAME constant

B(tau) = K/g_a + 1/g_b
       = 3 sqrt(2) pi^6 d^6 M / (tau sqrt(tau)) + 512 d^4 M^4 / tau^3.

This is a conditional statement uniform over histories, not merely the old root expected-depth bound. The support V=0 branches have zero source probability and do not enter conditioning.

Set L=ceil(2B). At every active state, conditional Markov gives
Pr(remaining depth >= L | observed history) <= B/L <= 1/2.
Apply this again at the stopping times L, 2L, ... and use the tower property. Inductively,

Pr(depth >= m L) <= 2^(-m), for all integers m >= 1.

This holds for fuel-capped trees too: unfinished leaves consume their full query fuel (Mixture.mbad_queries), and the same conditional residual-mean certificate applies for every restricted state and fuel. The exact >=/>, zero-fuel and equality conventions must be checked in Lean before the constant is promoted.

Set tau=epsilon^2 delta/2, m=ceil(log_2(2/delta)), and n=m*ceil(2B(tau)), for 0<epsilon,delta<=1. The probability of reaching unfinished leaves is <=delta/2. Mixture.mleaf_error bounds finished-leaf mean square error by tau; Chebyshev gives <=tau/epsilon^2=delta/2. Therefore this yields the PAPER-LEVEL candidate query cap

n = ceil(log_2(2/delta))
    * ceil(24 pi^6 d^6 M epsilon^(-3) delta^(-3/2)
           + 8192 d^4 M^4 epsilon^(-6) delta^(-3)).

Compare original Jensen root-Markov truncation:
O(d^6 M epsilon^-3 delta^-5/2 + d^4 M^4 epsilon^-6 delta^-4).
The new argument replaces ONE inverse power of delta in both terms by log(1/delta). This is a quantitative improvement if the per-history bound and stopping-time recurrence survive Lean checking. It does NOT establish the strong conjecture.

## Counterexample to variance-only strong simulation

Let X~Bernoulli(1/100), f(X)=X, tau=1/16, epsilon=1/4. The degree-one function has Var(f)=99/10000 < tau, so the variance-stopping rule outputs E f=1/100 at the root, without a query. Its error >epsilon occurs exactly when X=1, with probability 1/100. For target delta=1/1000, this violates the desired success guarantee. A correct classical algorithm could query X once: the obstruction is the method's tail-insensitive stopping rule, not intrinsic hardness of degree one.

The strong conjecture requires a different tail-sensitive mechanism, such as a conditional epsilon-outlier-mass or quantile certificate, with an influence/query-weight theorem that remains polynomial in d and log(1/delta). A generic low-variance stopping test cannot supply it.

## Independent checks / stop rule

1. Inspect the exact type of mexpected and invariant St_pres in the compiled Jensen source; verify Phi/V<=K under all positive-mass restrictions. Reject this claim if any reachable state violates it.
2. Prove the uniform-residual-mean -> geometric-tail lemma on finite trees, including fuel and stopping-time endpoint cases, in Lean.
3. Compose with mbad_queries and mleaf_error; require source-exact strict Lean receipt and replay before claiming the new depth bound is certified.
4. Run the stdlib-only exact-rational toy checker; it checks the biased-bit blocker, geometric-tail arithmetic, and substitution constants.
5. After one exact proof attempt, if not closed, STOP this operator family and switch to quantile-aware statistics. Do not conflate this bound with BDST Conjecture 2 or its random-oracle consequence.

Discovery graph: row bound -> posterior Jensen/Gini potential -> history-uniform residual mean -> exponential runtime tail -> improved truncation -> rare-event leaf blocker. No independent novelty claim: the geometric-tail argument is standard drift/conditional Markov theory applied to this algorithm.