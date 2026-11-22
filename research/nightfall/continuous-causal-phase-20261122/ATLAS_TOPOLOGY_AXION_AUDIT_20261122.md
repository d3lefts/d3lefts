# External topology engine: axiom-exact upstream certification gate

Date: 2026-11-22. NIGHTFALL flagship: continuous causal real phase retrieval.

## Objective

Unconditionally prove ProductSphereZero n (n−1) (n−1) in the pinned Lean kernel for all n≥2, then compose the kernel-certified topology theorem with the existing conditional causal theorem in main from #1015.

## Strongest external source checked

Facebook Research ATLAS Lean, immutable git commit 7857a2e8c32088b5002f7cafe29a21d936baf704: https://github.com/facebookresearch/atlas-lean/tree/7857a2e8c32088b5002f7cafe29a21d936baf704.

Active NIGHTFALL pin: Lean v4.36.0-rc2, Mathlib 9d581dfff2e41de989072ea63abf3daf69311520.

Parallel compatibility check [run 45053843238](https://github.com/d3lefts/d3lefts/actions/runs/45053843238) compiled five source-pinned files (ImageNull, Sard, ParametricSard, RiemannianMetricExistence, OneDimensional) against the active pin. That was compatibility, NOT theorem-level standard-axiom closure or ProductSphereZero.

## Exactly named external theorems

1. MathlibExt.Geometry.Manifold.SardWanted.sard_theorem (manifold Sard).

2. MathlibExt.Geometry.Manifold.ParametricSardWanted.parametricSard: a smooth Euclidean parameter family F : R^p × R^m → R^n, with surjective full derivative everywhere on the fiber above y, has a measure-zero set of parameters where y is not a regular value of the slice. This is NOT directly a theorem on product spheres or relative endpoint collars.

3. MathlibExt.Geometry.Manifold.OneDimensionalWanted.compact_connected_one_manifold_with_boundary_classification: a compact connected second-countable smooth 1-manifold with boundary is diffeomorphic either to a circle or a closed interval. It does NOT state a finite-orbit boundary parity conclusion.

The new CI workflow nightfall-atlas-sard-boundary-axioms.yml builds the exact sources and prints/checks all three named axiom dependencies, retaining external source hashes. Until exact-head CI passes, axiom certification is pending.

## Mechanism and proof gates

Parallel #1032's H_(A,B)(u,v,t) = (1−t)F₀(u,v) + t F₁(u,v) + t(1−t)(Au,Bv) has explicit matrix-parameter surjectivity by rank-one right inverses at all unit u,v and interior 0<t<1. Merged #1034 certifies the reference map's unique independent-antipodal zero orbit. Draft #1037 has pinned Lean-certified ambient smooth character approximation, and merged #1041 certifies exact sphere-to-ambient scalar Tietze extension.

Still to prove: (a) finite smooth charts for sphere product × open interval, full-derivative surjectivity for the transformed Euclidean parametric family and a nonempty set of regular parameters selected by the atlas parametricSard theorem; (b) compact regular zero fiber with 1-manifold-with-boundary structure and preservation of both endpoint faces; (c) finite interval component and group orbit counting proving total boundary count multiple of 8, contradicting four reference zeros; (d) a theorem of the exact ProductSphereZero type and end-to-end ordinary-axiom replay.

External Sard and 1-manifold classification theorem availability materially reduces the infrastructure gap but does NOT eliminate source-level chart, regular-level, boundary manifold and group parity proof obligations. No new axioms or admitted lemmas may be used.

## Verification and research status

Source exact #1015 conditional causal theorem already integrated on main; #1024 maximal-to-subcritical rank padding; #1034 one orbit; #1041 scalar extension. Parallel #1032 character averaging/perturbation, and stacked #1037 smooth approximation, are source-pinned progress. The maximal product-sphere topology existence theorem is still NOT Lean-certified, so m_cont(n)=2n−1 is not unconditionally Lean certified.

References: [#1003 topology](https://github.com/d3lefts/d3lefts/issues/1003), [#1004 independent audit](https://github.com/d3lefts/d3lefts/issues/1004), [#1032](https://github.com/d3lefts/d3lefts/pull/1032), [#1037](https://github.com/d3lefts/d3lefts/pull/1037), [#1041](https://github.com/d3lefts/d3lefts/pull/1041). A mathematical result's publication priority is separate from any Lean artifact.

Discovery chain: sphere tests → exact extension → character-preserving smooth approximation → parameter family → Euclidean Sard & charts → regular compact 1D zero fiber → free-orbit parity → product-sphere zero theorem → causal threshold.