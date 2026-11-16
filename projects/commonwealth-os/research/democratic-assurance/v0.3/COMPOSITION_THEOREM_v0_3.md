# NIGHTFALL / COMMONWEALTH — Democratic Assurance Composition v0.3

**Title:** Exact Change-Stable Election-Evidence Reuse, Joint Recertification Cost, and Anonymity-Compatibility Boundaries  
**Date:** 2026-11-15  
**Research direction:** Devin J. Wright / NIGHTFALL. AI-assisted mathematical formulation and independently implemented finite-model audit (two algorithms); no independent non-author mathematician, legal counsel, election specialist, or peer reviewer has approved the results.  
**Status:** Four elementary, explicitly proved finite-domain propositions; deterministic toy checks. Neither global novelty, real voting-system security, legal validity nor a joint human-agency/equality theorem is established.

## 0. Research contract

**Objective.** Replace DAP v0.2's conservative *all relevant epoch mismatches reject* rule by a precise, correct semantic test for reuse of authenticated election evidence after a change in the governing rule. For a portfolio of effects, characterize the exact minimum additional evidence cost under nonadaptive deterministic testing and explicit anonymity constraints, and establish the effect-time compositional safeguard.

**Domain and source assumptions.** A *fixed, finite, authenticated* eligible electorate; finite ballot configurations `B`; one immutable retained, accurate and authenticated transcript `T:B -> Y`; a genuinely authoritative new rule `lambda'` whose lawful effective date and applicability to the prior vote have been independently established; an action-authorization vector `F_{lambda'}:B -> {0,1}^m` that incorporates the relevant jurisdiction, election result, and effects; and a finite menu of available truthful deterministic additional queries `q_i:B -> Z_i`, with fixed nonnegative rational costs `c_i`. Queries can be run only if the institution possesses a lawful, secure means to obtain their outputs; encrypted ballots that are inaccessible do not create an oracle. All assertions are conditional on these prerequisites and ignore sampling or statistical inference.

**Public privacy convention.** A specified group `G` of legally equivalent voter permutations acts on `B`; permitted *public* queries are invariant under this action. This models *swap-invariance*, NOT coercion resistance, receipt-freeness, ballot secrecy against side information, or person-level political equality. For true production secrecy the **joint** released transcript must satisfy a suitable cryptographic privacy definition, including composition and auxiliary information.

**Strong external antecedents checked:** classical observation-factorization / sufficiency, weighted set cover, reference-monitor complete mediation, logically attested authorization (Sirer et al., *Logical Attestation*, 2011); EAC 2025 E2E verification process and 2018 National Academies election security discussion; *Revoked but Still Executable: Closing the Authorization-to-Effect Gap with Finality-Bound Revocation*, IETF Internet-Draft (September 2026, individual draft, not standard). See attribution section.

**Novelty gate.** No claim of a new general factorization, set-cover, authorization or privacy theorem. This is a **strictly stronger scoped DAP construction**: safe selective reuse, all-world multi-effect cost, and a privacy-compatibility condition absent from v0.2. An external mathematical novelty claim requires comparison with formal authorization/secure-composition work and a nontrivial separation that survives that comparison.

**Cost/stop rule.** Two independently coded finite algorithms must agree. Once the exact theorem passes a representative finite model, move engineering effort to the OS; refrain from additional variations unless a meaningful new proof obligation or counterexample arises.

## 1. Theorem DAP-CR1 — necessary and sufficient semantic reuse

Let `B` be finite, let `T:B -> Y` be the retained authenticated election evidence, and let `F:B -> {0,1}^m` be the authorization vector *under the verified applicable new rule*. A deterministic verifier `V:Y -> {0,1}^m` satisfying `V(T(b))=F(b)` for **every** `b in B` exists **iff**

`for all b,b' in B: T(b)=T(b') implies F(b)=F(b')`.

**Proof.** If a correct `V` exists and `T(b)=T(b')`, applying `V` to both sides gives `F(b)=F(b')`. Conversely, if the implication holds, define `V(y)=F(b)` for any `b` in the nonempty fiber `T^{-1}(y)` and define arbitrarily outside the image of `T`. Constancy makes `V` well-defined and correct on all `B`. QED.

**Interpretation.** The *old election data* need not be read again merely because the legal-rule version changed. If the new legally applicable rule depends only on already certified sufficient election evidence, re-evaluate it and renew the relevant legal/effect-time attestations. This does **not** say a new rule is legally permitted to alter a completed decision retroactively; that is an external legal predicate. Changes to the franchise, ballot validity or source correctness are outside the fixed-`B` theorem until re-modeled and attested.

## 2. Theorem DAP-CR2 — exact all-world, multi-effect nonadaptive recertification price

Assume a finite query menu `Q={1,...,n}` of truthful deterministic queries `q_i:B -> Z_i`, each with cost `c_i >= 0`. The verifier may purchase a *fixed subset* `S` of queries and then use `T` plus all `q_i, i in S`, to evaluate the entire vector `F` correctly for every ballot world. Define the finite conflict-pair set

