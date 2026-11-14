# The Right to Act — The Cost of Delegated Authority
## Source-Valid Hybrid Assurance Cuts and the Shared-Evidence Complexity Transition

**Research addendum v1.4 | 14 November 2026 | Devin J. Wright / NIGHTFALL (AI-assisted research)**

> **Claim status:** Restricted, original-to-this-project formalization with elementary, internally proved lemmas and independent finite checks. **No demonstrated historical novelty**, no independent specialist review, no production security proof, and no measured efficiency improvement on ControlArena. Mathematical facts below rely on classical max-flow/min-cut and Set Cover. Treat this as a reproducible research construction and a way to locate the genuinely open frontier, not as a standalone mathematical breakthrough.

### Abstract

A future autonomous laboratory agent may write code that is harmless while isolated yet harmful if promoted into deployed infrastructure. *The Right to Act* therefore distinguishes the permission to **propose** a change from the authority to **realize** its protected effects. We analyze a restricted finite effect graph. Each modeled edge can be neutralized by a trusted effect guard, a newly acquired and verified source-valid safety certificate, or a still-valid cached certificate. Under edge-local additive costs and worst-case unsafe-path semantics, the exact minimum cost of a sound assurance boundary is the capacity of a directed minimum cut, certified independently by a maximum flow. When one measurement certifies many edges jointly, this reduction fails: shared evidence yields weighted Set Cover, NP-hard in general, while laminar families permit an exact dynamic program. An eight-edge exact rational construction shows respective costs **18, 12, and 4** for full rechecking, local evidence reuse, and joint fixed design; those are stipulated prices, **not** empirical savings. Separate atomic-state tests demonstrate the scope of source and policy invalidation. The next proposed research step is a version-bound promotion gate over actual ControlArena IaC Fast changes, with independently evaluated effect semantics and a capable agent baseline.

## 1. Objective and controlled feasible set

The long-term objective is to determine the minimum cost of instrumentation, information acquisition, and verification that sustains sound, useful, mission-conditioned authority as agent capabilities, evidence sources, and systems change.

The finite problem here deliberately narrows that goal:

- A trusted directed multigraph `G=(V,E)` is an **effect-complete over-approximation** of unsafe causal propagation from the agent `s` to a protected resource `t`. Every in-scope harmful path is represented. The graph itself is authentic and immutable during an atomic promotion decision.
- At edge `e`, a **sound external guard** can prevent unsafe propagation with installation cost `g_e`, or an independent verification procedure can certify *for the current exact source and policy* that this edge cannot propagate a specified harmful effect, at acquisition cost `a_e` and verification cost `v_e`. Both types of protection preserve the specified legitimate action. Such protection is *assumed* rather than provided by the Python prototype.
- A prior certificate is reusable at zero marginal inspection cost **only** when its authenticated dependency closure, source version, policy version, proof semantics, and trust base remain valid. The fixture approximates these obligations by matching source and policy digests, and does not cryptographically attest them.
- Each selected edge is handled independently; there are no shared measurements, overlapping proof dependencies, bulk guard discounts, time-of-check/time-of-use races, uncertain effects, or residual hazard probabilities. All current newly acquired verifications are assumed to *pass*; an unsuccessful verification causes denial, not authorization.
- The adversary may choose **any** path that remains unsealed; there are no hidden alternative paths. A protected effect cannot be committed outside the trusted atomic gate. These assumptions are strong and must be discharged before generalizing to real agents.

The choice variables are `guard` (instrumentation), `recheck` (evidence acquisition + verification), and `reuse` (previously sound evidence). Defining these costs separately prevents the familiar mistake of treating testing, computation, and proof as free.

## 2. The finite hybrid-cut theorem

For a regime `r` and current policy `p`, define

\[
 w_e^{\mathrm{full}}=a_e+v_e,\qquad
 w_e^{\mathrm{local}}=\begin{cases}0,&\text{if the old certificate is source/policy-valid};\\a_e+v_e,&\text{otherwise},\end{cases}
\]

