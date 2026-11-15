# The Price of Admission
## The Economical Limits of Mediating Superautonomy

**NIGHTFALL flagship research charter — v1.0, 2026-11-15**
**Research direction:** Devin J. Wright. AI-assisted source reconnaissance, theorem formulation and audit scaffolding.
**Status:** program pivot and preregistration, NOT a claim of an original theorem, completed scientific benchmark, or deployed operational guarantee.

### Mission

Determine the least unavoidable cost of deciding whether a high-capability autonomous agent may exercise a specific consequential effect, and the least-cost combination of trusted evidence, inexpensive screening, expensive independent auditing, hard action restrictions, time/freshness guards, and recertification that meets formally stated safety, legitimate-usefulness, and latency guarantees.

Superautonomy denotes autonomy beyond practical direct human supervision; it is a system-deployment regime, not a claim that every agent is literally superintelligent.

This supersedes the prior dissertation flagship orientation for future research allocation. Prior NIGHTFALL structural observability (Q2 and all-degree source change), exact finite recertification, GAC comparison, and source-bound authority service become proof components and candidate tools, not separate dissertations competing for priority.

### Strongest competing work checked this session

1. Hua, Baskerville, Lemoine, Hopman, Bhatt, Tracy, **Combining Cost Constrained Runtime Monitors for AI Safety**, NeurIPS 2025. Already optimizes monitor selection plus interventions under average budgets using likelihood-ratio methods. https://proceedings.neurips.cc/paper_files/paper/2025/hash/ed56a654ddb681841fdb2184463c253e-Abstract-Conference.html
2. Terekhov, Liu, Gulcehre, Albanie, **Control Tax: The Price of Keeping AI in Check**, ICLR 2026. Already connects monitor accuracy, strategy, auditing budgets and monetary expense. https://proceedings.iclr.cc/paper_files/paper/2026/hash/c8c352e9ff2c3eb8511c6a996cbd77b1-Abstract-Conference.html
3. Cunningham et al., **Cost-Effective Constitutional Classifiers via Representation Re-use**, Anthropic 2025. Finds cheap probes and two-stage screening cost advantages; explicitly does not establish adaptive attack robustness of the studied cheap first-stage models. https://alignment.anthropic.com/2025/cheap-monitors/
4. Williams et al., **How we detect frontier model misalignment**, OpenAI 2026-10-29. Documents low-cost activation screening, model-based reviews, independent investigation, random sampling of low-suspicion traffic, security telemetry and incident response. Some stages are asynchronous and should not be mistaken for permission to perform irreversible effects. https://alignment.openai.com/how-we-detect-frontier-model-misalignment/

A new monitor combination or empirical control-tax curve alone is not a discovery. The new target must be a stronger verified bound or operationally checkable guarantee relative to those works.

### Research problem

Let M be an autonomous mission, A its consequential effect interface, H an adversarially specified set of joint agent/environment/source histories, T a finite deadline or horizon, delta a global maximum permitted probability of ANY unsafe admitted effect, alpha a maximum legitimate-mission failure probability, and L a latency/availability requirement.

A policy pi may screen cheaply, request stronger independent monitoring, acquire authenticated outside evidence, restrict or repair an effect, recertify a stale source-bound claim, deny, or admit through an unbypassable trusted effect-time gate.

Define C_adm*(M,H,delta,alpha,L) as the infimum over such causal policies meeting the effect-safety, legitimate-completion, source-freshness and deadline requirements of their worst-case expected sum of screening, independent auditing, evidence gathering, verification, certificate repair, enforcement, delay and denial costs. Costs must include ALL trusted computations and invocations, not merely model-token expense. Every assumption about monitor calibration, statistical independence, strategic adaptation, source truth, and actual effect mediation must be declared.

A deny-everything policy trivially attains zero safety violations; consequently nontrivial bounds MUST require legitimate action availability or mission completion. Never claim unconditional safety from an asynchronous monitor.

### Initial necessary-condition lemma (classical baseline, NOT novelty)

Consider a single potentially irreversible effect, one safe history S and one unsafe history U with *identical* cheap-monitor observation distributions. The only way to distinguish them is a perfectly accurate independent trusted audit costing c > 0. No hard intervention, substitute safe effect or other external observation is available. Policies may otherwise grant or deny; the audit routing decision must depend only on cheap evidence and internal randomness.

Require Pr(grant | S) >= 1-alpha and Pr(grant | U) <= delta, where 0 <= alpha, delta <= 1 and alpha+delta <= 1. Let q be the probability of purchasing an audit, common to both worlds because the cheap transcript is identical. Let g be the probability of granting without an audit, also common to both worlds.

Then Pr(grant | S) <= q+g, Pr(grant | U) >= g. Therefore
   q >= 1-alpha-delta
and expected trusted auditing cost in either world is at least
   c(1-alpha-delta).
