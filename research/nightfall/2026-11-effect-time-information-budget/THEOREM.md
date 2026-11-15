# The Right to Act — An Effect-Time Information Budget for Autonomous Systems

**Subtitle:** Selection-Adjusted Authority, Change-Stable Evidence, and Minimum-Cost Enforcement

**NIGHTFALL research checkpoint:** 2026-11-15. **Status:** finite-model analytical theorems with independently written exact-rational oracles and exhaustive small-policy search. **Not Lean-certified, peer-reviewed, priority-certified, or validated on a real actuator.**

## 0. Research contract and novelty gate

**Objective.** Form one falsifiable proposition joining observation, minimum-cost evidence, conditional cache reuse, distribution change, probabilistic authorization, service availability, and effect-time enforcement.

**Feasible domain.** Finite mission-state and interface spaces; calibrated joint latent/noise model (arbitrary internal dependencies); exact action-bound evidence and an unbypassable guard with atomic effectuation; authenticated and complete change-impact/interface information; a finite set of available tests; additive rational costs. The model allows arbitrary positive reweighting of *interface-state priors* but does not allow hidden changes in conditional state/evidence/guard channels.

**Predecessor results in our repository.** Merged PR #576: exact deterministic minimum cost of observations and effect guards via history transversals, plus graph mincut case. Draft PR #583: complementary-evidence optimum under independent modular gates. Draft PR #585: finite dependent/noisy Bellman and occupancy-LP policies with authenticated conditional separator cache. Draft PR #586: exact risk robustness for interface-prior reweighting but WITHOUT informative finality-guard selection. The theorem here composes and corrects the *risk semantics* at the last effect-time filter. It does not supersede those algorithms.

**Strongest outside antecedents checked this session.** Santos-Grueiro (July 2026), *Temporary Authority, Permanent Effects: Commit-Time Authorization for LLM Agents*, https://arxiv.org/abs/2607.10487; Bhadane et al. (October 2026), *Runtime Control for AI Agents: Closing the Evaluation--Execution Gap*, https://arxiv.org/abs/2610.27480; Jin and Ren (2025), *Confidence on the focal: conformal prediction with selection-conditional coverage*, https://doi.org/10.1093/jrsssb/qkaf016; *The Safety Filter: A Unified View of Safety-Critical Control in Autonomous Systems*, https://doi.org/10.1146/annurev-control-071723-102940; Picard (1976) maximum closure and classical Bayesian sensitivity analysis. These establish substantial overlap with statistical selection, runtime filtering, and prior-dependent robust decisions. No claim of global novelty for Bayes' theorem, box support functions, the finite policy optimizer, or the underlying cryptographic pattern.

**Originality threshold.** A contribution beyond existing work must demonstrate that it gives an execution-conditional, three-criterion, source-robust proof-or-counterexample *certificate*, tied to authenticated source-change closure and exact effect binding, and demonstrate a quantitative engineering win relative to independent baselines. Failure to find that precise combination in the sampled literature is not proof of world priority.

**Cheapest decisive test.** Compare a naively risk-approved pre-execution policy with its conditional risk *among actual guard-passed executions* in the rational counterexample below, then use an independent corner oracle to attack the robust replacement. **Stop rule:** do not elevate to deployment or novelty unless source-verified guard coverage, independent audit, and dated close-literature review pass.

## 1. System model and what the certificate actually asserts

Fix a proposed consequential action `a` and an authenticated evidence history `e` acquired before effectuation. Let `U` be the indicator that the action would be unsafe under the mission policy and decision-relevant state. Let `B` be a finite, complete interface summarizing how permissible environmental changes enter the retained conditional evidence model. Write the joint nonnegative masses

    a_b = P(U=1, B=b, e),       s_b = P(U=0, B=b, e).

Let `G` be the event that a *trusted atomic finality sink* actually accepts and commits precisely this action. With respect to the authenticated, current conditional model, define

    u_b = P(G | U=1, B=b, e),     v_b = P(G | U=0, B=b, e).

