# NIGHTFALL v0.1 — Optimal Change-Local Authority in a Modular Evidence Network

**Research checkpoint:** 2026-11-15 UTC. **Status:** complete mathematical reduction with independent brute-force verification, not Lean-certified or human-refereed. **Novelty:** no globally original mathematical theorem is claimed; the max-closure/min-cut operator is classical (Picard 1976). Contributions here are a precise recertification model, combination of local information complementarity with a matching cost lower bound, its posterior-risk extension, and a reproducible dual certificate.

## Research contract

- **Objective:** rigorously determine the minimum paid-evidence cost needed to renew authorization after a localized change, with two-sided correctness and conditional authorization risk.
- **Feasible set:** finite graph with independent uniformly random edge-endpoint values in `Z_r`, exact node and edge sensors, additive nonnegative rational costs, truthful and current cached readings, and unaffected constraints with valid change-stable certificates. A mission requires *all* affected constraints to equal zero.
- **External reference:** Zhang–Xu (2026), _Certified Task-Conditioned Active Observability_, has a Bellman-optimal distinguishing-tree formulation. _Analyses as First-Class Citizens in Model-Driven Development_ (FASE 2026) already proves sound incremental recertification. Picard (1976) proves the classical max-closure/min-cut equivalence. No novelty based solely on these operations.
- **Strongest verified result:** exact zero-risk safe-path optimum `C*` equals a minimum-cut value; for posterior risk `δ`, a fixed-parameter family of cuts computes exact optimum. A direct elementary indistinguishability argument supplies a matching lower bound for any adaptive policy.
- **Remaining gap:** correlated/overlapping edge secrets, noisy observations, actual lifecycle provenance, continuous-state physical simulators, stochastic acquisition costs, real agent authorization implementation, and independent Lean/human audit.
- **Certification:** `mincost.py` generates a feasible decision and primal/dual maxflow/mincut data; `audit_independent.py` independently enumerates candidate strategies and finite worlds with exact arithmetic; SHA-256 receipt recorded separately.
- **Stop rule:** finish finite theorem and checker, preregister next generalization; do not claim an unrestricted autonomous-systems solution or a historically novel complexity theorem.

## 1. Formal model

Let `G=(V,E)` be a finite loopless simple graph of unresolved mission-relevant constraints. Fix integer `r≥2`. Independently for every incidence `(v,e)` sample a uniform `A_{v,e}∈Z_r`. Set `K_e=(A_{u,e}+A_{v,e}) mod r` for edge `e={u,v}`. The mission is safe, `Φ=1`, exactly if `K_e=0` for **every** `e∈E`.

A **node read** `N_v` costs `w_v≥0` and discloses all the incidence values `{A_{v,e}:e∋v}`. A **direct gate read** `D_e` costs `d_e≥0` and discloses `K_e`. The verifier may adapt its queries. A cache `C⊆V` consists of *current, authenticated* node readings preserved under the change; their cost is already paid. (The assumption of cache validity is essential.) Edges outside `E` have separately authenticated unchanged proofs, so need not be queried here.

A policy must (i) authorize **every safe configuration** (no false denials); (ii) upon each authorized transcript, ensure that the posterior probability of an unsafe mission is at most a declared rational `0≤δ<1` under this model. Query readings are exact. We minimize the cost on the safe executions. Although the policy may adapt, all safe-execution paths have the same *optimal achievable minimum* because the lower bound is transcript-wise and the constructed fixed plan achieves it for every safe world.

**Pure information complementarity.** For each edge, `I(K_e;A_{u,e})=I(K_e;A_{v,e})=0`, while `H(K_e|A_{u,e},A_{v,e})=0` and `H(K_e)=log₂ r`. Reading a single endpoint does not help infer that edge's status, but the pair fully resolves it. Reading a vertex helps many incident edges at once.

## 2. The zero-risk exact-cost theorem

For `δ=0`, define the incremental cost

```
C*(G,w,d,C)= min_{S⊆V, S⊇C}
  [ ∑_{v∈S\C} w_v + ∑_{e={u,v}: {u,v}⊄S} d_e ].         (1)
```

**Theorem 1.** In the model above, (1) is exactly the minimum safe-execution recertification cost of every adaptive policy satisfying both correctness requirements, and can be computed by a single finite minimum source–sink cut.

