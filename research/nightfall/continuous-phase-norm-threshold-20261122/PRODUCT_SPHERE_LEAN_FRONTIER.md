# ProductSphereZero continuation — source-pinned certificate frontier (2026-11-22)

**Status: the topology lemma is NOT Lean-certified.** This is a scoped continuation of
NIGHTFALL PRs [#995](https://github.com/d3lefts/d3lefts/pull/995),
[#997](https://github.com/d3lefts/d3lefts/pull/997),
[#1000](https://github.com/d3lefts/d3lefts/pull/1000), and
[#1008](https://github.com/d3lefts/d3lefts/pull/1008).
Do not merge this branch as an end-to-end certificate or publish a priority claim.

## Exact obligation and source

Let \(S^{n-1}\subset\mathbb R^n\).
For \(r,s\le n-1\), any continuous pair
\[
F_U:S^{n-1}\times S^{n-1}\to\mathbb R^r,\qquad
F_V:S^{n-1}\times S^{n-1}\to\mathbb R^s
\]
with sign laws
\[
F_U(-u,v)=-F_U(u,v),\quad F_U(u,-v)=F_U(u,v),\\
F_V(-u,v)=F_V(u,v),\quad F_V(u,-v)=-F_V(u,v)
\]
has a joint zero. This is precisely `ProductSphereZero n r s` in
`ProductSphereObstruction.lean`, a **defined proposition** with no proof or
introduced axiom. Keep the witness in the domain of both unit spheres. Do not
silently replace continuous-on-sphere by global continuity, or separate sign
characters by simultaneous oddness.

External primary source: Chan, Chen, Frick, Hull,
[*Borsuk–Ulam theorems for products of spheres and Stiefel manifolds
revisited*](https://arxiv.org/abs/1902.00935) (2019), Theorem 2.5 and
Remark 2.7. The result is already known in topology. In a bundle formulation
it follows from the nonzero top Stiefel–Whitney class
\(\alpha^r\beta^s\) on
\(\mathbb RP^{n-1}\times\mathbb RP^{n-1}\).

## One obstruction calculation handles both norm regimes

The pure two-character obstruction for an annulus is
\(\alpha^{n-1}\beta^{n-1}\ne0\).

For a known norm, introduce a **mixed-character coordinate**
\(g_M(u,v)=\langle u,v\rangle\). This function is odd under *either*
individual antipode. Choose \(r=n-1,s=n-2\) pure U/V coordinates.
The full top class is
\[
  \alpha^{n-1}\beta^{n-2}(\alpha+\beta)
   =\underbrace{\alpha^n\beta^{n-2}}_{0}
    +\alpha^{n-1}\beta^{n-1}
   =\alpha^{n-1}\beta^{n-1}\ne0 .
\]
A common zero thus also has \(u\perp v\), producing equal-norm
signals \(u\pm v\). This offers one common
\((\mathbb Z/2)^2\) equivariance/obstruction engine for the annulus and
known-sphere cases, rather than treating the Stiefel assertion as an unrelated
primitive. The product-to-Stiefel approach is already in Chan et al.; it is a
**proof-engineering transfer, not an original topological theorem**.

The Lean file **only certifies the truncated mod-two coefficient arithmetic**
for these expressions. It does not identify the coefficient grid with
topological cohomology, construct bundle classes, establish the
nonvanishing-section principle, or close `ProductSphereZero`.

## Pinned environment and reproducible checks

* Lean toolchain: `leanprover/lean4:v4.36.0-rc2`
* Mathlib commit: `9d581dfff2e41de989072ea63abf3daf69311520`
* Compiler source: `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`
* Workflow: `.github/workflows/nightfall-product-sphere-obstruction.yml`
* Source: `research/nightfall/formalization/finite_field/ProductSphereObstruction.lean`

A successful pinned CI run establishes **only**
`monomial_nonzero`, `mixed_top_coefficient` and
`mixedProduct_nonzero` with the allowed axioms. It must not be reported as
a topological zero or a causal phase-retrieval certificate.

## Independent-audit and continuation gates

1. Confirm that the exact Lean proposition matches the product-sphere
   primary source; explicitly inspect both independent sign characters,
   sphere restrictions, finite codomain blocks, and continuity-on-subspace.
2. Reconcile #1008's checked genuine-prefix collision algebra with a
   witness from this exact interface. A zero assumption must remain explicit
   until independently discharged.
3. A proof of `ProductSphereZero` must use *no new theorem-shaped axiom*.
   Choose a genuinely formalized topological engine: equivariant obstruction
   theory / mod-two degree / multicolour Tucker. Mathlib on the frozen pin
   lacks the required full product theorem. Mario Ullrich's separate
   [Lean-ContMeasurements](https://mario-ullrich.github.io/lean.html) proves
   ordinary Borsuk–Ulam through Tucker, but uses a newer Lean release and
   does not itself supply the product theorem.
4. As a cheap decisive experiment, inspect whether a two-colour cubical
   Tucker lemma can be stated independently of the later Mathlib API.
   Test first for \(S^1\times S^1\), rank \((1,1)\), and establish the
   equivariant boundary parity without any unproved topological lemma.
   A finite test cannot prove the continuous theorem. Escalate to a
   full general-dimension proof only after this bridge compiles on the pin.
5. Before promoting to an unconditional result: source-exact Lean compile,
   kernel recheck, `#print axioms`, a second independent source-level
   mathematical audit, and same-model prior-art review.

**Stop rule:** if the topological bridge cannot be formalized on the pin,
retain a precisely named *conditional* theorem. Do not hide the gap by a
constant of type `ProductSphereZero`, `sorryAx`, or a postulated bundle
class.

## Discovery graph

Continuous causal rows → two genuine prefixes → separately equivariant
test map → (mixed-character for known sphere) → nonzero truncated
coefficient → **UNFORMALIZED topological zero bridge** → causal transcript
collision in #1008 → signal nonidentifiability.

**Scope:** deterministic continuous vector-valued selectors; exact
real squared-linear readings. Randomized, discontinuously selected rows,
non-scalar blocks, and noisy minimax results are separate obligations.