Both are genuine frequencies/probabilities under the model; they are NOT assumed equal. The guard may accept some unsafe worlds because safety is only partially observable, even when it correctly rejects every known stale epoch. We require that whenever `G` occurs, all changes relevant to the truth of `U` between evidence snapshot and commit are precluded by the complete sink/epoch/effect-binding mechanism. Otherwise the proof concerns the wrong state time and cannot certify the effect. We also require actual effect paths are mediated: signed tokens alone are not complete mediation.

An admissible change of interface prior multiplies these joint masses by `lambda_b>0` but leaves the *conditional* unsafe/safe masses and the guard's two acceptance probabilities unchanged. This covers changed priors over B, not changed sensors/policies/guard implementations. The model permits arbitrary correlated evidence and shared noise inside each B stratum.

Three distinct **operational claims** should not be conflated:

1. **Selective effect risk:** `P(U=1 | e, G) ≤ δ`, the actual fraction of unsafe executions among effects that pass the guard.
2. **Unsafe execution propensity:** `P(G | U=1, e) ≤ ξ`, the probability of committing in an unsafe state.
3. **Safe execution availability:** `P(G | U=0, e) ≥ α`, the probability a genuinely safe action can commit rather than being blocked/deferred.

The first is conditional on committed effects. The second and third are class-conditional. They are not equivalent to a guarantee of no false denials or a deterministic zero-harm policy. The user/institution sets `δ, ξ, α`, rather than the optimization program inventing acceptable risk levels.

## 2. The sharp guard-selection theorem

**Theorem A (selection-adjusted risk; sharp).** Let `p=P(U=1|e)∈[0,1]` and assume `P(G|U=0,e) ≥ α>0`. Make NO assumption on `P(G|U=1,e)` other than it is a probability. Then

    P(U=1 | e,G) ≤ p / [p + (1-p) α].                  (A1)

For each `(p,alpha)` with `0<p<1`, equality is attained by a guard with `P(G|U=1,e)=1` and `P(G|U=0,e)=alpha`; hence the bound is best possible under these assumptions. For `0≤δ<1`, evidence acquisition is uniformly sufficient to ensure post-guard risk ≤δ precisely when

    p ≤ (δ α)/(1−δ+δ α).                              (A2)

If `α=0`, no nontrivial positive `p` implies a subunit postselection risk. When `p=0`, a zero-risk guarantee is immediate whenever an effect occurs.

**Proof.** Bayes gives `p u/[p u+(1−p)v]` with `0≤u≤1`, `v≥α`. It is increasing in `u` and decreasing in `v`, yielding (A1). Set `u=1,v=α` for equality and solve (A1)≤δ for p to obtain (A2). This is elementary conditional probability; the significance is the required correction when carrying an authority certificate through a guard.

**Exact counterexample.** At the evidence snapshot, `p=1/10`. A correct freshness guard passes all unsafe states (`u=1`, because they never trigger an epoch change) and half of safe states (`v=1/2`, because some benign operations update the epoch). The actual unsafe proportion *among committed effects* is `2/11>1/10`. Neither signature validity nor completeness of change detection prevents this selection effect.

**Corollary A3 (availability-adjusted safety margin).** If the mission requires post-effect selective risk `δ=1/10` and the implementation guarantees conditional safe throughput only `α=1/2`, the pre-effect risk must be no more than `1/19`. This is a tight requirement under worst-case guard selection. It is not a safety claim for an implementation that has not measured and certified α.

## 3. Robust effect-time authority under prior drift

Let the current authorized model be reweighted by an arbitrary positive interface prior vector `lambda`. For any given λ,

    R(λ) = [Σ_b λ_b a_b u_b]/[Σ_b λ_b(a_b u_b + s_b v_b)],
    F(λ) = [Σ_b λ_b a_b u_b]/[Σ_b λ_b a_b],
    A(λ) = [Σ_b λ_b s_b v_b]/[Σ_b λ_b s_b].