**Proof, lower bound.** Fix any safe world and its eventual authorization transcript. Let `S` be vertices whose incidence values are known from the cache or were queried; let `D` be edges whose gate values were directly queried. Suppose some edge `e` has `e⊄S` and `e∉D`. At least one incidence half `A_{v,e}` is unread. Change only this half to a different value in `Z_r`; all observed node values, all directly observed gate values, and all cached values are unchanged. The altered world is unsafe (its `K_e` is nonzero), so a deterministic policy would produce the same transcript and wrongly authorize. More strongly, even randomized policies with zero *conditional* authorization risk cannot authorize such a transcript because its unmeasured half has positive posterior mass on unsafe values. Thus every edge not internal to `S` must be read directly. The cost of the safe path is at least the objective for `S`, hence at least its minimum.

**Proof, matching construction.** Choose minimizing `S`. Query nodes in `S\C` and directly test every edge not internal to `S`; compute other edge checks from both endpoint values. Deny if any tested check is nonzero, and authorize otherwise. This decides `Φ` correctly on every world, incurs no false denial, and costs exactly (1) on every safe world. QED.

**Minimum cut.** Build nodes `s,t`, one vertex node `v` for every agent, one reward node `z_e` for every edge. Add arcs `s→z_e` of capacity `d_e`, `z_e→u` and `z_e→v` each of capacity `M>Σ_e d_e+Σ_v w_v`, and `v→t` of capacity `w_v` (or 0 for cached vertices). A finite optimal cut cannot separate `z_e` from a selected endpoint. Its cost is exactly `Σ_{e not selected}d_e+Σ_{v selected}w_v`; optimal edge-reward nodes are selected whenever both endpoints are selected (unless d_e=0, a harmless tie). Adding cached vertices to the selected set is free. By max-flow/min-cut, the objective (1) equals the flow value. The returned flow and cut furnish a checkable optimality certificate.

For finite rational input, clear denominators to obtain an integer-capacity network and use any polynomial-time maxflow method. The included reference code uses exact Fraction Edmonds–Karp, prioritizing auditable correctness over speed.

## 3. Posterior-risk theorem and fixed-parameter optimization

Define `k=k(r,δ,|E|)=max{m≤|E|:1−r^(−m)≤δ}`. For a transcript let `S` denote known vertices, `D` directly tested edges, and `U={e∈E: e⊄S and e∉D}` unverified edges.

**Lemma 2 (exact residual risk).** Conditioned on a transcript with all observed gates passing, the unverified gate values `{K_e:e∈U}` remain independent and uniform on `Z_r`. Hence

```
P(unsafe mission | this authorized transcript)=1−r^(−|U|).     (2)
```

**Proof.** For each `e∈U`, at least one independent incidence half remains unread and was not used in any other query; adding this uniform half to a possibly known other half makes `K_e` uniform. Different edges use disjoint underlying halves, so unverified gate values are conditionally independent. QED.

**Theorem 3 (optimal conditional-risk recertification).** The minimum safe-path cost with posterior false-authorization risk at most `δ`, with zero false denial, is

```
C*_δ = min_{S⊇C, U⊆E, |U|≤k}
 [Σ_{v∈S\C} w_v + Σ_{e∈E\U: e⊄S} d_e].             (3)
```

The optimum can be computed by enumerating at most `k` edge exclusions `U` and solving an independent minimum-cut problem on `E\U` for each candidate. The number of cuts is at most `Σ_{j=0}^k binom(|E|,j)`, giving polynomial time when the risk budget corresponds to fixed `k` (an XP algorithm parameterized by `k`, **not** an FPT `f(k)poly(n)` bound). The algorithm is exact and carries a cut-dual certificate for the selected exclusion set.

**Proof.** On any safe authorized transcript the exact conditional risk (2) demands `|U|≤k`; every other edge must be fully determined by both node halves or a direct test, yielding lower bound (3). Conversely choose minimizing `S,U` and query nodes `S\C` and remaining noninternal edge tests. Authorize if all observed gates pass; otherwise deny. Every safe world is accepted, and every authorized transcript has precisely at most `k` independent unobserved gates, so risk ≤δ. The cost attains (3). The exhaustive-exclusion plus minimum-cut formulation follows from Theorem 1. QED.