`D = { {b,b'} subset B: T(b)=T(b') and F(b) != F(b') }`.

Then the **exact incremental acquisition cost** is

`kappa*(T,F,Q,c) = min_{S subset Q} sum_{i in S} c_i`

subject to, for every pair `{b,b'}` in `D`, at least one selected query has `q_i(b) != q_i(b')`. If no such `S` exists, the required information is unavailable and `kappa*=infinity`. Under additional privacy constraints restrict `Q` to public releases that meet the chosen privacy definition before computing `kappa*`.

**Proof.** If a selected portfolio leaves a conflict pair observationally identical, any verifier has one output on the common evidence but `F` requires two different values, contradicting correctness. Conversely, if the portfolio distinguishes all conflict pairs, `F` is constant on every fiber of the joint signature `(T,(q_i)_{i in S})`; apply DAP-CR1 to construct a correct verifier. Minimizing paid query cost over feasible portfolios proves equality, including impossibility. QED.

**Scope.** The cost covers *only* additional election-information queries. The authentic new law, effective-date determination, legal review, current authority, guard inspection, computation, appeals, and participation/inequality costs are neither zero nor included in `kappa*`. The theorem is for nonadaptive universal correctness, not optimal adaptive expected-cost decision trees. Selecting queries from a menu by brute force is exponential; the formula is a classical weighted cover reduction.

**Portfolio consequence.** Joint query portfolios can reuse evidence across multiple effects. For `F=(F_1,...,F_m)`, one can always take the union of per-effect feasible portfolios, giving `kappa*(F) <= sum_j kappa*(F_j)` when all use the same query availability and costs. The inequality may be strict. For `m` identical nonconstant action predicates and one shared sufficient query of positive cost `c`, the separate accounting totals `mc` while the joint query cost is `c`, an arbitrarily large multiplicative sharing factor as `m` grows. These are *technical evidence costs*, not overall democratic resource costs.

## 3. Theorem DAP-CR3 — anonymity-orbit compatibility (necessary condition)

Let a voter-permutation group `G` act on `B`. If retained public transcript `T` and every permissible public supplemental query `q_i` are invariant under this action, then an all-world correct public authorization verifier exists only if `F` is also `G`-invariant:

`F(g*b) = F(b)` for all `b in B`, `g in G`.

**Proof.** An invariant transcript supplies exactly the same information for `b` and `g*b`, including every permitted query. A correct verifier must therefore output the same authorization vector, so `F(g*b)=F(b)`. QED.

If `F` is not invariant, no additional query restricted to `G`-invariant outputs can resolve its authority correctly: `kappa* = infinity`. This is **not** an assertion that subgroup-count outputs are sufficiently secret in actual elections; a swap-invariant group aggregate can reveal an individual's ballot when the group is small, the tally is extreme, or auxiliary information exists. In particular, political equality and privacy require additional institutional/empirical and cryptographic tests.

**Example.** Four binary voters with total `T=sum b_i`. A rule `F=1{sum b_i>=3}` is invariant under all permutations, so no new ballot query is needed to change from a 2-vote threshold to a 3-vote threshold (assuming the new threshold legally applies). A rule `F=1{b_0+b_1>=1}` is *not* invariant under exchanges across group A `{0,1}` and group B `{2,3}`, so total-tally-only, full-swap-invariant public evidence is insufficient. If the lawful privacy equivalence group is only swaps *within* A and B, then an authorized group-A aggregate may resolve it, subject to a separate ballot-secrecy analysis.

## 4. Proposition DAP-CR4 — marginal privacy does not compose

Let `b` be a uniformly random individual's ballot conditional on a public two-voter tally of one yes vote. Let `r` be an independent fair bit. A public log publishes `M1=r`, another publishes `M2=r XOR b`.

For each `j` separately, `M_j` is uniformly random regardless of `b` (zero mutual information). Together `b=M1 XOR M2` is revealed exactly (one full bit). QED by direct distribution. This is the textbook reused-mask phenomenon and is **not novel**. Its relevance to DAP is that independently approved release policies for identity, election, AI assistance, and assurance receipts cannot replace one assessment of their *joint* ballot-privacy leakage.

## 5. Corollary — effect-time authorization composition

Suppose DAP-CR1 or DAP-CR2 supplies a correctly evaluated, authenticated authorization vector for the **lawfully applicable** rule and exact proposal/effect binding. Suppose a trusted sink completely mediates the modeled effects, reads a coherent current authority state and current legal source attestation atomically with effectuation, enforces the applicable action scope, revocation/stay state, and single-use effect IDs. Then by the original DAP-S1 induction, each committed effect has a witness of current lawful authority at its linearization point, and no ID commits twice.

