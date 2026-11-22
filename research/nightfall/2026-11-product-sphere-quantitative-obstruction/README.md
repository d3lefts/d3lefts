# Product-sphere zero to a scale-free, decoder-independent phase-retrieval risk floor

**Version:** 2026-11-22, candidate quantitative corollary, conditional on the original `ProductSphereZero` theorem for the stated dimensions. **Certification:** exact separation implication encoded in `ProductBUQuantitativeCollision.lean` and sent to a pinned Lean compiler gate; risk and scaling theorems below are paper proofs only, **not Lean-certified**. This does not close the global zero-fiber atlas or upgrade the external novelty status.

## Concrete research objective

Given a real squared-linear adaptive phase-retrieval protocol with at most `2n-2` readings, whose row selection is continuous *on its genuinely attainable histories*, prove more than noninjectivity: every attempted phase-class decoder has a dimension-free, nonvanishing worst-case error on every ball. The same applies to randomized decoding and arbitrary output noise, since the identical noiseless transcript is an admissible observation under the noise model.

The full mathematical claim uses the **product-sphere zero theorem** as the central topological premise. Its all-dimensional topological proof is currently paper-level; the remaining Lean gate is construction of the actual global regular one-dimensional zero-fiber-with-boundary structure, as described by #1111, #1108 and #1106. No source compilation of a related submersion theorem removes that gate.

## Operational setting

For `n>=2`, let a deterministic `m`-stage policy select a real vector `a_j(h)` at every attainable list `h` of preceding intensities; `a_j` is continuous on the set of genuinely attainable `j`-reading histories. Define the raw oracle reading `q_j(h,x)=<a_j(h),x>^2`, and the complete transcript `T_a(x)` recursively. Repeated, zero and signal-dependent measurement rows are allowed, and only global-sign ambiguity is disregarded.

Put

    d_pm(x,y) = min(||x-y||_2, ||x+y||_2).

This is the usual metric on sign orbits. The decoder may be any measurable deterministic or randomized map from the complete transcript (and its independently generated random seed) to an estimate; it need not itself be continuous. The continuous-selection requirement applies to the *measurement policy*, not the decoder.

## Lemma 1: exact unit-pair separation (Lean target in this PR)

If u,v are unit vectors, let x=u+v and y=u-v. Then

    ||x-y||_2^2 = ||2v||_2^2 = 4,
    ||x+y||_2^2 = ||2u||_2^2 = 4.

Thus d_pm(x,y)=2 EXACTLY, independent of n and of <u,v>. The original genuine-prefix causal collision theorem supplies `T_a(x)=T_a(y)` whenever its `ProductSphereZero` hypothesis is available. New scoped Lean source `ProductBUQuantitativeCollision.lean` composes these statements and records the two exact squares, with `ProductSphereZero` still an explicit theorem parameter.

**Independent proof attack:** The ambient function-space norm is typically a sup norm in Lean, so the statement uses the original `sqNorm` (finite coordinate-sum-of-squares) rather than an incorrect inferred norm type. The construction has distinct sign classes even when either x or y is zero: with unit u,v, both quotient separation squares remain four.

## Lemma 2: exact scaling of a genuinely causal protocol

For any lambda>0, define a new protocol `a^lambda` by

    a^lambda_j(h) = a_j(lambda^2 h),

where the scalar multiplies every earlier intensity in the history, not the measurement rows. For every signal z and stage count j,

    T_a(lambda z) = lambda^2 T_{a^lambda}(z).

**Proof:** At j=0 both lists are empty. Assume the relation holds at j. The row chosen on input `lambda z` is `a_j(lambda^2 T_{a^lambda}(z))`, exactly the row `a^lambda_j` chooses on input z. Squared linearity multiplies the resulting reading by `lambda^2`; appending it proves the induction. Attainable histories of `a^lambda`, scaled by `lambda^2`, are exactly attainable histories of a at the corresponding scaled input. Therefore reachability-continuity of a implies that of `a^lambda`.

The factor must be **lambda squared**. Scaling the row or scaling only by lambda in the history is wrong in general; an exact rational mutation test is supplied independently.

