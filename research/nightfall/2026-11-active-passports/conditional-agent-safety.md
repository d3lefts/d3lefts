# NIGHTFALL Proof Passport v14 — Conditional Arbitrary-Agent Safety

**Date:** 14 November 2026 (US Eastern) · **Research lead:** Devin J. Wright · **Construction:** AI-assisted · **Tier:** Lean-certified implication; physical satisfaction unverified.

## Statement and assumptions

For an arbitrary state space, action space, observation and epoch types, `Boundary.safe` is an invariant; `Boundary.plant` is a nondeterministic effect relation, and `compatible` specifies a source- and evidence-consistent set of actual states. A proposed action `a` is `Admissible e o a` only when **every modeled successor of every compatible safe state is safe**. Every physical trace step must be either (a) an effect-time current-epoch, compatible, admissible plant transition, (b) a rejection/stutter, or (c) a separately invariant-preserving environment transition.

Then for **every arbitrary proposer** `proposal : ℕ → Action`, all natural-number positions of every trace beginning in the invariant and satisfying complete mediation remain safe. This is not an unconditional claim about any actual superintelligent agent or continuous-time system.

## Proof and provenance

[PR #528](https://github.com/d3lefts/d3lefts/pull/528), `research/nightfall/formalization/agent_safety/ArbitraryAgentSafety.lean`, six named declarations including `arbitrary_agent_all_horizons_safe`, `admissible_maximal` and `no_declared_bad_state`. [Pinned Lean 4.36.0-rc2 run #43639554615](https://github.com/d3lefts/d3lefts/actions/runs/43639554615), source SHA256 `a335fffdddfeb81124159794db8c0289ad3afedc65c659946190d5f7da4f1397`, strict axiom audit reporting no additional axioms. Mainline original source can be traced via the merged PR.

Mechanism: universal safety-admissibility predicate plus one-step invariant preservation; induction on trace length. Computability of the admissibility test is **not** implied.

## Operational evidence, counterexample operators and limits

The separate [#530](https://github.com/d3lefts/d3lefts/pull/530)/[#531](https://github.com/d3lefts/d3lefts/pull/531)/[#517](https://github.com/d3lefts/d3lefts/pull/517) ControlArena IaC Fast prototype protects one local service-owned JSON effect, with cross-UID HMAC/peer checks, Docker isolation and source-policy revocation, not AWS deployment.

[Draft PR #554](https://github.com/d3lefts/d3lefts/pull/554) extends the local handler with complete-request bounded worker, nonce-epoch rollover and explicit operational assumption audit. Pinned Lean source and source-matched integration succeeded on [run #43662280902](https://github.com/d3lefts/d3lefts/actions/runs/43662280902) and [run #43662280945](https://github.com/d3lefts/d3lefts/actions/runs/43662280945), **at the PR head**, but #554 is not merged.

Attempt an unmediated effect, an observation that excludes the actual state, an environment step breaking the invariant, an unregistered source write, epoch race, malicious privileged issuer and an effect outside the declared CloudFormation model. These attack hypotheses, not the proved implication. Runtime/kernel/host-root trust, absence of bypass, accurate plant/environment models, physical actuation and full response availability are not certified.

**Independent human security review:** none. **Historical originality:** not claimed; reference monitors, invariance and shielding precede this work. **Next gate:** instrument a real external effect interface and demonstrate complete mediation against independent red-team probes before any deployment-level claim.