These respectively measure selective unsafe risk, unsafe execution propensity, and safe execution availability. Assume strictly positive a_b and s_b for these three ratios; supports with zero masses require separate deletion/zero conventions, never hidden divisions. Assume gate-passed mass in every considered interface stratum is positive.

**Theorem B (exact robust triple certificate and counterexample).** Suppose the admitted source changes form an independent rectangular box of positive weights `L_b ≤ λ_b ≤ H_b`. For limits `δ`, `ξ`, `α`, define

    c_b = (1−δ) a_b u_b − δ s_b v_b,
    d_b = a_b(u_b−ξ),
    e_b = s_b(v_b−α).

All three operational claims hold for **every** permitted source drift if and only if

    Σ_b [H_b c_b if c_b≥0 else L_b c_b] ≤ 0,          (B1)
    Σ_b [H_b d_b if d_b≥0 else L_b d_b] ≤ 0,          (B2)
    Σ_b [L_b e_b if e_b≥0 else H_b e_b] ≥ 0.          (B3)

Each test takes O(|B|) exact rational comparisons and arithmetic once the conditional masses are supplied. If any inequality fails, choosing its indicated endpoints returns an **admissible source-prior vector witnessing the violation**. These are checkable *primal* counterexamples and *dual* bound certificates. Precomputing complete interface masses may itself be exponential in the underlying graphical-model treewidth or separator cardinality; the O(|B|) statement does not hide that cost.

**Proof.** For a positive denominator, R≤δ iff Σλ c≤0, F≤ξ iff Σλ d≤0, and A≥α iff Σλ e≥0. Linear functions on a rectangular box are maximized or minimized at independently selected corners, exactly as displayed. Conversely, a failed support-function bound supplies a violating λ. No conditional independence of sensors is needed. QED.

**Theorem C (two-scalar all-prior invariant).** If λ can take all positive values without finite upper/lower caps, the sharp robust selective effect risk and worst safe availability are

    R_max = max_b [a_b u_b/(a_b u_b+s_b v_b)],
    A_min = min_b v_b.

This follows since the first expression is a weighted average of the slice risks and the second a weighted average of the safe-side guard pass rates; arbitrary positive reweighting can concentrate on any single slice. Their pair `(R_max,A_min)` is a sufficient exact *decision-invariance* certificate for any δ,α across all such prior changes. An analogous third scalar `max_b u_b` certifies the unsafe-effect propensity ξ. Reconstructing the exact posterior under every possible new prior generally requires more information; see PR #586's earlier identifiability theorem.

**Theorem D (exact joint change radius).** Under symmetric independent relative perturbations `λ_b∈[1−tρ_b,1+tρ_b]`, `ρ_b∈[0,1]`, `t∈[0,1)` and initially passing safety and availability, the largest *safety-and-availability* invariant radius is the minimum of

    t_risk = (−Σ c_b)/(Σ ρ_b |c_b|),
    t_avail = ( Σ e_b)/(Σ ρ_b |e_b|),

clipped to the positivity domain `[0,1]`, with zero denominator meaning the corresponding radius is unconstrained. The unsafe-commit cap adds the analogous `t_false = (−Σd)/(Σρ|d|)`. This is the exact source-change tolerance, not a Lipschitz approximation. A failed bound returns an adversarial corner.

## 4. Cost optimality and why information and enforcement must be co-designed

For a fixed trusted finality sink and calibrated finite observation model, let a policy choose sequential tests, deferred/rejected decisions, and permit attempts conditioned on their outcomes. The optimization objective includes

    C_total = E[observation cost + cache repair + verification cost
                + attempted guard cost + enforced revocation/repair cost],

subject to the selected institution's risk and availability constraints at **effect time**. For the unrestricted finite model, enumerating complete policy trees gives an exact optimum by definition. The previously developed Bellman/occupancy-LP algorithms (PR #585) are more efficient representations under their assumptions; do not advertise enumeration or linear programming as a new invention. The new required check is that every effect-time terminal is evaluated *after* conditioning on trusted guard acceptance and supported source changes, not at the earlier evidence snapshot.

