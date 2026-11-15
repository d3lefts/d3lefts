# NIGHTFALL — Exact joint recertification with source-bound authority

**Research version:** 0.1, 2026-11-14 (America/New_York) / 2026-11-15 UTC  
**Research direction:** Devin J. Wright, NIGHTFALL (AI-assisted proof construction and arithmetic checks)  
**Status:** self-contained mathematical proofs in a specified finite deterministic model; 5,195 exact independent finite-instance comparisons (reproduce with `check_optimal_recertification.py`); **not** Lean-compiled; **not** independently human-refereed; global historical novelty unresolved.  
**Goal:** exact *successful-path* minimum total acquisition, validation, and effect-time version-guard cost, with an explicit algorithm and a matching adversarial lower bound. General noisy/POMDP, deployment, adversarial scheduling beyond the authenticated-history model, arbitrary cost sharing, and real-world plant validation remain open.

## 1. Model and contract

Let \(\mathcal H\) be a **finite** set of physically and institutionally admissible two-time histories. A history \(h\) specifies a coherent evidence-acquisition snapshot, every source-version change between that snapshot and a final *atomic* effect, and whether the protected mission predicate is true at effect time. All valid reusable signed certificates, mission scope, local system contracts, source authenticators, authorized changes and allowed environment transitions are already enforced in the definition of \(\mathcal H\); they may restrict it and must not be invented by a proof checker.

Fix a nominal history \(h_0\) that is safe and should be successfully authorized. Let \(Q=O\sqcup G\) consist of:

* trusted, authenticated **snapshot observations** \(o\in O\), returning finite deterministic outputs \(r_o(h)\), whose acquisition+interpretation+validation costs are \(c_o>0\);
* trusted **atomic effect-time version guards** \(g\in G\), returning `pass` when the relevant source version equals its signed acquisition-time reference; tests run atomically with the action, costs \(c_g>0\). In the nominal history each guard passes.

A sound adaptive policy may interleave observation queries adaptively, then select a set of guards; it may authorize only if all effect-time guards pass. The policy may abort on unexpected observations or failed guards; it must accept \(h_0\). All actions along its accepting nominal path are counted once, with additive cost. The computation required to *find* the optimal policy is recorded separately; if local evidence checking has a price, it must be in \(c_q\), not silently neglected. Only mutually consistent coherent snapshot histories are allowed; if source updates can evade version increments, the admissible history model must include those changes, creating an indistinguishability obstruction.

Define \(\mathcal U=\{h\in\mathcal H:\text{mission unsafe at effect time}\}\), and for \(h\in\mathcal U\)
\[
D(h)=\{q\in Q:r_q(h)\ne r_q(h_0)\}.
\]
A guard's return is a modelled function of the history. The nominal-path cost is the actual sum of all queried observation and guard costs along \(h_0\), *not* the worst-case cost or average cost over all histories. This distinction is essential.

## Theorem A — exact finite semantic recertification cost

\[
C^*(h_0)=\min_{S\subseteq Q}\left\{\sum_{q\in S}c_q:\ \forall h\in\mathcal U,\ S\cap D(h)\ne\varnothing\right\},
\]
with value \(+\infty\) if no feasible \(S\) exists.

**Lower bound (adaptive adversary).** Take an arbitrary deterministic sound policy accepting \(h_0\), and let \(S\) be the union of the actions it performs on its nominal accepting branch. If an unsafe \(h\) has \(S\cap D(h)=\varnothing\), its observed results coincide with the nominal results at every one of those actions. By induction over the policy's adaptive choices, it selects precisely the same actions and ultimately authorizes \(h\); this contradicts soundness. Thus \(S\) intersects every unsafe distinguishing set, and the policy's cost is at least the minimum in the formula. This also proves impossibility if some \(D(h)=\varnothing\).

