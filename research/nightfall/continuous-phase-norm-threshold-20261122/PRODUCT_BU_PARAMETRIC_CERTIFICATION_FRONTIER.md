# ProductSphereZero: exact parametric certificate frontier (2026-11-22)

**Status: supporting algebra under pinned Lean CI; topological existence theorem STILL OPEN in Lean.**
Primary problem: prove maximal \`ProductSphereZero n (n−1) (n−1)\` in the repository's
Lean v4.36.0-rc2 / Mathlib 9d581dfff2e41de989072ea63abf3daf69311520.
By merged #1024, this one theorem implies every pure-character submaximal split.
Merged #1015 supplies the genuine-reachable-history causal theorem **conditional** on this input.

## Objective, assumptions and external theorem

For n≥2 put N=n−1, M=S^N×S^N and G=(Z/2)^2, with separate antipodes.
Target representation is W=(R^N, first-sign)⊕(R^N, second-sign).
Every continuous G-equivariant F:M→W must have a zero.

The external classical theorem is Chan–Chen–Frick–Hull (2019),
arXiv:1902.00935, Theorem 2.5 / Remark 2.7.
The proof here gives no new topology or priority claim.

The existing Lean import from main supplies the *definition*
\`ProductSphereZero\`, not its proof. No custom theorem-shaped axiom may be
introduced to satisfy this obligation.

## Representation-first alternate engine

The model map
F₀(u,v)=(tail(u), tail(v))
has exactly four transverse zeros (±e,±e), one free G orbit.
The reference sign claims were already kernel-checked in #1024.

If F were zero-free, approximate it uniformly by a smooth P. The
pure-character Reynolds projectors are

P_U^χ(u,v) =
 [P_U(u,v) − P_U(−u,v) + P_U(u,−v) − P_U(−u,−v)]/4,

P_V^χ(u,v) =
 [P_V(u,v) + P_V(−u,v) − P_V(u,−v) − P_V(−u,−v)]/4.

They preserve continuity, produce exactly the required independent
sign laws, fix already-equivariant maps, are idempotent, and are
orthogonal to one another. The Lean module
\`ProductBUCharacterAverage.lean\` contains those source-specific
algebraic and continuous declarations; promotion depends on exact
current-head CI.

If the approximation error of P to equivariant F is uniformly ≤ε,
then the corresponding projected error is ≤ε by the triangle
inequality; this keeps F₁=P^χ nowhere zero for ε below the
nonvanishing margin. This uniform-bound lemma is not yet a named
Lean declaration.

## Explicit finite-dimensional perturbation avoids general section perturbations

For time t∈(0,1), consider the equivariant homotopy

H_{A,B}(u,v,t) =
  (1−t)F₀(u,v) + tF₁(u,v) + t(1−t)(Au,Bv),

where A,B are arbitrary N×(N+1) real matrices. This preserves the
endpoint sections at t=0 and t=1 and respects both separate sign
characters.

At each interior (u,v,t), the parameter-to-target derivative
(δA,δB)↦t(1−t)(δA u,δB v) is **surjective**.
For any desired target (w_U,w_V), one explicit right inverse is

δA_ij = (w_U)_i u_j / [t(1−t)],
δB_ij = (w_V)_i v_j / [t(1−t)].

Because u,v are unit vectors, δA u=w_U/[t(1−t)] and similarly for δB.
This finite algebra removes the need to postulate arbitrary
equivariant local perturbations. It is isolated in
\`ProductBUPerturbation.lean\`, with a pinned CI gate.

A **classical parametric transversality theorem** would now provide
some parameters A,B whose interior zero set is a 1-manifold, with
the endpoint map F₀ still regular and the endpoint map F₁ still
zero-free. This is a missing Lean theorem on the active pin.
The smooth family/submersion calculation alone does **not**
assert or certify generic transverse parameters.

## Orbit parity without constructing a quotient manifold

The original parity argument quotients the zero locus by G.
A potentially cheaper formal route stays upstairs.

The zero locus Z of a transverse homotopy is a compact smooth
1-manifold with boundary, with a free G-action and precisely four
boundary points at time 0 (and none at time 1).

Every compact connected 1-manifold is a circle or a closed interval.
A nontrivial group element preserving an interval component would
induce a self-homeomorphism of [0,1], which has a fixed point
by the intermediate value theorem, contradicting freeness.
Therefore G acts freely on the set of interval components: their
number is divisible by 4. Every interval contributes exactly two
boundary points, so the total number of boundary points is
divisible by 8. Four is impossible.

This replaces constructing the smooth quotient Z/G by the
classification of compact 1-manifolds, an interval fixed-point
argument, and a finite-orbit divisibility lemma.
**Those manifold and parity inputs are not yet Lean-certified.**

## Exact pinned source survey and failure modes

Mathlib (frozen version):
* \`Mathlib/Geometry/Manifold/SmoothApprox.lean\` provides smooth
  approximation, with caveats about manifolds and vector bundles.
* \`Mathlib/Geometry/Manifold/Bordism.lean\` explicitly calls its
  machinery the beginnings of bordism theory, and describes
  future work needed for bordisms and groups.
* The inspected pinned source contains no ready-made relative
  parametric transversality or compact 1-manifold boundary-count
  theorem with the precise hypotheses above.
* An external unaxiomatized ordinary Borsuk–Ulam Lean proof exists
  in the atlas-lean project, but it does **not** itself provide the
  required two-character product theorem or a frozen-pin import chain.
  Do not substitute it silently.

Failure/attack tests:
1. Verify no group element has a fixed point on unit sphere products.
2. Check the smoothing projector is **character-signed**, not plain
   arithmetic averaging (which would erase odd components).
3. Confirm the perturbations use both independent matrix blocks,
   with t(1−t) and correct group representation.
4. Check transversality is **relative to BOTH boundary faces** and
   that F₀ is actually regular at each of four zeros.
5. Check compact 1-manifold classification and interval-component
   stabilization argument, including circles and fixed-point-free
   nontrivial group permutations.
6. If source-level Lean code uses \`sorryAx\`, extra \`axiom\` or a
   hypothesis that silently contains ProductSphereZero, do NOT
   claim the global theorem was proved.

## Certification ladder and stop rule

* Existing real causal collision: pinned Lean **conditional** theorem.
* Maximal-to-submaximal pure-character reduction: pinned Lean theorem
  (#1024).
* Two-character averaging and parametric right inverse:
  candidate Lean modules, subject to current exact-head CI receipts.
* Classical topological zero: published mathematical theorem.
* **Unconditional Lean ProductSphereZero: OPEN.**
* Unconditional full causal phase-retrieval certificate: OPEN.
* Novelty and external specialist referee: independent future gates.

The cheapest remaining decisive experiment is to locate/import a
verified relative parametric transversality plus compact-1-manifold
boundary parity API on a compatible pinned source; if absent,
formalize that small topological engine independently rather than
retranscribing the already checked causal theorem.
