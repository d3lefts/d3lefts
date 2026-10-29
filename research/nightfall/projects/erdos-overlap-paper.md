# NIGHTFALL: Exact Minimum-Overlap Witnesses and Their Discovery

Working paper outline and provenance freeze — 20 October 2026

## Abstract (working draft)

We study the constructive upper-bound problem for Erdős' minimum-overlap constant. Starting from archived finite-grid witnesses, a program of minimax refinement, smoothing continuation, multiresolution lifting, mass-preserving transports, and later independent block-residual scaling produced rational step-function certificates with exact verification over all real translations. The strongest supplied internal archive establishes

\[
\mu\le\frac{34788888032212764146872525963225147703298526879}{91343852333181432387730302044767688728495783936}=0.380856370118029325246278763656\ldots.
\]

An earlier archived 131,072-cell v3 candidate (Arena acceptance unverified) has exact score

\[
\mu\le\frac{58934668723367004717445487}{154742504910672534362390528}=0.380856370118785003720186184925\ldots.
\]

The stronger internal witness improves v3 by 7.5567847390742126850458890506640652576643161072322246013071933680E-13, **far below the 10^-8 research milestone**. We distinguish certified constructive bounds from the leaderboard's rounded display, and do not claim the global optimum is determined.

## Mathematical model

For measurable `f:[0,2] -> [0,1]` of integral one, write
**Complement zero-extension convention (explicit):** for admissible `f:[0,2] -> [0,1]` with integral 1, define `F(x) = 1_[0,2](x) f(x)` and independently `G(x) = 1_[0,2](x) (1-f(x))`. Then `R_f(t) = integral_R F(x) G(x+t) dx` and the objective is `inf_f sup_t R_f(t)`. Do **not** replace `G(x)` by `1-F(x)` on the full real line: that incorrectly assigns the complementary function value 1 outside the interval and makes the supremum identically 1. This specification correction does not assert any defect in the archived witness-scoring code. See [exact transport/boundary audit](projects/erdos/overlap_transport_20261029/RESEARCH_NOTE.md).

With `N=2H` equal-width cells, heights `a_i=A_i/D` for integer `0 <= A_i <= D` and `sum_i A_i=HD`, the event overlap at signed lag k is

`R(k/H) = sum_(valid i) A_i (D-A_(i+k)) / (H D^2)`.

Each translation interval between grid breakpoints has affine overlap; the supremum over real translations is attained at grid event shifts. This reduces a continuous witness certificate to integer polynomial correlations, prefix sums, and exact inequalities.

## Reproducible endpoints

**Archived v3 candidate** (`ARENA_overlap_submission_v3(1).zip`): `N=131072`, 131,072 discrete values, maximizing lag `+52440`; internal float submission score around 0.3808563701187851. This artifact includes a verifier and metadata. The October 27 Arena receipt shows one accepted leaderboard entry at 0.3808564043546676; its original cell count, input hash, and exact rational score remain unrecovered. This v3 artifact is not identified as the accepted submission.

**Strongest supplied internal archive** (`NIGHTFALL_Erdos_Latest(1).zip`): `N=131072`, heights of denominator `2^70`, exact maximizing lag `-17280`, exact signed-shift checks listed as 262143. This archive includes six-prime NTT residue files, CRT verification, a separate fiber rigidity proof, and lower fixed-row analysis. I inspected archived certificates and manifest but **did not rerun the full NTT proof in this session**.

## Optimization arc (to expand with experiments and timeline)

1. Coarse rational minimax, grid-constrained mass-conserving updates, and exact audit of every signed shift.
2. Temperature continuation of a softened maximum to escape stalled local basins; lift and re-optimize on a finer grid.
3. Geometry diversification using coarse block averages, spatial mass transports, joint contact constraints, and covariance identities.
4. Later 64-cell **independent** block-residual amplitudes: decompose `a_i=B_b+r_i` with zero block residual sum, vary `a_i(theta)=B_b+theta_b r_i`, then quantize and exactly certify. Unlike uniform coarsening, these degrees of freedom allow inhomogeneous changes in each block.