**Upper bound.** Select a minimum-cost transversal \(S^*\). Query all selected observations, abort unless every result matches the nominal result; then execute the selected version checks atomically with the effect, aborting if one fails. Every unsafe history differs on a selected check and therefore cannot authorize; \(h_0\) passes and costs exactly \(\sum_{q\in S^*}c_q\). Equality follows. For randomized, zero-error policies that authorize \(h_0\) with probability 1, almost every nominal random seed induces a valid cover and costs at least \(C^*(h_0)\); take expectations.

**Generality of cost.** The proof remains valid for any **monotone set-cost** \(F(S)\) paid along the nominal path, not just additive \(\sum c_q\). In particular, one-time source instrumentation, attestation, or service setup fees activated by selecting a check can be included in \(F\). However, the polynomial-time results below use specifically structured setup fees.

**Independence from protocol adaptivity.** Off-nominal branches may be deliberately conservative. This theorem does *not* claim to optimize worst-case diagnostic completion, grant availability in all safe histories, or time needed to discover the nominal witness \(h_0\). If granting *every* safe world is required, a full adaptive decision-tree problem generally reappears.

**Prior-art classification:** The underlying nominal-path transversal is classical weighted certificate/hitting-set complexity. The value of this formulation is exact typing of **two temporal boundaries**, cached authentic source evidence, effect-time guards, and full cost accounting; global mathematical priority is not claimed.

## Theorem B — exact polynomial minimization with priced shared setup

Assume each minimal unsafe difference set (duplicates removed) consists of **exactly one** observation \(o_j\) and **exactly one** version guard \(g_i\), i.e. \(D(h)=\{o_j,g_i\}\). The unsafe histories define a bipartite graph \(E\subseteq O\times G\).

Each observation test \(o\) costs \(c_o\), each guard \(g\) costs \(d_g\). Observation facility \(a\) has setup fee \(A_a\ge0\) paid once if **any** of its associated observation tests is selected. Independently, authority service \(b\) has fee \(B_b\ge0\) paid once if any associated guard is selected. Facilities may overlap within their own class, but no setup fee is shared across both sides. The cost is
\[
F(S_O,S_G)=\sum_{o\in S_O}c_o+\sum_{g\in S_G}d_g+\sum_{a:S_O\cap O_a\ne\emptyset}A_a+\sum_{b:S_G\cap G_b\ne\emptyset}B_b.
\]

**Claim.** The exact optimum is a **single directed minimum \(s\)-\(t\) cut**, hence computable in polynomial time for rational capacities and accompanied by a matching feasible max-flow lower-bound witness. The cut and flow are independently checkable finite certificates.

**Construction.** Let \(L=1+\sum_oc_o+\sum_gd_g+\sum_aA_a+\sum_bB_b\). Create nodes \(o\) for observations and \(g\) for guards, plus facility nodes \(a,b\), and add arcs:

1. \(s\to o\) of capacity \(c_o\), and \(g\to t\) of capacity \(d_g\).
2. \(o\to g\) of capacity \(L\) for every unsafe witness edge \((o,g)\in E\).
3. \(s\to a\) of capacity \(A_a\), and \(a\to o\) of capacity \(L\) for every observation \(o\) installed by \(a\).
4. \(b\to t\) of capacity \(B_b\), and \(g\to b\) of capacity \(L\) for every guard \(g\) requiring authority service \(b\).

**Proof.** A cut placing **all observation nodes and their facilities on the sink side**, and **all guards and their services on the sink side**, cuts only the arcs \(s\to o\) and \(s\to a\), hence costs at most \(L-1\). No witness or dependency arc crosses. Thus no minimum cut crosses an \(L\)-capacity arc. For any minimum cut \((U,V)\) with \(s\in U\), select observations in \(V\) and guards in \(U\). An unhit witness edge would have its observation in \(U\) and guard in \(V\), crossing a prohibited \(L\) arc. If an observation is selected, its required facilities must lie in \(V\), otherwise \(a\to o\) crosses \(L\); if a guard is selected, its services must lie in \(U\), otherwise \(g\to b\) crosses \(L\). The finite cut value therefore covers precisely the selected test and all required activation fees, possibly more for unnecessary activated facilities. Removing those unnecessary activations only decreases cost, so the optimum cut gives an optimal feasible recertification plan. Conversely, from any feasible plan, put selected observations and their required facilities on the sink side; put selected guards and their required services on the source side; put all other observation and observation-facility nodes on source, other guards and guard-facility nodes on sink. No \(L\) arc crosses, and the cut has exactly plan cost. Hence equality.