**Important scope:** this is **posterior conditional** error, not merely an unconditional false-authorization rate, and only concerns a correctly pinned product-uniform model. If a model changes adversarially or observations have arbitrary dependencies, the formula fails without further justification. Cost is safe-path minimum, not global worst-case cost of detecting unsafe worlds.

## 4. Preregistered experiments and outcomes

Prediction: paired observations plus shared node reads can outperform either all-edge tests or all-node reads; local graph updates can be certified without reprocessing unchanged gates; a posterior-risk budget may reduce required reads according to the exact `k` formula. Alternative: certificate dependencies would force a higher cost than the cut or risk relaxation would fail due hidden dependence. Discriminator: independent exhaustive strategy oracle, exact finite-world checker, and maxflow dual.

**Exact example A (mixed evidence):** Two disjoint gates `(0,1)` and `(2,3)`, node costs `(1,1,5,5)`, direct costs `(5,3)`. All-direct costs `8`, all-node costs `12`, but reading nodes 0,1 plus the second edge directly costs **5**, which is optimal by the cut certificate. If node 0's current half-evidence is authenticated and reusable, incremental cost is **4**.

**Exact example B (change locality):** Five agents, all ten pairs require checking, each node costs 2 and each direct gate costs 3. Whole-mission zero-risk optimum is **10** (read all five agents), versus **30** for all-direct tests. If exactly one edge certificate is invalidated and all other certificates remain current, the change-local optimum is **3** (directly retest that edge), rather than 10.

**Exact example C (risk/availability trade-off):** In A, with `r=2`, `δ=0`, cost 5; with `δ=1/2`, cost 2 by omitting one independently uniform unresolved edge; with `δ=3/4`, cost 0 by omitting both edges. All safe configurations are authorized, but false-authorization posterior risk rises to 0, 1/2 and 3/4 respectively. These high δ values illustrate the theorem, **not recommended operational risk levels**.

**Independent audit:** run `python3 audit_independent.py` in this folder. It exhaustively compared min-cut to a separate vertex/direct-sensor enumeration for 3,000 rational-weight instances and checked 296,401 complete finite-world assignments. The checker separately verifies exact flow feasibility, dual cut equality, and safe-world acceptance / an unobserved-half perturbation. The receipt SHA256 is committed to `AUDIT.md` and `experiment_receipt.json`. The finite checks are not proof of the all-n theorem; Theorems 1–3 have the analytic proofs above.

## 5. Prior art / novelty limit

- **Picard (1976),** _Maximal Closure of a Graph and Applications to Combinatorial Problems_, Management Science 22(11):1268–1272, https://doi.org/10.1287/mnsc.22.11.1268. Exact maximum-closure-to-min-cut is classical.
- **Linzhe Zhang and Changming Xu (2026),** _Certified Task-Conditioned Active Observability_, arXiv:2609.28520, https://arxiv.org/abs/2609.28520. Already develops optimal adaptive distinguishing trees and formal task observability.
- **FASE 2026,** _Analyses as First-Class Citizens in Model-Driven Development_, https://etaps.org/files/2026/fase-2026.pdf. Incremental analyses and sound recertification antecedent.
- **Miaobo Hu et al. (2026),** _ActiveEvidence: Decision-Focused Evidence Graphs with Verifiable Acquisition Gaps_, arXiv:2610.20532, https://arxiv.org/abs/2610.20532. Decision-focused acquisition and independently replayed certificates.

We have not established that this combined application or any individual theorem is globally new. Its significance is a **fully specified exact benchmark for the broader mission-conditioned authority problem**, not a claimed resolution of arbitrary autonomous-system assurance.

## 6. Next structural transitions

1. **Shared latent secrets and noisy sensors:** when edge halves can be correlated or evidence lies in a noisy channel, simple per-edge posterior factorization fails. Derive a graphical-model width parameter and see whether a tree-decomposition Bellman recursion admits matching lower bounds.
2. **Authenticated lifecycle evidence:** replace the model's assumption of valid caches with a byte/hash/source-version certificate protocol, demonstrate safe cache invalidation under a change, and audit malicious stale-evidence substitutions.
3. **Posterior risk and asymmetric costs:** show a nontrivial universal gap theorem or an instance family where the coupled optimal acquisition beats sequential testing under both low risk and nonzero availability constraints.
4. **Systems transfer:** connect concrete mission gates to plant/agent observables in an independently source-matched simulator; no claims about deployed authority before this test.
