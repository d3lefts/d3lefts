# Coupled Evidence: Mission–Change Separation and Pure Information Synergy
### A source-matched seed theorem for certified human–AI systems engineering

**NIGHTFALL research note, version 0.2 — 13 November 2026**

**Scientific status:** The deterministic separation below is proved and exhaustively checked for r=2,3. Its mechanism is elementary and related to known task-conditioned sensing and test-cover methods. The noisy generalization reuses a previously derived, restricted trusted information-cover theorem; external proof and novelty review remain outstanding. This note **does not claim a world-first landmark result** or an empirical human–AI performance gain.

## The question

When can a human's mission specification, an AI's information-acquisition policy, and an independent verifier collectively reduce the **minimum trusted evidence** needed to recertify a changing engineering system? What happens when either mission context or authenticated change provenance is absent?

The target is source-matched capability: no unpriced stronger oracle, no AI self-attestation, and no assumption that an AI-generated explanation constitutes independent evidence.

## System model

Let r >= 2 and I = [r] x [r]. A previous authenticated version establishes that all components are safe. An engineering version change may alter only components in one column J_j = {(i,j): i in [r]}. The human mission t requires safety of one row S_t = {(t,j): j in [r]}. The unchanged-row guarantee is externally authenticated. In the current version, each unit-cost trusted sensor reads one Boolean component exactly. A zero-error authorizer must accept the all-safe world and reject any world with an unsafe component in S_t, consistent with the declared change scope.

A pre-acquisition information class m specifies whether the mission t and/or change column j is known *before* any trusted current-version reads. Remaining metadata is revealed after acquisition, before the final decision, when no further reads are allowed.

For each m let P(m) be the set of (t,j) pairs still possible, and define the required uncertainty set

    R(m) = UNION_{(t,j) in P(m)} (S_t INTERSECT J_j).

The read-count objective is the number of trusted component reads along the all-safe execution. The sensor interface, physical state, and per-read prices are identical across all four architectures; only the *timing and integrity of metadata* differ. Metadata production, attestation, and infrastructure costs must be separately charged in applied comparisons.

## Theorem 1 (exact mission–change separation)

For every pre-acquisition information class m, the minimum all-safe read count of any zero-error adaptive policy is exactly |R(m)|. In the r x r model, the four minima are:

| Mission before sensing? | Manifest before sensing? | Minimum reads |
|---|---|---|
| No | No | r^2 |
| Yes | No | r |
| No | Yes | r |
| Yes | Yes | 1 |

Consequently, the ratio of the optimum with neither item of context to the optimum with both is exactly r^2, and the ratio to either single-context design is r. These separations hold for every r>=2 and thus yield an unbounded family.

### Proof

Fix m and the all-safe world. Every i in R(m) belongs to S_t intersect J_j for at least one pair (t,j) consistent with m. Construct a second current-version world in which only component i is unsafe. That world is consistent with the same prior certified version and selected change scope. Unless the acquisition policy reads i in its safe-world execution, its sensor transcript is identical in those two worlds, and after the metadata revelation its decision cannot be correct in both. Thus every i in R(m) must be read along the all-safe path. For a randomized policy with zero error, the same statement holds with probability one. This proves the lower bound |R(m)|. Reading every component in R(m) is sufficient: once (t,j) is revealed, the verifier checks precisely S_t intersect J_j using those current-version results and reuses authenticated prior evidence for unchanged components. This gives the matching upper bound. Under row and column supports, R(m) is respectively the whole array, one row, one column, or one cell. QED.


## Theorem 2 (pure mission–configuration information synergy)

The preceding row/column model gives useful savings from either cue alone. The more decisive architecture uses a *reconfigurable routing rule* in which the relevant component is not a separable intersection of a fixed task and a fixed change scope. Let I = Z_r, let mission T and system configuration A be independent and uniformly distributed in Z_r, and let the sole mission-critical component be

    K(T,A) = (T + A) mod r.

Each trusted current-version sensor reveals one component's safety status at unit price. A zero-error authorizer must correctly decide whether the mission-critical component is safe after any previously hidden metadata has been revealed, and may purchase reads only before revelation. Then the minimum all-safe trusted read counts are

| Metadata received before sensing | Minimum trusted reads |
|---|---|
| Neither T nor A | r |
| T only | r |
| A only | r |
| Both T and A | 1 |

Thus neither input alone reduces evidence cost at all, whereas the joint inputs yield an **r-fold** improvement. The information-theoretic statement is exact:

    I(K;T) = I(K;A) = 0,  but  I(K;(T,A)) = log_2(r) bits.

**Proof.** For a fixed T=t, varying A over all r possible configurations ranges K over every component. The same holds when A is fixed and T varies. Hence if either input is hidden, every component is a possible mission-critical target. Under the all-safe world, skipping a component yields a transcript identical to a one-fault world where that component alone is unsafe; therefore all r reads are necessary. If both T and A are known, exactly one component can be critical, and its single read is necessary and sufficient. Under independent uniform T and A, conditioning on either individual input leaves K uniform; conditioning on both determines K. QED.

This is **pure joint informational synergy**, in contrast to the diminishing marginal cost savings of the intersecting row/column example. XOR-style information synergy is classical; we do not claim it as a new information-theoretic discovery. Its operational use is to identify a falsifiable engineering *coupling mechanism*: mission knowledge alone or configuration data alone can be worthless for deciding which source evidence to acquire, while the authenticated combination is decisive.

**Critical trust condition.** Both T and A must be authorized/authenticated. Incorrect configuration information can redirect the single read away from the truly relevant component. This theorem does not establish that the human is the only possible source of T or AI is the only possible consumer of A; it proves a property of the information architecture, not the personal superiority of particular agents.

## Noisy and costed extension (conditional on existing restricted theorem)

