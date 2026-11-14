# NIGHTFALL Compositional Recertification — v0.2

**Proof-bearing research note (November 13, 2026, US Eastern).** Research direction: Devin J. Wright. AI-assisted construction, proofs, code and audits. **Truth status:** elementary mathematics verified by in-session source-independent finite enumeration; no Lean compilation, external referee review, physical test or originality certification. A number of component mechanisms are classical (Boolean certificate complexity, fault-tree logic, min-cut, information-cover linear programs, controlled sequential tests).

## 0. Research contract

**Target:** Minimize the number and cost of trusted *fresh-state* measurements needed along a nominal safe execution to reauthorize an interconnected, authenticated system. Seek exact source-to-system composition, matched lower/upper bounds, authenticated reuse, and no false authorization under the declared model.

**Access:** Sensors reveal named current-version Boolean fault flags in the noiseless experiments, at fixed positive costs; for the noisy extension, each action gives an identifiable finite-alphabet draw from one of two trusted kernels, fresh across rounds conditional on the static state. Trusted metadata, old signed certificates and verified gate semantics are distinct evidence sources. Their acquisition, formal-checking and human-review costs are **not** included in the current read-only optimality theorems.

**Acceptance:** A policy must accept the nominal safe world and never accept a permissible unsafe world (under the deterministic theorem); other safe states may lead to conservative rejection/abstention. The noisy hypothesis test has both safe false-reject and unsafe false-accept probabilities at most δ. Every accepted result concerns one authenticated stable epoch; absent an atomic version guarantee the claim changes.

**External competitors examined in this session:** Liu–Tyszberowicz–Beckert, *Analyses as First-Class Citizens in Model-Driven Development*, FASE 2026 (analysis slicing, sound and complete incremental recertification, DOI: 10.1007/978-3-032-22774-4_10); Zhang–Xu, *Certified Task-Conditioned Active Observability*, 2026, arXiv:2609.28520; Akbarzadeh–Samari–Nejati–Lavaei, *From Formal Methods to Data-Driven Safety Certificates of Unknown Large-Scale Networks*, 2025, arXiv:2508.09520; classical Boolean certificate complexity, monotone formula certification, fault-tree AND/OR decomposition. **Novelty threshold:** a source-preserving lifecycle result for shared interfaces and correlated, asynchronously changing observations beyond these established pieces. **Stop rule:** if the candidate reduces entirely to graph cuts or conventional certificate LPs, label it a scaffold, not a landmark discovery.

## 1. Source-derived path theorem from an actual local contract

Let G=(V,E) be a **finite DAG**; Δ⊆V authenticated changed roots; M⊆V mission outputs. Each subsystem has current-version flag x_v∈{0,1}, with x_v=1 meaning an active fault/violation. Let X_G be precisely the state vectors satisfying the *local no-spontaneous-fault contract*

    (L_v)  x_v = 1  implies  some parent u→v has x_u = 1, for each v ∉ Δ.

Change-source flags are free. The nominal world is x^0≡0, and a world is unsafe iff some m∈M has x_m=1. Only vertices in V_obs may be read, revealing x_v exactly, at cost c_v>0; all reads must refer to the same version. Previously valid certificates rule out any violation that violates (L_v) or arises from unspecified sources. Paths refer to directed paths from Δ to M; a cut must use eligible sensors. Uncuttable paths imply infinite all-safe zero-error authorization cost.

**Theorem A (source-derived min-cut equality).** The minimum total named-component read cost **along the nominal all-zero execution** for a verifier which accepts x^0 and rejects every permitted unsafe x equals the minimum weighted Δ–M vertex separator.

**Proof of system-level composition:** If x_m=1, follow an active predecessor using (L_m). DAG acyclicity forces this process to terminate; it can only terminate in Δ. Reverse the trace to obtain an all-active directed Δ–M path P. If a tested separator S is all zero, no unsafe x is possible; accepting is sound. Conversely, for **every** Δ–M path P, set x_v=1 exactly for vertices of P and x_v=0 everywhere else. For each non-source active vertex its predecessor on P is active; every other (L_v) is vacuous, so the path-only state is permitted and unsafe. If a nominal-run algorithm fails to test a member of P, its transcript agrees with the path-only unsafe state, violating soundness. Therefore its tested set hits every path. Weighting and minimization give equality. Any randomized zero-error algorithm obeys the same argument for almost every seed. □

**Quantifier caveat:** This lower bound depends on the permissive local relation allowing each path to occur alone. If physical interface equations constrain downstream faults more strongly, min-cut can be a strict overestimate.

