# Continuous and Finite-Precision Taxes for Adaptive Squared-Linear Sensing

**Status:** theorem A (three-coordinate and all-dimensional continuity obstruction) kernel-certified under pinned Lean 4.36.0-rc2, with standard axioms only. Verified source run: https://github.com/d3lefts/d3lefts/actions/runs/44029629084 . Classical projective embedding consequence and precision packing bound are *not* Lean certificates. No originality or peer-review claim.

## Model and objective

Observe an unknown real vector (x\in\mathbb R^n), identified only up to (x\sim-x). A permitted query is exactly
\[
Q(a,x)=(a\cdot x)^2.
\]
A causal policy chooses (a_j) from previously observed values, never from hidden signs. The source theorem in [PR #695](https://github.com/d3lefts/d3lefts/pull/695) established sharp unrestricted, noiseless field-generic query counts:
\[
A(n)=n+1,\quad F(n)=2n-1\quad(n\ge2).
\]
The goal here is to determine the *price of regularity and precision* in that separation, without repeating the existing construction.

## Mechanism / operator

The unrestricted upper bound first acquires (x_1^2,\ldots,x_n^2) and then packs the remaining sign data into one measured square using a row chosen from the observed squares. That row is not continuous near changing zero support.

**Theorem A: coordinate-first continuity obstruction.** For every (n\ge3), let a deterministic two-stage scheme first obtain the (n) individual coordinate squares and then select one squared-linear row (a(d)\in\mathbb R^n) using only those squares. If just the first two entries of that row vary continuously along
\[
d(t)=(t^2,(1-t)^2,1,0,\ldots,0),\quad 0\le t\le1,
\]
then the scheme cannot identify every signal up to global sign.

*Proof.* Write (u(t)=t a_1(d(t))) and (v(t)=(1-t)a_2(d(t))). Universal recovery at (t=0) forces (v(0)\ne0): otherwise ((0,1,1,0,\ldots)) and ((0,-1,1,0,\ldots)) collide. At (t=1), recovery forces (u(1)\ne0). Since (u(0)=v(1)=0), the continuous function (u^2-v^2) changes sign. There is (0<t<1) with (u=v) or (u=-v). In the first case, ((t,-(1-t),1,0,\ldots)) and ((-t,1-t,1,0,\ldots)) have identical coordinate squares and identical final **unsquared** readings. In the second, the witnesses are ((t,1-t,1,0,\ldots)) and ((-t,-(1-t),1,0,\ldots)). Both pairs are distinct modulo global sign because the third coordinate remains (1). Contradiction.

This theorem uses only the intermediate value theorem; its scope is the coordinate-first architecture. It does **not** claim all continuous (n+1)-query causal policies fail.

**Formal sources:**
- `research/nightfall/formalization/finite_field/ContinuousPhaseCrossing.lean`: real IVT signed-crossing lemma.
- `research/nightfall/formalization/finite_field/ContinuousPhaseOracleObstruction.lean`: actual three-coordinate squared-linear no-go; compiled under pinned Lean 4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`, run 44028162692, standard axioms only.
- `research/nightfall/formalization/finite_field/ContinuousPhaseAllDimensions.lean`: embedded three-active-coordinate obstruction for every (n=k+3), kernel-certified for every `n=k+3` by pinned run 44029629084, named declaration `no_continuous_final_row_all_dimensions`; standard axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.

## Broader classical topological consequence — NOT a Lean theorem here

A continuous, sign-invariant, universally separating causal observation map restricts to a continuous injection from unit-sphere antipodal classes (\mathbb{RP}^{n-1}\) into (\mathbb R^m). Compactness and the Hausdorff codomain make this a topological embedding. The classical projective-space embedding theorem (Peterson, via Dugger, *A Geometric Introduction to K-Theory*, Corollary 39.15) establishes that (\mathbb{RP}^{2^r}\) needs ambient embedding dimension (2^{r+1}). Thus for (n=2^r+1) (r≥1), any continuous *causal transcript* needs (m\ge2n-2) measurements. For n=9: unrestricted adaptive 10, continuous adaptive ≥16, fixed 17. This is an inference from established topology, not a claim of new topological novelty or kernel certification.

Primary external text: https://pages.uoregon.edu/ddugger/kgeom_040524.pdf (Section 39, Corollary 39.15).

## One-final-reading finite-precision bound — analytic, NOT yet Lean-certified

On the normalized sign cube (x_s=s/\sqrt n), first-stage coordinate-square outputs agree for all (M=2^{n-1}) global-sign classes. When the final row satisfies (\|a(d)\|_2\le1), its last squared output lies in ([0,1]), so any exact code must have a pair separated by at most (1/(M-1)). Worst-case additive error at level (\varepsilon=1/[2(M-1)]) can equalize those outputs. The two signal classes are at least (2/\sqrt n) apart under projective Euclidean distance, so no decoder can guarantee error below (1/\sqrt n) at that noise level. This is an information-theoretic packing result for the **coordinate-first, one-final-reading** architecture, not a universal bound for every adaptive protocol.

## Independent audit

`research/nightfall/continuous-phase-obstruction/independent_checker.py`: standard-library-only, deterministic, separate numerical implementation of support-path witnesses. It checks exact rational witness equalities and random polynomial policies; this finite experiment is never used as a substitute for the Lean certificate.

## Certification and novelty gates

- The prior F9 and field-generic (n+1) terminal are not duplicated; they are the antecedent proof objects.
- The continuity obstruction is stricter than the projective topological bound *for the coordinate-first architecture* at dimensions 3 and 4, where topology alone does not exclude n+1 observations.
- General continuous causal policy lower bounds, two-stage full-rank calibration extension, noise-stable matching constructions, and quantized policies remain future research.
- Literature overlap must be judged separately. Relevant work: Balan–Casazza–Edidin real phase retrieval; Charikar–Wu–Ye adaptive discrete phase retrieval; Eldar–Mendelson stability; Peterson/Milnor/Dugger projective embedding obstructions. No independent novelty review yet.
- Mechanism record: connected support transition → forced sign-fiber crossing → indistinguishable actual squared-linear outcomes. Limit: continuity only on a specified observed-data path; not a general universal sensor budget theorem.
