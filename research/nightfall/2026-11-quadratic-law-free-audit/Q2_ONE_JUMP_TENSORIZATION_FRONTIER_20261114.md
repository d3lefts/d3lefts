# Q2 first-moment frontier: exact one-increment gate and the missing tensorization theorem

**14 November 2026.** This is a *scoped* result, not a claim of a universal sub-100 Q2 theorem.

## Setup and the one-increment proof

Let `H` be a real Hilbert space, `h ∈ H` fixed and `Y` one centered random vector with `||Y|| ≤ c` almost surely, `c≥0`. Write

`a=||h||, R=||h+Y||, u=E R, e=E R²=a²+E||Y||²`.

Then `R≤a+c` by triangle inequality, so `e=ER²≤(a+c)u`. Jensen gives `u≥||E(h+Y)||=a`. Thus, without a fourth-moment estimate,

`e≤(a+c)u≤(u+c)u=u²+cu`.                                (1)

Consequently the **single-increment** shifted reverse-Khintchine inequality holds with correction `c/6`:

`sqrt(e)≤sqrt(3)u+c/6`.                                  (2)

A rational sum-of-squares derivation uses `sqrt(3)≥5/3` and, for `u,c≥0`,

`(sqrt(3)u+c/6)²−(u²+cu) = 2(u−c/9)²+c²/324+(sqrt(3)−5/3)uc/3≥0`.

Lean file: `research/nightfall/formalization/q2_shifted/Q2OneIncrementC6.lean` (strict kernel receipt required before marking as Lean-certified).

## Sharp one-increment correction and exact equality witness

Let `q=(sqrt(6)−2)/4` and `beta_*=(sqrt(3)−sqrt(2))/2`. Exact identity:

`(sqrt(3)u+beta_*c)²−(u²+cu)=2(u−qc)²`.                  (3)

Therefore (1) implies the sharper one-increment theorem

`sqrt(e)≤sqrt(3)u+beta_*c`.

It is optimal **among one-increment bounds**. With `c=1`, `h=q`, and

- `P(Y=1)=q/(1+q)=5−2sqrt(6)`;
- `P(Y=−q)=1/(1+q)`;

we have `EY=0, |Y|≤1, R=1+q` on the first atom and `R=0` on the other. Hence `u=q`, `e=q(1+q)=1/8`, and

`sqrt(e)−sqrt(3)u=beta_*`.

For a general radius c, scale h and Y by c. This witness is an exact obstruction to beta smaller than beta_*, even if additional increments are allowed.

## Relation to Q2 budgets (conditional until tensorization)

The currently source-certified integrated section budget `sum_i u_i≤5B` and ownership cover `sum_i c_i≤8B`, when paired with a hypothetical **all-independent-sums** shifted inequality `sqrt(e_i)≤sqrt(3)u_i+beta c_i`, yield

`Var(f)² ≤ (5sqrt(3)+8beta)² B² M`.

- At `beta=1/6`: `C=(5sqrt(3)+4/3)² =691/9+40sqrt(3)/3≈99.8717885454`. This uses no improved section budget but still requires the full random-sum probabilistic theorem.
- At the one-jump obstruction `beta=beta_*`: `C=(9sqrt(3)−4sqrt(2))²=275−72sqrt(6)≈98.6367385196`. **Method-specific possible floor, not a proven universal floor.**
- If the sharp source-section bound `2(1+sqrt(2))B` also becomes certified, the hypothetical `beta_*` terminal is `164+72sqrt(2)−32sqrt(3)−48sqrt(6)≈92.8222429951`.

Earlier separate conditional `99.2629850192` in PRs #539 and #540 requires `beta=1/5` *and* the sharper source-section budget, so it remains logically distinct.

## Open multistep target and independent audit

For independent centered Hilbert-valued `Y_1,...,Y_n` with `||Y_i||≤c`, `Z=∑Y_i`, `e=||h||²+E||Z||²`, `u=E||h+Z||`, establish either

`(A) sqrt(e)≤sqrt(3)u+c/6`,

or the plausible reverse-moment inequality

`(B) e≤2u²+cu`.

Neither follows from (1) by a naive induction. In particular, after one step the intermediate `h+Y_1` is random and may have norm larger than the original c. A proof of (B) alone does **not** yield the c/6 coefficient at the certified 5B budget (its optimal scalar correction is `(sqrt(3)−1)/4`, about 0.183, rather than 1/6).

**Cheapest next decisive experiment:** independently enumerate two- and three-point centered scalar/vector increment laws with exact rational probabilities, then seek an analytic tensorization invariant for the first moment; an exhaustive finite-grid search cannot prove an all-distributions theorem. For symmetric deterministic-magnitude Rademacher sums, the sharp Khintchine constant gives `e≤2u²` even with a fixed shift by adjoining an auxiliary global Rademacher sign. That subclass does not include asymmetric rare jumps.

Prior art to compare before any novelty claim: sharp Khintchine constants (Haagerup, Latała–Oleszkiewicz); Pinelis's bounded-sum and 2-smooth Banach-space inequalities; concentration for independent symmetric random vectors. Local formal proof and exact checker are not independent non-author review.

## Status

- Exact one-step probability proof: **analytic theorem**.
- Exact equality witness: **symbolic algebra, reproducible in checker**.
- Lean one-step scalar declarations: **PR build pending; do not mark passed yet**.
- Unrestricted `n`-increment (A)/(B): **conjectural**.
- Unrestricted source-only sub-100 Q2: **not certified**.
