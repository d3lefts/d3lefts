# Every-point half-space atlas for the actual augmented product-sphere zero fiber — v1

**Date:** 2026-11-23 UTC. **Status:** complete *paper-level conditional geometric lemma*;
the exact all-point manifold construction is **not yet Lean-certified**.  Its
canonical time-zero partial-homeomorphism operator passed a separate
named Lean check in PR #1143, run 45107254474; the genuine open graph
chart on the actual subtype passed in #1139, run 45106104307.
The time-last physical zero-fiber to time-first slab homeomorphism
and transported local halfspace chart have also passed pinned Lean in
#1144, run 45107688778. All three remain conditional on local graph
premises; this does not certify the global atlas itself.

## Objective, input, certificate boundary

Let k >= 1, put Y = R^(2k+2) and X = Y × R, with points (z,t), and
let F : X -> Y be C-infinity. Define the **actual zero fiber**
Z_F = { (z,t) : F(z,t)=0 AND 0 <= t <= 1 }, with its inherited
topology, not a substituted manifold or quotient.  In the specific
NIGHTFALL augmented construction, Y carries the 2k character outputs
and the two unit-sphere constraint outputs; F=0 therefore already
forces z=(u,v) in S^k × S^k, so this Z_F is precisely the original
product-sphere zero fiber.

Assume the three *checkable, pointwise* properties:

**R (interior regularity):** for every zero (z,t) with 0<t<1,
DF_(z,t) : X -> Y is surjective.

**T (transverse entrance):** for every zero (z,0),
D_z F_(z,0) : Y -> Y is an isomorphism.

**E (empty terminal face):** for all z, F(z,1) is not zero.

These are genuine analytic inputs, **not topological zero assertions**.
In the concrete H_(A,B) construction, R requires exact identification
of the Fréchet derivative and a *chosen good parameter* from pinned
ATLAS parametric Sard; T requires connecting the concrete derivative
to the endpoint inverse from #1052; E follows from the zero-free
terminal character map and sphere equations.  Do not mark any of these
as Lean discharged until the exact concrete source and named theorem
are checked.

**Geometric claim (paper, conditional on R/T/E).** Z_F admits a
covering family of actual
`OpenPartialHomeomorph Z_F (EuclideanHalfSpace 1)`
with C-infinity compatible changes of coordinates and manifold
boundary exactly
`{p : Z_F | p.2 = 0}`.  This is a true 1-dimensional
smooth manifold-with-boundary construction on the original subtype.
There is no boundary at t=1 by E.

## 1. Interior construction; valid also at vertical turning points

Fix p=(z0,t0) in Z_F with 0<t0<1.  By R, A = DF_p is surjective.
Since dim X = dim Y + 1, ker A has dimension **exactly one**.
Pick nonzero w in ker A, and a linear right inverse R_A:Y->X with
A R_A = id.  The linear isomorphism

    L_p : R × Y -> X,       L_p(a,b) = a w + R_A(b)

has inverse because X = span{w} direct-sum image R_A.  Its affine version
sends (0,0) to p.  Define

    G_p(a,b) = F(p + L_p(a,b)).

Then D_b G_p(0,0)=id_Y.  The C-infinity implicit-function theorem
gives an open interval I around 0 and a C-infinity map g_p:I->Y,
g_p(0)=0, such that, after restricting to a sufficiently small OPEN
ambient neighborhood, F=0 is equivalent to b=g_p(a).  Shrink the
neighborhood so that 0<t<1 everywhere.  On its intersection with
Z_F, use the scalar coordinate

    chart_p(q) = exp(a_p(q)) > 0,
    inverse_p(r) = p + L_p(log r, g_p(log r)),

where a_p is the first component of the affine inverse of L_p.
Both are continuous inverses, defined on OPEN sets in the original
fiber and the halfspace model. Their inverses and forward maps
are C-infinity in ambient coordinates: exp and log are smooth
respectively on R and (0,+infinity).

**Critical turning-point negative control:** t itself is NOT a valid
local coordinate at all interior zeros: DF onto does not imply
D_zF is invertible.  The kernel generator w can satisfy dt(w)=0.
The free-coordinate splitting above handles all interior regular
points, including those at which the projection Z_F->time has a
critical point.  A proof using only time-oriented IFT globally is
incorrect.