## Two witness-specific barriers, not universal optimality theorems

For dyadic widths `m=2,4,8,16,32,64`, the latest archive claims and records an exact rational verifier showing that uniform residual rescaling cannot improve the fixed 131,072-cell witness. At `m=128`, a two-lag affine-in-`1-theta^2` argument bounds all improvement within the scalar family by `1.8426438153379315e-13`. These eliminate a specific search class, not independent multiblock or topology-changing searches.

## Lower bound and remaining gap — editorial update, 2026-10-28

The historically peer-reviewed lower reference is White's `mu > 0.379005`. More recent source-reported lower bounds require their individual verification status to travel with the number:

- Price (2026): `mu > 0.38055470`. Independent reproduction covers the finite interval certificate; specialist review of the full analytic reduction remains outstanding, as documented by [MathWorld](https://mathworld.wolfram.com/MinimumOverlapProblem.html). Conditional gap to our internally replayed upper witness: `0.000301670118029325246…`.
- Wetch (2026): `mu > 0.380627425`. [The source repository](https://github.com/justinwetch/erdos-36-minimum-overlap) reports exact fresh-copy local checks, with full external peer review still outstanding. Conditional gap: `0.000228945118029325246…`.

Neither stronger lower claim has been independently proved in this NIGHTFALL manuscript. The mathematical upper construction now has a publicly released curated binary witness with passing anonymous-download and independent-implementation CI replay (29 October 2026). An external human referee and broad priority review remain outstanding. These conditional intervals must not be presented as jointly independently certified bounds. A verified global lower-bound improvement would be more significant than tiny fixed-witness refinements.

### Comparison with other upper constructions

The [curated optimization-constants index](https://teorth.github.io/optimizationproblems/constants/1b.html) records Atris's independently replayed exact `0.38085855031642856010…` upper construction. The reported NIGHTFALL internal value is approximately `0.00000218019839923485` smaller, subject to external certificate reproduction and matching normalization. A different 4096-cell construction publicly associated with a score around `0.380856` was reported to contain a grid-width normalization error (corrected objective around `0.38094895`); see [the normalization analysis](https://www.benzanghi.com/blog/erdos-minimum-overlap-technical). It is distinct from the 131,072-cell NIGHTFALL archive.

The [witness identity and prior-art ledger](erdos/STATUS_AND_PRIOR_ART_20261028.md) separates the accepted Arena snapshot, the documented rejected submission, the archived v3 candidate, and the exact mathematical witness. The approved curated mathematical evidence release is published and verified ([closed issue #5](https://github.com/d3lefts/d3lefts/issues/5)). A [scoped external referee packet](erdos/EXTERNAL_REFEREE_PACKET_20261029.md) now provides exact public download and reproduction instructions. Recovery of the separate accepted submission's original input remains tracked in [issue #6](https://github.com/d3lefts/d3lefts/issues/6).

## Provenance freeze

- `NIGHTFALL_Erdos_Latest(1).zip`: SHA-256 67197b5ba1b81b5f017505ab4f0042712d77bc94fc41edab01eef5d7b2f61a5d.
- `ARENA_overlap_submission_v3(1).zip`: SHA-256 ae5abcd9afee9e56dd919526ce5a0243b474665b3264c59fe763831b996dc520.
- Latest witness file hash: a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e.
- Arena v3 witness hash: b00f821ba6d99fd992230e9d2b96b36acb3f6b06fff15a4e00e3a5b441ea9fe2.

## Outstanding scholarly tasks

Cross-check the exact leaderboard entry and solution ID against the accepted payload; expand the method history with numbered checkpoints and collaborator attribution; obtain an external non-author audit of the public exact witness and finite-to-continuous bridge; compare the seven-resolution obstruction with prior literature. Avoid assigning publication priority or general novelty until the prior-art audit is complete.