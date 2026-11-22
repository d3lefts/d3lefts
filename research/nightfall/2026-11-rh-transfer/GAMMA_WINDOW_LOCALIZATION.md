# RH transfer notebook: a quantitative, reusable window-localization lemma

**Checkpoint:** 2026-11-22 · NIGHTFALL · algebraic/probabilistic proof on paper, exact-rational constants audited, high-precision numerical probes. **Not a Lean certificate, a new RH theorem, a source-level reconciliation of Alpöge's argument, or a novelty claim.**

## Objective and limits

Extract a *self-contained analytic kernel lemma* used in the architecture of the zero-exclusion argument without importing its unexamined arithmetic machinery. Original sources: [Rubinstein's working exposition, 21 November 2026](https://www.math.uwaterloo.ca/~mrubinst/alpoge_claude_grh/zeta-paper.pdf), Part II, §1 (localized Landau argument), and [Slijepčević's outline, 21 November 2026](https://hexagonmath.org/2611.00812v1). Both describe windows of the form `[Y,Y^(3/2)]`, with `U=log Y`. **The lemma below is a classical gamma/Chernoff concentration estimate, not attributed as novel to NIGHTFALL.** It establishes only kernel concentration, **not** Landau's zero-exclusion theorem and not the required one-sided arithmetic bound.

## Proposition (explicit algebraic tail certificate)

For every real `lambda > 0`, integer `j >= 0`, put `k=j+1` and `U=4k/(5 lambda)`. Then

\[
\frac{\int_0^U u^j e^{-\lambda u}\,du+\int_{3U/2}^{\infty}u^j e^{-\lambda u}\,du}
{\int_0^{\infty}u^j e^{-\lambda u}\,du}
\;\le\;\left(\frac{171}{175}\right)^k+\left(\frac{60}{61}\right)^k.
\]

In particular, the relative mass outside `[U,3U/2]` tends exponentially to zero as `k` increases. Both bases are *exact rationals strictly below one*.

### Proof (no numerical inference)

Let `Z=lambda*u` under the normalized density proportional to `u^j exp(-lambda*u)`. It has the gamma distribution of integer shape `k`; directly integrating the gamma density gives

\[
\mathbb E[e^{tZ}]=(1-t)^{-k},\qquad t<1.
\]

The window becomes `[4k/5,6k/5]`. Markov's inequality applied to the nonnegative random variables `exp(-Z/4)` and `exp(Z/6)` gives

\[
\Pr\{Z\le4k/5\}\le \left(\frac45e^{1/5}\right)^k,\qquad
\Pr\{Z\ge6k/5\}\le\left(\frac65e^{-1/5}\right)^k.
\]

The elementary Taylor bounds (with `t=1/5`)

\[
1+t+\frac{t^2}{2}\le e^t\le 1+t+\frac{t^2}{2(1-t/3)}
\]

follow because every term is nonnegative and `n! >= 2*3^(n-2)` for `n>=2`. At `t=1/5` they become

\[
\frac{61}{50}\le e^{1/5}\le\frac{171}{140}.
\]

Therefore `(4/5)e^(1/5) <= 171/175` and `(6/5)e^(-1/5) <= 60/61`. Summing the two disjoint tails proves the proposition. `QED`.

### Checks, independent routes, and failure conditions

`python3 research/nightfall/2026-11-rh-transfer/check_rh_window_gamma.py` uses `fractions.Fraction` to check the *exact* rational constants. Separately it evaluates the actual gamma window mass via the finite Poisson-tail identity for integer shape (`Decimal`, high precision, k=1,2,5,10,20,50,100,250). Those numerical probes are checks for mistakes, **not proof** of the bound for all `k`. An independent reviewer should rederive the Chernoff step, Taylor estimate and scaling without reading the checker, then attack `lambda→0`, `k=1`, integer rounding, endpoint inclusion, and normalization.

The constants are deliberately conservative. The optimal Chernoff exponents are `I(4/5)=4/5-1-log(4/5)` and `I(6/5)=6/5-1-log(6/5)`; tightening them is **not** a scientific breakthrough and is not currently a priority.

## Source-to-target bridge **NOT established**

The original argument needs more than concentration:

1. For *arbitrarily large prescribed windows* with `U=log Y`, choose an integer `j` close to `(5/4) lambda U - 1`; our proposition sets `U` from `j` and does not by itself prove the integer-rounding bridge in precisely the source's parameter regime.
2. Establish the signed-to-positive conversion and tail bounds for the specific `G` and analytic continuation in the actual Landau lemma; positivity of the gamma kernel alone does not exclude poles or zeros.
3. Supply the one-sided Riesz-weighted Chebyshev bounds from the arithmetic theta-lift construction. **Nothing in this note establishes these bounds.**
4. Match every introduced quantity to a pinned Lean declaration and challenge statement; independent semantic review remains OPEN.

These are explicit gates; no claim may inherit RH/GRH certification through this note.

## Amplification cost model: exact abstraction, no unearned transfer

The 21 November 2026 exposition reports four error terms (suppressing powers `x^(C epsilon)`):

\[
E(x;m,k,n)\asymp x/m+m+xm/k+k/n^2.
\]

For **abstract freely chosen positive real parameters** with coefficients `A,B,D,F>0`, the first two terms satisfy the *sharp* lower bound

\[
Ax/m+Bm\ge2\sqrt{ABx},\quad m_*=\sqrt{Ax/B}.
\]

At a fixed `m,n`, optimizing the other two gives

\[
Dxm/k+Fk/n^2\ge2\sqrt{DFxm}/n,\quad k_*=n\sqrt{Dxm/F}.
\]

Combining these yields a valid **lower bound** `E >= 2 sqrt(ABx)` and a **constructive upper bound** for the idealized cost objective by choosing `m=m_*` and `k=k_*`:

\[
\inf_{m,k>0}E(x;m,k,n)\le 2\sqrt{ABx}+
\frac{2\sqrt{DF}}{n}\left(\frac AB\right)^{1/4}x^{3/4}.
\]

This does **not** improve Alpöge's asymptotics: his `m,k,n` are not independent free controls; they satisfy representation-theoretic and arithmetic feasibility conditions. As a cheapest decisive transfer test, extract the *actual allowed range* and dependency order of these parameters from the pinned source, then ask whether any other NIGHTFALL problem has two proven, opposing costs with these constraints. Do not claim a new optimization record by ignoring those conditions.

## Audit / stop rule

- **Best verified construction:** exact rational gamma-tail constants with a short, complete paper proof; no formal kernel certificate and no new analytic number-theory theorem.
- **Independent audit:** pre-register a separate derivation using an Erlang/Poisson tail or integration-by-parts and check every `j>=0` step symbolically, not merely by sampled numerics.
- **Novelty gate:** existing gamma Chernoff bounds are standard; new contributions require a genuinely stronger theorem, a nontrivial transfer with proven feasibility, or a new formally verified bridge not already in Lean/Mathlib.
- **Budget/stop:** stop optimizing these easy constants after 8 sample tests and exact arithmetic checks; invest next in the *prescribed-window-to-integer-index* bridge and its proof dependencies. If that is already in the RH source, extract/cite it rather than redescribe it as original.
- **Status:** illustrative standalone lemma, verified handwritten reasoning plus machine-checked rational arithmetic, independent human review pending.