**Exhaustive numerical construction (two sensors).** Fix p=1/10, finality guard u=1 and v=1/2, thresholds δ=1/10, ξ=1/4, α=7/20. Two independent conditional noisy evidence options are:

- Sensor A costs 1, reports a green/pass signal with probabilities `P(A=green|unsafe)=1/4` and `P(A=green|safe)=3/4`.
- Sensor B costs 3, with corresponding probabilities `1/10` and `9/10`.

All effects **still** require the finality guard. The optimizer enumerates every deterministic two-test binary decision tree, including deferred/denied leaves; no sensor may be read twice. There are exactly 74 policies. Seven satisfy all three constraints. The unique lexicographically selected minimum-cost policy is: read A; attempt the guarded effect only on A=green; defer otherwise. Its expected *additional evidence acquisition cost* equals 1. The postselection unsafe risk on its permitted branch is `2/29≈6.897%`, the unsafe-world commit frequency is `1/4`, and the safe-world commit frequency is `3/8`. A guard-only strategy fails the 10% selective-risk limit (`2/11≈18.18%`); a perfect-check baseline could achieve risk zero at a stipulated cost of 4, but is more expensive. The mandatory effect-time gate fee is held fixed/outside this example's evidence-cost objective; do not claim this is an all-in lifecycle cost result.

**Indistinguishability/cost lower bound for this toy.** Any feasible policy cannot permit at the root because the first effect-time test would have risk 2/11>1/10. It cannot deny without testing because safe availability would be zero. Therefore at least one paid sensor is necessarily read. The cheapest cost is 1, which the constructed policy attains. Complete policy-tree enumeration separately verifies no cheaper contingent policy; this is a narrow exact lower bound, not a new general complexity theorem.

