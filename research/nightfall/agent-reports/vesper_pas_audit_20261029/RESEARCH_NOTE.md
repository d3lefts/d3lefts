# Vesper / PAS: exact minimum-cost independent-reproof shield
**Checkpoint:** 2026-10-29 | **Owner:** Vesper | **Research attribution:** Devin J. Wright / NIGHTFALL | **Assignment:** [#129](https://github.com/d3lefts/d3lefts/issues/129) | **Status:** applied theorem with exhaustive internal model check; mathematical reduction is classical; novelty and real-dossier application pending.

## Question, assumptions, and claim
Let a finite **directed** graph \(G=(V,E)\) encode causal proof dependency: \(u\to v\) means a tainted or unverified claim \(u\) could contaminate the justification of \(v\). If raw citation edges point the reverse way, reverse them before applying the procedure. Cycles and mutually citing claims are permitted.

Let \(U,T\subset V\) be disjoint, nonempty collections of *untrusted roots* and *protected target claims*. Every intermediate \(v\notin U\cup T\) has nonnegative integer **independent reproof cost** \(w_v\). Auditing \(v\) means obtaining a **sound, source-independent new justification** of its mathematical truth with all inputs separately validated; only under this meaning does it intercept tainted upstream reasoning. Merely replaying an existing proof, citing the same dependency, running its checker unchanged, or establishing self-consistency of a citation cycle fails this assumption.

**Scoped theorem (classical graph reduction):** A subset \(S\subset V\setminus(U\cup T)\) shields \(T\) against every untrusted root in \(U\) precisely when the directed graph obtained by removing \(S\) has no path from \(U\) to \(T\). The minimum independent-reproof cost
\[
 C^*=\min_{S\subset V\setminus(U\cup T)} \left\{\sum_{v\in S}w_v:\, U\not\leadsto T \text{ in }G-S\right\}
\]
is computable exactly by one integer directed minimum cut, including graphs with cycles. If no allowed internal cut exists, report **INFEASIBLE**; never coerce infinity into a finite score. This algorithm plans *which claims would need true independent reproof*. It does not itself prove those claims.

## Proof
Assign \(B=1+\sum_{v\in V\setminus(U\cup T)}w_v\). Split every claim \(v\) into \(v_{\rm in},v_{\rm out}\) joined by a directed arc of capacity \(w_v\) if eligible and \(B\) if \(v\in U\cup T\). Replace each original dependency \(u\to v\) by an arc \(u_{\rm out}\to v_{\rm in}\) of capacity \(B\). Connect a new super-source to every \(u_{\rm in}\) and every \(t_{\rm out}\) to a super-sink, all with capacity \(B\).

Every eligible independent-reproof set \(S\) that hits all untrusted-to-target paths yields a finite cut of capacity **at most** \(\sum_{v\in S}w_v\), by taking the source-reachable region after deleting its split arcs. Redundant audited vertices need not be crossed by that cut. Conversely, any cut of capacity less than \(B\) crosses none of the forbidden arcs, so its crossed eligible split arcs form a valid hitting set with exactly the cut's capacity. If all source/sink cuts have capacity at least \(B\), an unprotected path survives every eligible vertex deletion, and the constrained problem is infeasible. Integral max-flow/min-cut gives the exact minimum; the proof does **not** depend on acyclicity, mutual independence of different roots, or a probabilistic risk model. The supplied implementation uses an Edmonds–Karp residual augmenting-path method; its worst-case running time is polynomial in the split graph size.

## Exact adversarial examples
For \(U=\{s_1,s_2\}\), \(T=\{t\}\), eligible claims \(a,b,c,d,e\), and dependencies
\[
s_1\to a,\ s_1\to b,\ a\to d,\ b\to d,\ d\to t,\quad
s_2\to c,\ c\to e,\ e\to c,\ e\to t,
\]
with costs \(w=(2,3,1,4,2)\) on \((a,b,c,d,e)\), the exact optimum is **5**, achieved by \(\{c,d\}\). The \(c\leftrightarrow e\) citation cycle is handled exactly. For a direct \(s\to t\) edge with endpoints forbidden from auditing, **no internal shield exists**. A zero-cost intermediate independent reproof correctly yields optimum zero.

A DAG has nilpotent adjacency matrix, hence spectral radius zero, even when an unverified seed reaches a protected claim via a directed path. Consequently **spectral radius zero is not a soundness certificate**; path interception with true rederivation is a different, strictly operationally relevant condition. The converse also matters: a cyclic dependency graph may admit a finite audit shield.

## Executable evidence
Run:
\`\`\`bash
python3 research/nightfall/agent-reports/vesper_pas_audit_20261029/audit_cut.py
\`\`\`
The standalone solver's node-split integer min-cut is checked against a **separately structured brute-force subset deletion oracle**. Deterministic suite: **4,096 directed simple graphs on four labeled vertices × 3 explicit cost vectors = 12,288 cases**, plus **3,000 seeded random 4–8-vertex directed cases**, including cycles and zero-cost audits. Total **15,288** exact pairwise optimum comparisons. Additional protected-endpoint, impossible direct-edge and deliberate zero-cost examples. All tests pass locally. Frozen receipt SHA-256 \`fcf872ac44c5f9f8d763c890aac841ba04d38f661a744a242d5d68d9239a7ea3\`; locally executed Python source SHA-256 \`a8ff3191bd5c351238156f9012af24ae4136fad416a3ea0a78f0a4cc46a3d9b9\`. CI/reviewer replay remains separate until completed.

## PAS application and strict limits
This formulation turns a proof-provenance DAG **or a cyclic mutually citing cluster** into a measurable, weighted independent verification assignment. It does not require fabricated independence probabilities. For the previously identified mutually citing group of five algebraic-geometry drafts, **no numeric optimum is asserted**: the actual citations, claim-level dependency directions, and reproof costs must first be reconstructed. A mutually citing five-paper graph by itself cannot certify any theorem's validity. The graph's edges model possible taint propagation, not mathematical entailment.

**Scientific priority:** directed weighted vertex cut and max-flow/min-cut are classical, and many software-security/provenance cut formulations already exist. This checkpoint is an applied PAS **audit-allocation instrument**, not a mathematical novelty claim or a substitute for independent formal proof. A stronger next scientific assignment is a proof **hypergraph** model where a conclusion can have alternative sufficient proof sets, plus correlated failure among purportedly independent auditors; test whether such costs admit a new exact parameterization or a sharp hardness theorem.

**Cross-review:** Lemnis attack the reproof independence and cut iff; Ryev implement a distinct network-flow checker with corrupted dependency edges; Axiom assess hypergraph-vs-graph entailment semantics. No public Original Finding until independent specialist review and human approval.
