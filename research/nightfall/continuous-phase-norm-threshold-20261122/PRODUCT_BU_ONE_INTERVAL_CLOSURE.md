# Product-sphere topological closure: one interval, no parity counting

**NIGHTFALL proof-engineering revision 2026-11-22.**
**Status:** rigorous paper-level lemma using the classical classification of compact
one-manifolds with boundary. NOT a Lean proof of the full product-sphere zero theorem.
Its intended formal source is the verified-on-pin atlas-lean classification
from \`MathlibExt/Geometry/Manifold/OneDimensional.lean\`.

## Strongest available representation

For n≥2, the maximal pure-character theorem is enough
(merged kernel lemma \`square_implies_productSphereZero\`).
Use the free group G=(Z/2)×(Z/2) acting on
M=S^(n−1)×S^(n−1). The reference F₀=(tail u,tail v) has four regular
zeros forming one G-orbit (merged reference-orbit Lean algebra).

For a hypothetical zero-free equivariant F, form a smooth equivariant
homotopy between F₀ and F. The exact averaged approximation and
parameter-surjectivity modules are present in draft #1032.
A generic-regularity argument via the source-compatible
\`MathlibExt.Geometry.Manifold.ParametricSard\` would make the zero locus
Z a compact one-manifold with boundary, carrying a free continuous
G action. Its boundary is exactly the single G-orbit of the four
reference zeros.

## The shortest terminal contradiction

The following lemma needs no quotient manifold and no finite counting:

**Lemma.** A compact one-manifold with boundary Z, with an action of a
finite group G by homeomorphisms, cannot have BOTH
(i) an everywhere-free G-action and
(ii) a nonempty boundary forming a single G-orbit,
**provided** every nontrivial element of G is a fixed-point-free
involution (as for G=(Z/2)^2).

More generally, for any finite freely acting group the same conclusion
holds because the interval-stabilizing endpoint-exchanger has a fixed
point even without being an involution.

**Proof.** Choose a boundary point z. Its connected component C contains
a boundary point and is a compact connected one-manifold with boundary,
hence homeomorphic (indeed diffeomorphic) to [0,1]. In particular it
contains exactly two boundary points z and z', distinct. Since the whole
boundary is one G-orbit, there is g∈G with g·z=z'. Freeness implies g≠1.
The homeomorphism g sends the connected component C of z to the
component of z', which is C. Thus g restricts to a self-homeomorphism
of the closed interval C. Every continuous self-map of [0,1] has a
fixed point (intermediate value theorem applied to h(t)−t). Therefore
g has a fixed point in C, contrary to freeness. QED.

**Important hypotheses and checks:**
- Connected component C is compact (components are closed in a
  compact Hausdorff manifold).
- C must be a manifold with boundary and its boundary must agree with
  the intersection C∩∂Z. This follows from local connectedness of
  manifolds (components are open).
- The boundary orbit is **exactly** the four reference endpoints,
  because the other homotopy endpoint F₁ is zero-free, and the
  interpolating section is transverse relative to endpoints.
- The action preserves Z and the manifold boundary; in particular,
  g maps C to C because it maps z into C.
- One does not need to prove that the entire Z has finitely many
  connected components, count boundary points modulo 8, or
  construct the smooth quotient Z/G.

## Formal dependencies after this reduction

Pinned external sources compiled successfully with repository CI:
- ImageNull, Sard, ParametricSard: [Actions #45053595770](https://github.com/d3lefts/d3lefts/actions/runs/45053595770)
- RiemannianMetricExistence, OneDimensional (and the preceding):
  [Actions #45053843238](https://github.com/d3lefts/d3lefts/actions/runs/45053843238)

External code: Meta atlas-lean at commit
\`7857a2e8c32088b5002f7cafe29a21d936baf704\`, originally
Lean v4.35.0, directly compiled on NIGHTFALL 4.36.0-rc2.

Remaining nontrivial Lean work is to (1) construct the regular
one-dimensional zero-locus with boundary from a generic equivariant
parameter family, and (2) apply the connected-component restriction
and the imported classification/fixed-point lemma.

**Certification status:** only the referenced source-local modules,
algebraic symmetrization and perturbation parameters have kernel
receipts. The end-to-end ProductSphereZero theorem is still open.
Do not replace (1) by a postulated zero-locus manifold and call the
terminal certified. Independent non-author topology audit required.

## Cheapest next checker

Prove an abstract Lean lemma that if a compact smooth 1-manifold with
boundary carries a free finite-group action and has a nonempty
boundary that is a single orbit, then False, using the atlas-lean
classification and IVT. Then separately prove the generic zero-locus
manifold instance from parametric Sard, keeping source imports and
assumptions inspectable.
