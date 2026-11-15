# The Price of Permission — integration of NIGHTFALL's original-source theorem program

**Dissertation:** *The Price of Permission: The Economical Limits of Mediating Superautonomy*  
**Prepared:** 15 November 2026; revised integration v0.3  
**Purpose:** Transport earlier mathematical mechanisms into the flagship permission-economics manuscript, without promoting theorem proof to worldwide priority or to operational guard completeness.

## 1. A four-type admission contract

A consequential action is permitted only if four independently typed claims can be checked:

1. **Sensitivity / structural observability:** which inputs can affect the evaluated mission quantity, under which source law?
2. **Decision information / acquisition:** which available observations suffice to discriminate safe from unsafe admissible situations, and at what resource cost?
3. **Evidence continuity / lifecycle:** which acquired facts and proofs remain current after a change of law, model, mission or authenticated version?
4. **Effect authority / execution:** can every actual consequential effect be intercepted, checked against current authority and completed within the service deadline?

The stages are **not** equivalent. In particular, a coordinate may have high Efron–Stein influence while an exact read of that coordinate has *zero mutual information* with the mission safety predicate. This makes influence-only monitor placement an invalid general shortcut to minimum permission cost.

A useful typed certificate is

`PermissionCertificate=(mission, source, information, change-impact, version, guard, capacity, guarantee, checker)`.

Its entries are proofs with separate scope and provenance, not interchangeable numeric scores. The word *permission* is reserved for an effect crossing a trusted guard, not for a monitor producing an approval label.

## 2. The strongest original-source product theorem and its correct economic role

**Earlier NIGHTFALL result Q2 — original-product degree-two influence.** Let `p` be any finite independent product law with normalized nonnegative coordinate masses (zero atoms allowed), and let `f` be bounded pointwise by `B`, with Efron–Stein degree at most two under `p`. For original-source conditional-variance influence

`I_i^p(f) = E_p[(f(X)-E_p[f(X)|X_{-i}])^2]`,

our scoped pinned Lean declaration proves

`Var_p(f)^2 ≤ C_Q2 B^2 max_i I_i^p(f),`

`C_Q2=[2(1+sqrt(2))*sqrt(3)+48/25]^2≈105.741756923658.`

