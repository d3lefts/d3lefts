# NIGHTFALL — Authenticated Change-Local Recertification with Dependent, Noisy Evidence

**Research checkpoint:** 2026-11-15 UTC. **Version:** v0.2. **Status:** finite-model analytic optimality theorems with independent exact certificates; **not** Lean-checked, human-refereed, source-calibrated, or deployed. **Global novelty:** not established. Maintains continuity with [NIGHTFALL PR #583](https://github.com/d3lefts/d3lefts/pull/583), which solves a noiseless independent modular-gate subclass by a min-cut reduction.

## Research contract

- **Objective:** compute the minimum expected price of retaining, denying, or renewing mission authority when latent agent states and sensor errors may be dependent, and reuse older evidence only when its authenticated conditional meaning survives a change.
- **Feasible set:** a *finite static* complete-world space Ω and a known, normalized rational joint law μ; fixed binary mission predicate S(ω); noninvasive tests t with finite outcomes and rational nonnegative acquisition costs; each available test used at most once; bounded test count. All potential test errors, including their common causes, are part of the same complete world. Repeated noisy tests are represented by distinct, jointly distributed outcome slots. A currently valid, authenticated cache is conditioned into μ; only unchanged conditional messages may be reused.
- **Two error specifications (distinct):** (A) **pathwise posterior:** every authorizing terminal history has P(unsafe|h)≤δ, and every denying terminal history has P(safe|h)≤η; (B) **population conditional:** P(authorize|unsafe)≤δ and P(deny|safe)≤η. Neither entails the other at the same numerical thresholds. Mode B permits policy randomization.
- **Strongest external reference checked this session:** finite POMDP belief-state Bellman optimality and constrained POMDP occupancy LP (AAAI 2015); junction-tree messages (Oxford notes); FASE 2026 incremental recertification; SLSA v1.2 provenance. See §9. These operations are not claimed as new mathematical algorithms.
- **Construction / bound:** exact Bellman recursion and a checkable value-function lower-bound table (mode A); exact history occupancy LP and its dual (mode B); unchanged-separator message reuse identity; conditional cryptographic cache validation. A source-matched small model supplies independent exact replay and one exact nontrivial global-LP primal-dual example.
- **Limitations:** exponential history space in general; finite horizon, static latent truth and correctly specified joint law; authentication is conditional on trust anchor, source hashes, correct change-impact closure, sensor semantics, clock and revocation. No mechanism to infer a trustworthy physical model from signature alone.
- **Independent audit:** `audit_independent.py` enumerates actual contingent policies for small models; `check_receipt.py` independently recomputes all 549 Bellman values from source inputs; `global_risk_lp.py` verifies exact primal and dual; `cache_attestation.py` verifies Ed25519 signatures and negative controls; `test_negative.py` attacks the receipt and dependence assumptions.
- **Stop rule:** publish the finite theorem and durable verifier, but do not call the general uncontrolled real-world problem solved without validated dynamics/observations, operational certification, independent expert review, and full bibliographic novelty comparison.

## 1. Complete-world representation of correlated noise

Let Ω be a finite space whose elements contain the true hidden state, mission truth, and a **joint vector** of possible observation outcomes. We do *not* assume that test results are independent after conditioning on the physical state. For example, two tests can share the same unobserved error bit N, and their joint likelihood is represented without approximation.

An observation history `h=((t1,o1),...,(tk,ok))` means that each test `ti` returned `oi`. Because tests are noninvasive and their outcomes pre-sampled in ω, its order can be discarded. Let μ(h)>0 denote the mass of compatible worlds and `p_h = μ(unsafe,h)/μ(h)`. A cached noisy observation is simply another correctly authenticated condition in h; using the *old posterior* after the prior changes is forbidden.

The representation covers *arbitrary finite dependence*: if two noisy observations share a latent cause, include that cause or their joint outcome table in Ω. It also covers arbitrary static misclassification rates given by μ. It does **not** cover an agent changing hidden state *because* tests are administered; that requires a controlled state-transition model/POMDP.

## 2. Exact optimality under per-decision posterior constraints (Theorem A)

Let R(h) be the not-yet-used tests. For rational `0≤δ,η<1`, define available zero-cost terminal actions only when their *conditional* failure risks meet threshold. Otherwise, tests have nonnegative costs `c_t` and reveal `o` with probability μ(o|h,t).

\[
V(h)=\min\left(\left\{0:p_h\le\delta\right\}\cup
                  \left\{0:1-p_h\le\eta\right\}\cup
  \left\{c_t+\sum_o\mu(o\mid h,t)V(h\cup\{(t,o)\}):t\in R(h)\right\}\right).
\]

An empty minimum means infeasible (+∞). If an exact gold test is available and correct, feasible termination is assured. **Theorem A:** `V(h)` equals the minimum expected additional evidence cost of every finite adaptive policy that meets the conditional errors on *every* positive-probability authorized/denied history. A deterministic optimum exists. Proof: induction on the number of remaining tests. Conditioning on the first action decomposes any policy's cost into its immediate cost plus conditional costs of the remaining subproblems; the induction hypothesis lower-bounds each child. Selecting the minimizing action and recursively attaining the child's bound constructs a matching policy. As all costs and masses are rational, every computed value is rational.

**Certificate:** A table containing `μ(h)`, `p_h`, `V(h)` and all action values at every reachable history is a checkable Bellman lower-bound certificate. Each legal action's computed value is ≥`V(h)` and the selected action attains equality. `check_receipt.py` recomputes the joint probability model from scratch and checks these statements, rather than trusting the search implementation.

**Caveat:** `P(safe|deny history)≤η` does NOT imply `P(deny|safe)≤η`. Under the exact cached-z=0 example below, the latter is `3/16` even though η=`1/10` pathwise. The two notions must never share an unlabeled risk field.

## 3. Exact optimality under *global* two-sided error constraints (Theorem B)

The operational constraints instead may demand:

\[
\Pr_\pi(\mathrm{authorize}\mid\mathrm{unsafe})\le\delta,
\qquad
\Pr_\pi(\mathrm{deny}\mid\mathrm{safe})\le\eta.
\]

For each positive-mass history h and available action a (including terminals A/D), define nonnegative occupancy `x_{h,a}`: the probability the verification policy reaches history h and takes a. Let `p_{h,t,o}` be its exact observation transition probability and `r=()` the initial cache-conditioned history. The finite linear program is

\[
\min_x \sum_{h,t} c_t x_{h,t}
\]

subject to

\[
\sum_a x_{h,a}
=\mathbf 1_{h=r}+\sum_{(g,t,o):g\cup\{(t,o)\}=h}p_{g,t,o}x_{g,t},
\]

\[
\sum_h p_h x_{h,A} \le\delta\Pr(\mathrm{unsafe}\mid r),
\qquad
\sum_h (1-p_h)x_{h,D}\le\eta\Pr(\mathrm{safe}\mid r),
\quad x\ge0.
\]

When test outcomes are static and independent of query order *given the complete world* (they may still be mutually dependent), equivalent histories are safely merged by their observed test-value set. The graph is acyclic because each test may be used once.

**Theorem B:** This finite rational LP has exactly the same optimum as the minimum expected evidence cost over all history-dependent, possibly randomized recertification policies meeting both *global* error constraints. Proof: every policy induces occupancy flows by the law of total probability, and its expected cost/error rates equal the linear objective/constraints. Conversely, each feasible flow defines at every reached history a randomized decision distribution `x_{h,a}/Σ_b x_{h,b}`; the flow equalities reproduce the original state visitation probabilities by induction on history length. Thus the LP is exact in *both directions*. Standard finite LP duality supplies a matching lower-bound certificate.

**Important:** Mode B is a different optimization from Theorem A. With additional pathwise requirements, simply remove prohibited terminal-action variables from the LP. Without randomization, add integrality constraints or solve a finite contingent policy search; do not assume the LP's fractional optimum is achievable deterministically.

### Exact globally constrained example with a hand-checkable dual

Let S be a uniform safe/unsafe bit. A noisy test Y matches S with probability `3/4`, costs 1; a perfect gold test costs 5. Both global class-conditional error budgets are `1/8`. An optimal policy flips a fair independent private coin: with probability `1/2` it uses gold and returns the correct answer; otherwise it uses the noisy test and outputs Y. It costs `(5+1)/2=3` and each global class-conditional error rate is `(1/2)*(1/4)=1/8`.

To prove optimality *against every adaptive randomized policy*, define total joint wrong-decision mass `R = P(A∧unsafe)+P(D∧safe)`. The exact Lagrangian first-action recursion gives

\[
\boxed{\mathbb E[\mathrm{cost}] +16R\ge 5.}
\]

At the initial state, deciding immediately incurs weighted error `16*(1/2)=8`; first using gold incurs cost 5; first using noisy Y incurs cost 1 plus at least `min(16*(1/4),5)=4` for either outcome, so at least 5. The two global constraints imply `R≤(1/8)(1/2)+(1/8)(1/2)=1/8`, hence cost ≥`5−16/8=3`. Equality is attained by the policy above. No deterministic policy can satisfy both `1/8` budgets without using gold first, because one terminal classification after Y generates joint error 1/8 in one class, exceeding its allowed 1/16. The optimal deterministic cost is 5. `global_risk_lp.py` checks this exact primal/dual and a numerical LP as a separate sanity test.

## 4. Exact **interface-conditioned reuse** theorem (Theorem C)

Let the current model factor into changed and unchanged sectors joined through a finite separator B:

\[
\mu_e(a,u,b,z_U,z_A)\propto
L_e(a,b,z_A)\;G(u,b)\;K_U(z_U\mid u,b).
\]

The changed part `L_e` includes all changed dependence factors, new model priors, and new noisy observations; the unchanged part `G` and cached sensor channel `K_U` are the same as when the old certificate was issued. The mission depends on U only through a finite sufficient interface statistic `t=τ(u,b)`:

\[
\mathrm{Safe}(u,a,b)=s(\tau(u,b),a,b).
\]

**Theorem C:** The conditional message

\[
\boxed{m(b,t;z_U)=\sum_{u:\tau(u,b)=t}G(u,b)K_U(z_U\mid u,b)}
\]

may be reused *without recomputation* when `L_e` changes, provided that `G`, `K_U`, separator identities, `τ`, and observation `z_U` remain unchanged and authenticated. The current posterior mission-safety probability is exactly

\[
\boxed{
\frac{\sum_{b,t,a}m(b,t;z_U)L_e(a,b,z_A)\,s(t,a,b)}
{\sum_{b,t,a}m(b,t;z_U)L_e(a,b,z_A)}.}
\]

Proof: substitute the factored joint law into the numerator and denominator and exchange finite sums; group terms according to `(b,t)`. **No independence of U and A in the marginal law is required**—dependence through B is fully retained. Further dependencies/shared noise crossing the partition must be included in B; otherwise factorization is false. The old *marginal posterior* `P_old(U|z_U)` generally is **not** reusable. The conditional message is.

**Complexity:** Constructing m costs O(|B||U|) finite scalar operations once, while each changed-side recombination costs O(|B||T||A|) instead of O(|B||U||A|), where T is the interface-statistic alphabet. This is an inference-certificate saving, not a guarantee that the complete adaptive planning problem is polynomial-time.

### Exact changing-prior witness

Let `P(U=1|B=0)=1/4`, `P(U=1|B=1)=3/4`, cached noisy `Z` equal U with probability 3/4, and observed `Z=1`. Change only `P(B=1)` from 1/2 to 1/3. The unchanged four-entry message `m(B,U;Z=1)` gives

\[
P_{old}(U=1\mid Z=1)=\frac34,
\qquad P_{new}(U=1\mid Z=1)=\frac{15}{22}.
\]

For a mission to authorize only if U=1 with declared posterior unsafe risk ≤3/10, blindly using the old posterior would authorize (wrong risk `1/4≤3/10`) while the current law makes its risk `7/22>3/10`. The old conditional message correctly produces the new posterior, so it avoids the error. `cache_attestation.py` and `audit_independent.py` check all quantities using fractions.

### Nonseparated shared-noise counterexample

If `Z=U⊕N` and a new measurement `Y=A⊕N` use the *same* latent noise N, then conditioning on Z and Y reveals `U⊕A` exactly. An interface that omits N (and incorrectly multiplies two independent noise channels) can report an error probability strictly different from the truth. The separator must include the shared nuisance cause or an equivalent joint likelihood factor.

## 5. Authentication and change-local dependency validity (Theorem D, conditional)

Define a cache receipt with explicitly bound: mission identity, evidence value, conditional-region identity, interface names, current trusted factor/channel digests, message digest, derivation version, issuance/observation epoch, expiry, certificate serial and signer key identity. A trusted issuer signs the canonical receipt. The verifier must independently establish:

1. Valid signature under an authorized public key (cryptographic origin/integrity);
2. Correct mission, region, separator and versioned semantics;
3. No expiration or revocation;
4. **Actual** source and observation-channel factor digests match trusted current source;
5. The current change-impact graph is complete and no unrecorded dependency alters the reused message;
6. If model changes cross the separator, include those common causes in the interface or reject reuse.

**Theorem D (conditional soundness):** Assume signature unforgeability, trusted issuer/key state, truthful sensor data, a complete authenticated change-impact description, and semantically correct factor/channel hashes. Then a receipt passing checks (1)–(6) denotes the same cached conditional evidence message as the current model; by Theorem C its use does not change the current posterior. **Authentication alone cannot prove any of the assumptions.** Changing only the *other* sector's prior leaves a valid conditional message but invalidates an old posterior or Bellman policy.

`cache_attestation.py` uses actual Ed25519 signatures and includes eight negative controls (tamper, expiry, factor change, channel drift, revocation, wrong mission, incomplete impact closure, untrusted key). Test keys are generated in-memory; do not reuse this code's trust configuration for production. The prototype is **not** an operational assurance service.

## 6. Independent exact benchmark

A complete world has five bits `(B,U,A,N,Z)`. The mission is `Safe=[A=U]`. `B` couples U and A with heterogeneous conditional laws; `N` is **shared** by two distinct noisy sensors `noisy_A=A xor N`, `noisy_B=B xor N` with `P(N=1)=1/4`; cached Z is a separate noisy reading of U with error probability 1/4. Six available tests have costs `(1,1,3,4,3,7)` with the final `gold` revealing mission truth exactly.

The exact independent-policy finite check covers 54 scenarios with different priors, cache conditions, posterior-risk budgets, and three-test subsets. The complete six-test Bellman certificate checks **549 distinct positive-mass histories** and reports:

| Initial cache condition | Pathwise δ=η=0 | Pathwise δ=η=1/10 |
|:--|--:|--:|
| no cache | 7 | 163/24 |
| Z=0 current cache | 7 | 601/104 |
| Z=1 current cache | 7 | 145/22 |

The prior probability of cached Z=0 is 13/24 and Z=1 is 11/24. Reading the cached Z before new testing reduces the *ex ante* minimum pathwise-mode cost from `163/24=1304/192` to `1181/192`, a saving of **41/64** evidence-cost units; the old cached message remains exactly valid when only the B prior changes. This is conditional on source-model and cache validity and does not account for the historical cost of obtaining the cache.

**Posterior-vs-global warning:** when Z=0, the pathwise-optimal policy's global false-denial rate among safe worlds is 3/16, larger than the 1/10 posterior-denial threshold. To enforce a global false-denial rate ≤1/10, solve Theorem B's occupancy LP (with or without Theorem A's additional per-history constraints), not Theorem A alone.

**Noise-dependence control:** conditional on actual `A=B=0`, the probability both noisy sensors return 1 equals `1/4`; a falsely independent-error model would assign `1/16`. The complete-world representation preserves this difference exactly.

## 7. Impossibility and validity boundaries

**Perfect-certification no-go:** If the prior gives positive mass to both safe and unsafe worlds, every available test's finite outcome transcript has positive likelihood under both classes (strict full-support noise), and only finitely many tests are permitted, *zero* posterior error for either terminal decision is impossible. Every nonempty positive-mass transcript admits both classes. Any zero-error, guaranteed-terminating system needs a genuinely separating test, valid structural proof, or an honest 'cannot certify' outcome (which must carry its own availability cost).

**Global risk limits differ from posterior limits.** Pathwise is strong conditional protection on each decision but need not bound `P(deny|safe)`. Conversely a global error budget can permit rare histories with posterior risk > the per-decision threshold. Do not substitute one for the other.

**Model uncertainty:** If an independently validated bound `TV(P_true(.|h),P_model(.|h))≤ρ(h)` holds for each history, then decisions require stricter **model** limits `P_model(unsafe|h)≤δ−ρ(h)` and `P_model(safe|h)≤η−ρ(h)` to guarantee true conditional limits δ and η. A bound on *unconditional* total variation alone is not automatically a bound on every rare conditional history. For fully observed mission truth (exact gold sensor), class uncertainty can collapse even if other latent variables are misspecified.

**Temporal authority:** when sensor acquisition changes agent state or the environment evolves mid-test, a static complete world is inadequate. A finite controlled POMDP (belief-state dynamics and revalidation) is the next gate, not a silent consequence of these theorems.

## 8. Certification ledger

- **Theorem A:** mathematical proof by finite induction; reproduced exactly by independent oracle and portable 549-state Bellman checker. No Lean kernel/human referee.
- **Theorem B:** standard occupancy-flow equivalence; exact rational hand primal and Lagrange dual for a nontrivial two-sided-error example, plus numerical LP corroboration. Full arbitrary-dimensional exact LP source certificate not constructed here.
- **Theorem C:** finite-sum identity with an independently checked changing-boundary-prior counterexample and exact reusable-message replay. No Lean/human reviewer.
- **Theorem D:** conditional cryptographic/source-validity guarantee; prototype Ed25519 negative tests pass. **No trusted deployment** or formally proved infrastructure assumptions.
- **Novelty:** none of the standard Bellman, LP, cached junction-tree message, or cryptographic attestation tools is claimed to be originally invented here. The synthesis may be useful, but global original priority requires a dated, theorem-to-theorem comparison and independent expert review.
- **Next strongest experiment:** factor a *real* agent/plant assurance graph, identify its minimal mission boundary, calibrate observation likelihood and dependence, and measure evidence/recertification cost with independently monitored change impact. Attempt exact Lean verification of Theorem C and the finite Bellman certificate checker, not vague 'superintelligence safety' certification.

## 9. Closest prior art checked in this session

- Finite-horizon POMDP belief-state optimality; Dujardin, Dietterich & Chades, IJCAI 2015, https://ijcai.org/proceedings/2015/366
- Constrained POMDP belief-state LP: Poupart, Malhotra, Pei, Kim, Goh & Bowling (AAAI 2015), *Approximate Linear Programming for Constrained Partially Observable Markov Decision Processes*, https://ojs.aaai.org/index.php/AAAI/article/download/9655/9514
- Junction-tree message passing and separator factorization: https://www.stats.ox.ac.uk/~evans/gms/_book/jt.html
- Incremental update in Bayesian networks: https://cdn.aaai.org/FLAIRS/1998/FLAIRS98-086.pdf
- *Analyses as First-Class Citizens in Model-Driven Development* (FASE 2026): https://doi.org/10.1007/978-3-032-22774-4_10
- SLSA v1.2 provenance and attestations: https://slsa.dev/spec/v1.2/
- In-toto bundle anti-replay considerations: https://github.com/in-toto/attestation/blob/main/spec/v1/bundle.md

Research directed by the NIGHTFALL project; AI-assisted construction and checking. Independent human review remains outstanding.