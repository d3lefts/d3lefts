# NIGHTFALL Q2 — rational sub-100 reduction (14 November 2026)

**Status:** analytic source-section proof and exact rational checker; proposed Lean
scalar lemmas (no current-head compiler receipt at creation). **NOT an
unconditional Q2 c/5 theorem**. The necessary probabilistic lemma remains open.

## Why this matters

PRs #539/#540 correctly identify two requirements for the exact 99.262985
endpoint: an unrestricted shifted-Hilbert reverse Khintchine c/5 lemma, and a
source-original sharp section budget 2(1+sqrt(2))B. The latter **is not
necessary for a sub-100 conclusion**. With the rational t=2/5 source switch,
one gets a slightly weaker exact section constant 29/6 and conditional Q2
coefficient

    K=(29 sqrt(3)/6+8/5)^2=99.43238582373193... < 100.

Thus the numerical *first sub-100* target requires only the genuine shifted
c/5 probabilistic theorem plus the rational switching bridge, not the
irrational sharp switch that is currently blocked in #535/#544.

## Proof of the rational source budget

For finite original product law p (heterogeneous positive or zero marginals),
pointwise degree <=2 real f bounded by B everywhere, and fixed configurations
x,y,z, let Py(t)=E_mask[f(switch(x,y,mask))] where each independent mask bit is
Bernoulli(t). Quadratic degree makes

    Py(t)=A+t Dy+t² Qy,  A=f(x),
    Dy=Σ_i [f(x with i replaced by y_i)-f(x)].

Likewise for z with the **same A**. At t=2/5:

    6(Dy-Dz)=25(Py(2/5)-Pz(2/5))-4(f(y)-f(z)).

All four endpoint and mask-expectation values belong to [-B,B]. Hence

    Dy-Dz <= 29B/3.

Maximize/minimize each actual x-fixed coordinate section separately with y,z.
Then Dy-Dz is the sum of coordinate ranges. Weighted Popoviciu gives
sqrt(Var_{p_i}(f(x_{-i},X_i))) <= range_i(x)/2, including zero atoms.
Integrate over the **original product source**, obtaining:

    Σ_i sourceMeanSectionNorm(p,f,i) <= 29B/6.

This is an *analytic all-source theorem*, not a Lean source declaration yet:
the generic Bernoulli-mask polynomial needs to be connected to actual-source
section definitions in a named pinned source theorem. The Lean file here
certifies no more than its stated scalar algebra when compiled.

## Remaining probabilistic assumption and aggregation

Fix the existing source-greedy owner partition. Let e_i be genuine owner
energy with e_i<=I_i<=M, Σ_i e_i=V; let u_i be genuine original-source
coordinate L1 section norm and c_i>=0 the owner amplitudes with Σ c_i<=8B.
Assume the still unproved **unrestricted** shifted norm inequality for each
independent bounded centered Hilbert owner sum and deterministic singleton:

    sqrt(e_i) <= sqrt(3) u_i + c_i/5.

Then summing e_i<=sqrt(M)*sqrt(e_i) yields

    V² <= (29 sqrt(3)/6+8/5)² B² M.

Exactly, sqrt(3)<26/15 because (26/15)²>3. Thus

    29 sqrt(3)/6+8/5 < 449/45 < 10,

establishing K<100 without rounding.

**Important:** This only proves *the reduction*. Source-certified 5B sections
and 364.552683 unconditional Q2 remain the previously checked baseline.
The stronger 99.262985 conditional target is unchanged.

## Independent adversarial gate

Run:

    python3 research/nightfall/2026-11-quadratic-law-free-audit/check_q2_rational_sub100.py

Expected: exact masked polynomial identity and coefficient rational checks;
86,160 exact masked source comparisons, 155 biased/zero-mass finite source
checks. Sampling does not prove the universal mask lemma or c/5.

The true c/5 inequality is not refuted by the old quartic-envelope failure.
A one-jump centered asymmetric Bernoulli law forces any universal correction
beta to satisfy beta >= (3-sqrt(6))/(2 sqrt(3)) ~= .1589186226, which leaves
beta=.2 feasible. This is a **lower-bound obstruction**, not a proof of .2.

Next independent review: (1) source-integrated 29/6 Lean declaration with
original p,f and zero atoms; (2) proof or counterexample for unrestricted c/5
including deterministic h and Hilbert-valued asymmetric jumps; (3) strict
pinned Lean and axiom receipts for the final source-only claim. Prior-art
antecedents include Khintchine/Rosenthal, quadratic noise operators and
Popoviciu. No publication/priority claim.