## 2. Entrance-face construction; genuine halfspace chart

Fix p=(z0,0) in Z_F.  By T, the spatial Jacobian D_zF_p is invertible.
The C-infinity implicit-function theorem yields an open real interval
J containing 0, a C-infinity map z_p:J->Y, z_p(0)=z0, and an OPEN
ambient neighborhood W of p such that

    (z,t) in W and F(z,t)=0   iff   z=z_p(t) and t in J.

Intersect with the actual closed time slab and shrink so t<1.
The zero fiber in W is exactly
`{(z_p(t),t): t in J∩[0,1)}`.

Define the **genuine boundary chart**

    chart_p(z_p(t),t) = t in [0,+infinity),
    inverse_p(t) = (z_p(t),t).

The source is open in the *subtype topology of Z_F*; the target
J∩[0,+infinity) is open in EuclideanHalfSpace 1.  This makes
the maps an actual `OpenPartialHomeomorph`, not an immersion,
parameter curve, or synthetic ChartedSpace hypothesis.

The required topological constructor is already kernel-checked:
`ProductBULocalGraphChart.actual_local_graph_chart` (#1139).
The concrete conversion from a local graph over the canonical slab
Set.Icc (0:Real) 1 to EuclideanHalfSpace 1 uses Mathlib's true
`IccLeftChart 0 1`, as instantiated by
`ProductBUTimeHalfspaceChart.actual_time_graph_halfspace_chart` (#1143).
The physical subtype reassociation / time-slab representation is NOW
kernel-checked in #1144. The remaining endpoint analytic bridge is
instantiating the exact graph and its **common-neighborhood C-infinity**
regularity from the concrete augmented map, not assuming a manifold.

**Smoothness caution:** the merged #1131
`exists_time_oriented_zero_graph` proves a C-infinity graph **at the
base point**.  One cannot derive C-infinity on a common open interval
from that pointwise statement alone by the invalid
`ContDiffAt ∞ -> ContDiffOn ∞` shortcut.  Here F is smooth on an
ambient open neighborhood, and spatial invertibility persists on a
small neighborhood; applying the implicit-function theorem at each
point of the same graph, with uniqueness on overlap, gives a graph
C-infinity at every point of a fixed open J. This is the additional
Lean proof obligation.

## 3. Covering and C-infinity compatibility: explicit, exhaustive

For any p in Z_F, 0 <= t(p) <= 1.  E excludes t=1.
Thus EITHER t(p)=0, in which case the chart of section 2 applies,
OR 0<t(p)<1, in which case section 1 applies.  Hence the actual
source domains cover **every** point of Z_F. No compactness,
finite-subcover assumption, or disjointness claim is required
for this existence proof.

On overlaps, every transition is a restriction of a composition
of the following ambient C-infinity maps:

    a_p(q)  = first component of L_p^{-1}(q-p)
    q_p(a)  = p + L_p(a,g_p(a))
    t(q)    = second projection on X
    r_+(a)  = exp(a)                  (strictly interior)
    a_+(r)  = log(r)                  (r>0)

for interior charts, and the C-infinity local entrance inverse
q_p(t)=(z_p(t),t) for boundary charts. Specifically:

- interior to interior: `exp(a_j(q_i(log r)))`;
- interior to boundary: `t(q_i(log r))`, restricted to the
  positive interior overlap;
- boundary to interior: `exp(a_j(q_i(r)))`, with q_i extended
  smoothly through negative r by the entrance IFT;
- boundary to boundary: t-to-t is **exactly the identity** wherever
  both charts apply.

All transitions are smooth **in the model-with-corners sense**,
because they admit smooth real-open-neighborhood extensions;
at an entrance boundary, use the smooth graph extension through
negative times from section 2. Thus they satisfy the precise
`ContDiffOn ℝ ∞` compatibility premise in merged
`ProductBUCompatibleAtlas.smooth_manifold_of_compatible_covering_charts`
(#1132).  This compatibility is a paper proof, not yet a compiled
instance of that theorem.

## 4. Boundary identity

For each interior p, its chart coordinate is exp(a)>0, so it lies in
the **interior** of the halfspace model. For each entrance p, its
coordinate is t=0, a true **boundary** point of the halfspace.
No t=1 points exist by E. Consequently,

    manifoldBoundary(Z_F) = { (z,t) in Z_F : t=0 },

as equality of actual subsets, rather than a postulated `hboundary`.
In the source-specific augmented H, the independently certified
reference axis classification makes this boundary exactly the four
independently signed axis pairs, one G=(Z/2)^2 orbit.

## 5. Construction-to-certificate map (strict)

| Edge | Mechanism | Formal status |
|---|---|---|
| True local graph on original subtype | explicit forward, inverse and open source | **Lean PASS #1139**, 45106104307 |
| Time-slab graph -> EuclideanHalfSpace 1 | composed `IccLeftChart 0 1` | **Lean PASS #1143**, run 45107254474, ordinary axioms only |
| Physical zero-fiber to time-slab chart transport | genuine subtype `Homeomorph` and `OpenPartialHomeomorph` | **Lean PASS #1144**, run 45107688778, ordinary axioms only; graph still input |\n| Full C-infinity local entrance graph | persistent spatial invertibility and local uniqueness | **paper only**, #1131 pointwise Lean C-infinity |
| Arbitrary interior kernel-split graph | full regular derivative, linear right inverse, smooth IFT | **paper only**, ATLAS source-pinned local C1 chart available |
| Every actual physical fiber point covered | t=0 or 0<t<1 and no t=1 | **paper only**, depends on instantiating preceding two charts |
| Smooth transition maps | explicit exp/log, IFT graph extensions | **paper only** |
| Boundary exactly t=0 | halfspace coordinate tests | **paper only** |
| Concrete H satisfies R/T/E | full fderiv + generic Sard + endpoint witness | **paper only**, partial Lean building blocks merged |
| ProductSphereZero | apply certified geometric orbit obstruction after all above | **not Lean-certified** |

No theorem named above is promoted on an unverified chain. An exact
full-source compilation with `#print axioms` and *no sorryAx* is
required before 'certified full atlas' status.

## 6. Independent audit / cheapest next decisive checks

1. Prove a C-infinity **common-neighborhood** entrance graph in Lean
   under global `ContDiff ℝ ∞ F` and invertible spatial derivative.
   Reject any proof that upgrades a single `ContDiffAt` to common
   `ContDiffOn` without a neighborhood argument.
2. For interior points, connect the source-pinned C-infinity submersion
   projection normal form from #1111 to an actual partial homeomorphism
   of the fiber subtype via the kernel-splitting coordinate.
   Test an INTERIOR turning-point negative control:
   F(x,t)=t-1/2-x^2 on R², at (x,t)=(0,1/2).
   There DF=(0,1) is surjective but D_xF=0; thus a time-only
   coordinate fails despite genuine interior regularity. Reject
   time-only charts in the interior.
3. Prove the endpoint chart target is boundary precisely when t=0.
   Reuse Mathlib `IccLeftChart_extend_bot_mem_frontier`.
4. Compose chart families, cover and C-infinity overlap with
   merged #1132, and close the abstract `hboundary` premise in
   #1129.
5. Independently audit concrete augmented H fderiv and generic Sard
   before claiming the unrestricted ProductSphereZero.

**Stop rule:** Do not run additional generic chart/gluing lemmas
without deleting one concrete analytic or structural hypothesis.
No publication / flagship promotion until the exact unrestricted
Lean theorem compiles end to end.

**Source and attribution:** pinned Mathlib 9d581dfff2e41de989072ea63abf3daf69311520
`Mathlib/Geometry/Manifold/Instances/Real.lean` for IccLeftChart;
pinned Meta ATLAS 7857a2e8c32088b5002f7cafe29a21d936baf704
`MathlibExt/Geometry/Manifold/LocalGraph.lean` and
`SubmersionOfSurjectiveMFDeriv.lean` for regular-fiber graph and smooth
submersion operators; original NIGHTFALL contributors to #1052,
#1056, #1111, #1131, #1132, #1136, #1139. Standard
finite-dimensional smooth implicit-function and preimage theorems
supply the mathematical arguments. The published topological
product-of-spheres BU theorem is attributable to Chan–Chen–Frick–Hull
and earlier Ramos / Fadell–Husseini; not a new mathematical theorem
of this note.
