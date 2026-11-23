# Tessera: affine-circle fiber obstruction (2026-11-23)

## Contract and provenance
Objective: rule out candidate causal continuous rank-one PSD six-reading protocols in R4 without assuming oriented-row lifts. Source: main charter TEAM_ROLES_20261029; coordination #1071; #1078; #1047, #995, #1015, #1068. Strongest external topological input needed here: elementary Borsuk–Ulam in dimension one (equivalently intermediate value on a circle); this is classical prior art. No new novelty claim. Baseline: #1047 full-rank-prefix no-go and Tessera 2026-11-22 fixed-reflection obstruction. New test targets a different failure: an affine two-dimensional *common-kernel fiber*, without requiring any global reflection symmetry.

## Exact theorem (paper-level, conditional)
Let Q_j:H_{j-1}->Sym_4^+ be continuous rank<=1 detector selectors for j=1,...,5 on attained histories; y_j(x)=x^T Q_j(y_1,...,y_{j-1})x. Fix c in R4 with attained transcript h=(y_1(c),...,y_5(c)). Set K=intersection_{j=1}^5 ker Q_j(h_{<j}). Suppose dim K>=2 and c_perp=proj_{K^perp}c !=0. Then for every r>0 and every continuous even sixth scalar response y_6(h,x), there are two inputs x_+=c_perp+r v and x_-=c_perp-r v with v in K, ||v||=1, whose *six* outputs coincide. Their projective Euclidean separation is exactly

  min(||x_+-x_-||,||x_++x_-||) = 2 min(r,||c_perp||).

In particular, no globally sign-injective six-reading protocol can have such a nonzero-transcript five-stage history with a common detector kernel of dimension >=2. In R4, the condition is equivalent to rank of the five attained detector rows <=2 (row signs irrelevant).

## Proof
For each w in K, induct on j: if the prior outputs at c+w and c agree, the selected Q_j is the same as at c; since Q_j w=0, (c+w)^T Q_j(c+w)=c^T Q_j c. Thus every point of c+K shares h. The same is true of c_perp+K since c-c_perp is in K. Choose an orthonormal pair v1,v2 in K and circle x(theta)=c_perp+r(cos(theta)v1+sin(theta)v2). It lies entirely in the same attained five-reading fiber. The function D(theta)=y_6(h,x(theta))-y_6(h,x(theta+pi)) is continuous and satisfies D(theta+pi)=-D(theta); intermediate value gives D(theta)=0. These points are not sign-equivalent since c_perp and v are orthogonal and both nonzero. Their difference has norm 2r and sum norm 2||c_perp||, giving the exact separation.

The result does NOT require Q6 to lift to an oriented row, or even be quadratic: any continuous final scalar fails. The result does NOT establish a universal PSD six-reading no-go; candidate protocols may maintain attained detector span >=3 at all nonzero histories while having an early rank-degenerate prefix. It is stronger than a *fixed reflection-axis* hypothesis in a different direction: the common two-dimensional kernel may depend on the attained history.

## Cheapest falsifier and independent-check contract
Construct an explicit five-stage PSD policy and a nonzero attained history with rank <=2, then attempt to produce a sixth continuous scalar separating the antipodal points on the affine circle. This must fail. The accompanying exact Python checker independently verifies the rank/kernel/circle identity and the projective gap on a rational fixture. It is a finite algebraic calibration, NOT a proof of the topological IVT step. A stronger adversarial test is to find an actual six-reading protocol with all nonzero attained five-stage row spans >=3, a rank-degenerate early prefix and nontrivial holonomy, then test global injectivity; this theorem does not decide it.

## Status / transport
Status: self-contained paper-level lemma, one exact rational fixture, no Lean terminal, no non-author mathematical review, no dated comprehensive priority clearance. Mechanism: causal common-kernel transport -> affine-circle fiber -> odd final difference -> collision. Scope: R4 six readings, nonzero c_perp, rank<=1 PSD prefix, continuous scalar final stage. No publication/merge. Existing #95/#76 remain deferred obligations, not abandoned.