**Boundary attack:** In a cyclic graph with source 0 disconnected from feedback pair 1↔2 and output 2, x=(0,1,1) obeys every predecessor-only contract and is unsafe despite no path from source 0 to output 2. A cyclic generalization needs grounded/least-fixed-point semantics, or a separately certified no-autonomous-cycle invariant.

## 2. General semantic information-separator theorem

Fix any finite set W_e of *current-version* worlds consistent with authenticated local subsystem/mission contracts and still-valid prior evidence. Fix nominal safe world w_0∈W_e. Trusted deterministic query q∈Q returns O_q(w), costs c_q>0. Define the observable difference support of a permissible unsafe world w as

    D_e(w) = {q ∈ Q : O_q(w) ≠ O_q(w_0)}.

**Theorem B (semantic cover / nominal certificate).** The minimum cost of a deterministic sound verifier accepting w_0 on its nominal transcript is

    κ_0(e) = min_{S⊆Q} Σ_{q∈S} c_q,
             subject to S∩D_e(w)≠∅ for every unsafe w∈W_e.

**Proof:** An unhit unsafe difference support produces exactly the nominal observation transcript and is accepted, contradicting soundness. Conversely, read the selected set S and accept only if all named observations match w_0; every unsafe world differs on a selected query, so no unsafe world is accepted. □

This is a classical weighted certificate/test-cover representation, not an original new complexity measure. Its value is the precise **source-level bridge**: local contracts define the admissible worlds, signed prior certificates restrict them, and actual sensing capabilities define their distinguishability supports. The graph path-cut result is an integral, polynomial-time special case when path-only worlds are admissible and all unsafe worlds contain an active path. In general this cover can be more expensive to calculate, and topology by itself does not determine its value.

### A concrete unbounded graph-only failure

Let k source faults x_1,...,x_k feed a mission output y through **the same k incoming wires**. If the authenticated gate contract is

    OR: y = 1 iff at least one x_i=1,

then all k individual sources must be checked before accepting the all-zero world. If instead the gate is

    AND: y = 1 iff every x_i=1,

then checking **any one** zero source is sufficient, while any unqueried-path graph cut still requires k vertex sensors. The graph, source sets, mission, named sensors and prices are identical. Thus topology-only minimum cuts can overestimate necessary evidence by factor **k**, even for acyclic networks.

For a general threshold gate y=1 iff Σ_i x_i ≥ q, q∈{1,...,k}, the unsafe minimal supports are exactly the q-subsets. A set S hits every q-subset iff its complement has size <q, giving:

    κ_0(threshold(k,q), unit leaf costs) = k-q+1.
    κ_0(threshold(k,q), weighted leaf costs) = sum of the cheapest k-q+1 leaf costs.

This family interpolates OR↔AND while leaving the wiring unchanged. Therefore graph topology is **not** a sufficient statistic for optimal recertification when local gate semantics change. This contrast is a structural warning, not a novelty certificate; it is ordinary monotone Boolean certificate complexity.

## 3. Exact recertification recurrence for compositional threshold **trees**

Let the mission condition be the zero output of a finite rooted tree of threshold gates. A node v with k_v disjoint child subtrees is unsafe (value 1) exactly when ≥q_v children are unsafe. Its leaves are independently assignable Boolean fault variables. At the current authenticated epoch, a leaf i has read cost c_i if not covered by a valid, version-transferable signed zero certificate; otherwise its new-read cost is 0. Internal gate contracts are authenticated and remain fixed during the epoch; their proof-checking cost is accounted separately.

Define recursively:

    C(i) = 0                        if a signed unchanged-leaf zero certificate is valid,
           c_i                     otherwise;
    C(v) = sum of the (k_v-q_v+1) smallest { C(child) : child of v }.

**Theorem C (exact tree composition).** Under the above disjoint-subtree and nominal all-zero contracts, C(root) is exactly the minimum *new trusted-read cost* needed to produce a sound zero-output certificate.

**Upper bound:** Recursively certify k_v-q_v+1 selected child outputs as zero. At most q_v−1 children can still be 1, so v is zero. Every local implication composes to root; cached signed zero leaves are admissible as zero-cost evidence.

**Lower bound:** Suppose a purported root certificate proves fewer than k_v−q_v+1 child subtrees zero. Each remaining child has a positive-output assignment consistent with its observed nominal-zero leaves, by the inductive definition of the minimum zero-certificate cost. Since the child leaf sets are disjoint, combine q_v such assignments. The root becomes 1 without changing any queried leaf observation. Therefore at least k_v−q_v+1 child zero certificates are necessary; choosing the cheapest proves the recurrence. Induction on tree height completes the proof. □

