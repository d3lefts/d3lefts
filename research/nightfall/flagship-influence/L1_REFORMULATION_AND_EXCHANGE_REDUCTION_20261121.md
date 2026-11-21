# Polynomial-degree exponent two: L1 reformulation and a one-step reduction

**Author:** Claude, 21 Nov 2026. **Status:** author-side.
- §2 is a proof.
- §1 and §3 are conjectures backed by numerical evidence.
- Not refereed, not Lean-certified, no novelty clearance.

**Notation.** $f$ is a bounded function on an arbitrary finite independent product, $B=\inf_c\|f-c\|_\infty$, and $d$ is its Hoeffding degree. Further:
- $D_if=f-\mathbb E_if$, where $\mathbb E_i$ integrates out coordinate $i$.
- $L_i=\mathbb E|f(X)-f(X^{(i)})|$ is the $L^1$ resampling influence. It satisfies $\mathbb E|D_if|\le L_i$ and $\operatorname{Inf}_i\ge L_i^2/2$.

## 1. Reformulation: the natural target is $L^1$ exponent ONE

**Conjecture N-L1.**
$$\max_iL_i\ \ge\ \frac{\operatorname{Var}(f)}{C\,d\,B}.$$
Since $\operatorname{Inf}_i\ge L_i^2/2$, N-L1 implies $\operatorname{Var}^2\le2C^2d^2B^2\max_i\operatorname{Inf}_i$, which is the sharp N-UE2(2) with the right $d^2$.

Why this form is the right target:
- **Level sets produce $L^1$ influence natively.** By the coarea identity, $L_i=\int 2\operatorname{Inf}_i(\mathbf 1\{f>t\})\,dt$.
- **What Turturean's machinery already gives.** It proves $\max L_i\gtrsim V^{3/2}/d^4$, i.e. $L^1$ exponent $3/2$ (v8 median theorem). His $V^{5/2}$ result is exactly that bound plus the averaging step that converts $L^1$ influence into $L^2$ influence.
- **So the landmark gap is precisely $L^1$ exponent $3/2\to1$.**
- **Degree one: N-L1 is a theorem with $C=1$, sharp, on every product law.** Write $f=c+\sum h_i$ and let $\omega_i$ be the range of $h_i$. Then $2\operatorname{Var}h_i\le\omega_iL_i$ and $\sum\omega_i=2B$.

**Evidence (no counterexample found).**

| Search | Max $V/(B\max L)$ found | $d$ |
|---|---|---|
| Nelder–Mead on the cube, $d=2$, $n\le6$ | 1.58 | 2 |
| Nelder–Mead on the cube, $d=3$, $n\le6$ | 1.46 | 3 |

Biased Chebyshev families $T_d(2S/n-1)$, with $n$ up to $16d^2$ and $p\in\{0.5,0.2,0.05\}$, give ratio/$d$ of 1.78, 2.22, 1.96, 1.10, 1.14 at $d=2,3,5,8,13$. This is consistent with linear-in-$d$ growth.

## 2. Theorem (proved): a pointwise bound reduces everything to one exchange

Let $T=\sum_S|S|^{-1}P_S$, where $P_S$ projects onto the Hoeffding component on $S$. Equivalently $T=\int_0^1\rho^{-1}T_\rho\,d\rho$ on mean-zero functions, with $T_\rho$ the product noise operator.

**Lemma (pointwise, bias-free).** For every $x$,
$$\sum_i|TD_if(x)|\le 2d^2\bigl(1+\ln(2d^2)\bigr)B.$$

*Proof.*
1. **Noise preserves the hypotheses.** $T_\rho$ is a Markov averaging operator, so $T_\rho f$ keeps the bound $B$ and degree $\le d$. It also commutes with each $D_i$.
2. **Pointwise sum bound.** By the v8 bound (eq:Dsum, which uses FHKL on binary sub-restrictions), $\sum_i|D_ih(x)|\le\sum_i\max_s|h(x)-h(x_{-i},s)|\le2d^2B$ for every such $h$.
3. **Small-$\rho$ improvement.** Fix $x$ and signs $s_i$. Then $p_s(\rho)=\sum_is_iD_iT_\rho f(x)$ is a polynomial in $\rho$ of degree $\le d$. It satisfies $p_s(0)=0$ and $|p_s|\le2d^2B$ on $[0,1]$. Markov on $[0,1]$ gives $|p_s(\rho)|\le4d^4B\rho$.
4. **Combine.** Maximizing over signs, $\sum_i|D_iT_\rho f(x)|\le\min(2d^2B,\,4d^4B\rho)$.
5. **Integrate.** $\int_0^1\rho^{-1}\min(2d^2B,4d^4B\rho)\,d\rho=2d^2B(1+\ln 2d^2)$. ∎

**Theorem.** On every finite independent product,
$$\operatorname{Var}(f)=\sum_i\mathbb E[(TD_if)(D_if)]\ \le\ 2d^2\bigl(1+\ln 2d^2\bigr)B\cdot\mathbb E\Bigl[\max_i|D_if(X)|\Bigr].$$

The identity holds because $\mathbb E[(TD_if)(D_if)]=\sum_{S\ni i}\|f_S\|^2/|S|$, and summing over $i$ gives the variance. The inequality follows from the Lemma. ∎

**Consequence.** The polynomial-degree exponent-two landmark (in the strong N-L1 form, with degree loss $d^{2+k}\log d$) follows from a single **exchange inequality**:
$$\textbf{(EXCH)}\qquad\mathbb E\max_i|D_if|\ \le\ C\,d^k\max_i\mathbb E|D_if|\quad\text{for bounded degree-}d\ f.$$

The obstacle is now isolated as exactly the $\mathbb E\max$ versus $\max\mathbb E$ exchange, with no level sets, medians or third moments left. The v8 paper flags this same exchange in its two-sample transfer. Here it appears once, cleanly, with the analytic loss already paid (a $d^2\log d$ factor).

## 3. Assessment of EXCH

- **Degree one and degree-two sign pairs:** $|D_if|$ is constant, so EXCH holds with equality.
- **Addressing function:** the target bits are each pivotal on a $2^{-k}$ fraction of inputs, so $\mathbb E\max\approx1$. But the address bits have $\mathbb E|D_if|$ of order 1, so EXCH survives.
- **Danger scenario:** $f$ whose pivotal coordinate wanders with $x$ while every fixed coordinate is rarely pivotal. That is AA-type behaviour, so EXCH is probably as hard as the problem. It is also a cleaner single-quantity target for adversarial search: maximize $\mathbb E\max_i|D_if|\,/\max_i\mathbb E|D_if|$ over bounded degree-$d$ polynomials. No search has been run yet.
- **A natural proof route to try:** combine the Lemma's pointwise $\ell_1$ control with Turturean's fixed-weight all-pairs averaging. That inequality is the one known tool that averages before optimizing over coordinates.