Suppose trusted group q costs c_q and returns separately identifiable, independently noisy component observations with known bias 0 < beta_i < 1. Put d_i = beta_i log((1+beta_i)/(1-beta_i)). For A subseteq I, define the fractional information cover

    kappa(A) = min_{x_q >= 0} SUM_q c_q*x_q
       subject to SUM_{q: i in G_q} x_q >= 1/d_i for every i in A.

Under the fixed-state, group-independence, authenticated-version, and conditional error contract in the research dossier, and provided metadata is not usable before its declared revelation time, the previous sequential-testing argument yields

    C_delta(m) = kappa(R(m))*log(1/delta) + o(log(1/delta))

for the all-safe expected cost, with the error guarantee holding for each admissible metadata continuation. The lower bound follows by comparing the all-safe world to each single-component unsafe alternative and applying the stopped-transcript KL inequality. A sequential likelihood-ratio schedule matching the fractional-cover optimum provides the upper bound. This is **not** a new proof of that result, and no new independent Lean certificate is asserted.

With singleton unit-cost channels of common bias beta, kappa(A) = |A|/d. Hence both the row/column r^2:r:r:1 and the routed r:r:r:1 leading-coefficient ratios persist for each fixed r, subject to the exact source and independence contract.

## Integrity boundary and failure case

A current-version change manifest must be independently authenticated, not merely reported by the AI. If the actual changed column is j=1 but the AI states j=0, an authorizer checking only the single purported intersection may accept even when the true mission-critical component in column 1 is unsafe. Likewise an untrusted task description cannot be promoted to authoritative mission scope without a human-authority contract.

Old certificates for unchanged components cannot simply be treated as perfectly correct if their original validity was probabilistic. Any applied repeated-version guarantee must account for old errors, policy reuse, optional stopping, adversarially chosen updates, dependence shifts, and verification of source provenance.

## Independent finite checker

The attached script `coupled_assurance_checker.py` contains distinct symbolic and brute-force signature routes. It checks all 25 row/column metadata contexts at r=2,3 and all 131 routed/XOR metadata contexts at r=2,3,4,8, verifies both exact optimum formulae, and exercises a counterfeit-manifest counterexample. Its machine-readable result is `checker_results.json`. The checker is evidence for the stated finite models only, not historical novelty or deployed safety.

## How this becomes an ambitious systems-engineering thesis

**Research target:** Generalize the pure-synergy construction beyond algebraic routing and jointly optimize mission-context revelation, sensing, human intervention, independent attestation, and revalidation on *compositional systems with dependence and bounded verification resources*. Seek a theorem giving a provably improved upper bound and a same-interface lower bound, with a practical certificate checker.

**New result required for a landmark claim:** A structural result whose optimal cost depends on an engineering invariant (such as an authenticated interface separator) rather than the total twin state size, with correlated/noisy sensors, recurring updates, and quantified human-AI control flow. A mere reinterpretation of task-conditioned sensing, XOR information synergy, set cover, dynamic verification, or side information is insufficient.

**Cheapest decisive study:** Implement a modular digital twin with a pre-registered task family, trusted source adapter, authenticated change manifests, an AI scheduler, and a separate read-only validator. Compare four metadata-timing architectures under identical physical sensors. Measure true acquisition, computation, attestation, false-authorization risk, and evidence-revalidation costs. First use exact synthetic instances to expose model errors; then test on real facilities/equipment with institutional oversight.

**Admission framing (USA):** A thesis-based M.S. in Systems Engineering is the appropriate initial route, given the published provisional 2.5 GPA criterion and the user's reportedly strong GRE results. The project fits USA faculty interests in AI agents, digital twins, MBSE, mission engineering, and V&V. Eligibility and faculty supervision require official confirmation; no admission or supervision is asserted.

## Prior art and sources checked 13 Nov 2026

1. Zhang & Xu, *Certified Task-Conditioned Active Observability*, arXiv:2609.28520 (2026), https://arxiv.org/abs/2609.28520. Major subsumption risk for task-dependent observer complexity.
2. Gonzalez et al., *Toward a science of human-AI teaming for decision making*, PNAS Nexus (2026), https://pmc.ncbi.nlm.nih.gov/articles/PMC12983458/. Broad complementarity framework.
3. Ko & Lin, *Human-AI Collaboration for Multi-Line Task Adjustment Using Local Large Language Models and a Digital Twin*, arXiv:2609.29061 (2026), https://arxiv.org/abs/2609.29061. Propose-verify-decide workflow.
4. Carwehl et al., *Parley+: Uncertainty Reduction in Self-Adaptive Systems*, ACM TAAS (2026), doi:10.1145/3746234. Cost-aware adaptive sensing.
5. *ACCESS: Assurance Case Centric Engineering of Safety-Critical Systems*, Journal of Systems and Software (2024), doi:10.1016/j.jss.2024.112034. Dynamic assurance/change impact.
6. University of South Alabama, Systems Engineering programs and admissions, https://usade.southalabama.edu/colleges/engineering/se/phd_admissions.html; official bulletin https://bulletin.southalabama.edu/programs-az/engineering/systems-engineering/.
7. University of South Alabama College of Engineering research interests, https://www.southalabama.edu/colleges/engineering/research-keywords.html.
8. NIGHTFALL, *The Convoluted Costs of Knowing — Systems Engineering v4.0*, internal research contract (13 Nov 2026), and *Safety-Decisive Evidence: Oracle-Matched Bounds, Certificates and Revalidation*, internal York dossier (13 Nov 2026).

**Stop rule:** If existing task-conditioned observability or sequential-testing results imply the proposed structural extension at identical source, trust, and cost contracts, present it as an engineering transfer rather than as a new theorem. Demand independent review before public originality or landmark claims.