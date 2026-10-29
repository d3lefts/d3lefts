# RYEV / exact global optimizer of Axiom's two-endpoint finite-prefix Sidon window

**Date:** 2026-10-29. **Program owner:** Devin J. Wright. **Research contribution:** Ryev. **Self-assignment:** [#86](https://github.com/d3lefts/d3lefts/issues/86). **Immediate parent:** Ryev [#81 / draft PR #84](https://github.com/d3lefts/d3lefts/pull/84), itself derived from Axiom's [PR #62](https://github.com/d3lefts/d3lefts/pull/62).

**Evidence status:** internally exact algebraic proof of the *loss-surrogate optimization*; the imported Bose–Chowla fixed-prefix extension theorem and its cross-collision hypotheses remain separately reviewable. External mathematical proof attack and dated same-scope novelty review OPEN. No infinite Sidon sequence coefficient gain, resolution of Erdős #44/#329, or finite record is asserted.

## Sharper statement

Fix a positive integer `r` and any particular Sidon prefix `A` of cardinality `r`. Axiom's established asymptotic modular-block/translation/delete argument, as adapted in parent PR #84, yields for every real endpoint pair satisfying `0 < beta < alpha < 1/2` and loss less than 1:

```
L_r(alpha,beta) = (16/27)*r*alpha^3/(alpha-beta)
C_r(alpha,beta) = (1 - L_r(alpha,beta))/sqrt(2-beta).
```

Here the quantifiers are **A and r fixed, q→∞ through primes**, and all floor/ceiling errors are `O_A(1)`; `C_r` is the certified normalized density coefficient within this particular *sufficient deletion bound*. Its optimum does **not** optimize all conceivable Sidon extension constructions.

**Theorem (conditional on that previously derived construction bound).** This explicit two-parameter coefficient has a *unique global maximum* on the positive-margin admissible domain at

```
alpha*_r = 2 - sqrt(4 - 3/(16r))
         = (3/(16r)) / (2 + sqrt(4 - 3/(16r)))
beta*_r  = 2*alpha*_r / 3.
C*_r = (1 - (16/9)*r*(alpha*_r)^2) / sqrt(2 - 2*alpha*_r/3).
```

For **every** integer r≥1, it is strictly stronger than the already improved parent PR #84 coefficient

```
C_parent = (1 - 1/(256r)) / sqrt(2 - 1/(32r)).
```

The numerical gain is small and positive: for r=1 it is approximately **3.977862597×10^−7**, and for r=5 approximately **3.063234859×10^−9**. This is a second-order improvement, **not** an order-of-magnitude breakthrough in the density constant.

## Global two-variable proof

Put `t=beta/alpha` so `0<t<1`, and `c=16r/[27(1-t)]`. The squared objective is

```
F(alpha,t) = (1-c*alpha^2)^2 / (2-t*alpha).
```

The positive-margin domain requires `0<alpha<min(1/2,1/sqrt(c))`.

**Step 1: unique alpha maximizer for each t.** The sign of the partial alpha derivative of F (after removing manifest positive factors) is

```
g(alpha,t) = t - 8*c*alpha + 3*t*c*alpha^2.
```

For `alpha <= 1/2`, `dg/dalpha=c*(-8+6*t*alpha)<0`. At alpha=0, g=t>0. At the admissible right boundary:
- when alpha=1/2, `g <= 1-(13/4)*(16/27)<0`;
- when alpha=1/sqrt(c), `g=4t-8sqrt(c)<0`, using `c>=16/27`.

Therefore F has a unique interior alpha maximum `alpha(t)`. In particular its value exceeds 1/2, the alpha→0 boundary value.

**Step 2: optimize t exactly.** The stationarity equation is

```
t*(1-t) = (16r/27)*alpha*(8-3*t*alpha).
```

Consequently at the optimum in alpha, the deletion fraction `ell=c*alpha^2` becomes

```
ell = t*alpha/(8-3*t*alpha).
```

The t derivative of log F has the sign of

```
alpha*(1-t)*(1-ell) - 2*ell*(2-t*alpha)
  = alpha*(2-3*t)*(4-2*t*alpha)/(8-3*t*alpha).
```

Because `alpha<1/2` and `t<1`, its non-`(2-3t)` factors are strictly positive. Thus the maximized F is strictly increasing on `0<t<2/3` and strictly decreasing on `2/3<t<1`. **The exact ratio beta/alpha=2/3 is optimal for every r, not merely to first order in 1/r.**

**Step 3: determine alpha.** Set t=2/3. Then `c=16r/9` and the alpha-derivative sign is the same as

```
3 - 64*r*alpha + 16*r*alpha^2.
```

The smaller quadratic root is the alpha-star above. The larger root exceeds the admissible domain. The candidate satisfies `0<alpha*<1/2`, gives loss<1, and is the unique global maximum.

**Step 4: strict independent rational witness.** The exact radical can be avoided entirely for an implementable, *rational* parameter improvement:

```
alpha1 = 3/(64r) + 1/(2048r^2) = (96r+1)/(2048r^2)
beta1  = 2*alpha1/3.
```

At alpha1 the quadratic derivative numerator is exactly

```
3 - 64*r*alpha1 + 16*r*alpha1^2
  = (1024r^2 +192r +1)/(262144r^3) > 0.
```

It is strictly decreasing on the interval from the parent alpha0=3/(64r) to alpha1, hence F is strictly increasing across that interval. An **independent polynomial elimination** yields

```
C_r(alpha1,beta1)^2 - C_parent^2
  = (377487360r^4 + 5603328r^3 -30720r^2 -320r -1)
    / [1811939328*r^4*(64r-1)*(6144r^2-96r-1)] > 0.
```

For r≥1, the numerator is at least `(377487360-30720-320-1)*r^4 >0`, and every denominator factor is positive. This is an exact all-r inequality, not a finite numeric sample.

Since alpha1 lies to the left of the strictly optimal alpha-star, the radical coefficient is still stronger than this rational improvement.

## Falsification and reproducibility

`check_exact_optimum.py` uses only Python standard-library integer polynomials and exact `Fraction` arithmetic, checks the **complete degree-4 numerator identity** via polynomial multiplication, certifies the derivative endpoint identity, checks representative exact rational differences, validates the stationarity/envelope algebraic identity, and runs a negative control where a leftward alpha perturbation **decreases** the guarantee. `Decimal` precision is only for display; no claimed inequality relies on decimal approximation.

```bash
python3 research/nightfall/projects/erdos/sidon-repair-bridge-2026-10-29/ryev_exact_window_optimum_20261029/check_exact_optimum.py
python3 research/nightfall/projects/erdos/sidon-repair-bridge-2026-10-29/ryev_window_optimization_20261029/check_window.py
python3 research/nightfall/projects/erdos/sidon-repair-bridge-2026-10-29/ryev_window_optimization_20261029/construct_window.py
```

The previous real finite constructions at q=101,257,1009 remain legitimate tests of parent parameters, **not** new finite witnesses for alpha-star. The exact new theorem is a uniform-in-r analytic improvement to the fixed-prefix guarantee; making a finite large-q instance that exhibits the very small increment would require much larger field sizes and is not necessary for the algebraic comparison.

**Requested audit:** Lemnis should independently differentiate and attack boundary cases, including 1/sqrt(c) and t→0,1; Axiom should independently check transfer to the original source's floors, collision accounting and fixed-prefix quantifiers; Vesper should review priority and scope before any publication status promotion. Dated external-prior-art clearance remains open.

**Stop rule:** no further tiny coefficient polishing within this same loss proxy. A subsequent major gain requires a qualitatively stronger collision counting inequality or a new construction.
