# NIGHTFALL — A Nonseparable Price of Permission: Exact Joint Evidence–Freshness–Capacity Lower Bound

**Research date:** 15 November 2026. **Flagship:** *The Price of Permission: The Economical Limits of Mediating Superautonomy*. **Status:** complete scoped analytic theorem and independently implemented exhaustive finite checks. **NOT** Lean-certified, human-refereed, globally priority certified, or a deployment security proof.

## Research contract

- **Question:** What is the unavoidable *joint* cost of acquiring enough information to certify every legitimate action and finishing guarded effects before a deadline, with authenticated cached evidence that may become invalid?
- **Feasible systems:** finite independent modular hidden states, individually uninformative cheap half-reads, a perfect direct test, hard fixed synchronized deadline, a common nonchanging evidence epoch inside the allowed window, and a trusted complete atomic effect guard. Every legitimate action must be admitted; zero unsafe action may be admitted. Costs and worker capacities are explicit.
- **Strongest external related work checked:** He and Yu (2026), *Before Agents Act: Assurance-Aware Semantic Scheduling for Evidence Acquisition in Distributed Systems*, arXiv:2609.34376, already combines portfolio selection, scheduling, freshness, source dependencies and repair, even conditional exact global cost optimality. Talbot (1982) and Hartmann–Briskorn (2022) cover multimode time/resource/cost scheduling. Hua et al. (NeurIPS 2025) optimizes average-cost monitor combinations. RFC 9334 covers attestation freshness and caching. Our closed-form restricted result is not advertised as a new general scheduling algorithm.
- **Scientific novelty threshold:** a full-text model-level nonimplication from the above works, ideally a new adversarial in-window freshness/availability lower bound with a matching implementation; not met yet.
- **Independent test:** an implementation that searches actual per-slot operations and observer-state changes instead of using the formula, including wasteful read-then-deep schedules.
- **Checker:** `audit_independent.py`, 510 time-slot cases, 504 independent capacity-investment cases, 818 modular-world checks; full SHA-256 in `AUDIT.md`.
- **Stop:** Do not promote this to full lifecycle optimality or internationally novel mathematics. Use it as a valid first nonseparable benchmark, then attack an in-window adversarial update model. 

## 1. A typed, all-safe-world availability model

There are **N** independent protected actions, with hidden pairs `(X_i,Y_i)` independent and uniform on `(Z_r)^2` for `r>=2`. Their effect-time safety predicate is `P_i = 1{X_i+Y_i=0 mod r}`. A legitimate batch is any state with all `P_i=1`. No controller may permit a failing predicate, and it must commit **all N** genuinely safe actions by a common deadline. The corresponding statements must hold on **every** admissible state, not merely in expectation.

For each action, three information operations are available:
- a perfect read of X_i, priced **c**, requiring one verifier-worker-slot;
- a perfect read of Y_i, priced **c**, requiring one verifier-worker-slot;
- a perfect direct predicate test, priced **d>2c>=0**, requiring one worker-slot.

Read results can be compared without additional cost. The readings may occur in any order and, with two workers, in parallel. Different actions have distinct hidden input pairs; there is no cross-action information reuse except an explicitly authenticated **completed certificate cache**. A partly read pair never certifies the predicate. If an action is known to be safe from a valid scoped certificate, it requires no new verification work; each action nonetheless requires a trusted effect-time guard.

Let K0 <= N actions initially have signed source-bound certificates; before the fresh inspection window an adversary may invalidate any B <= K0 (or fewer). Complete dependency closure and source-epoch checking identify those invalidations. Therefore exactly K=K0−B remain current in the worst case and R=N−K require new verification.

There are H>=1 final verifier slots *within the modeled time-to-live of every new reading* and m interchangeable verifier workers, one unit operation each per slot. The source state and certification epoch are held stable for these H slots, and every action is guarded atomically in a single final commit slot immediately afterward; the model's guard workers g must satisfy g>=N. Acquisition and guard do not share worker capacity. A guard's successful version test is separately modeled as complete and unbypassable. No unmodeled side effects or deferred provider calls exist in this model.