By integral network max-flow/min-cut for integer prices, a feasible max flow of equal value and this cut certify optimality. For rational prices scale by a common positive denominator. The result is **not** valid for arbitrary cross-side shared setup charges or general hyperedges; their optimization can be NP-hard.

**Example (joint decision).** Let \(O=\{o_0,o_1\}\), \(G=\{g_0,g_1\}\), witness edges \((o_0,g_0),(o_0,g_1),(o_1,g_1)\) and costs \(c=(1,9)\), \(d=(8,1)\), with zero setup. Select \(\{o_0,g_1\}\) and pay **2**, compared to 10 for selecting all observations and 9 for selecting all guards. Neither observation-only nor guard-only optimization attains the joint optimum. A matching two-unit maxflow or cut independently certifies the cost.

## Theorem C — optimal compositional threshold-tree recertification

Let a finite rooted tree represent mission unsafety. Each internal node has \(k\) disjoint child subsystems and a threshold \(q\in\{1,\ldots,k\}\): the parent is unsafe iff at least \(q\) children are unsafe. A complete system history is any product of child histories; each subtree has disjoint observation/guard actions and **no setup service crosses subtree boundaries**. All subtrees are nominal-safe. At a leaf/subtree, let \(C(v)\) be its exact Theorem A recertification cost, including its local checks and local activation/setup fees.

Then, for internal \(v\) with children \(v_1,\ldots,v_k\),
\[
\boxed{C(v)=\sum_{j=1}^{k-q+1}C(v_{(j)})}
\]
where \(C(v_{(1)})\le\cdots\le C(v_{(k)})\) are the children's costs, with infinite values permitted.

**Upper bound.** Soundly certify any \(k-q+1\) children as safe, using the cheapest individual certificates. At most \(q-1\) children remain potentially unsafe; the parent cannot reach its unsafety threshold. Disjoint costs add.

**Lower bound.** Let a set of successful-branch actions on the parent fail to establish the safety of at least \(q\) children. In each such child there exists an unsafe local history with exactly the same results as all its selected checks. Independent product realizability lets us combine \(q\) of these histories, keeping every other child nominal; the parent becomes unsafe while every selected test still has the nominal result. Contradiction. Therefore at least \(k-q+1\) child certificates must be fully sound, with summed cost at least the cheapest \(k-q+1\). Induction over tree height proves the formula. Theorem A upgrades the argument from fixed sets to all adaptive policies along the nominal acceptance path.

**Operational reuse:** A signed, epoch-valid zero certificate makes its already-paid observation cost zero, but its effect-time version guard remains payable unless a stronger source binding proves it unnecessary. After a change to a leaf's valid-evidence status or sensor fee, the optimum cost metadata may be recomputed only along its ancestor chain: \(O(hb\log b)\) comparisons/arithmetic for fan-in \(b\) and height \(h\), excluding sensing, proof checking, and explicitly outputting the certificate. This is a full-cost extension of the source team's previous sensor-only threshold-tree recurrence, not proof that generic shared-DAG systems obey tree composition.

## Proposition D — general computational limitation

