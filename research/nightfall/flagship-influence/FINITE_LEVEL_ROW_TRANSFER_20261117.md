# Finite-output row-to-influence transfer and a sharp single-cut information barrier

**Research checkpoint:** 2026-11-17 Eastern. Author-side derivation by the NIGHTFALL parallel audit, under Devin J. Wright's research direction. **Mathematical status:** proved conditional on the **established Boolean two-sided fractional-row theorem** (Turturean 2026, Theorem 5.4 / Section 9.5; original-product finite-alphabet bridge in merged NIGHTFALL #298/#309). Exact independent finite rational regression checks included. This does **NOT** solve the unrestricted real-valued row problem, unrestricted Q3 exponent two, or N-UE2(2,1); no new Lean certificate or publication-priority determination. Attribution: Turturean's Boolean row theorem is an imported prior result.

## 1. Fully audited old obstruction: singleton sensitivity 4, optimal full row 6

On four independent fair signs define
\[
f(a,b,c,d)=(-a+b-c-d)/2+(a+b)(c-d)/4.
\]
The earlier real-valued sharp PSI statement using singleton sensitivity \(R=\max_x\sum_i|f(x)-f(x^i)|=4\) fails: \(V=5/4\), every genuine resampling influence \(I_i=3/8\), and \(4V^2/(R^2M)=25/24>1\) (draft #808).

The **true uniform fractional-row cost**
\[
K^*(f)=\max_x\min_{r^x_i\ge0}\left\{\sum_i r_i^x:
 |f(x)-f(y)|\le\sum_{i:x_i\ne y_i}r_i^x\quad\forall y\right\}
\]
is exactly **six**, not four. At \(x=(-1,+1,-1,-1)\) with \(f(x)=2\), the two destination states
\[
y_1=(-1,-1,+1,-1),\qquad y_2=(+1,+1,-1,+1)
\]
have \(f(y_1)=f(y_2)=-1\), and their disagreement sets are disjoint, \(\{b,c\}\) and \(\{a,d\}\). The two **simultaneous** full-row constraints force
\(r_b^x+r_c^x\ge3\) and \(r_a^x+r_d^x\ge3\), so \(K^*\ge6\). An independent exact table of sixteen explicitly feasible rational rows, each costing \(\le6\), proves the reverse inequality. This is a **primal/dual exact certificate**, with the two disjoint demands constituting a dual fractional packing of total value six; no generic LP optimizer is needed to verify it.

The tempting row coefficient-four conjecture \(M\ge4V^2/K^2\) **survives** this example, because \(4V^2/(K^{*2}M)=25/54<1\). Neither the c=4 row conjecture nor the weaker existence of some c>0 is established by this check.

## 2. New finite-level theorem — all finite source products

Let \(f\) be any bounded real function on a finite product of independent finite probability spaces, with **m \(\ge2\) distinct positive-support output levels** \(u_1<\cdots<u_m\). Null-mass letters are discarded. Suppose that every source point \(x\) admits a nonnegative **full fractional row** \(a^x\) with \(\sum_i a_i^x\le K\) and
\[
|f(x)-f(y)|\le\sum_{i:x_i\ne y_i}a_i^x\quad\text{for every supported }y.
\]
Put \(V=\operatorname{Var}(f)\), \(M=\max_i \operatorname{Inf}^{\rm resample}_i(f)\), \(\delta_k=u_{k+1}-u_k>0\), \(g_k=\mathbf1_{\{f\ge u_{k+1}\}}\), and \(q_k=\operatorname{Var}(g_k)=p_k(1-p_k)\), with \(p_k=\Pr[f\ge u_{k+1}]\). Then the exact **threshold-sensitive certificate** and its gap-free corollary are
\[
\boxed{\quad K^2M\ge\max_{1\le k<m}\delta_k^4q_k,\qquad
  K^2M\ge\frac{4}{(m-1)^4}V^2.\quad}\tag{FL}
\]
No degree bound, atom floor, equal alphabet, Boolean input assumption, or coordinate-count dependence appears. The only non-elementary imported input is the finite original-product Boolean two-sided row theorem; on the uniform cube this is explicitly Turturean 2026 Section 9.5. For general original product laws, use the true-law row/influence transfer in merged #298/#309 and positive-support reduction; its Lean top-level hypotheses must be audited before claiming an integrated terminal for (FL).

### Independent analytic proof

**A. One row works for every threshold after a known gap scaling.** For any supported \(x,y\) with \(g_k(x)\ne g_k(y)\), their output levels lie on opposite sides of \((u_k,u_{k+1})\), so
\[
\delta_k\le|f(x)-f(y)|\le \sum_{i:x_i\ne y_i}a_i^x.
\]
Consequently \(\lambda^{k,x}_i=a_i^x/\delta_k\) is a *genuine full row* for Boolean \(g_k\), with cost \(\le K/\delta_k\). The established **Boolean** row theorem implies
\[
\max_i I_i(g_k)\ge q_k\delta_k^2/K^2.
\]

**B. Preserve the genuine original-law influence.** Each source single-coordinate independent resampling pair \(X,X^{(i)}\) satisfies
\[
(f(X)-f(X^{(i)}))^2\ge\delta_k^2(g_k(X)-g_k(X^{(i)}))^2.
\]
Taking one-half expectation gives \(I_i(f)\ge\delta_k^2 I_i(g_k)\) under the actual independent laws. Thus \(K^2M\ge\delta_k^4q_k\) for **every** k.

**C. Recover total variance from nested threshold layers.** Pointwise,
\(f=u_1+\sum_{k=1}^{m-1}\delta_k g_k\). In \(L^2\) centered around expectations, the triangle inequality yields
\[
\sqrt V\le\sum_{k=1}^{m-1}\delta_k\sqrt{q_k}.
\]
Let \(S=\max_k\delta_k^2\sqrt{q_k}\). Since \(q_k\le1/4\),
\[
\delta_k\sqrt{q_k}
 =\sqrt{\delta_k^2\sqrt{q_k}}\ q_k^{1/4}
 \le\sqrt{S/2}.
\]
Therefore \(V\le (m-1)^2S/2\), so \(K^2M\ge S^2\ge 4V^2/(m-1)^4\). The case of constants has \(V=M=0\).

**At m=2**, this gives the **dictator-sharp coefficient four**, \(K^2M\ge4V^2\), and in fact the stronger \(K^2M\ge \delta_1^4q_1=4B(f)^2V\). The proof correctly specializes to Boolean real-output functions and arbitrary original product marginals.

## 3. Sharpness of the *single-threshold mechanism*, not of universal row complexity

For fixed \(m\ge3\), take a **single categorical source coordinate** with m equally spaced output values on \([-1,1]\):
\[
u_j=-1+\frac{2(j-1)}{m-1}.
\]
Put mass \((1-\varepsilon)/2\) on each endpoint and mass \(\varepsilon/(m-2)\) at each interior level, with \(0<\varepsilon<1\). As \(\varepsilon\to0\), \(\operatorname{Var}(f)\to1\), and for **every** threshold \(p_k\to1/2\), \(q_k\to1/4\), while \(\delta_k=2/(m-1)\). Hence
\[
\frac{\max_k\delta_k^4q_k}{V^2}
\longrightarrow \frac{4}{(m-1)^4}.
\]
So the *final numerical step based only on selecting one threshold and using its gap-rescaled row* cannot improve the power \(m^{-4}\). **This does not show that the true full-row inequality needs an m-dependent coefficient.** In fact this very example has one input coordinate, exact uniform full-row cost \(K=2\), and \(M=V\), so \(K^2M/V^2=4/V\to4\), with no dependence on m.

This is the decisive mechanism lesson: the single-cut information can be arbitrarily weaker than the actual coherent multi-level row geometry, **even for a one-coordinate source**. A universal real-valued bilinear estimate must aggregate **cross-threshold information**, not simply take the best separately normalized Boolean cut. This explains the cubic moment in Turturean's original integrated level proof (Section 7.2); it is not a new proof of the stronger desired quadratic-moment bound.

## 4. Independent replay and next adversarial test

Run \`python3 -I research/nightfall/flagship-influence/check_finite_level_rows_exact.py\`. It validates:
- 16 hard-coded, rational, feasible full rows for the four-bit PSI witness and a two-disjoint-block dual lower certificate forcing \(K=6\);
- full original-law resampling influences and *every* nested threshold's gap-rescaled row feasibility for rational-output functions on biased, heterogeneous and null-atom categorical products;
- the exact bound \(K^2M\ge\max \delta^4q\ge4V^2/(m-1)^4\) across all fixtures;
- m=2 Boolean equality for a fair dictator, and the multi-output one-coordinate near-endpoint sharpness mechanism.

**Certification:** analytic deduction + exact finite regression + explicit primal/dual certificate for the four-bit witness. No Lean (except the imported earlier Boolean source theorem), non-author mathematical review, or full universal/novelty proof. Exact checker is *not* evidence that the open real-valued row theorem holds for arbitrary m. The next decisive operator is a coherent *bilinear* estimate summing threshold interactions without losing one gap factor per cut. Any success must survive the one-coordinate m-level example, the four-bit \(K=6\) source certificate, and the true source-consistent Q3 replica witness with \(K_{\rm annealed}\ge64/49\) from draft #810.
