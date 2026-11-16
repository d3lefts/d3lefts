# Commonwealth OS — Proof Passport mathematical soundness ledger v0.3

**2026-11-15. Status:** conditional finite-model theorems plus source-different executable audits. **Not** a Lean certificate, human-independent review, verified cryptographic voting protocol, legal opinion, deployed reference monitor, or production assurance. Authorship: NIGHTFALL research direction; AI-assisted derivation and implementation.

## Research contract and what is actually established

Objective: define a Decision-to-Effect Democratic Assurance Proof Passport whose *technical* statement is sound relative to a complete, truthful finite-world semantics and an atomic, completely mediated effect sink, while identifying irreducible legal, ballot-integrity, human-agency and equality assumptions.

Feasible set: a finite nonempty set of current, same-epoch possible worlds; deterministic read-only named queries with positive integer costs; a fixed effect and Boolean legally-authorized predicate defined in an externally reviewed jurisdiction adapter; a real current world belonging to the modeled possibilities; single linearization-point effect commit with complete mediation and a unique effect-ID register. We never infer real-world statutory authority from a model predicate.

Closest checked external antecedents this session: reference-monitor complete mediation and tamper-proofness (Schneider, Cornell reference monitor chapter); proof-carrying authentication and the assurance-case gap between proof and implementation (Chaki et al., *Assurance Cases for Proofs as Evidence*); classical decision-tree certificate complexity/set cover; EAC's 2025 E2E evaluation process; ElectionGuard specifications; and *Computational Jurisprudence: Verifiable Law for Machine Societies* (2026). This is a scoped synthesis, not a priority claim. Links below.

Best verified construction: Theorems P1–P4 below, with executable finite reference checker and source-different audit of 3,108 cost-certificate instances and 529 predicate/guard perturbations, plus explicit indistinguishable legal-world, stale-check, and replay fixtures. These counts are test executions, **not** theorem proofs or real-system certifications.

Remaining gap: no deployed atomic middleware; no complete effect inventory; no formalized positive law; no independent election-security proof; no cryptographic validation of ballots; no authenticated source provisioning; no quorum/roster protocol verification; no proof assistant compilation; no independent specialist review; no demonstrated confidentiality/coercion resistance, operational liveness, informed agency, or effective political equality.

Novelty threshold: a mathematically nontrivial lower/upper bound for fully coupled changing democratic authority and evidence cost beyond classical set cover, reference monitoring, proof-carrying authorization, and existing recertification work. **No claim meets this threshold yet.**

## 1. Typed sources, semantics and non-goals

Distinguish **fact/authority** (what legally and actually holds) from **evidence** (what a supplied record says). The latter may be authenticated but mistaken. Externally verified or attested facts include institution, exact proposal, legally operative voting rule, authoritative electorate, quorum, motion result, fiscal and rights constraints, appeals, effective dates, stays and delegated power. At each transaction a trusted coherent snapshot supplies their current versions and truth values. The model cannot resolve contested statutory interpretation.

For jurisdiction J, action x and epoch e, let W_e be a nonempty finite set of worlds consistent with independently authenticated current evidence and validated jurisdictional constraints. Let w* in W_e be the actual world. Let A_J(w,x) mean that executing x is allowed at w by the *correct* legal and procedural interpretation. Q is a finite set of named deterministic observations q:W_e→O_q with c(q)>0, and a transcript h={(q,o_q)}. Let W_e(h)={w∈W_e:∀(q,o)∈h, q(w)=o}. Signed cached observations may restrict W_e only after a trusted transfer/invariance argument and authenticated common epoch; changed unproven claims must be discarded. No result here establishes that w*∈W_e in an actual deployment.

Four **non-interchangeable** passport classes: (i) cryptographic electoral correctness, (ii) externally attested legal/procedural authority, (iii) empirical informed-agency and effective-equality findings, and (iv) operation-level checked effects. Empirical agency/equality must never be inferred merely from formal acceptance of a ballot or a Boolean input.

## 2. Theorem P1 — robust finite-world soundness and exact nominal certificate cost

For fixed x and a nonempty W_e(h), define Certify(h,x):=∀w∈W_e(h), A_J(w,x). If actual w*∈W_e(h), Certify(h,x) implies A_J(w*,x) by universal instantiation. An empty consistency class is **rejected**, not treated as vacuously true.

