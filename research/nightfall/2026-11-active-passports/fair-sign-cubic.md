# Proof Passport: NF-FAIR-SIGN-CUBIC-20261111

**NIGHTFALL Constellation · Devin J. Wright · version 1.0 (2026-11-11).**
**Status:** DRAFT PROOF PR; external referee, novelty and Lean gates OPEN. This is a claim-specific proof-passport note, not an independently refereed theorem or novelty certificate.

## Exact claim and quantifiers

PR #354 supplies a written proof candidate: for an ℓ₁-valued degree-two function G of independent fair signs with uniform norm bound A, W=E||G−EG||₂² and M=max_i E||G−E_iG||₂², the bound W≤4A√M holds. This yields conditional rank-one cubic selector Var(f)≤5B√M for arbitrary finite leaf laws, and a fixed-rank posterior-stable subclass bound Var(f)≤(5+4√t) B√M.

**Display shorthand:** `W ≤ 4 A √M  (fair-sign ℓ₁-valued degree ≤ 2)`

## Premises

1. Fair, independent ±1 controls; arbitrary independent finite-alphabet leaf variables are allowed in the selector corollaries.
2. G has Fourier degree ≤2 with values in ℓ₁^K and ||G(x)||₁≤A.
3. Posterior-closure corollary requires a fixed t-dimensional feature subspace for each leaf; no unbounded-rank generalization.

## Mechanism (dependency graph)

1. A sign-flip one-leaf projector isolates exactly-one-leaf terms without norm growth under the fair-sign cube.
2. Sharp classical Khintchine estimates and a random bipartition retain enough quadratic Fourier energy to derive the mixed ℓ₁–ℓ₂ influence inequality.
3. Conditioning on a leaf moves its realized coefficient into the degree-two control-only term; fixed feature rank is stable under posterior observations, so the scalar exponent-two bound can be iterated.

## Provenance and certification

1. PR #354 contains the proof note and exact rational finite checkers. At this snapshot it is a DRAFT, not merged into main.
2. The draft reports finite random vector quadratic tests, exhaustive small trilinear tensors, rare-leaf examples and posterior checks; these do not establish the theorem generally.
3. Classical Khintchine and mixed Littlewood inequalities are imported; PR #354 acknowledges prior work including Pellegrino.

**Primary candidate:** draft GitHub PR #354 (unmerged); this new summary provides a main-branch review entry, not the source proof. The older `CUBIC_OBSTRUCTION_NOTE.md` is context, not the manuscript proving this bound. The present page is a source-bound summary and does not supersede the primary original proof.

**Research source links:**
- [Draft theorem, derivation and prior art](https://github.com/d3lefts/d3lefts/pull/354)
- [Earlier leaf-spectral reduction and attack](https://github.com/d3lefts/d3lefts/pull/350)
- [Earlier cubic operator audit](https://github.com/d3lefts/d3lefts/pull/347)
- [Existing mixed-product limitation](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/observability-publication/CUBIC_OBSTRUCTION_NOTE.md)

## Failure conditions, limits, and priority

1. The statement is not about arbitrary biased control laws; leaf-law independence does not imply control-law independence.
2. The unrestricted cubic exponent-two theorem, high-rank leaf sections, and mixed-law extension remain open.
3. No independent referee, dated global novelty audit, or end-to-end Lean certificate for PR #354.

**Upstream attribution and comparison:** Classical Khintchine/Littlewood and degree-two Fourier methods; Pellegrino arXiv:1501.00965; PRs #347, #350, #354. No claim of first-ever fair-cube exponent-two influence theorem.

## Independent adversarial audit

Independently check both Khintchine norm steps and every √M normalization; verify the rank-one and fixed-rank scalarization with biased/rare leaves; reconstruct posterior closure and bound at every reached state. Review PR #354 before promoting its proof.

**Gate:** Preserve this certificate and every failed or superseded result, but do not promote to published novel theorem without independent proof review and dated prior-art comparison. No frozen historical Proof Passport or five approved Original Findings are being changed.
