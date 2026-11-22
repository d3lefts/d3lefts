# Augmented Euclidean regular-value representation for product-sphere Borsuk–Ulam

**NIGHTFALL research checkpoint, 2026-11-22. Status: independently formulated paper-level reduction, NOT Lean-certified topology.** This uses exact external ATLAS parametric Sard (git 7857a2e8c32088b5002f7cafe29a21d936baf704) and the published product-sphere theorem as references, not as newly discovered topology.

## Structural improvement: remove sphere charts from the Sard application

Put N=n−1≥1, U=V=R^(N+1), W=R^N×R^N and P=R^{N×(N+1)}×R^{N×(N+1)}. Let F0(u,v)=(tail(u),tail(v)) and let F1 be a smooth globally defined, separately antipodal equivariant map that is nowhere zero on S^N×S^N. Such F1 follows from the strict-positive nonvanishing margin and a sufficiently accurate character-preserving smooth approximation, if the original zero-free F existed.

For parameters A,B in P, define

    H_(A,B)(u,v,t) = (1−t)F0(u,v) + t F1(u,v) + t(1−t)(Au,Bv).

Rather than parameterize spheres by local charts, ADD their equations as TWO scalar output coordinates:

    E_(A,B)(u,v,t) = ( H_(A,B)(u,v,t), ||u||²−1, ||v||²−1 ).

This is an entirely Euclidean smooth map from R^(2N(N+1)) × R^(2N+3) to R^(2N+2). The regular zero fiber has expected dimension (2N+3)−(2N+2)=1. Every zero automatically has ||u||=||v||=1. The original independent antipodal actions preserve the zero set because they change the appropriate W sign and leave the scalar norm constraints invariant.

## Full parameter-family derivative surjectivity at every zero (paper proof)

Fix any (A,B,u,v,t) with E=0. Then u,v are unit, so no radial degeneracy. There are three cases.

**Case t≠0,1.** Given a desired target (yU,yV,a,b), choose variations δu=(a/2)u and δv=(b/2)v (δt=0), which give d(||u||²−1)=a and d(||v||²−1)=b. Let z=(zU,zV) be their induced contribution to dH. It may be arbitrary but is determined and finite. Choose parameter variations δA,δB by the explicit rank-one right inverse

    δA_ij = (yU_i−zU_i) u_j / (t(1−t)),

    δB_ij = (yV_i−zV_i) v_j / (t(1−t)).

Since ||u||²=||v||²=1, these choices give t(1−t)(δA u, δB v)=(yU−zU,yV−zV). Therefore dE is surjective.

**Case t=0.** H=F0. Its zeros on S^N×S^N are (u,v)=(±e0,±e0). Here derivatives in u,v of E0 give precisely tail variations plus two radial variations 2u0 δu0 and 2v0 δv0. Since both first coordinates are ±1, the spatial block d_(u,v)E0 is an isomorphism R^(2N+2)→R^(2N+2). Thus full dE is surjective. Moreover, the zero locus is transverse to the time boundary t=0: the one-dimensional kernel of dE has nonzero dt.

**Case t=1.** H=F1, which is nowhere zero on the product of spheres. Since E=0 imposes unit norms, this case has no zero, so regularity is vacuous.

All real t are covered: t<0 and t>1 satisfy t≠0,1 and the rank-one argument still applies. This point is essential because ATLAS's Euclidean parametricSard theorem is GLOBAL, not restricted to the open cylinder 0<t<1.

## Consequences of the exact external parametricSard theorem

Once the smoothness and surjective-derivative proofs above are kernel-checked for the encoded finite Euclidean spaces, the ATLAS theorem MathlibExt.Geometry.Manifold.ParametricSardWanted.parametricSard implies that the set of bad parameters has measure zero. Choose a good parameter from any positive-measure parameter ball. Then zero is a regular value of E_(A,B) globally, giving a smooth 1-dimensional zero locus. Restricting to 0≤t≤1 yields a compact 1-manifold-with-boundary, with four time-0 boundary points and no time-1 boundary points, provided the regular preimage and boundary-transversality structure is formalized.

**Remaining geometric gate:** the external Sard theorem itself does NOT assert that a regular preimage inherits a smooth manifold structure with boundary; this requires an implicit-function/submersion chart construction. Nor does it prove orbit parity. Do not promote the topology theorem by merely importing Sard.

## Parity upstairs, without constructing the quotient manifold

The finite group G=(Z/2)^2 acts freely on the zero locus by independent input antipodes, commuting with the projection to t. A compact connected smooth one-manifold with boundary is either a circle (no boundary) or an interval (exactly two boundary points), by ATLAS's separate pinned theorem compact_connected_one_manifold_with_boundary_classification. If a nonidentity g∈G preserved an interval component, its induced continuous self-map of [0,1] would have a fixed point by the intermediate value theorem, contradicting freeness. Thus G acts freely on the finite set of interval components. Their number is divisible by four, so the total number of boundary points is divisible by eight. But the four reference zeros at t=0 give exactly four boundary points. Contradiction.

## Why this matters / independent adversarial checklist

This augmented-output representation reduces the previously proposed relative sphere-manifold transversality problem to a Euclidean parametric Sard theorem that has source-pinned **compiled** external Lean code. The key new operator is adding the two sphere constraints to the target, which makes full derivative surjectivity checkable via a two-block rank-one parameter right inverse plus radial variations. It does not by itself establish a new topological theorem or a kernel proof.

Audit: dimensions p=2N(N+1), m=2N+3, codomain=2N+2; all t including t<0 and t>1; derivative at t=0; zero-free t=1; norm constraints under both antipodes; compactness of time-restricted fiber; boundary transversality and no critical tangency at endpoints; finite connected components; interval fixed-point argument; exact ATLAS source version/axioms; no admitted theorem or hidden orbit-parity assumption.

## Formal certificate agenda

1. Exact Lean source and ordinary-axiom audit of ATLAS parametricSard and 1D classification (PR #1048); parent #1032 contains the explicit matrix right inverse and character projectors.

2. Kernel proof of product-sphere smooth input extension and approximation (#1041 merged; #1037 exact-head pass; #1046 under CI).

3. Kernel proof of E and its full derivative surjectivity, partitioned into t≠0,1, t=0 and vacuous t=1.

4. Kernel proof of compact regular preimage as smooth 1-manifold-with-boundary, plus G-action on finite interval components.

5. Apply precise ATLAS classifications and derive mod-8 contradiction; finally produce an unconditional theorem of exact imported type ProductSphereZero n (n−1) (n−1) with #print axioms ordinary only, then compile the full causal threshold.

**CURRENT STATUS: paper representation and proof roadmap, NOT a completed step 3–5.** Attribution: ATLAS authors for Sard/1D classification; mathematical product-sphere BU published Chan–Chen–Frick–Hull; NIGHTFALL parallel #1032 perturbation right inverse and #1024 parity route.