Fix nominal w0∈W_e with A_J(w0,x)=true. For each unauthorized w∈W_e define D(w)={q∈Q:q(w)≠q(w0)}. Among deterministic, perfectly sound policies accepting w0, with query cost evaluated *only on w0's accepting path*, the exact optimum is

    kappa(w0)=min_{S⊆Q} Σ_{q∈S} c(q),  subject to S∩D(w)≠∅ for every w with A_J(w,x)=false.

If any unauthorized w has D(w)=∅, kappa(w0)=+∞ (no such correct policy). Otherwise the minimum exists for finite Q.

**Proof:** Along any accepting path of a sound policy on w0, list the distinct queries S (repeated query reads cannot help deterministic static observations with positive costs). If S fails to meet D(w) for some unauthorized w, that world's complete answers on the accepting path equal w0's. The deterministic policy accepts w, contradiction. Hence S is a cover and its cost is ≥ the minimum. Conversely, query any cheapest hitting set S and accept only if all answers match w0; every unauthorized world differs somewhere on S, so no unauthorized world is accepted, and w0 is accepted. This construction attains the minimum. An adaptive decision tree cannot improve the fixed nominal-path optimum. QED.

P1 is classical zero-error certificate complexity / weighted hitting set expressed for governance. It makes no assertion about globally optimal *expected* adaptive cost or completeness on every authorized world. No absence of evidence can be silently promoted to legal permission.

**Minimal witness:** w+=(ballot=1, legal=1), w−=(ballot=1, legal=0), with only q_ballot observable. Both worlds yield identical ballot evidence but require opposite decisions; D(w−)=∅. Any tally-only passport that accepts w+ must also accept w−. Legal evidence must be introduced or the checker must abstain.

## 3. Theorem P2 — coherent compositional assurance

Suppose a passport has predicates A_i(w,x) covering, e.g., verified tally, lawful procedure, legal authority, financial/right constraints, and effect scope, with A_J(w,x)=AND_i A_i(w,x). On one **same nonempty set** W_e(h),

    ∀w∈W_e(h), AND_i A_i(w,x)  iff  AND_i (∀w∈W_e(h), A_i(w,x)).

**Proof:** finite conjunction and universal quantification commute, directly in both directions. QED.

Each component's claimed scope, jurisdiction, decision, proposal digest, rule version, authority source, and epoch MUST be unified before combination. An isolated proof over W_i does not establish the joint theorem if its W_i differs or its assumptions are incompatible. Signatures alone do not create common-world evidence, sound adapters, or legal truth. The 'and' rule is an elementary logical fact, not a novel composition theorem. If one component is unknown, conflicted, or unverified, joint approval fails closed.

## 4. Theorem P3 — conditional effect-time soundness and replay exclusion

Fix a sequential transition system whose only way to commit a relevant effect x is a trusted sink. The sink atomically reads the actual coherent current state s_t, checks a pure Permit(P,s_t,x) built from correctly interpreted and faithful predicates, confirms x.effect_id is unused, and in the SAME indivisible transition appends a commit event and consumes x.effect_id. Initial log and consumed-ID set are empty.

Then at every reachable state: (a) each recorded event (x,t) has a corresponding passport P with Permit(P,s_t,x)=true **at that event's linearization point**; and (b) no effect identifier appears twice.

**Proof by induction on sink transitions:** initially both claims are vacuous. A rejected request changes neither log nor consumed-ID set. At an accepted request, the atomic predicate and nonmembership test hold; that transition appends exactly one event with its witness and adds its previously unused ID. Earlier event witnesses are statements about their historical commit points and remain true. QED. Complete mediation lifts this log invariant to every in-scope physical effect; absent complete mediation it says nothing about bypass effects. P3 is reference-monitor induction, not novelty.

This is a **safety** result. It neither proves that a valid legitimate request eventually completes nor preserves authority *forever* after commitment. A subsequent repeal cannot retroactively falsify the historical time-indexed predicate. Concurrency requires a proven linearizable database/effect transaction or a protocol replacing this atomic abstraction; Python's sequential example does not provide one.

## 5. Theorem P4 — stale-check impossibility without transaction protection

