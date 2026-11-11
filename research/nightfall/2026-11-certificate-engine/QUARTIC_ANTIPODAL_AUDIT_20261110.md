# Quartic antipodal inequality: exact sharpness, two-draw reduction, and proof gap

**NIGHTFALL research audit — 10 November 2026**  
**Research lead:** Devin J. Wright. **Status:** proved *conditional reduction* and additive-class calculation; exhaustive small-instance falsification only. **Unrestricted (2,4) influence bound: OPEN.** No independent external referee, no global novelty certificate, and no Lean proof of the quartic conjecture.

## Objective and assumptions

Seek a universal constant C independent of dimension and input law for the averaged quartic antipodal inequality (AQ). This would improve the squared-resampling influence exponent from (5/2,6) to (2,4). This file is a reproducible **research checkpoint**, not a declaration that the question is solved.

For finite sign cubes, let G:{-1,1}^n -> R. At each vertex u fix a **valid nonnegative row** a_u, meaning

    |G(u)-G(v)| <= sum_{i:u_i != v_i} a_{u,i}   for every v.

Fix arbitrary w_i>0 and define s(u,v;w)=sum_{i:u_i != v_i} w_i a_{u,i} a_{v,i}, and u^i the i-th-bit flip. If G(u)>G(-u), then s(u,-u;w)>0 (proof below); 0/0 elsewhere is interpreted as 0.

**Conjecture AQ(C):**

    E_U [ (G(U)-G(-U))_+^4 / s(U,-U;w) ]
      <= (C/2) sum_i E_U (G(U)-G(U^i))^2 / w_i .

The conjecture asserts *some* universal finite C; the sharp candidate C=3 remains unproved in general. It is stronger than the desired product-space influence theorem and could fail even if that theorem is true.

## Claim 1 — exact conditional two-draw transfer (analytic proof)

Assume AQ(C) for all finite sign cubes and valid rows. For any finite independent product of arbitrary finite coordinate alphabets and strictly positive masses, independent X,Y and independently resampled X^(i), the following follows with the **same** C:

    E_{X,Y} [ (f(X)-f(Y))_+^4 / s(X,Y;w) ]
      <= C sum_i I_i(f)/w_i ,

where I_i(f)=E Var(f(X)|X_{-i}) = (1/2) E(f(X)-f(X^(i)))^2.

**Proof.** Conditionally on the unordered pairs {X_i,Y_i}, each differing coordinate has an independent uniform orientation. The resulting restriction is an antipodal uniform sign cube; the original rows restricted to those coordinates remain valid. Apply AQ(C), then average the conditional estimate. Each cube flip is exactly a replacement of X_i by Y_i. Its conditional squared difference averages to E(f(X)-f(X^(i)))^2=2I_i(f), and the factor C/2 becomes C. QED.

**Denominator positivity.** For f(x)>f(y), let D={i:x_i != y_i} and S={i in D:a_{x,i}<=a_{y,i}}. Form z by replacing x_i by y_i for i in S. The two valid row inequalities and triangle inequality imply

    0 < |f(x)-f(y)| <= sum_{i in D} min(a_{x,i},a_{y,i}).

Thus some product a_{x,i}a_{y,i}>0 on D, so s(x,y;w)>0.

## Claim 2 — conditional (2,4) closure

Combining the transferred quartic inequality with the localized weight-removal lemma in the [Certificate Engine](README.md), the median split, and valid real rows of cost <= K yields, **conditionally on AQ(C),**

    max_i I_i(f) >= Var(f)^2 / (8 C K^2).

One uses the positive-side and negative-side fourth moments relative to a median, each opposite class having probability at least 1/2, and at least one side with fourth moment >= Var(f)^2/4. For bounded degree-d functions the competing-symbol row bound K<=pi^2 d^2/2 then gives

    max_i I_i(f) >= Var(f)^2 / (2 C pi^4 d^4).

This is an implication, not a proof that such C exists. The degree-cost bound and weight-removal result are separately attributed inputs; their full arbitrary-measurable-product composition has additional formalization requirements.

## Claim 3 — a fully proved additive special case with optimal C=3

For G(u)=c+sum_i b_i u_i and the canonical constant rows a_{u,i}=2|b_i|, **AQ(3) holds for all positive weights w_i**.

