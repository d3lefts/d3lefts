# NIGHTFALL — Change-invariant authority and sharp recertification radius

**Date:** 2026-11-15 (UTC). **Status:** analytic finite-model theorem; independently enumerated exact rational tests; not a Lean certificate or human peer review. **Global novelty not established.**

## Research objective and strongest baseline

The prior NIGHTFALL v0.2 separator theorem reuses unchanged conditional evidence messages but must recombine with a changed boundary prior to calculate a new posterior. This paper asks for an exact condition under which **the authorization decision itself remains valid across an entire declared family of changes**, with zero new sensor reads and no new posterior computation. The theorem extends the functionality, not the globally known foundations of credal inference.

### Assumptions and feasible change class

A finite separator `B={1,...,n}` is an authenticated sufficient interface. At a fixed trusted evidence history `h`, define unnormalized nonnegative source masses

- `a_b` = current evidence mass at separator state `b` and an unsafe mission state;
- `s_b` = current evidence mass at state `b` and a safe mission state;
- `t_b=a_b+s_b>0` for every interface state that may become possible.

These can encode arbitrarily correlated hidden system variables and arbitrarily dependent noisy sensor channels inside a separator stratum. A permitted environment/model change **only** multiplies the entire separator stratum, safe and unsafe alike, by a positive number `lambda_b`, leaving `a_b/s_b`, the mission semantics and the underlying cached sensor likelihoods unchanged. The resulting posterior is

```
R(lambda) = sum_b(lambda_b*a_b) / sum_b(lambda_b*t_b).
```

Full-support certification for every newly reachable `b` is mandatory. A change to the conditional model *within* a stratum, the observation channel, separator identity, or mission predicate is outside this theorem and invalidates the reuse decision.

## Theorem 1. Arbitrary-prior change invariance (necessary and sufficient)

For unrestricted positive stratum reweights,

```
sup_{lambda_b>0} R(lambda) = max_b (a_b/t_b).
```

Hence an authorization limited to conditional posterior unsafe risk at most `delta` remains valid after **every** such boundary-prior change iff every certified interface slice satisfies `a_b <= delta*t_b`. Proof: `R(lambda)` is a weighted average of `a_b/t_b` with positive normalized weights proportional to `lambda_b*t_b`. The bound follows; for any target slice b the reweights can concentrate the mixture arbitrarily close to that slice. This is exact, with no independence or sensor-noise restriction inside the slices.

**Interpretation:** if the cached authenticated certificate includes `max_b a_b/t_b <= delta`, neither new evidence *nor recalculation of the current scalar posterior* is necessary to authorize after a prior-only change. The minimum **additional acquisition** cost is then exactly zero, under this change class and assuming no mandatory external audits. It does not authorize a model change to the conditional channels or a global frequentist error-rate promise.

## Theorem 2. Sharp interval-robust decision certificate and counterexample

Suppose `0 < lower_b <= lambda_b <= upper_b`. Define `c_b(delta)=a_b-delta*t_b` and

```
Psi_delta = sum_b [ upper_b*c_b if c_b >= 0 else lower_b*c_b ].
```

Then **every** admissible changed posterior has risk at most `delta` **iff** `Psi_delta <= 0`. Proof: the denominator of `R(lambda)-delta` is positive, so its sign is the sign of `sum_b lambda_b*c_b`; maximizing this affine form over the rectangle selects `lambda_b=upper_b` for positive `c_b` and `lower_b` for negative `c_b`. If `Psi_delta>0`, that explicitly selected corner is a rational finite witness violating the authorization threshold. If `Psi_delta<=0`, each admissible change satisfies the threshold. The certificate is `O(n)` rational operations. The result for robust **denial** interchanges `a` and `s`, with threshold `eta`, and has the same proof.

This is an exact **proof-or-counterexample** authorization gate for a declared, trusted interval change class. It does not claim global optimal adaptive recertification cost when the gate fails.

## Theorem 3. Exact symmetric change radius

Suppose `lambda_b in [1-k*rho_b, 1+k*rho_b]`, with `rho_b>=0` and `k>=0` sufficiently small to keep all lower factors strictly positive. Let

```
T=sum_b t_b,  A=sum_b a_b,
slack = delta*T-A,
exposure = sum_b rho_b*abs(a_b-delta*t_b).
```