General Theorem A is NP-hard to optimize under additive costs. Given any weighted set-cover instance with universe \(U\) and sets \(S_q\), define one unsafe history \(h_u\) for each \(u\in U\), one nominal safe history \(h_0\), and a trusted Boolean observation \(q\) satisfying \(r_q(h_0)=0\) and \(r_q(h_u)=1\) iff \(u\in S_q\). With no version guard options, the unsafe history's distinguishing set is \(\{q:u\in S_q\}\). Thus the recertification optimum equals the original weighted set-cover optimum. This rules out a polynomial-time exact algorithm for arbitrary semantic histories unless P=NP. The bipartite and disjoint-tree cases identify precise tractable structural subclasses, not an unrestricted optimum algorithm.

## Theorem F — exact Bayesian-risk recertification with positive nominal prior

Let \(\mu\) be a probability measure on the **finite complete history space** \(\mathcal H\), with \(\mu(h_0)>0\); let \(\delta\in[0,1)\) be the permitted **posterior risk of unsafe authorization on any accepting transcript**. Assume the same deterministic authenticated observations and atomic guards. A policy is required to grant the nominal history and never grant any transcript with conditional unsafe-history probability exceeding \(\delta\), and may abstain elsewhere.

For \(S\subseteq Q\) let \(A_S=\{h:
orall q\in S,\ r_q(h)=r_q(h_0)\}\). Put \(U_S=\mu(A_S\cap\mathcal U)\) and \(G_S=\mu(A_S\setminus\mathcal U)\), so \(G_S\ge\mu(h_0)>0\). Then the exact minimum nominal successful cost is
\[
oxed{C^*_{\delta}(h_0)=\min_{S\subseteq Q}\{F(S):(1-\delta)U_S\le\delta G_S\}.}
\]
If no set meets the posterior-risk condition, the cost is \(+\infty\).

**Lower bound.** Fix a nominal accepting transcript of a deterministic policy, and let \(S\) be its checks. Every history in \(A_S\) generates the identical transcript by adaptive induction, including its final guard outcomes, hence is authorized. The posterior unsafe probability for that transcript equals \(U_S/(U_S+G_S)\), which must be at most \(\delta\). Rearrangement gives the displayed linear inequality. Thus every sound nominal accepting path has cost \(\ge C^*_{\delta}\).

**Upper bound.** Choose a minimizing \(S\); perform those checks, accept only their nominal outcomes and deny otherwise. The unique accepting transcript (if there are repeated queries, remove duplicates) has posterior unsafe probability \(U_S/(U_S+G_S)\le\delta\); the nominal history is accepted at price \(F(S)\). This is exact for the stated **Bayesian conditional** error contract, not an adversarial per-unsafe-history error guarantee. At \(\delta=0\) it discards zero-prior unsafe histories, while Theorem A's robust formulation must protect against *every* admissible unsafe history.

**Important failure of monotonic posterior risk.** Adding a check can increase conditional unsafe risk even if its result matches the nominal safe history: take three histories with masses \(1,9,1\), labeled respectively (nominal safe, alternative safe, unsafe). With no check the unsafe posterior is \(1/11\). A check yielding nominal result on histories 1 and 3 but a different result on history 2 eliminates the mass-9 **safe** alternative and increases unsafe posterior to \(1/2\). This is a counterexample to the commonly assumed monotonicity of posterior safety under additional successful evidence. It does not contradict robust zero-error monotonicity or expected information gain theorems. It implies a naive greedy "more matching evidence only improves safety" proof is invalid under this Bayesian contract.

Finite exact rational checks use integer masses and the inequality \((d-n)U\le nG\) for \(\delta=n/d\), with **no floating-point operations**. A new physical or noisy-sensor interpretation would require a different observation likelihood model.

## Proposition E — effect-time soundness under repeated transitions (conditional enforcement)

Suppose the current global invariant is \(K\), every mission-authorized action \(a\) has a verified precondition \(S_a\) such that \(K\land S_a\) implies the next state remains in \(K\), all environment transitions preserve \(K\), every effect is completely mediated by the atomic service modeled in the histories, and at each attempted effect the service runs a sound plan for that effect's actual admissible history family. Then by induction over effects and environment transitions, every reachable state preserves \(K\). This is a refinement under **trusted-boundary and model-adequacy premises**, not proof that deployed agents satisfy those premises. It is logically distinct from calculating the optimal proof cost.

