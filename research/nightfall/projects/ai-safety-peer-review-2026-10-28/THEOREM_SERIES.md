# Series map: mathematical results and exact scopes

This is an integrated **reading guide**, not a substitute for the primary mathematical proofs in the September manuscripts.

## Core model

Worlds or executions form a set X, with safety target F: X → {0,1}; F(x)=1 means acceptable. An observer receives R: X → V. Two worlds are indistinguishable at that view when R(x)=R(y).

**T01 / static descent (classical factor theorem):**

F=d∘R for a set function d on R(X) **iff** every pair with equal R has equal F.

**T02 / restricted protocol correction:** for a pre-specified class P of R-limited algorithms, descent is necessary; exact realization additionally requires the induced decoder d∘R to lie in P. A computationally unbounded set function can still be uncomputable as an algorithm. **Do not reuse the invalid universal converse from the older boundary draft.**

## Sound observation-level enforcement

**T03 / maximum safe admission:** in a one-shot proposal model with the complete adversarial execution space X fixed,

g(v)=1 exactly when every x with R(x)=v has F(x)=1.

Any universally sound R-limited admit decision permits at most the executions g permits. Randomization provides no escape from the zero-unsound-admission requirement.

**T04 / statistical obstruction:** for two worlds with opposing labels and complete observable record laws P and Q, every shared final-decision kernel has total two-world error ≥ 1−TV(P,Q). This is classical two-point testing. Adaptive interfaces require explicit query/reply assumptions and record laws.

## Evidence repair and provenance

**T05 / finite feature repair:** given finite candidate trusted observables with fixed costs, each separates a subset of obstructing execution pairs. An adequate refinement covers every obstructing pair. Minimum cost is a weighted-set-cover instance.

**T06 / authored-evidence limit (conditional):** when an adversary can mimic honest self-descriptions across a bad/good pair, self-reported intent, reasoning or provenance cannot split the obstruction. The mimicry premise is essential.

**T07 / policy-dependent provenance:** ordered delegation chains may require a policy-specific equivalence-class summary. Unordered taint sets suffice only for appropriate algebraic policy classes; correctness and authentication of labels are separate premises.

**T08 / history:** some finite-memory safety monitors have no sufficient fixed-length sliding window, owing to neutral padding and history-dependent requirements.

**T09 / controlled invariance:** sound authorization in a transition system concerns controllable and uncontrollable future effects. View sufficiency for a state predicate need not imply sufficiency for closed-loop control.

## Capabilities and composition

For monotone closure TC, a reference class Q of compliant configurations has reach Γ(Q)=⋃_{q∈Q}TC(q). A realized J escapes when Δ(J,Q)=TC(J)\Γ(Q) is nonempty. This union **must not** be newly closed: doing so combines different counterfactual configurations.

**T11 / cardinality budget:** if Q_k contains all grant sets of size ≤ k and η(t) is the least size of a grant set deriving t, then t lies outside Γ(Q_k) iff η(t)>k.

**T12 / graded review:** let c be the maximum size of an inclusion-minimal generating set over derivable atoms. For every grant set G, TC(G) is the union of TC(S) over subsets S⊆G with |S|≤k **iff** c≤k. Underlying closure/Carathéodory results predate this series; novelty claims require specific prior-art adjudication.

**T13 / collective viewing:** a central coordinator with the joint view can distinguish some cases no individual local veto guard can decide. A centrally realizable decoder does not automatically yield decentralized enforcement.

## Relative oversight limits and application

The **Three Ceilings** distinguish (i) observational indistinguishability, (ii) computational decoding under fixed resources, and (iii) the provenance/trust/actuation premises supporting a guarantee. Interactive human investigation can change the regime through new information and additional tools.

**T14 / SourceBound consequence:** identical publisher-authored evidence can coexist with different real-world truths; therefore a document-only admission gate cannot guarantee universal external truth. SourceBound aims at traceable assertions supported by a restricted grammar and independently verified source bindings.

## Citation and status discipline

T01, T04 and much of T03/T05/T12 use known mathematical theory. Agent-specific hypotheses and consequences are the research subject. **Fresh independent finite checker: 27,740 tests; finite-model evidence only.** September formal supplement's 66 checks and ASUA's historical 58 tests are distinct runs. External theorem audit, novelty validation, and complete archived source certificates remain separate obligations.

See [EVIDENCE_AND_LIMITATIONS.md](EVIDENCE_AND_LIMITATIONS.md), [SourceBound evaluation](SOURCEBOUND_EVALUATION.md), [primary source map](README.md).