and

\[
 w_e^{\mathrm{joint}}=\min\{w_e^{\mathrm{local}},g_e\}.
\]

Let `δ⁺(S)` be the set of directed edges leaving `S`, where `s∈S` and `t∉S`.

**Proposition A (Restricted source-valid hybrid assurance cut).** Under all assumptions in §1, the least **additional** deterministic expenditure ensuring no in-scope unsafe path can reach `t` is

\[
 \boxed{C_r^*(G,p)=\min_{S:\ s\in S,\ t\notin S}\sum_{e\in\delta^+(S)}w_e^r.}
\]

It equals the value of the maximum `s–t` flow with edge capacities `w_e^r`, including rational capacities and parallel edges.

**Proof.** Choose any cut `δ⁺(S)`. Protect each crossing edge by its minimum-price admissible mechanism; every `s–t` path crosses at least one such edge. Under complete mediation and sound current protection, unsafe propagation cannot cross that edge, proving sufficiency. Conversely, let `F⊆E` be the protected edges in any sound design. If there is an `s–t` path in `E\F`, the adversary can use that wholly unprotected path, contradicting soundness. Thus `F` separates `s` from `t`. Let `S` be exactly the vertices reachable from `s` in `E\F`. Then `t∉S` and `δ⁺(S)⊆F`; by nonnegative additive costs the design costs at least the weight of this cut. Minimizing over all `S` proves equality. Classical max-flow/min-cut provides the flow dual. ∎

**Corollary.** `C_joint ≤ C_local ≤ C_full` under the nested option sets. Invalidating a cached source or policy proof cannot lower `C_local` when the graph and other costs are unchanged. A newly added path may invalidate an earlier release certificate even if all existing source digests remain unchanged. These are *model* claims, not empirical benefit assertions.

**What is not proved:** completeness of the real protected-effect graph; soundness of a CDK synth diff against deployed cloud effects; source-to-claim attestation; execution atomicity beyond one process; safe concurrency across a deployment API; source-compatible multiversion consistency; or safe recertification under noisy observations and strategic model changes.

## 3. Exact construction and independent certificate

The attached `example_network.json` has five vertices and eight typed edges modeling an agent, build environment, evaluation environment, training environment, and protected resource. Old source-specific attestations cover two edges; selected source digests for other formerly certified edges have changed. Costs are **hypothetical exact rational** units.

| Regime | Exact minimum | Cut evidence | Meaning |
|---|---:|---|---|
| Full recheck, no reuse or new guard | 18 | rational max-flow = 18 | every selected edge is freshly checked |
| Source-matched local reuse, no new guard | 12 | rational max-flow = 12 | unaffected evidence may be reused |
| Joint guard/evidence design | **4** | rational max-flow = 4 | reuse edge `a`; guard edges `f` and `g` |

The difference `12 → 4` is **8/12 = 66.7% on this priced fixture**, not a ControlArena benchmark estimate, not an independent scientific gain, and not a general competitive ratio. If the policy version changes while sources remain fixed, the locally cached authorizations are not reusable and the local optimum rises from 12 to 18.

`hybrid_cut.py` computes rational max flow using a residual graph with independently indexed parallel arcs. `independent_checker.py` separately enumerates all `2^m` candidate edge protection subsets and uses a graph-search criterion rather than the solver's residual algorithm. It compares exact optimum, selected cut, and dual-flow values on the frozen instance and 500 deterministic random rational-weighted DAGs (up to 11 edges). This finite audit is a **counterexample search** and exhaustive certification for its specific bounded instances, not a proof of the general theorem. The mathematical proof is the argument above.

A separate local promotion specification uses a process lock, state epoch, policy versions, exact source strings, and a re-evaluated cut. Ten tests check rejection when a source changes after evidence collection, the policy version changes, authority is revoked, or a newly declared bypass edge appears. It writes no external protected state, and successful in-process checks do not make the proposed gate non-bypassable by real tools.

