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

## Corollary: prescribed windows with an integer derivative order

The apparent integer-rounding gap can be resolved without changing the source theorem. Fix any `lambda > 0`, `U > 0` such that `t=lambda*U >= 10`. Choose

\[
k=\left\lfloor\frac{5t}{4}\right\rfloor,\qquad j=k-1\ge0.
\]

Then **for this prescribed** `[U,3U/2]`, rather than a window chosen after fixing `j`, the same normalized kernel satisfies

\[
\frac{\int_0^U u^j e^{-\lambda u}\,du+\int_{3U/2}^\infty u^j e^{-\lambda u}\,du}
{\int_0^\infty u^j e^{-\lambda u}\,du}
\le \left(\frac{2919}{2944}\right)^k+\left(\frac{60}{61}\right)^k.
\]

**Proof.** By the floor inequality and `t>=10`,

\[
\frac{8t}{7}\le\frac{23t}{20}\le\frac{5t}{4}-1\le k\le\frac{5t}{4}.
\]

Consequently `t<=7k/8` and `3t/2>=6k/5`. Under the substitution `Z=lambda*u`, the lower tail is at most `P(Z<=7k/8)` and the upper tail at most `P(Z>=6k/5)`. For the lower tail, Markov applied to `exp(-Z/7)` gives

\[
\Pr(Z\le7k/8)\le \left(\frac78 e^{1/8}\right)^k.
\]

Taylor's bound at `1/8` is `e^(1/8)<=417/368`, so the base is at most `(7/8)*(417/368)=2919/2944<1`. The upper tail uses the preceding `60/61` bound. **QED.**

This proves the *elementary kernel integer-rounding bridge* for any prescribed window with `lambda U>=10`. It does **not** close the Landau analytic-continuation, zero-exclusion, arithmetic one-sided bound, or source-statement equivalence gates. The checker now additionally probes seven prescribed windows by a separate finite Poisson-tail formula.

## Source-to-target bridge **NOT established**

The original argument needs more than concentration:

1. The elementary prescribed-window integer rounding is now proved above for `lambda U>=10`; matching the exact kernel normalization and `lambda` choices in the pinned source is still open.
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

## NIGHTFALL research-priority transition

- **Direct RH rediscovery:** historical/superseded as a flagship objective following the external formal proof and independent kernel checks. Keep prior RH/Hankel derivations and counterexamples intact; do not retroactively assert they proved RH.
- **Hankel operators:** preserve exact finite-rank positivity certificates and analytic failures for independent mathematical value. Reopen only with a sharp standalone theorem, a demonstrable transfer beyond the already proved RH statement, or a material reduction in formal proof complexity.
- **Active reusable analysis:** isolate the actual localized Landau zero-exclusion dependency and source-pinned arithmetic parameter restrictions. The elementary gamma-window results above are complete as written; **the full Landau and theta-lift bridges are open**.
- **Other flagship work:** do not divert resources from the source-scoped two-query tensor-subcube simulation problem, the degree/variance frontier, or exact certificate review merely to optimize gamma concentration constants.
- **Independent reviewer challenge:** first reproduce the prescribed-window statement, verify its integer floor constants and the exponential moment proof without reading `check_rh_window_gamma.py`; then determine whether a materially stronger statement is needed by the source.

The portfolio transition is a **priority recommendation**, not a claim of a new discovery or a deletion of historical records.

## Audit / stop rule

- **Best verified construction:** exact rational gamma-tail constants with a short, complete paper proof; no formal kernel certificate and no new analytic number-theory theorem.
- **Independent audit:** pre-register a separate derivation using an Erlang/Poisson tail or integration-by-parts and check every `j>=0` step symbolically, not merely by sampled numerics.
- **Novelty gate:** existing gamma Chernoff bounds are standard; new contributions require a genuinely stronger theorem, a nontrivial transfer with proven feasibility, or a new formally verified bridge not already in Lean/Mathlib.
- **Budget/stop:** stop optimizing these easy constants after 8 base and 7 prescribed-window sample tests and exact arithmetic checks; invest next in the semantic Landau/analytic-continuation bridge and its proof dependencies. If that is already in the RH source, extract/cite it rather than redescribe it as original.
- **Status:** illustrative standalone lemma, verified handwritten reasoning plus machine-checked rational arithmetic, independent human review pending.