**Pure complementarity.** Our modular examples (PR #583) establish that individually zero-information signals can jointly enable cheap certification; therefore greedy single-step mutual information is not a valid general cost-optimal acquisition operator. This is a motivating counterexample, not a new proof of general POMDP algorithms.

## 5. Connection to Q2 / structural influence without invalid transfers

The separately Lean-certified unrestricted degree-two product influence theorem (merged PR #564 and receipts) states that nontrivial variance in a bounded Efron–Stein degree-two product source cannot hide from *every* coordinate. It can support structural observability and identification of candidate sensing coordinates **when its source and degree assumptions apply**. It does not identify the optimal sensor, determine mission-conditioned epistemic sufficiency, preserve observations under dependency, or prove effect-time execution safety. Do not infer any such statement from the Q2 coefficient.

The theorem's position in the dissertation is foundational, not a black-box implication to autonomous authority. The bridge is an explicit source-matched mission predicate and a verified evidence model, followed by the decision and finality certificates of Sections 2–4. The program's original evidence-complementarity examples establish why local influence alone is insufficient for optimal acquisition.

## 6. Executable assurance architecture and claim-to-code boundaries

    Mission M + current policy P + exact action a
         |                      protected provenance roots
         v                             |
    Change-impact / factor dependency graph
         |                             |
         +--> conditional separator masses, source/epoch digests
         |                             |
    Acquire cheapest mission-relevant evidence (Bellman/LP/mincut where valid)
         |
    Certify THREE effects: committed selective risk, false commit, safe availability
         |              + declared interface-prior robustness box
         v
    Prepare action-bound, version-bound, short-lived permit
         |
    Effect-time trusted finality sink checks action identity / policy epoch /
    dependency version / revocation / replay / current state and atomicity
         |
    [accept + effect]  OR  [deny/defer + repair/reacquire evidence]
         |
    Signed, independently replayable outcome/decision evidence

The *trusted boundary* is substantial. A cloud signature check or audit log does not by itself guarantee complete mediation, path integrity, or an atomic check-and-effect transition. PR #576 and existing execution-finality papers correctly make these premises explicit. Any real-system deployment requires independent proof or tests that every side-effecting path is mediated, that all decision-relevant changes advance the protected version, and that the guard cannot be bypassed or race with effectuation.

**Three types of work and ownership.** (1) Mathematical: exact conditional and robust risk certificates (this note). (2) Computer science: verification algorithm, source factor graph, authenticated cache and effect-time guard (existing components plus integration). (3) Systems engineering: calibrate observation/latency/control models and measure operating cost and availability on mission-representative faults. None substitutes for another.

## 7. Proposed source-matched experimental program (NOT yet executed)

Starting testbed: the Tennessee Eastman Process simulator and source-matched published fault cases already designated for NIGHTFALL. Keep the process simulator's training/test fault identities and action admissibility rules distinct from authorization controls. Implement a *sandboxed actuator* that will reject stale policy epochs, altered commands, replays and unauthorized alternate service paths; do not control any physical plant.

**Pre-register metrics:** (i) unsafe committed effects / all committed effects (selective risk), (ii) unsafe effect probability conditional on unsafe plant states, (iii) fraction of mission-safe requested effects actually committed (availability), (iv) evidence and recomputation cost, (v) time between mission change and valid recertification, (vi) effect-time guard latency P50/P95/P99, (vii) guard path/bypass coverage, (viii) source-model calibration residual and conditional independence violations, (ix) certificate replay pass rate, and (x) model drift over the 21 published faults. Report denominators and zero-denominator cases; a reported zero observed failure is not proof of zero risk.

**Compare five baselines:** (A) static approval only; (B) signature/freshness guard with naive pre-guard posterior; (C) full rerun after each change; (D) change-local cache repair with unadjusted risk; (E) proposed joint, selection-adjusted evidence-and-finality synthesis. Declare test-time and cost-equivalence assumptions for each baseline. A clean holdout and independent source-matched fault replay are necessary before cost-performance claims.

**Attack matrix:** stale but signed evidence; missing dependency edge; guard cancellation conditioned on hidden unsafe state; benign state churn causing systematic selection; correlated noise; forged factor/channel digest; altered action parameters; retry/replay through a different sink; out-of-order epoch propagation; asynchronous effect race; permit reuse; policy revocation between check and effect; deliberate prior shift to a risk-maximizing separator corner; and monitoring delay under saturated arrivals. Include a negative control in which a guard reports fresh but a bypass path commits; fail the deployment claim, even if mathematical risk checks pass.

## 8. What is proved, what is only checked, and what remains

- **Analytic theorem:** A, B, C, D and the small instance's cost lower bound, under exact finite source and trusted-effect assumptions.
- **Independent exact rational checks:** 900 heterogeneous robust 3-criterion instances, 1,800 change-radius comparisons, 1,000 sharp selection-bound instances, and an exhaustive 74-policy optimization; all passed as recorded in the immutable source receipt. These are finite adversarial regression checks, not universal theorem proofs.
- **Not Lean-checked:** this new joint theorem and its soundness application to an actual source/guard implementation.
- **Not established:** global originality, peer review, calibrated noisy physical sensors, current trustworthy source impact closure, unbypassable cloud/plant effect path, bounded queueing delay, or realistic safe-operating-cost improvements.
- **Current novelty prospect:** the explicit end-to-end *three operational semantics* under changed priors and informative guard selection, with exact proof-or-counterexample certificates that can be checked at the authorization boundary, as an integrated systems assurance method. The component probability and mincut/decision-tree techniques are known. Human prior-art specialists should attack this claim against selective-risk calibration, runtime safety filters, policy finality, incremental certification and credal-network sensitivity.

## 9. Immediate next decisive transition

First formalize in Lean only the finite sign-support rule (B1–B3) and the sharp guard-selection theorem (A1–A2), where a nonauthor proof check is tractable. Separately build an independent effect sink in the TEP sandbox and demonstrate that it cannot be bypassed by direct actuation, asynchronous retries, or stale capabilities. Then add empirical calibration of `u_b,v_b` with confidence intervals. Without a truly verified effect sink and calibrated channel laws, the mathematics does not confer trustworthy authority.

**Publication authorization:** none inferred. Remain a research draft. Credit prior art and collaborators. Versioned superseded assumptions are retained above instead of being overwritten.
