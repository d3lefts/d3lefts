# Agent Safety Under Abstraction — September 2026

**Researcher:** Devin J. Wright. **Research scope:** runtime safety, provenance, guardrails, formal observability and distributed agent authorization. **Status:** substantial theorem manuscript plus finite tests and a September 30 independent revision audit; external refereeing pending.

This 43-page manuscript precedes and structurally grounds several later research programs. Principal claims:

- **Obstruction / descent:** F is exactly recoverable from observation α iff it is constant on each observation fiber (a classical factor criterion, explicitly credited as prior art).
- **Maximally permissive sound enforcement:** under an observation obstruction, unavoidable false denials arise; randomized guards cannot evade the exact fiber-level constraint under the stipulated universal soundness contract.
- **Minimal additional sensors:** selecting observables that remove all harmful indistinguishable pairs is a weighted set-cover problem.
- **Provenance compression:** policy-specific syntactic congruences characterize sufficient information preserved through principal chains; taint-set summaries require algebraic restrictions on the policy monoid.
- **Finite windows and composition:** state history, uncontrollable actions, global controlled invariants, centrally fused views and independently acting local guards have separate exact sufficiency criteria.

The manuscript reports an AgentDojo-ground-truth analysis: among 25 side-effect injection tasks, 23 have a tool name shared with legitimate actions; on the scoped 60-task set, a universally sound name-only guard must deny 45 legitimate tasks. These are specific finite-instance counts, **not an end-to-end production defense evaluation**.

A September 30 reconstruction replay checked 58 finite ASUA properties, identified an attachment-shape bug in a related policy simulator, and emphasized the difference between synthetic reference replay and interpreter-level empirical evidence. No live-model claims arise from that validation.

**Original research:** *Agent Safety Under Abstraction: Descent, Provenance, Closure, and Compositional Sufficiency*, 43-page revised manuscript archived in the user's Library, September 2026 (final revision accessed October 8). **Binary source/public checker upload pending**. Classical factorization, Myhill–Nerode equivalence, supervisory control, and set cover retain their earlier attribution.
