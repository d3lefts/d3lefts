# ProductSphereZero via equivariant mod-two cobordism (alternative proof route)

**NIGHTFALL technical note — 2026-11-22.** Target: the single topological
dependency of the already pinned conditional causal proof
(`CausalPhaseConditional.lean` on main; independent continuation #1017).
**Status:** complete *paper-level* deduction from standard smooth
approximation, relative transversality, and compact 1-manifold boundary
parity. **NOT Lean-certified.** Not new topology; the result is
classical and also follows from Chan–Chen–Frick–Hull (2019), Remark 2.7.
No claim of novelty or priority.

## Exact goal and useful reduction

For n≥2 let N=n−1, M=S^N×S^N and G=(Z/2)² act by independently
negating the two factors. Let
W=R^N_(first-sign) ⊕ R^N_(second-sign).
For every continuous G-equivariant F:M→W, prove F has a zero.
The G action on M is *free* because no unit vector equals its negative.

This **single square case** suffices for every
`ProductSphereZero n r s` with r,s≤N: pad each output block
with zeros to N coordinates. A zero of the padded map is a zero
of the original. There is no need for a separate transversality
argument for each split r,s.

The conditional all-policy continuous-causal result now on main
only needs `ProductSphereZero n N N`, since the full 2N-stage
collision can be truncated to m≤2N. This is a useful formalization
reduction; **it does not discharge the topology premise**.

## Paper proof, independent of characteristic classes

**Step 1: a reference with exactly one zero orbit.**
Set e=(1,0,...,0)∈S^N. Define
F₀(u,v)=((u₁,...,u_N),(v₁,...,v_N)).
It is smooth and G-equivariant. Its zero set consists of
the four points (±e,±e), **one G-orbit**. At each point,
the derivative of F₀ along the 2N-dimensional tangent space
is an isomorphism: in the standard local hemispherical
coordinates it is the identity on the two N-coordinate blocks
(up to signs). Thus F₀ is transverse to zero.

**Step 2: reduction to smooth maps.**
Suppose a continuous G-equivariant F is nowhere zero.
Compactness gives min_M ||F|| = η>0. Approximate F uniformly
within η/4 by a smooth P on M, then equivariantly average:
F₁(p)=1/4 Σ_(g∈G) ρ(g)⁻¹P(gp), where ρ is the target
representation. Since ρ(g) acts orthogonally and F is
equivariant, ||F₁−F||_∞≤η/4. Hence F₁ is smooth,
G-equivariant, and nowhere zero.

**Step 3: an equivariant relative transverse homotopy.**
The straight homotopy H(p,t)=(1−t)F₀(p)+tF₁(p) is smooth
and G-equivariant. Its restrictions at t=0 and t=1
are already transverse to zero (the latter is zero-free).
By the ordinary *relative transversality theorem for smooth
sections of a vector bundle*, perturb the induced section
of (M×[0,1]×W)/G over (M/G)×[0,1], leaving a collar of both
ends unchanged, to make it transverse to zero everywhere.
Equivalently, since G is finite and acts freely on M,
one can make independent local bump perturbations in pairwise
disjoint orbit neighborhoods and translate them equivariantly.

The perturbed zero locus Z is a compact smooth
(2N+1−2N)=1 dimensional manifold with boundary, and so
is its finite free quotient Z/G. Its boundary consists of
the G-orbits of zeros at t=0 and t=1. There is **one** orbit
at t=0 and **none** at t=1.

**Step 4: parity contradiction.**
Every compact 1-manifold is a disjoint union of circles
and closed intervals. Each interval contributes two boundary
points and each circle contributes none. Thus its boundary
has even cardinality, contradicting the single boundary orbit.
Therefore the original continuous F has a zero.

This is a complete mathematical proof **conditional only on standard
classical smooth approximation and relative transversality
theorems**, not on Stiefel–Whitney cohomology. It does not
establish those background theorems in the NIGHTFALL Lean environment.

## Exact dependency budget and independent audit

- The base zero-orbit calculation and transversality are elementary
  coordinate mathematics and are natural small Lean goals.
- Smooth approximation on compact spheres, respecting a finite-group
  action via averaging, is another distinct, auditable goal.
- The central missing Lean bridge is **relative transversality of a
  section on (M/G)×[0,1] with boundary collars fixed**, plus a
  Lean proof of compact one-manifold boundary parity.
- Keep the zero theorem itself as an explicit hypothesis until those
  facts are actually imported or proved without theorem-shaped axioms.
- A polynomial or rational grid test of F₀ zeros does not certify
  the parity theorem for arbitrary continuous F.

### Attack checklist

1. n=2 (M=S¹×S¹), N=1: confirm the four zeros form one orbit
   and each derivative is nonzero on the relevant tangent line.
2. n≥2 arbitrary: check dimension 2N, free group action,
   local smooth chart and the derivative at all four points.
3. Verify the equivariant averaging formula uses the target
   action inverse (ρ(g)⁻¹), not merely an arithmetic mean of P(gp).
4. Require the relative perturbation to preserve both endpoint
   restrictions. Otherwise the parity count is not justified.
5. Confirm the zero locus on the quotient is a smooth 1-manifold;
   compactness and G-freeness eliminate orbifold/fixed-point issues.
6. Do not conflate absence of top Stiefel–Whitney formalization
   with absence of ordinary mod-two cobordism formalization.

## Relation to existing proof and possible next action

The mathematical paper proof in #995/#997/#1000 already uses the
known nonzero characteristic-class obstruction. This parity route is
a *second method of verifying the same classical topological input*,
not a second new discovery. On frozen Lean 4.36.0-rc2 and Mathlib
9d581dfff2e41de989072ea63abf3daf69311520, an immediate full
import of this route is not established in this session.

The cheaper **decisive** next source experiment is to locate an
available relative-transversality and manifold-boundary-parity API
compatible with the pin. If absent, importing a sufficiently small
formal one-dimensional cobordism mechanism is a separate substantial
formalization project. Do not replace it with an extra axiom and
report the theorem as kernel-checked.

**Certificate level:** paper proof relying on standard external
transversality facts, not unconditional Lean theorem; no novelty gate
passed. Source-level review by a distinct mathematician is still
needed before public theorem promotion.