## Important countermodels and limits

* **Missing source version:** unsafe history \(h\) with \(D(h)=\emptyset\) makes sound successful authorization impossible, however much computation is spent.
* **Untrusted/no snapshot consistency:** mixing observations from different epochs invalidates their meaning as functions of one history's coherent snapshot unless that interleaving is modeled and guarded.
* **Correlated subtrees/shared source:** Theorem C's combination lower bound may fail; semantic witness cover A remains the correct finite characterization.
* **Shared setup fees across both observation and guard sides:** Theorem B's specific directed closure gadget does not directly represent such a cross-side OR fee. No polynomial-time claim is made for this enlarged interface.
* **Known classification is not the stopping rule:** A safe mission label may already be fixed while further inspection reduces the price of effect-time version guards. The joint optimum can select that inspection.
* **Arbitrary policies that must accept all safe worlds:** May require expensive full decision trees; nominal-path optimum alone is not a worst-case/minimax optimum.
* **Real-time deadlines and actual hardware:** The model does not establish execution latency, source authenticity, absence of guard bypass, or operational safety without platform-specific evidence.

## Exact finite checks and audit

Run `python3 check_optimal_recertification.py` (requires Python 3 and NetworkX 3.6.1; integer arithmetic only). Fixed seed 20261114. The script compares:

* 1,350 arbitrary hypergraph instances: exhaustive powerset vs independent recursive adversarial-branching search;
* 960 bipartite priced instances: exact exhaustive cover vs network max-flow/min-cut;
* 960 bipartite setup-cost instances: exhaustive activation-cost cover vs a directed cut and independently checked maxflow conservation/capacity;
* 500 flat threshold instances: exhaustive product-history worlds vs recurrence;
* 225 nested threshold instances: exhaustive product histories vs recurrence;
* 1,200 exact Bayesian-risk instances: exhaustive subset search versus separate recursive nominal-history search.

Total: **5,195** comparisons, all passed. Checks are finite audits; the analytic proofs above establish general results. A new Lean kernel certificate would be a separate gate, and no such certificate is asserted here.

## Prior art reviewed this session

1. Liu, Tyszberowicz, and Beckert, *Analyses as First-Class Citizens in Model-Driven Development*, FASE 2026, DOI [10.1007/978-3-032-22774-4_10](https://doi.org/10.1007/978-3-032-22774-4_10): sound/complete analysis slicing and incremental recertification.
2. Zhang and Xu, *Certified Task-Conditioned Active Observability*, [arXiv:2609.28520](https://arxiv.org/abs/2609.28520): task-conditioned observer equivalence and optimal adaptive distinguishing trees.
3. NIGHTFALL repository's prior [compositional recertification v0.2](https://github.com/d3lefts/d3lefts/pull/472), [semantic fencing v0.3](https://github.com/d3lefts/d3lefts/pull/537), and [Lean semantic fence](https://github.com/d3lefts/d3lefts/pull/554): already established read-only semantic hitting sets, authority version-fence hitting sets, general Bellman recursion, and sensor-only threshold-tree composition. This note integrates **joint nominal-path optimization and typed infrastructure setup** with an exact primal-dual mincut subclass.
4. Standard antecedents: weighted set cover, certificate complexity, bipartite vertex cover/maximum flow, maximum-closure network design, threshold-tree zero certificate dynamic programming. These mechanisms are not claimed invented by NIGHTFALL.

**Independent review target:** Test whether existing admission-control / certification-complexity models already directly imply Theorems A--C under the same time/authority and cost contracts. Without that adversarial priority review, call this a scoped mathematical synthesis and new research-program capability, not a globally original universal optimal-recertification theorem.