Put B=sum_i b_i^2. Since sum_i b_i U_i is symmetric and has fourth moment 3B^2-2sum_i b_i^4,

    E[(G(U)-G(-U))_+^4] = 8(3B^2-2sum_i b_i^4).

The antipodal denominator is 4sum_i w_i b_i^2. Hence the left side is

    2(3B^2-2sum_i b_i^4)/(sum_i w_i b_i^2)
      <= 6 B^2/(sum_i w_i b_i^2)
      <= 6 sum_i b_i^2/w_i

by weighted Cauchy--Schwarz. This equals the AQ right side with C=3, because E(G(U)-G(U^i))^2=4b_i^2.

The constant **cannot be reduced uniformly** within this additive canonical-row class: choose all b_i=1/n and w_i=1 and let n tend to infinity.

## Claim 4 — two distinct exact finite-n sharpness ratios

For f_n(u)=n^{-1}sum_i u_i with a_{u,i}=2/n and unit weights:

1. **Antipodal AQ ratio** (LHS divided by its right side with C=1): 3-2/n.
2. **Independent-product all-pairs ratio** (LHS divided by sum_i I_i(f_n)): 3-(4/n)(1-2^{-n}).

They both approach 3. **Correction:** the previous conversational recap attributed the second formula to the antipodal calculation. These are not interchangeable finite-n identities.

In the all-pairs calculation, the disagreement count H is Binomial(n,1/2); given H=k>0, the conditional left-side contribution is 2(3k-2)/n^2, yielding the second formula after averaging.

## Failed approach — pointwise quartic charging

Replacing the average over U in AQ(C) by a claim at each vertex fails. For the same additive example at U=(+1,...,+1), the left expression is 4n, whereas one-half the local sum of squared flip increments is 2/n. A pointwise analogue therefore requires C>=2n^2. The **orientation average cannot be dropped**. This failure is not a counterexample to averaged AQ(C).

## Exact finite falsification check

Run (Python standard library only):

~~~bash
python3 research/nightfall/2026-11-certificate-engine/checks/check_quartic_antipodal_exact.py
~~~

The checker uses exact rational arithmetic. It verifies each antipodal ratio for 1<=n<=8, both independent-pairs ratio expressions (and direct pair enumeration for n<=6), and **28,280** nonconstant small-cube row/weight cases: all three-valued truth tables on three bits (26,232 cases across two valid row constructions and two weight vectors), plus 512 fixed-seed four-bit binary truth tables (2,048 cases). Each row is verified globally against every opposite vertex. Both constant coordinate-edge Lipschitz rows and explicitly input-dependent suffix-telescoping rows are tested. These screens found no C=3 violation; **finite sampling does not establish a theorem**.

## Inputs, audit, and stop rule

- **Strongest imported external references:** D. Turturean's 2026 Aaronson--Ambainis proof and antipodal inequality (arXiv:2611.09773); Filmus--Hatami--Keller--Lifshitz pointwise sensitivity bound. Certificate/product transfer source is in this repository (not independent prior art).
- **Verified this checkpoint:** elementary additive fourth-moment proof, exact sharpness arithmetic, denominator positivity, conditional two-draw transfer, reproducible limited checks.
- **Unverified:** AQ(C) for nonlinear real functions with arbitrary vertex-dependent valid rows; optimal C universally; full (2,4) influence theorem; novel-priority status.
- **Independent attack protocol:** construct a separate cube-level solver allowing genuinely vertex-dependent LP-minimal valid rows and independently optimized positive weights; check exact or interval inequalities and retain any violation with rational rows and a finite verifier. Explicitly test against near-point-mass, selector, addressing and high-degree parity families. Numerical failures to find a counterexample do not imply universal truth.
- **Cheapest decisive next experiment:** adversarially optimize the ratio in AQ(C) on 3-6 variable nonadditive examples with freely variable *valid* rows and positive weights, then rationalize and independently replay a violating witness. If no counterexample, seek an *averaged* fourth-moment antipodal charging lemma; avoid the disproved pointwise route.
- **Significance threshold:** only a proof of universal finite C (plus a separate novelty audit) would justify promoting the unrestricted exponent improvement. Keep this note as an open-problem audit until then.

**Attribution:** Turturean's upstream antipodal theorem and Lean work; classical Rademacher fourth moments, Cauchy--Schwarz, conditional two-draw orientation; NIGHTFALL synthesis under Devin J. Wright, with AI-assisted checking. No submission or originality promotion authorized by this record.