## Theorem: uniform, scale-free conditional reconstruction obstruction

**Conditional premise.** For n>=2 and any r,s<=n-1 with r+s=m, assume `ProductSphereZero n r s`, the standard equivariant product-sphere zero theorem. Any protocol of m<=2n-2 stages can be padded and coloured so these conditions cover its genuine prefix as in the established source. For fixed m<2n-2, an unused-stage padding convention must be stated explicitly; the present formula assumes a colour split within the known theorem's scope.

For every R>0, the protocol has **two inputs x,y in the closed Euclidean R-ball** such that

    T_a(x) = T_a(y)
    and
    d_pm(x,y) = R.

**Proof:** Apply the causal collision theorem to the rescaled protocol `a^lambda` with `lambda=R/2` and obtain unit u,v with equal `a^lambda` transcripts at u+v and u-v. Scale both signals by lambda; Lemma 2 gives equal original transcripts. Their norms are at most lambda*(||u||+||v||)=R. Lemma 1 gives their sign-orbit separation exactly 2lambda=R.

Consequently, for any deterministic decoder D, one of the two errors `d_pm(D(T_a(x)),x)` and `d_pm(D(T_a(y)),y)` is at least `R/2`, by the triangle inequality on sign orbits. A randomized decoder has the **same output distribution** on these indistinguishable inputs. Pointwise `e_x+e_y>=R`, hence `e_x^2+e_y^2>=R^2/2`. Integrating and averaging yields

    sup_{||z||<=R} E[d_pm(D(T_a(z)),z)^2] >= R^2/4.

No statistical sampling or Gaussian assumption enters. The lower bound also holds for any observation-noise model including zero noise, as a minimax guarantee against all admissible noise. These are lower bounds, **not** claims that the constants are optimal for the whole ball or that every algorithm fails identically.

**Important restriction:** the underlying source theorem concerns *real rank-one squared-linear sensing* with deterministic reachable-continuous row policies. It does not automatically cover complex phase, known-norm sphere-only recovery, rank-k blocks, discontinuous row choice, arbitrary adaptive oracle models, or noisy adaptive control with random selection unless those are separately formalized.

## Source provenance and novelty gates

- Original topological input: classical product Borsuk–Ulam / Stiefel–Whitney obstruction, including Chan–Chen–Frick–Hull (2019) and the Ramos-type product-sphere theorem literature (e.g. [2019 overview](https://arxiv.org/abs/1902.00935)). **Do not claim novelty of that theorem.**
- NIGHTFALL internal source: original causal collision and reachable-history continuity composition in `ProductSphereCausalComposition.lean` (main; previous #1008/#1015).
- PR #1111 imports the frozen ATLAS smooth-submersion criterion; #1108 constructs a compatible-atlas implication; #1106 derives the interval and sign-orbit contradiction conditional on an actual boundary manifold.
- Quantitative phase-orbit separation and scale-transfer are direct mathematical corollaries; no comprehensive global priority search for this specific minimax formulation has been completed. The retrieved 2026 phase-retrieval minimax papers use other (notably Gaussian) observation models, so they do not settle this exact priority comparison.
- External and internal proof stages must remain distinct: source-custody hashes -> named Lean kernel receipts -> concrete global `ProductSphereZero` theorem -> reachable-history terminal -> date-pinned priority -> potential scientific publication. No automatic promotion.

## Budget and next decisive test

Run the pinned `nightfall-bu-quantitative-collision.yml` CI on the exact PR head. Confirm the full four-source Lean import closure, named type and ordinary axioms; if compilation fails, repair rather than downgrade the gate. Run `python3 scripts/check_phase_causal_scaling_exact.py` to check the independent rational scaling identity and its mutation control. Then prioritize **the actual half-space zero-fiber charts at t=0**: isolate a local smooth graph with nonnegative time as a chart coordinate using #1052’s reference spatial Jacobian inverse, prove overlaps with #1111's interior local projections, and feed the resulting concrete atlas to #1108 and #1106. Stop without a topology promotion if any of those steps is still missing.