**Critical qualifiers:** A valid election transcript is not a legal ruling; a cryptographic signature alone does not certify applicability, fairness or correctness of the record; no public election security claim follows from this finite model; external side effects that bypass the sink defeat the invariant. The corollary **imports** existing standard guarded-state-machine reasoning, not a new universal OS security theorem.

## 6. Finite demonstration and independent reproduction

Four binary voters (`2^4=16` worlds), an authenticated total tally, groups A and B with two voters each, six supplemental query types, exact integer costs:

- `a_any`: 3 units, whether A has >=1 yes;
- `a_all`: 3 units, whether A has 2 yes;
- `a_count`: 4 units, A's yes count;
- `b_count`: 4 units, B's yes count;
- `individual_0`: 2 units, named voter's ballot;
- `individual_1`: 2 units, named voter's ballot.

Allowed queries depend on a declared permutation-invariance group: all four voters, swaps only within each group, or no anonymity constraint. Under within-group permutation invariance:

- Changed overall threshold (`k>=3`): 0 additional election-query units.
- `A_any`: 3; `A_all`: 3.
- Joint `(A_any,A_all)`: 4 using `a_count`, versus 6 if the separately cheapest certificates are purchased independently: **33.33% modeled saving**.
- Named voter 0's ballot: infeasible with within-group-invariant queries; with no group restriction, 2 units.

Under full-voter permutation invariance all non-symmetric subgroup rules are infeasible from the permitted public query menu; a global tally threshold remains free of *additional election queries*.

**Primary implementation:** `semantic_reuse.py` evaluates the exact conflict-pair hitting condition.  
**Independent code:** `audit_semantic_reuse_independent.py` enumerates query portfolios and constructs observed-signature-to-rule lookup tables; it does not use the pair-cover computation as its oracle. It checked 165 rule×privacy-group instances and the four equally weighted masked privacy worlds, with exact equality. The two programs reuse declared ballot configurations and query semantics but use different decision algorithms. These tests are neither a mathematical proof nor an independent external referee; the formal arguments above are proofs of the stated finite-domain propositions.

Run in this directory:

```
python3 semantic_reuse.py
python3 audit_semantic_reuse_independent.py
```

The output `semantic_reuse_receipt.json` and checksums are included. `None` in receipt JSON denotes infeasibility, not a null price or zero cost.

## 7. Scientific consequences and OS implementation acceptance criteria

1. **Typed semantic law-change detector:** Do not invalidate all source-sound vote evidence solely because a rule version has changed. Check authenticated legal applicability and whether `F_new` factors through the retained verified transcript plus permitted new evidence.
2. **Privacy-preserving evidence boundary:** Enforce secrecy against the complete collection of logs/receipts and auxiliary data, not just separately audited components. Do not store identifiable personal voting choices in proof passports.
3. **Explicit partial knowledge:** If the rule is not determined by the accessible evidence, return `INDETERMINATE` or require additional authorized verification/revoting. Never fill missing facts using AI predictions or a fictitious ballot.
4. **Independent legal predicate:** New law's applicability to the old vote requires certified human legal process; semantic re-evaluation cannot grant retroactive authority by itself.
5. **Effect-time enforcement:** Commit only exact bound effects under current source versions and stays; verify all real consequence paths for complete mediation before any live deployment.
6. **Research gates:** Informal and empirical evidence for informed agency and effective equality remain independent mandatory requirements. No Boolean passport should claim to have proven these conditions for every voter.

## 8. Prior-art and attribution

- Classical factorization / sufficiency of observations, weighted set cover, group symmetry/invariance, one-time-pad mask reuse, reference-monitor composition: established mathematical/computer-security foundations, not NIGHTFALL discoveries.
- Sirer, de Bruijn, Reynolds, Shieh, Walsh, Williams & Schneider, *Logical Attestation: An Authorization Architecture for Trustworthy Computing* (SOSP 2011): https://www.cs.cornell.edu/fbs/publications/nexusSOSP.pdf
- EAC/NIST, *End-to-End (E2E) Protocol Evaluation Process* (December 23, 2025): https://www.eac.gov/voting-equipment/end-end-e2e-protocol-evaluation-process
- National Academies, *Securing the Vote* (2018): https://www.nationalacademies.org/read/25120/chapter/7
- Das, *Revoked but Still Executable: Closing the Authorization-to-Effect Gap with Finality-Bound Revocation*, September 2026 **individual Internet-Draft, not a standard**: https://datatracker.ietf.org/doc/html/draft-das-finality-bound-revocation-00
- NIGHTFALL *Compositional Recertification* (2026-11-13) already contains the single-world exact certificate/hitting-set characterization; NIGHTFALL *Change-invariant Authority* (2026-11-15) covers a different probability-prior-change class; the v0.3 result improves the DAP contract by offering a universal multi-effect **legal-rule semantic reuse** criterion with explicit anonymity constraints. No independent global originality finding has been made.

**Resulting decision:** The next research task is OS implementation, using these equations as executable acceptance properties; further pure-math optimization without a stronger concrete counterexample is lower leverage.