The controller may be adaptive, but on a legitimate batch all certificates must be completed by the final slot. The prices below are **safe-batch incremental costs**, not average costs over the action generator, and exclude already paid historical cache costs. Source and policy updates during the active inspection window or the effect callback require a different model (a negative control below).

## 2. Theorem — matching joint price and feasibility

Put C=mH, the number of available verifier-worker-slots. If g<N or C<R, no architecture can commit all N legitimate actions under the contract.

If g>=N and C>=R, then the minimum number of expensive direct checks is exactly

    D_min = max(0, 2R−C).

The minimum new-evidence cost is exactly

    C_evidence*(N,K0,B,H,m) = 2cR + (d−2c)*max(0,2R−mH).

For verifier facility fee F_m per installed worker, guard facility fee F_g per guard, and each committed effect guard invocation fee c_g, the exact total safe-batch cost at fixed m,g is

    C_joint* = F_m*m + F_g*g + N*c_g + 2cR + (d−2c)*(2R−mH)_+.

The price per genuinely safe committed action is `C_joint*/N`. A nonzero unsafe authorization rate is **not** permitted in this particular theorem; a probabilistic or monitor-drift version is a future problem.

If m and g may be purchased, F_m,F_g>=0, an optimal g=N and m between `ceil(R/H)` and `ceil(2R/H)` attain the precise minimum

    C_purchase* = N*(F_g+c_g) + 2cR
          + min_{ceil(R/H)<=m<=ceil(2R/H)}
                 {F_m*m + (d−2c)*(2R−mH)_+}.

If R=0 choose m=0 (all valid caches), and if F_m=0 the upper limit still yields an optimum. All statements are exact for nonnegative rational prices.

### Proof — lower bound, for **all** admissible zero-error strategies

1. **Informational necessity.** A single Xi or Yi has zero mutual information with Pi under the uniform modular law. More strongly, for every fixed observed Xi or Yi there exist both a safe and an unsafe completion with exactly the same visible data. Because the source pairs across actions are independent and full-support, observations of other actions do not eliminate that ambiguity. Thus, on each legitimate accepting branch, each of the R noncached actions must acquire both halves or directly test Pi. Otherwise the same transcript would also authorize an unsafe, indistinguishable world.
2. **Capacity necessity.** Write x for the number of actions certified by exactly two cheap half-reads and y for those by direct inspection (discarding useless partial readings can only reduce cost/work). Since x+y=R, the verifier must execute at least 2x+y=2R−y unit operations. Hard slot capacity forces 2R−y<=mH, hence y>=(2R−mH)_+. Also y>=0. One cannot complete R certifications at all if mH<R.
3. **Cost necessity.** Every valid schedule spends at least 2c x + d y = 2cR+(d−2c)y, minimized exactly when y takes its smallest feasible value, since d>2c. Every committed action additionally requires its atomic guard at finality. With all N in a single final slot, g>=N. Facility fees are unavoidable given installed capacities.
4. **Construction attaining equality.** Choose y=(2R−mH)_+, x=R−y. Complete y direct tests and two half-reads for each of x remaining actions in arbitrary worker-slot positions in the final H slots. The total number of operations is R+x<=mH. Jobs are independent, and half-reads need no ordering, so simple round-robin fills at most m jobs per slot; two halves of the same action may be read simultaneously on different workers. Compare exact predicate values; abort unsafe cases. At the final commit slot, atomically check each action's source/policy epoch and issue a single protected effect for every passing, safe action. All safe worlds pass, all unsafe worlds are rejected, and the cost exactly matches the lower bound.
5. **Facilities.** Given R, no m<ceil(R/H) is feasible; since more than ceil(2R/H) workers cannot save further inspection expense, a nonnegative setup fee never favors purchasing more. Minimize the exact fixed-m expression over this complete finite interval. QED.

### Falsification conditions

If half-reads overlap across multiple actions, direct checks are noisy, cache contents can be forged, effect-time mediation is incomplete, guard workers share verifier capacity, worker/check latencies are non-unit, or in-window version changes trigger retries, the formula is not guaranteed. These are not small technicalities: they alter the feasible information partitions, service equations or protected effects.

## 3. Certificate invalidation causes a *capacity externality*