Suppose an effect authority may be revoked between a policy read and the effect commit, and there is no trusted mechanism to prevent such an intervening change, atomically validate the actual state at commit, or establish a stable authorization invariant. Consider two executions identical through the final policy read; in the first authority persists until commitment, in the second it is revoked afterward but before commitment. The observer has an identical transcript in both. Any mechanism that proceeds with the commit based only on that stale transcript must commit in both; it therefore violates authority in the second. QED.

A cryptographic timestamp, signed earlier ballot, matching cached epoch or fast network response does **not** remove this impossibility. Practical solutions require atomicity/linearizability, validated leases whose guarantees cover the effect, or a trusted equivalent. When those fail, fail closed.

## 6. Correct change-aware recertification semantics

After an authenticated change Δ, first compute a sound **overapproximation** W_{e'} of all possible current worlds. Retain an old evidence claim only if a trusted, authenticated contract proves it unchanged **for all possible current worlds** (or its current value is actually re-established). Revalidate the passport by P1 against W_{e'}(h'). The minimum *additional* deterministic cost on a fixed nominal world then has exactly P1's hitting-set form, but with the already trusted, transferable observations incorporated in the baseline consistency set and with the current queried facts priced. No global claim that syntactic dependency-graph reachability is minimal, or that previously signed evidence is automatically transferable, is justified.

The previous NIGHTFALL source-derived min-cut and threshold-tree theorems apply ONLY under their DAG/local-fault and disjoint-subtree contracts. Those are not universally valid models of constitutional law, contested authority, or human preference. Do not import their optimum into live governance by analogy.

## 7. Executable evidence and independent counterexample plan

Files: finite_model.py (reference checker / bounded optimal certificate), independent_audit.py (separately written dynamic-programming oracle and adversarial fixtures), audit_receipt.json (counts and toolchain). Run with Python 3.11+ using the command python3 independent_audit.py from this directory. The auditor compares exhaustive Boolean safety-mask cases through 3 bits and 128 deterministic 4-bit safe masks, all positive costs in {1,2}, plus direct guard perturbations and explicit legal/timing counterexamples. It tests equivalence of two different exact optimization algorithms. It does **not** certify universal math, human review, legal truth, or cryptography.

Open proof/engineering gates: (1) pin an institution-specific legally authorized semantics and responsible reviewers; (2) adopt separately audited E2E electoral verification and ballot secrecy/coercion controls; (3) formally verify the actual transactional implementation, including effect bypass and read/write races; (4) verify correct role/eligibility and quorum proofs; (5) independently assess privacy, accessibility, empirical agency/equality; (6) compile any Lean/TLA+ implementation-level proof and obtain non-author audit. Stop binding deployment on any confirmed bypass or authorization mismatch.

## 8. Prior-art / reference anchors (not claims of source-independent review)

- F. B. Schneider, Cornell security notes, reference monitor and complete mediation: https://www.cs.cornell.edu/courses/cs5430/2026sp/paper.chptr.enfMech.refMonitor.pdf
- Chaki, Gurfinkel, Wallnau, Weinstock, *Assurance Cases for Proofs as Evidence*: https://ntrs.nasa.gov/api/citations/20150004720/downloads/20150004720.pdf
- U.S. EAC, E2E Protocol Evaluation Process (2025-12-23): https://www.eac.gov/voting-equipment/end-end-e2e-protocol-evaluation-process
- ElectionGuard specifications and verifier responsibilities: https://electionguard.vote/spec/
- *Computational Jurisprudence: Verifiable Law for Machine Societies* (2026): https://www.mdpi.com/1999-5903/18/8/437
- Existing NIGHTFALL source-derived exact recertification (v0.2): /research/nightfall/2026-11-compositional-recertification/THEOREMS_AND_PROOF_AUDIT_V02.md

## 9. Status conclusion

P1–P4 are explicitly scoped analytic arguments with exact finite executable corroboration. The *passport mathematics within that declared abstraction* is sound subject to its listed assumptions. A proof passport does not yet certify real binding elections, legality, complete mediation, the absence of coercion, or the public launch of Commonwealth OS. Those remain independent, substantive proof obligations; without them, issue only DEMONSTRATION/ADVISORY artifacts.