The bound is attainable in the explicitly stated model: audit with probability 1-alpha-delta, grant without audit with probability delta, and deny otherwise; when audited grant exactly in the safe world. This requires 1-alpha-delta >= 0. If admission is required with probability one in the safe world and unsafe admission is prohibited, every case must be audited.

For cheap-evidence distributions at total variation distance at most epsilon, an elementary bounded-function comparison gives the weaker necessary bound
   q_S >= max(0,1-alpha-delta-epsilon)
for the auditing probability under S. This is a hypothesis-testing indistinguishability consequence, not a novel information-theoretic theorem. It need not be tight for arbitrary distributions.

**Scope failure:** a trusted effect restriction that makes both histories safe, or a cheap authenticated source signal separating them, changes the admissible interface and can eliminate the auditing floor. This is a feature of the intended monitoring/control substitution analysis, not a contradiction.

### Cheapest decisive experiment already checked

For alpha=1/10, delta=1/100, c=100, exact rational exhaustive enumeration of every (audit probability, unaudited grant probability) on a 0.01 grid (5,252 candidates satisfying q+g<=1 before safety/usefulness tests) produced optimal q=89/100, g=1/100, audit cost=89 units. This agrees with the analytical lower and constructive upper bound. The arithmetic enumeration does NOT substitute for an independent proof.

The baseline is intentionally elementary. Its purpose is to rule out impossible claims that cheap, perfectly uninformative evidence can guarantee both high legitimate availability and low unsafe admission with no trusted audits.

### Stronger frontier (not yet proved)

Obtain matching, policy-class-independent lower and constructive upper bounds for MULTI-EPOCH adaptive adversaries whose actions change the distributions and validity of cheap-monitor signals and source evidence. Permit the defender to choose inexpensive screening, independent expensive monitors, hard effect restrictions, certificate reuse and recertification. Include service rates, queueing delays and an executable fail-closed effect gate. Show when cheap evidence and restricted capabilities are mathematically interchangeable with expensive monitoring, and characterize the irreducible trusted oversight floor.

A decisive novel result should cover a class not subsumed by Hua et al. or Control Tax, produce a nontrivial separation or complexity gain, and have a finite exact Lean/mechanized kernel plus independent actual-effect refinement evidence. We do NOT assume the theorem is new merely because these phrases co-occur.

### Independent adversarial audit protocol

A (construction) must state the policy space and exact objective before optimizing. B (independent critic), designed before seeing A's candidate, attempts to falsify via (i) cheap-signal manipulation and strategic evasion, (ii) hidden alternate effect paths and ambient credentials, (iii) stale source attestation and epoch ABA, (iv) correlated monitor errors and false assumptions of independence, (v) source churn and denial-of-service in audit queues, (vi) deferral/denial tricks that fake low cost by sacrificing legitimate availability, (vii) unaccounted verifier and physical-enforcement costs, and (viii) known equivalences to dual control, selective classification, budgeted inspection games and proof-carrying authorization.

Require exact independent checker with reproduced inputs and hashes for claims involving numeric optimality. A counterexample search cannot establish global optimality. Every source-to-service guarantee requires a direct refinement/coverage check; a Lean compilation alone is insufficient.

### Research order and stop rule

1. Recover published mixed-monitor benchmarks and price definitions; reproduce the NeurIPS 2025 benchmark at source-matched settings, rather than inventing a favorable baseline.
2. Define robust cost, attack and effect boundary semantics. Prove a first multi-epoch lower bound with an exact matching construction, not just existence of a minimum via well ordering.
3. Independently verify exact finite games with different code, then Lean-certify the strongest formal statement.
4. Measure real monitor costs (compute, queueing, token cost, human review, instrumentation), calibration deterioration under adaptive attacks, and legitimate workload availability.
5. Connect the certified policy to the existing NIGHTFALL protected-effect implementation, explicitly checking external source authenticity and absence of effect bypasses.
6. Undertake a dated prior-art and independent scholarly review before any claim of novelty or worldwide priority.

Stop polishing if repeated gains are beneath checker tolerance or attributable to evaluator flaws. Preserve failures, counterexamples and operator transitions. Do not represent this charter as publication or submit externally without human authorization.

### Discovery graph

Problem -> minimum cost of legitimate consequential admission under strategic uncertainty.
Representation -> adversarial history equivalence classes, typed authority/effect obligations, monitor outcome distributions, hard effect restrictions, source-version custody.
Mechanism -> indistinguishable unsafe/safe states force independent trusted audit or restriction; changes can invalidate cheap signals.
Operator -> robust hypothesis testing lower bounds, game Bellman synthesis, source-change recertification, exact effect-level refinement.
Construction -> monitor/guard/repair policy chosen jointly.
Certificate -> independent exact game checker, Lean scoped theorem, audited actual-effect trace and source provenance.
Limitations -> assumptions on adversary, monitor calibration, authenticated sources, complete mediation, latency and availability.
Transfer -> cloud agent tools, autonomous industrial-process controls, higher capability agents.