If `slack>=0` (the original authorization passes) and `exposure>0`, **all** changes of size at most `k` preserve authorization iff

```
k <= k_star := slack/exposure.
```

For `exposure=0`, the authorization survives all feasible such changes. The formula is exact, not an asymptotic approximation. Proof: apply Theorem 2 to the symmetric intervals, which yields `Psi_delta(k)=-slack+k*exposure` identically. This is a weighted `L1` dual norm of the signed threshold-excess mass `c_b`; it measures **certificate fragility** rather than total variation of the whole system. A violated threshold carries a rational adversarial reweight witness.

### Concrete phase transition

For two interface states, let `a=(0,1/10)`, `s=(1/2,2/5)`, `delta=3/20` and `rho=(1,1)`. The old risk is `1/10`, the robust-unbounded risk `1/5`; the exact symmetric change radius is `k_star=1/2`. At `k=1/2` the adversarial factors `(1/2,3/2)` give posterior risk `3/20` exactly, and any larger feasible `k` permits a failing posterior. For factors `(1,9)` the risk is `9/50`, exceeding `3/20`.

### Marginal-posterior insufficiency

Two valid cached models with the **same** old marginal unsafe risk `1/10` can respond differently to the **same** boundary change: Model A has `a=(0,1/10)`, `s=(1/2,2/5)`; model B has `a=(1/20,1/20)`, `s=(9/20,9/20)`. Both old risks equal `1/10`. Reweight `lambda=(1,9)`: A has risk `9/50`, B remains at `1/10`. Thus preserving only the old scalar posterior is **not** sufficient to certify future change robustness; the separator-conditional information is operationally necessary.

## Authentication, decision semantics and limitations

The existing cached separator masses must be signed/attested with source factor digests, sensor/channel versions, trusted change-impact coverage, mission identity and stable history timestamps. A valid signature alone never establishes correct completeness or model calibration. New symbols with no old slice certificate are a separate failure case. Correlations and shared noise crossing the declared separator must be included in the interface or the hypotheses do not apply.

All theorems bound a **per-evidence-history posterior unsafe risk**. Neither bounded posterior risk on authorization histories nor this reuse theorem automatically establishes global class-conditional false-authorization/false-denial bounds. Those require the global occupancy-risk LP used by NIGHTFALL v0.2, with robust model constraints if changes are uncertain.

## Independent check and prior-art status

The two implementation files use exact `fractions.Fraction`; the first constructs an `O(n)` threshold checker, a rational maximum-risk optimizer and a closed-form change radius. The second enumerates all rectangle corners independently, checking `2100` models and `4394` change-radius cases with rational equality, plus exact two-stratum counterexample fixtures. No stochastic numerical tolerance is used. The finite audit cannot prove the general theorem; the three arguments above provide the mathematical proofs.

Closest checked external antecedents, **not claims of originality**:

- Fabio Cozman, *Credal networks*, Artificial Intelligence 120 (2000), 199–233. Generalized Bayesian interval inference and linear-fractional formulations: https://doi.org/10.1016/S0004-3702(00)00029-1
- Wijk, Wang, Kwiatkowska, *Robustness Guarantees for Credal Bayesian Networks via Constraint Relaxation over Probabilistic Circuits*, IJCAI 2022: https://doi.org/10.24963/ijcai.2022/677
- Chakherlou, Khastgir, Zhao, *Reusing Operational Evidence After Context Changes*, 2026: https://www.alphaxiv.org/abs/2608.03384
- Anzum and Shahriar, *A robust Bayesian and game-theoretic framework for certifying AI-enabled safety-critical systems under structural misspecification*, Scientific Reports, 2026: https://www.nature.com/articles/s41598-026-69285-w

The candidate original *systems-engineering* contribution is an operationally checkable decision-invariance certificate and exact repair threshold **integrated with authenticated separator reuse**, but the underlying robust Bayes/fractional optimization formulas are classical or readily derived from known methods. No worldwide priority assertion or publication-ready claim without independent theorem-to-theorem review.

## Next new problem (not the old C96 obstruction)

Find the **minimum additional sensor acquisition cost** that restores a failing robust separator certificate under a noisy adaptive experiment model and a global two-sided-risk constraint. Seek a matching primal/dual or hardness certificate under a specified bounded interface width; do not substitute a noiseless mincut for dependent observations.