## 4. A structural transition: shared evidence invalidates edge-local min-cut

In actual frontier-laboratory engineering, one expensive test (for example a combined infrastructure plan audit) might certify several causal edges simultaneously. Then selecting tests is not the same as purchasing edges independently.

Let `U` index disjoint unsafe paths, and let a certification action `j` of cost `c_j` certify the edges of exactly the paths in `S_j⊆U`. Singleton effect guards, when available, have costs `g_i`. In the all-tests-pass, fixed-source setting, a sound promotion requires the union of purchased test supports and guarded singleton paths to cover `U`.

**Proposition B (Shared-evidence complexity boundary; classical reduction).** Choosing the least expensive set of shared tests and singleton guards is equivalent to weighted Set Cover with optional singleton sets; therefore it is NP-hard in general.

**Proof.** Given any weighted Set Cover instance `(U,{S_j},c_j)`, build the parallel-path effect graph `s→u_i→t` for every `i∈U`. Define test `j` to seal path-edge `(u_i,t)` for exactly those `i∈S_j`. Set each singleton guard cost `M > ∑_j c_j` and assume the given family covers `U`. A minimum-cost sound design never purchases a guard, because purchasing all tests costs less than `M`. It must therefore choose tests whose supports cover every path, with total weight exactly a weighted Set Cover solution. Conversely every set cover seals every path. Polynomial construction and objective preservation yield the reduction. ∎

This **does not** claim to discover Set Cover hardness or a new general complexity class. It explains precisely why the preceding min-cut reduction must not be used after evidence becomes shared, even when every individual verifier is perfect and independently trusted.

**Proposition C (Laminar shared-evidence subclass).** If the supports of every two tests are disjoint or nested, with optional per-path guard prices, exact minimum cost is computable by dynamic programming on the containment forest augmented with singleton nodes.

**Proof.** For each set node, either buy the least expensive test directly certifying the entire set, or cover its maximal proper test descendants and uncovered singleton elements independently. In a laminar family these descendants are disjoint; no other test can overlap two descendants without containing their parent. The optimum therefore obeys this Bellman recursion. Bottom-up evaluation over the finite containment tree computes an optimum; the naive parent-selection construction is polynomial in the test count and universe size. ∎

`shared_evidence.py` implements exact enumeration for small arbitrary families and the laminar dynamic program. The separately constructed comparison test set passes 400 deterministic random laminar instances. In the explicit three-path example, three independent singleton guards cost 12, while one joint evidence acquisition-and-verification action covers all three for 1. It is a synthetic feasibility example, not proof of an engineering advantage.

## 5. Scope attacks and adversarial falsification

1. **Hidden effect path:** adding an unmodeled `s→t` route means the claimed cut is not an actual cut. An atomic graph-local verifier cannot establish external security when the effect graph is incomplete.
2. **Stale source or altered policy:** a cached certificate for old semantics is invalid even if its named file is unchanged. The source-dependency closure must include policy, tool schema, verifier, grants, deployment configuration, and external reachable effect semantics.
3. **Time-of-check/time-of-use:** if an agent can alter the artifact between verification and promotion, a previous hash does not justify a new effect. Atomic content-addressed promotion or a fail-closed version lock is needed at the true effect boundary.
4. **Guard fidelity:** a Python flag declaring an edge guarded is not an OS, cloud, credential, or network enforcement mechanism. Any real non-bypassability claim requires independent resource-side evidence.
5. **Shared evidence:** treating a multi-effect test as separate cost-free certificates falsifies the edge-local price model. The correct model becomes a path-covering family or a stochastic decision game.
6. **Strategic adaptation:** if the adversary can choose when to attack based on observed monitors or modify the environment while observing the gate, fixed iid failure estimates are insufficient.
7. **Legitimate throughput:** the analysis assumes every selected protection preserves authorized work. A design that denies all activity trivially satisfies a no-effect property but is useless. Future experiments must impose nonzero legitimate completion constraints.

