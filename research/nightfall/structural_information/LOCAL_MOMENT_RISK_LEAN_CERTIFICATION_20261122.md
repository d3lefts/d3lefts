# Exact local-moment risk transfer — scoped named Lean source certificate

**Date 2026-11-22. Status: pinned Lean kernel evidence for the exact finite squared-risk conservation implication; full PR #988 biconditional and recursive-tree interface not yet formalized.**

Original paper work: [merged #988](https://github.com/d3lefts/d3lefts/pull/988), *LOW_DEGREE_QUERY_RISK_CONSERVATION_20261121.md*, and [dimension-controlled comparison #990](https://github.com/d3lefts/d3lefts/pull/990). This is a formal verification of part of that paper, **not a new mathematical theorem claiming worldwide originality**. Underlying moment matching and k-wise independence are classical.

## Kernel-checkable claims

Two source files:
- `research/nightfall/formalization/structural_information/LocalMomentRisk.lean`
- `research/nightfall/formalization/structural_information/LocalMomentAtoms.lean`

**Theorem 1:** `Nightfall.LocalMomentRisk.exact_squared_risk_transfer`. Given a finite input index \(I\), finite common alphabet \(A\), two arbitrary real weight tables \(\mu,\nu\), a function \(f\) expressed as a finite sum of components each using ≤d input coordinates, and a leaf system \(t\) expressed as mutually exclusive and idempotent path indicators each using ≤q input coordinates, if the expectations of all functions of ≤k input coordinates agree under the two weight tables, then at \(k≥\max(2d,d+q)\)
\[
  \sum_x\mu(x)(f(x)-t(x))^2 =
  \sum_x\nu(x)(f(x)-t(x))^2.
\]

**Theorem 2:** `Nightfall.LocalMomentAtoms.functional_moments_of_atom_marginals`. The original law-side condition — identical masses on **every exact joint atom** of ≤k original coordinates — implies the functional expectation condition. This uses a finite partition of the full table by the restriction map, not a new probabilistic axiom.

**Combined theorem:** `Nightfall.LocalMomentAtoms.exact_squared_risk_of_atom_marginals`, directly combining the two. It is valid for any finite nonempty alphabet, without independent coordinates, density domination, positivity or boundedness of the target components.

The leaf system's idempotent and exclusive path indicators ensure that the square of the tree uses **only q coordinates**, not 2q. The proof controls three terms separately: \(f^2\) at ≤2d, \(ft\) at ≤d+q and \(t^2\) at ≤q. The named Lean proof is not assuming these term expectations already match; it derives that from the local supports and the atomwise marginal data.

## Exact-source named kernel receipts

Original source-head named Lean run [#45056943338](https://github.com/d3lefts/d3lefts/actions/runs/45056943338): `LocalMomentRisk.lean` compiled, exact named declarations and allowed-axiom policy passed.

Further source-head named Lean run [#45057135352](https://github.com/d3lefts/d3lefts/actions/runs/45057135352): both `LocalMomentRisk.lean` and `LocalMomentAtoms.lean` compiled; named declaration, `#print axioms`, and allowed kernel axioms passed.

Git blobs held unchanged for reconciled main-based PR:
- `LocalMomentRisk.lean`: `be9073504ae43fd8dd719b7bb7db799b47a5ded7`
- `LocalMomentAtoms.lean`: `50291b712f1c843e89bd0d89fa7418b3541f7592`

Toolchain: `leanprover/lean4:v4.36.0-rc2`; Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`. Dedicated `.github/workflows/nightfall-local-moment-risk-lean.yml` pins compiler source and prints dependencies. The frozen 67-entry historical Lean registry is **not updated**. Pending exact blob custody is only `unreviewed-source`, not a claim of full theorem certification.

## Outstanding mathematical interfaces

1. Prove that **every** finite-depth deterministic adaptive query tree is representable by the `LeafSystem` interface, including repeated queries, redundant branches and zero-probability leaves; no tree-semantic equivalence proved here.
2. Kernel-certify **the converse** of the paper's if-and-only-if claim: universal risk equality for all [0,1] targets/trees forces all marginals through \(\min(n,\max(2d,d+q))\) to match.
3. Formalize the two general even-parity sharpness constructions for 2d and d+q, beyond finite numerical examples.
4. Formalize higher loss moments and Bernstein polynomial approximate-tail transfer separately (paper Theorem 3b).
5. Obtain non-author semantic review and dated literature-implication audit; known prior art in k-wise independence / fooling must be credited. Do not automatically promote to Novel Contribution.

**Result status:** the ordinary marginal-to-risk implication is a genuine **named Lean kernel-checkable theorem on the explicit leaf-system interface**, not a mere numerical test. The entire original paper theorem involving arbitrary syntax trees and the iff remains open.