**Evidence:** [PR #564](https://github.com/d3lefts/d3lefts/pull/564); source-only named declaration `Nightfall.Observability.ActualSourceQ2105Terminal.actual_source_q2_105_unconditional`, pinned Lean 4.36.0-rc2 receipt [run #43671321904](https://github.com/d3lefts/d3lefts/actions/runs/43671321904), and [Proof Passport v15 #575](https://github.com/d3lefts/d3lefts/pull/575). Arbitrary finite length, heterogeneous zero-mass marginals, and unrestricted singleton components are included. Conditional sub-100 bounds are **not** included.

**Economic implication, precisely typed:** whenever `Var_p(f)>0`, at least one coordinate satisfies `I_i^p(f) ≥ Var_p(f)^2/(C_Q2 B^2)`. Thus a structured bounded function cannot conceal all variance from every source-coordinate *resampling perturbation*. This does **not** establish that a coordinate *observation* identifies a safe mission, that the coordinate is cheap, that a monitor is calibrated or that every physical effect is guarded. Those conclusions require additional theorems and measurements.

**Prior-art limit:** David Turturean's November 2026 Aaronson–Ambainis result treats bounded low-degree functions of fair Boolean inputs with a different general-degree variance exponent. NIGHTFALL's arbitrary-product degree-two, variance-squared statement is a serious candidate for an independent mathematical contribution, but exact subsumption by Grothendieck/decoupling and related literature still requires non-author review. A Lean certificate verifies the scoped statement, not global priority.

## 3. Exact bridge theorem: influence is not one-sensor information

**Theorem A (finite information–influence separation and permission price).** For any integer `r≥2`, draw independent uniform `T,A∈Z_r` and let `K=(T+A) mod r`, with binary mission predicate `f=1{K=0}`. Then:

`E f=1/r`, `Var(f)=(r−1)/r²`, and `I_T(f)=I_A(f)=(r−1)/r²` for original-source Efron–Stein influences;

`I(K;T)=I(K;A)=0`, `I(K;T,A)=log₂(r)`; similarly `I(f;T)=I(f;A)=0` despite both influences being positive.

Suppose a verifier, before a separately mandatory trusted atomic effect-time version guard, may exactly read `T` at cost `c_T`, read `A` at `c_A`, or directly test `K=0` at `c_D`, with all costs positive. Safe-path authorization must accept every safe state, reject every unsafe state, and be correct for all `r²` physically admissible states. Its exact minimum fresh-evidence-plus-guard cost is

`C_perm(r)=c_G+min(c_T+c_A,c_D)`.

**Proof.** Given either single input, the missing independent uniform input makes `K` uniform; thus one input read cannot distinguish any safe state from all unsafe alternatives, although changing it perturbs `f`. Two reads determine `K`; a direct gate test also determines `K`. Along any accepting safe path, absent a direct test, both individual reads are necessary. The separate trusted version guard costs `c_G`; either complete observation plan attains the bound. The variance/influence formulas follow by taking the conditional variance of a Bernoulli variable of success probability `1/r` for each fixed opposite input. Individual mutual information vanishes because each conditional `K` law is uniform. QED.

**Audit:** [`permission_bridge_exact.py`](permission_bridge_exact.py) independently enumerates all safe/unsafe transcript pairs and every instrument subset for 3,584 integer-cost settings (`r=2,...,15`), plus exact rational source variance/influence and pairwise conditional distributions. Ordered receipt SHA-256: `7e31b88a96cbfe9b757edcf7fd8fbf8af12730175994ba32516681b48da7c74f`. The proof is analytic and finite; the test is corroboration, not human review or Lean certification. Modular XOR/Latin-square synergy and weighted decision-certificate arguments have established antecedents: the novel claim, if any, concerns the **typed engineering composition**, not invention of XOR.

**Why this matters for monitors:** A monitor selected solely because an input has high perturbational influence may fail to provide any information about the mission decision. A cheap monitor whose observation function collapses safe and unsafe states cannot fix that by increasing model intelligence. Admission requires sufficient **jointly purchased evidence**, a source-authentic direct semantic test, or denial. The last alternative violates availability when legitimate safe actions must succeed.

## 4. A source-law-change test that forces separation of the four types

**Theorem B (exact support-vs-adversarial-source countermodel).** In Theorem A, replace the source marginal of `T` from uniform to the Dirac law `T=0`, while `A` remains uniform. Then `K=A`, so an `A`-only read identifies the mission predicate *on the support of the new probability law*. But the pointwise two-coordinate function `f(t,a)=1{t+a=0}` is unchanged, and its new canonical pair kernel is

`h^q_{T,A}(t,a)=f(t,a)−f(0,a)`.

This is pointwise nonzero for every `r≥2`. New-law Efron–Stein influence is `I_T^q(f)=0`, `I_A^q(f)=(r−1)/r²`. Despite this, if `T≠0` remains a physically admissible adversarial execution, a read of `A` alone **cannot** soundly authorize every safe world; an unsafe change of `T` is invisible. Reuse of the cheap supported-law certificate therefore requires an authenticated, effect-time-enforced invariant `T=0` (or equivalent fresh semantic checking).

**Proof.** Conditioning on the Dirac `T` makes `K=A` and `I_T^q=0`. Direct calculation of the new ANOVA double-centered pair yields `f(t,a)−f(0,a)`; it is nonzero off support. For `a=0`, nominal `t=0` is safe, while any nonzero `t` is unsafe and yields the same sole observed value `a=0`. Thus no `A`-only observer distinguishes those histories. A trusted effect-time test of `T=0` rules out precisely these unmodeled alternatives, provided it really mediates the effect. QED.

**Connection to our independently Lean-certified source-incremental theorem:** [SCIF PR #529](https://github.com/d3lefts/d3lefts/pull/529) machine-checks one-coordinate law replacement, degree-two preservation, algebraic pair-graph invariance, exact pair recentering and original-source influence updates (pinned [run #43640173972](https://github.com/d3lefts/d3lefts/actions/runs/43640173972)). The example above is an explicit consequence/interpretation, not a new claim that PR #529 certifies permission. Pointwise interaction support, probability-weighted influence, and physical possibility are three different objects.

## 5. Restore the remaining original NIGHTFALL results to their necessary proof roles

**Mission-quotient recertification.** In the earlier subgroup-safe change model with homomorphism observation map `L_S` and safe subgroup `H`, a fixed observation family is mission-sufficient exactly when `ker(L_S)⊆H`; the field/row-space version yields the corresponding linear criterion. Its exact finite cost problem determines *which distinctions must be purchased*. Its no-adaptivity conclusion requires the subgroup and homogeneous observation assumptions; it is not a claim about arbitrary nonlinear missions. An authenticated mission digest can substitute for complete latent reconstruction if its source and scope are real.

**Pure informational complementarity.** The two earlier finite examples in [PR #469](https://github.com/d3lefts/d3lefts/pull/469) show: (i) a mission-row and change-column metadata example with exact-read costs `r²:r:r:1`; and (ii) the modular routing theorem of Section 3 with exact-read costs `r:r:r:1`. These are distinct phenomena: operational cost savings interaction and pure Shannon synergy must not be conflated. They inform monitor bundles and authenticated context, not claims of globally first XOR mathematics.

**Posterior-actionable influence.** [PR #449](https://github.com/d3lefts/d3lefts/pull/449) gives a posterior-resampling identity and a finite-cost conditional observer with explicit state-coordinate, posterior-oracle and model-uncertainty expenses. It belongs in the *calibrated acquisition* subproblem, with oracle calls and source-model uncertainty priced rather than supplied for free. It does not certify arbitrary LLM monitor probabilities.

**Change-stable certificates and original-source drift.** The previous dependency-transversal paper gives an exact update-resilience criterion for hazards and dependent evidence under its completeness model. SCIF #529 shows how a one-coordinate **probability-law** change affects degree-two canonical terms and influences without rebuilding every source term. Do not merge probability-law recentering with authentication: an evidence item can remain mathematically computable while its signed dependency closure has become invalid. Evidence reuse must pass an authenticated, complete impact closure and version check.

**Finite joint optimal recertification.** The nominal-path theorem in merged [PR #576](https://github.com/d3lefts/d3lefts/pull/576) minimizes weighted observation and effect-time guard checks hitting all unsafe-history difference supports. The one-observation/one-guard subclass with structured setup fees has an exact min-cut and flow dual; the general cover is NP-hard. This is a cost lower bound for the **specified nominal accepting history**, not a theorem for all legitimate worlds, dynamic queues, or physical actuation.

**Semantic fencing and impossibility of invisible unsafe changes.** Named Lean declarations in [PR #554](https://github.com/d3lefts/d3lefts/pull/554), pinned [run #43668841941](https://github.com/d3lefts/d3lefts/actions/runs/43668841941), prove that a version-only fence is sound exactly when its guarded set intersects every permitted unsafe source-change support. If any unsafe change is invisible to all version counters, no version-only fence can be sound. The operational claim is explicitly conditional on honest, ABA-safe counters and complete effect-path interception.

**Two-clock margin and guard-fiber diameter.** *The Minimum Cost of Justified Action* supplies conditional author-analytic margin/freshness and adversarial source-fiber diameter bounds. They distinguish source-snapshot expected inference error from worst-case changes between evidence acquisition and actual effect. The two-clock transfer is **not** itself an end-to-end Lean-certified deployed guard theorem. Treat the margin bound as a sufficient observation condition, not proof of complete mediation or universal minimum cost.

**Time and capacity.** Draft [PR #593](https://github.com/d3lefts/d3lefts/pull/593) gives the exact finite synchronous-batch bound `M_T=min(N,gT,K+g(T−1),K+m(T−1))` for a one-slot deep-to-guard delay under stated cache/churn assumptions. This creates a strict separation between affordable *average* monitoring and timely *effect-time* admission. The bound is a classical finite-capacity construction, not evidence that production guard and monitor services meet its assumptions.

## 6. What the combined results actually establish about the economic floor

For the restricted modular mission of Section 3, with a mandatory disjoint guard charge and a single fresh, fully sound safe action, there is a **matching information-plus-enforcement cost floor** `c_G+min(c_T+c_A,c_D)`. The source-drift countermodel proves that reducing this cost by switching to supported-law `A`-only evidence is safe under a physically enforced support invariant, but unsafe if that invariant can change invisibly. The two-clock fence theorem identifies the needed check, and the capacity result adds a deadline feasibility constraint for batches.

For arbitrary systems, the prior theorems imply *separate* necessary conditions, not automatically an additive or multiplicative global lower bound. A monitor read can also support an effect guard, a cached certificate may be shared across actions, a risk-constrained policy may randomize, and a workload may contain dependent arrivals. Hence **no universal price-of-permission theorem follows by simply summing Q2, information, min-cut and capacity costs**. A fully coupled matching lower bound remains the dissertation's central open target.

The resulting research graph is:

`original-source structure (Q2) -> source-sensitive candidates`  
`mission quotient + complementarity -> sufficient information bundles`  
`SCIF + dependency impact -> fresh reusable evidence`  
`semantic fencing -> effect-time non-bypassable guard requirement`  
`queue/deadline + risk/availability -> feasible workload`  
`joint primal construction + matching adversarial dual -> Price of Permission.`

At each arrow there is a new contract. **A theorem at the previous layer is not a certificate of the next layer.**

## 7. Proof Passport and novelty ledger

| Claim | Strongest checked authority | Priority/status limitation | Value for the flagship |
|---|---|---|---|
| Arbitrary finite independent-product Q2 degree≤2, coefficient 105.7417569 | Strict named Lean 4.36.0-rc2, PR #564 / run 43671321904 | Worldwide novelty/subsumption not independently closed | Source-coordinate sensitivity lower bound under bounded structural model |
| One-coordinate original-law recentering and local influence updates | Strict named Lean, PR #529 / run 43640173972 | Algorithmic optimality, authentic versions and global novelty open | Mathematical repair rather than source-wide rediscovery |
| Semantic-fence hitting-set equivalence; invisible-change impossibility | Lean PR #554 / run 43668841941 | Real guard completeness, source counters and originality separate | Formal requirement for effect-time version mediation |
| Mission quotient / dependency transversals | Author analytic prior manuscripts, finite model checks | General nonlinear adaptive cases and independent review open | Identify precisely the evidence needed for mission decisions and reuse |
| Row-column and modular synergy | Exact finite constructions, PR #469 | Related to classical secret sharing / quotient routing | Show why cheap univariate monitoring can fail despite high influence |
| Joint nominal-path mincut and setup fees | Analytic + exact finite checker, merged PR #576 | Classical weighted cover/mincut; nominal-path scope | Matching cost floor in specified two-time cases |
| Posterior actionable influence and conditional observer | Analytic identities + exact checks PR #449 | Requires priced calibrated posterior oracle, limited optimality | Choose low-cost state evidence under epistemic uncertainty |
| Two-clock margin/freshness | Prior analytic work and finite checks | End-to-end Lean and deployed guard not established | Turn snapshot inference into a scoped action guarantee |
| Batch admission capacity | Exact finite construction + CI PR #593 | No source-matched physical/workload verification | Hard deadline feasibility and installed-capacity floor |
| **New Section 3–4 connection** | Analytic proof + 3,584-case exact arithmetic checker, this integration | XOR/conditional variance classical; no novelty promotion | Explicit non-implication among influence, observation and permission |

**Novelty threshold:** The mathematical originality of the Q2 and SCIF result families is plausible and deserves precise full-text prior-art review; machine checking establishes scoped validity, not historical priority. Classical XOR, set cover, max flow, Bayes and deadline scheduling must be credited. A publishable flagship advance requires either a *new* joint feasibility/price bound beyond its strongest neighboring prior model, or a source-matched, adversarially verified economic/availability improvement at an actual mediated effect boundary. Do not assert worldwide novelty from this integration alone.

## 8. Experiment implied by the integration

Use source-matched ControlArena IaC Fast offline effect-promotion as the first benchmark, Tennessee Eastman as a separate cyber-physical transfer test. Freeze three controlled arms: (i) cheap-monitor route using influence-based individual ranking, (ii) synergy-aware joint evidence/direct test with equivalent guard and queue, (iii) source-drift-aware cached evidence plus effect-time guard. Add a forged support claim (`T=0` without enforced version), a genuine authenticated support lock, an invisible source change, expired or mis-scoped cache, a direct provider-effect bypass, and asynchronous retry. Every arm is charged for monitor inference, evidence reads, source attestations, worker capacity, final guards, latency and failed legitimate actions. Verify both unconditioned error and risk **conditional on the committed effect**. The goal is a matched lower bound or measured strict cost reduction; synthetic examples alone cannot establish production permission economics.

**Independent audit contract:** an independent A model generates priced candidate controllers; B independently enumerates source/mission pairs and validates exact finite certificates; C compares every actual effect against the trusted effect inventory and source epochs. Record symbolic proof, verifier hash, file source, run version, admissible inputs, contradicted assumptions and next decisive experiment. No unverified operational guard or human peer review claim.

### Essential external predecessors

- Turturean (2026), *A proof of the Aaronson–Ambainis conjecture*, https://arxiv.org/abs/2611.09773.
- Hua et al. (NeurIPS 2025), *Combining Cost Constrained Runtime Monitors for AI Safety*, https://proceedings.neurips.cc/paper_files/paper/2025/hash/ed56a654ddb681841fdb2184463c253e-Abstract-Conference.html.
- Terekhov et al. (ICLR 2026), *Control Tax: The Price of Keeping AI in Check*, https://proceedings.iclr.cc/paper_files/paper/2026/hash/c8c352e9ff2c3eb8511c6a996cbd77b1-Abstract-Conference.html.
- Liu, Tyszberowicz & Beckert (FASE 2026), *Analyses as First-Class Citizens in Model-Driven Development*, https://etaps.org/files/2026/fase-2026.pdf.

**Attribution:** NIGHTFALL research direction and publication authority: Devin J. Wright. This integrated text, bridge lemma/checker, audit and editing were AI-assisted. Existing named theorems, published predecessors and independent implementation evidence must retain their own credits and provenance.