For a fixed installed verification capacity C=mH, the new-evidence price at R required recertifications is `Q(R)=2cR+(d−2c)(2R−C)_+` when feasible. Losing one additional valid cache changes the price by

    Q(R)−Q(R−1) = 2c+(d−2c)[(2R−C)_+−(2R−2−C)_+].

The premium can exceed the **direct cost d** of rechecking the single invalidated action, because the extra work displaces cheap paired checks for other actions. In particular, when both bracket terms lie in the linear regime, the increment is `2d−2c`, which is strictly greater than d when d>2c.

**Exact witness:** N=3, K0=1, H=2, m=2 (C=4), c=1, d=5. With the cached certificate valid, R=2 and new-evidence price is 4. Invalidate it before the window: R=3, at most one cheap paired certificate and two expensive direct tests fit; new-evidence price is 12. The loss of **one certificate raises minimum evidence cost by 8**, despite its direct replacement costing 5. This is a genuine interaction between information complementarity, finite capacity, deadline freshness and certificate invalidation; not a sum of the independent component minima.

With worker facility fee 4, guard facility fee 1 and effect fee 1, the robust installed-batch optimum is 18 with no invalidation (m=2) and 24 with one invalidation (m=3). Fixing m=2 after invalidation instead costs 26. Those are complete matched-cost calculations **within this synthetic model**, not measurements of a deployed guard.

## 4. Novelty and transfer assessment

This is the first complete **matching chain-price theorem in NIGHTFALL's finite flagship model**: informational indistinguishability -> two alternative certificate constructions -> hard verification capacity -> valid cache accounting -> atomic guarded completion -> exact minimum total cost. It is not a claim of worldwide discovery of multimode scheduling or tight worker-count formulas.

**Closest external references:**
- He and Yu (2026), *Before Agents Act: Assurance-Aware Semantic Scheduling*, https://arxiv.org/abs/2609.34376 — joint witness selection, expiry/deadline scheduling, provenance and receipt-aware repair, with conditional exact global optimality.
- Talbot (1982), *Resource-Constrained Project Scheduling with Time-Resource Tradeoffs*, https://doi.org/10.1287/mnsc.28.10.1197 — classical multimode time/cost worker scheduling.
- Hartmann and Briskorn (2022), *An updated survey of variants and extensions of the resource-constrained project scheduling problem*, https://doi.org/10.1016/j.ejor.2021.05.004.
- Hua et al. (NeurIPS 2025), *Combining Cost Constrained Runtime Monitors for AI Safety*, https://proceedings.neurips.cc/paper_files/paper/2025/hash/ed56a654ddb681841fdb2184463c253e-Abstract-Conference.html — average budget monitor allocation, not general hard guarantee at external effect boundary.
- IETF RFC 9334 (2023), remote attestation and freshness, https://www.rfc-editor.org/rfc/rfc9334.html.
- Prior NIGHTFALL PR #564 (source Q2), #529 (SCIF update), #554 (semantic fence), #576 (nominal transversal), #593 (capacity), and #588 (selection-conditioned guard risk).

No external human referee has established that the combined closed form is historically new; the standalone optimization formula is likely a simple special case of existing multimode scheduling theory. **What matters for the dissertation is the explicit finite economic lower-bound benchmark and its adversarially testable hypotheses.** A truly globally original theorem must cover at least a missing degree of freedom, such as nonstationary monitor reliability under adaptive adversarial in-window changes with two-sided availability and effect-time finality, or prove a new complexity/approximability classification not implied by the papers above.

## 5. Next experiment and stop rule

Hold all N action predicates, cost prices, guard semantics, allowed cache invalidations and deadlines identical across: cheap-pair only, expensive-only, average-budget optimized cascade (reported feasible only if actual deadlines pass), static capacity composition, and the joint exact policy. Compare total **legitimate effects committed**, unsafe effects, expired evidence, verifier work, guard work, queue delay and cost. First independent checker must reproduce the finite theorem from an explicit slot-level scheduler and demonstrate an unsafe-world rejection. Then introduce a controlled *in-window* source revision; this violates the theorem's epoch assumption and must fail closed, not silently reuse proof. Test after changing operational assumptions only under a new preregistration.