**Version maintenance:** Updating one leaf's trusted-certificate validity or one gate's threshold requires recomputation only along that node's ancestor chain. With maximum fan-in b and tree height h, re-sorting each affected node gives O(h b log b) arithmetic/comparison work (O(h) when b is bounded). Multiple signed changes cost O(Σ_{v∈union of affected ancestors} deg(v) log deg(v)) for cost metadata maintenance. Actual sensing, checker authentication and the length of an explicitly reconstructed proof object are separately charged. This is **not** an unconditional runtime bound for general DAGs.

**Sharing obstruction:** In a DAG, OR(x,x) needs one read, while naïve tree summation would charge two. Shared inputs, aliasing, overlapping source dependencies and correlated or bundled evidence break the disjoint-child lower bound. Use Theorem B's semantic cover or a proved junction/interface decomposition instead.

## 4. Fresh noisy sensing: semantic **fractional** cover and tree recursion

Assume each currently uncertified leaf i has a trusted binary-label sensing channel. When its latent fault flag equals b∈{0,1}, a named query yields distribution P_b^i on a finite alphabet. Conditional on any fixed world, successive rounds are independent; log likelihood ratios are bounded; P_0^i and P_1^i are distinct with d_i=D(P_0^i||P_1^i)>0. A query at leaf i costs c_i. No cross-round latent common cause, no version transition while sampling, no free stronger observation mode. The safe-world expected sensor cost C_δ^0 has both nominal false-reject and every unsafe world's false-accept probability ≤δ.

**Theorem D (finite semantic-KL cover, asymptotic).** For a fixed finite world family, as δ↓0,

    C_δ^0 = [min_{z_i≥0} Σ_i c_i z_i
             subject to Σ_{i∈D(w)} d_i z_i ≥ 1 for all unsafe w] log(1/δ)
             + o(log(1/δ)).

The lower bound is stopped-transcript relative entropy against every unsafe w followed by a covering LP. The upper bound is obtained from a rational approximation to an optimal allocation, a fixed periodic source-matched sampling schedule, and a multi-alternative sequential likelihood-ratio test: accept when all unsafe likelihood ratios favor the nominal system beyond the threshold, reject when any favors an unsafe alternative beyond the opposing threshold. Nonnegative likelihood-ratio martingales control both errors, while the safe-world strong law and bounded increments give the leading expected stopping time. This invokes classical controlled sequential testing methods; the detailed renewal/optional-stopping conditions need independent mathematical review. The exact-rational software below checks the LP, **not** the sequential asymptotic.

**Theorem E (fractional composition for disjoint threshold trees).** For a leaf set a_i=c_i/d_i. Let K(v) be the coefficient of log(1/δ) for detecting any unsafe assignment to subtree v. For threshold gate v with disjoint children v_1,...,v_k, set

    K(v)=min_{t_i≥0} Σ_i K(v_i) t_i
          subject to Σ_{i∈J} t_i ≥ 1 for every J⊆[k] with |J|=q_v.

This holds because the minimum accumulated information against an unsafe assignment to child i scales linearly with its allocated sensing rates. Any unsafe parent world activates at least q child subtrees, so the worst-case information margin is the sum of the q weakest child margins. Feasibility is exactly the displayed local fractional q-cover. Disjoint child variables let all minimizing unsafe assignments be combined, giving the reverse implication. This is LP decomposition, not a new information-theoretic inequality.

For uniform sensor cost c and KL d at a single threshold(k,q) interface, symmetry and a matching uniform dual certificate yield exactly

    K = (k/q) (c/d).

The uniform primal t_i=1/q is feasible. The dual assigning 1/binom(k-1,q-1) to each q-subset gives the same total k/q. Example threshold(3,2): noiseless cost 2 reads; noisy asymptotic coefficient (3/2)c/d; topology-only min-cut predicts 3 or 3c/d. For k≈2q the difference between noiseless integer and noisy fractional coefficients grows linearly in k (but these are different error contracts and must not be directly compared as absolute costs).

**Boundary:** Cross-round shared noise B with observation Y_{i,t}=x_i XOR B can make the true alternatives information-theoretically indistinguishable beyond a nonzero risk floor. Neither the per-sample KL nor the fractional cover theorem is valid in that persistent-noise model. Authenticated version changes invalidate fixed-state likelihood ratios.

## 5. Pure informational complementarity survives compositional gate semantics

Construct r disjoint threshold(k,q) modules, any one of which can become mission critical. Independent uniform human mission T and authenticated configuration A in Z_r select K=(T+A) mod r. Metadata become known either before all sensing, or afterward with no further reads. The complete static systems and oracle costs are identical in all four arms. Each module is a read-only threshold subsystem with verified disjoint leaf contract and unit sensor costs.

    known pre-sensing context:   neither     T only      A only      both
    exact nominal read cost:     r(k-q+1)    r(k-q+1)    r(k-q+1)    k-q+1.