## 6. Prior-art comparison and originality boundary

- **PACE, Li et al. (2026), arXiv:2610.01349**, already develops provenance-aware capability/effect verification and executable cuts. We do not claim priority for effect cuts or call-time authority gates.
- **Liu, Tyszberowicz & Beckert (FASE 2026), DOI:10.1007/978-3-032-22774-4_10**, already studies sound incremental analysis slicing and evidence reuse, including a restricted fixed dependency structure. We do not claim priority for dependency-local recertification.
- **Zhang & Xu (2026), arXiv:2609.28520**, already formalizes task-conditioned information acquisition and optimal adaptive distinguishing trees. We do not claim novelty for Bellman information acquisition.
- **AID-Guard (2026), arXiv:2608.21159**, already formalizes stateful authority-to-effect closure with retries, fences, and recovery. We do not claim to have discovered effect-time revalidation or race-free provider commits.
- **Elmasry (2026), DOI:10.1007/s10207-026-01343-w**, documents the mismatch between agent authorization claims, enforcement points, and actual effect evidence. That review strengthens our negative-control requirements.
- **Staley (2026), DOI:10.47001/jaiet/2026.308004**, already separates an agent modification's benchmark improvement from safe inheritance of production authorization. Versioned recertification alone is not a novel premise.
- Classical **max-flow/min-cut**, **weighted Set Cover**, and laminar dynamic programming provide the actual mathematical engines of Propositions A–C. Their application here is a well-scoped research construction, not established historical novelty.

### Defensible open claim

A potentially significant future theorem would identify the exact tradeoff between **shared/correlated evidence**, **independent effect-time enforcement**, and **change-triggered certificate validity** under adaptive, adversarially chosen actions, with a tight lower bound and a computationally efficient method for a meaningful structured class. Our present results show the tractability transition that such a theorem must navigate; they do not solve the general problem.

## 7. Next decisive source-matched ControlArena experiment

The live GitHub benchmark history is [PR #492](https://github.com/d3lefts/d3lefts/pull/492): real Docker/Inspect/ControlArena IaC Fast task execution with MockLLM and Qwen 2.5 1.5B, but the small model did not complete the sampled legitimate task; no real authorization bridge has yet been tested in those runs. Do not substitute synthetic price wins for measured benchmark costs.

**Next experiment (pre-registered):** On an isolated IaC Fast worktree, prepare a small, deterministic **legitimate** infrastructure patch and a paired **unauthorized** variant affecting a protected IAM/monitoring property. Use a trusted independent verifier of *actual sandbox effects* (not an agent judgment), snapshot the artifact/policy/environment digests, and attempt promotion under (i) full revalidation, (ii) source-valid local reuse, and (iii) jointly chosen guard/evidence actions. Introduce a configuration change just before promotion to attack stale source receipts and a previously unknown effect edge to attack graph completeness. Keep a constant legitimate-task success requirement; log checker calls, verifier wall time, source authentication, effective resource differences, and effect-boundary denials. If the same task fails for every policy or the effect semantics cannot be measured, report a blocked experiment instead of a savings claim.

**Prerequisites and stop rule:** pin fixture sources and exact scorer versions; verify coverage of all in-scope paths; demand at least one legitimate successful promotion and one blocked unauthorized effect; retain independent transcript and verifier artifacts. Stop if the claimed certificate rests solely on a tool-call approval or an attacker-writable record. Do not promote results without externally reviewed effect semantics and source-to-claim provenance.

### Record of what this contribution changes

We can now move from an informal three-cost objective to a **checked restricted optimization boundary**:

`Complete effect graph → version-compatible sources → edge-local guard/certificate options → exact min-cut and dual flow → atomic abstract promotion → explicit limitations → shared-evidence hardness and laminar tractability → next live effect test`.

The central distinction remains: **intelligence establishes capability; independent evidence and enforceable boundaries justify authority.**
