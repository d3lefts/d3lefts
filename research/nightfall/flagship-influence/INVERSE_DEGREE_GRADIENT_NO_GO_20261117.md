# NIGHTFALL / UE2 — exact addressing counterexample to a stronger heat-resolvent shortcut

**Checkpoint:** 2026-11-17 US Eastern. **Status:** exact analytic no-go theorem for one proposed sufficient proof step; independently checked with rational Fourier and direct small-state enumeration. This is **not** a counterexample to N-UE2(2,1), N-UE2(2), N-UE2(6), or unrestricted cubic exponent two. No external novelty or Lean proof claimed.

## Proposed stronger bridge — FALSE

Let \(\nu\) be a finite independent product law, \(f\in L^2(\nu)\) be bounded with mean zero and Efron–Stein degree at most \(d\), and write \(R_i=I-\mathbb E[\cdot\mid X_{-i}]\), \(N=\sum_i R_i\). The inverse \(N^{-1}\) is defined on centered functions by multiplying each nonempty ANOVA sector of order \(|S|\) by \(1/|S|\).

A tempting conjectural strengthening of the flagship inequality is

\[
\tag{FALSE (H)}
\sum_i\|R_iN^{-1}f\|_2\le d\,B(f),
\quad B(f)=\tfrac12\operatorname{ess\,osc}(f).
\]

It would imply N-UE2(2,1) immediately, since
\[
\operatorname{Var}(f)=\sum_i\langle R_if,R_iN^{-1}f\rangle
\le\sqrt{M}\sum_i\|R_iN^{-1}f\|_2.
\]
**(H) is false with an unbounded violation factor**, even for independent fair bits.

## Exact address family

Take \(k\) independent fair address signs \(A_1,\ldots,A_k\) and \(2^k\) independent fair leaf signs \(Y_s\), one for each \(s\in\{-1,1\}^k\). Set \(f(A,Y)=Y_A\). This is a bounded mean-zero pure selector, with \(B=1\), \(\operatorname{Var}(f)=1\) and Fourier degree exactly \(d=k+1\).

Expand every addressing indicator as
\[
1_{\{A=s\}}=2^{-k}\sum_{T\subseteq[k]}\chi_T(s)\chi_T(A),
\quad f=2^{-k}\sum_s\sum_{T\subseteq[k]}\chi_T(s)\chi_T(A)Y_s.
\]
Each term has order \(|T|+1\). Therefore, for each leaf s,
\[
\|R_{Y_s}N^{-1}f\|_2^2
=4^{-k}\sum_{j=0}^k\frac{\binom{k}{j}}{(j+1)^2}.
\]
Summing leaf norms gives the **exact** lower bound
\[
\sum_i\|R_iN^{-1}f\|_2
\ge\sqrt{\sum_{j=0}^k\frac{\binom{k}{j}}{(j+1)^2}}.
\]
For k=14, the squared leaf sum is exactly
\[
\frac{1710440723}{5405400}>225=(k+1)^2,
\]
so (H) fails already at finite degree d=15. Since the square-root expression grows asymptotically like \(2^{k/2}\cdot(2/k)\), the violation factor over \(dB=k+1\) is unbounded as k grows. A coarser fully elementary bound \(\sum_j\binom{k}{j}/(j+1)^2\ge2^k/(k+1)^2\) also proves unbounded failure.

## Does the address function challenge UE2? No.

For a leaf s, the true source influence is \(I_{Y_s}(f)=2^{-k}\). For each address bit, swapping its value selects an independent fair leaf, giving \(I_{A_j}(f)=1/2\). Consequently M=1/2, V=B=1 and
\[
\frac{V^2}{d^2B^2M}=\frac{2}{(k+1)^2}<1\quad(k\ge1).
\]
This example **does not refute the underlying conjecture**. It shows that any sharp proof cannot merely apply Cauchy and a uniform \(\ell^1(L^2)\) bound for the inverse degree operator; address-selection effects need to be charged jointly to the original influential address coordinates.

## Exact audit and next transition

- Checker: `research/nightfall/flagship-influence/check_address_resolvent_no_go.py` (Python stdlib / `Fraction`). Full-state exact Fourier audit for k=1,2,3 and exact rational symbolic sum for k=14 and other k; two logically independent computational paths at small k.
- This negative result is an audit of our own stronger proposed lemma, not of a published lemma. Known addressing functions and Fourier decompositions are classical; no novelty claim.
- **Next proof mechanism:** introduce a *coupled* dual certificate assigning leaf gradient mass to address-coordinate influence, instead of charging every inverse-degree gradient separately. The same issue obstructs naive random-selector maximum/expectation interchanges in cubic two-replica reductions (#799, #803).

**Discovery graph:** N-UE2(2,1) → inverse degree operator → conjectured global \(\ell^1(L^2)\) gradient bound → exact address Fourier expansion → violation at k=14 → joint selector charge required.