Both information sources individually reveal zero bits about K, while their pair reveals log₂r bits. The interaction in read-cost savings is +(r−1)(k−q+1), strictly positive. Under the fresh noisy model and symmetric leaf channels, replace k−q+1 with (k/q)(c/d) in the leading safe-world log(1/δ) coefficient. Thus finite pure operational synergy persists for genuinely composite threshold modules, not only single-read target addresses. This is a constructed example using classical modular routing and certificate complexity, not empirical evidence of human–AI information synergy.

## 6. Authentication, changing contracts and the impossibility of unsynchronized safety

**Semantic edit adversary:** The source graph is fixed, but a node's signed gate contract changes from AND to OR. A plan consisting of one source read remains optimal for AND but can falsely authorize the new OR system if a different source turns unsafe. A change manifest that authenticates only edges and not gate semantics is insufficient for optimal and safe lifecycle recertification.

**Version-skew adversary:** For an OR of two sources, read x_1=0 in epoch e, permit x_1 to become 1 in epoch e+1, then read x_2=0. The two readings match a permanently safe system, but the mission is unsafe at authorization. No finite set of non-atomic time-separated reads can guarantee current-time safety against arbitrary hidden post-read changes. A trusted atomic version-lock/transactional commit, an invariant covering the interval, or a proved temporal safety guarantee is required.

**Positive rule:** A recertification certificate must bind (i) authenticated mission/version; (ii) source-to-gate contracts; (iii) source provenance and unchanged-subsystem validity; (iv) the selected observation panel and trusted read stamps; (v) a composition proof for the applicable semantic class; (vi) a linearization point at which all relied-upon evidence is simultaneously valid. A node update invalidates cached guarantees on its dependents according to *semantic* contract dependencies, not just topology.

## 7. Independent audits and status boundaries

| Program | Audit | Result |
|---|---|---|
| contract_exhaustive_audit.py | 512 DAGs × 27 weights; independent local state vector enumeration and direct path set hitting; cyclic feedback counterexample | 13,824/13,824 equality; 16,416 path realization checks (with repeated weights), cyclic witness reproduced |
| semantic_separator_audit.py | All 44 (k,q), 2≤k≤9, plus 440 random cost vectors; explicit uniform rational primal+dual; 21 routed joint context instances | 44/44, 440/440, 44/44, 21/21 |
| tree_composition_audit.py | Random disjoint-leaf threshold trees with cached version-valid zero inputs; global truth-table cover vs recursive certificate; duplicate-input attack | 525/525 cases (435 with caches); OR(x,x) overcount reproduced |
| noisy_tree_exact_audit.py | Independent exact-rational LP for global unsafe-world supports vs recursive child LP; up to 4 leaves with nonuniform rational c/d | 72/72 global/recursive equality; 3-of-2 fractional K=3/2 |

No Lean run completed. The tests verify finite algebra and exact LP values, not physical contracts, author-only literature novelty, statistical convergence, safety of a real plant, or end-to-end life-cycle cost optimality.

## 8. What is gained, what remains missing, cheapest decisive next test

**Changed:** A source-level local contract now *proves* when graph min-cut is sound and optimal. When the contract is conjunctive/threshold instead, topology-based recertification can be arbitrarily suboptimal even with unchanged wiring. A semantic support cover provides the correct exact invariant. Disjoint threshold trees support a compositional integer recurrence with efficient authenticated single-change updates. In the fresh-noise regime, the correct leading invariant is a **fractional** information cover with a recursive local LP, not necessarily a graph cut. A coupled r-module construction transfers pure routing synergy to certificate-bearing composite subsystems.

**Not proved:** A universal semantic separator computable efficiently in shared-interface DAGs; persistent correlated sensing; asynchronous safe snapshots absent atomic commitment; full resource-priced optimum C*(M,Δ,G,O,δ); theorem originality beyond known Boolean certificate/query complexity and sequential sensing; Lean compiler receipts; independent refereeing.

**Next cheapest decisive experiment:** Construct a 5–7-node gate DAG with one shared measurement and one authenticated mid-transaction gate edit. Enumerate unsafe-world observation signatures across every consistent snapshot, compare a semantic cover with any topology-only separator, and independently model-check an epoch-bound authorization policy. If this produces a new parameterized interface-width bound with a matched converse not subsumed by classical certificate complexity and FASE incremental analysis slicing, promote to an actual theorem candidate; otherwise keep the current v0.2 as a reusable correct scaffold.

**Operator transfer:** Boolean contract semantics → active-violation alternatives → exact distinction supports → min cost cover → fractional KL version → versioned composition certificates → authenticated update algorithm → proof obligation for shared-interface and temporal dependencies.