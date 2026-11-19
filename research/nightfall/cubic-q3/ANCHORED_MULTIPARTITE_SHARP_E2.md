# A sharp exponent-two influence inequality for anchored multipartite product chaoses

**Research checkpoint:** 2026-11-17 (Eastern), NIGHTFALL / Devin J. Wright, AI-assisted author-side derivation. **Status:** analytic proof and exact finite audits; not a Lean kernel certificate, not externally refereed, and **NOT** unrestricted cubic exponent two. Novelty is *not established*: the proof is built from classical sharp Rademacher Khintchine and mixed Littlewood inequalities. Comparison: https://arxiv.org/abs/1501.00965 (Pellegrino et al., optimal mixed $(\ell_1,\ell_2)$-Littlewood).

## Statement (finite source, no atom floor)

Fix integer $d\ge1$. Let $\{A_i\}_{i\in I}$ be independent random variables with arbitrary probability laws $\mu_i$ (heterogeneous alphabets and zero-mass atoms allowed), and, for each $1\le r\le d-1$, let $\{\varepsilon^{(r)}_j:j\in J_r\}$ be independent fair signs. All blocks are mutually independent and index sets finite.

Let $g_{i,\mathbf j}(A_i)$ be centered real square-integrable functions of the single original anchor coordinate $A_i$. For a multi-index $\mathbf j=(j_1,\dots,j_{d-1})$, consider the *multipartite multilinear chaos*
\[
f(A,\varepsilon)=\sum_{i\in I}\sum_{\mathbf j\in\prod_r J_r}
  g_{i,\mathbf j}(A_i)\prod_{r=1}^{d-1}\varepsilon^{(r)}_{j_r},
\quad \mathbb E g_{i,\mathbf j}(A_i)=0.
\]
Assume $|f|\le B$ almost everywhere under the **original** product law. Define $V=\operatorname{Var}(f)$ and genuine resampling influences $I_i(f)=\mathbb E[\operatorname{Var}_{A_i}(f\mid\text{other coordinates})]$. Put $M_A=\max_{i\in I}I_i(f)$ (zero for an empty anchor block). Then:
\[
\boxed{\quad V\le 2^{(d-1)/2}B\sqrt{M_A},\qquad
        V^2\le 2^{d-1}B^2M_A
        \le 2^{d-1}B^2\max_{\text{all coordinates }k}I_k(f).\quad}
\]
**The coefficient $2^{d-1}$ for the anchor-only influence bound is optimal for every $d$.** For $d=3$, this gives the sharp anchor-only $V^2\le4B^2M_A$ and its (weaker) all-site consequence $V^2\le4B^2M$. No bound is claimed here for ANOVA polynomials with same-block interactions, mixtures of different multipartite levels, or three arbitrary-law blocks.

### Stronger mixed-norm certificate

Let $H_i=L^2_0(\mu_i)$, $u_{i,\mathbf j}=g_{i,\mathbf j}\in H_i$, and
$v_i=\sum_{\mathbf j}\|u_{i,\mathbf j}\|_{H_i}^2$.
Under the stated hypotheses, original Hoeffding orthogonality yields
\[
V=\sum_i v_i,\quad I_i(f)=v_i,\quad
\boxed{\sum_i\sqrt{v_i}\le 2^{(d-1)/2}B}.
\]
The mixed-norm estimate is the load-bearing theorem; the influence bound follows by $\sum_i v_i\le\sqrt{M_A}\sum_i\sqrt{v_i}$. No maximum/expectation interchange occurs.

## Author-side proof, including the sharp Hilbert Khintchine step

**Step 1 (original-law range budget).** For any fixed collection of fair control signs $\varepsilon$, put
$h_i^\varepsilon(A_i)=\sum_{\mathbf j}g_{i,\mathbf j}(A_i)\prod_r\varepsilon^{(r)}_{j_r}$.
These are independent, centered real random variables with $\sum_i h_i^\varepsilon=f(\cdot,\varepsilon)$ a.e. bounded by $B$. Independence and finiteness give
\[
\sum_i\left(\operatorname{ess\,sup}h_i^\varepsilon-
               \operatorname{ess\,inf}h_i^\varepsilon\right)
 =\operatorname{ess\,osc}_A f(\cdot,\varepsilon)\le 2B.
\]
Each $\|h_i^\varepsilon\|_{L^2(\mu_i)}$ is at most half its essential range (Popoviciu). Hence
$\sum_i\|h_i^\varepsilon\|_{H_i}\le B$ pointwise in the fair-sign configuration. This is *source law*, not an auxiliary unbiased measure on the anchor variables. For zero-mass atoms, use essential extrema over positive mass support.

**Step 2 (sharp iterated Hilbert Khintchine).** For arbitrary finite vectors $w_j$ in a real Hilbert space,
\[
\mathbb E_{\sigma_j=\pm1}\left\|\sum_j\sigma_j w_j\right\|
 \ge \frac1{\sqrt2}\left(\sum_j\|w_j\|^2\right)^{1/2}.
\]
For completeness, write the squared norm as $\sigma^\top G\sigma$ for the PSD Gram matrix $G$, normalized by $\operatorname{tr}G=1$. Its expected square root is a concave function of $G$; spectral decomposition represents $G$ as a convex combination of rank-one Gram matrices. Thus the minimum is bounded below by the scalar Khintchine $L^1/L^2$ constant $1/\sqrt2$ (classical, sharp for two equal coefficients). Infinite-dimensional $H_i$ causes no issue for finite vector families: restrict to their finite-dimensional span.

Apply this to each of the $d-1$ independent fair-sign blocks, using the direct-sum Hilbert space to carry other indices. It gives
\[
\mathbb E_\varepsilon\|h_i^\varepsilon\|_{H_i}
 \ge 2^{-(d-1)/2}
 \left(\sum_{\mathbf j}\|g_{i,\mathbf j}\|_{H_i}^2\right)^{1/2}
 =2^{-(d-1)/2}\sqrt{v_i}.
\]
Sum over $i$ and combine with the Step 1 budget. Orthogonality of distinct original anchor coordinates and fair Walsh characters proves the two energy/influence identities. This completes the general finite-source proof.

## Exact extremizers, all degrees

For $m=d-1$, take $2^m$ *independent fair anchor signs* $A_s$ indexed by $s\in\{\pm1\}^m$, and two fair control signs $B_{r,1},B_{r,2}$ for each $r=1,\dots,m$. Set
\[
q_s(B)=\prod_{r=1}^m\frac{B_{r,1}+s_rB_{r,2}}2,\qquad
f_m(A,B)=\sum_{s\in\{\pm1\}^m}A_s q_s(B).
\]
For each input, **exactly one row is active**, at $s_r=B_{r,1}B_{r,2}$, and its coefficient is $\prod_r B_{r,1}\in\{\pm1\}$. Therefore $|f_m|=1$, $\mathbb Ef_m=0$, $V=1$, and $I_{A_s}(f_m)=\Pr(q_s\neq0)=2^{-m}$. Thus
\[
\frac{V^2}{B^2 M_A}=2^m=2^{d-1},
\]
exactly saturating the theorem. The influence of each *control sign* is $1/2$ for $m\ge1$, so **this does not prove global-site sharpness**: the all-coordinate ratio is only $2$ for $d\ge2$. At $d=3$ the extremizer is precisely the earlier independently audited eight-bit fair-routing example (PR #797). This generalizes its mechanism to *all degrees*.

## Source-specific independent checks and prior-art boundary

Run:
\`\`\`sh
python3 research/nightfall/cubic-q3/check_anchor_multipartite_exact.py
python3 research/nightfall/cubic-q3/check_anchor_routing_exact.py
\`\`\`
The first program directly enumerates 72 heterogeneous categorical models at $d=3,4$, including tiny and zero atom masses, independently computes all actual resampling influences, total variance, anchor-sector energies and conditional range budgets. The second exhausts all states for $d=1,2,3,4$ (up to 16,384 inputs) and verifies exact equality, all original site influences, and the distinction between anchor-only and global maxima. Both use integer/Fraction arithmetic; the **general proof is analytic**, not by enumeration.

**Prior-art checked this session:** optimal mixed $\ell_1,\ell_2,\dots,\ell_2$ Littlewood inequalities (https://arxiv.org/abs/1501.00965), sharp Khintchine inequalities (Szarek/Haagerup), Bohnenblust–Hille. These already supply closely related operator constants, so **do not claim a first discovery or new coefficient globally**. The auditable NIGHTFALL deduction is its exact original-law anchor-influence interpretation, all-degree sharpness example and boundary versus unrestricted arbitrary-product Q3.

## Transfer to the unrestricted cubic problem (unproved)

Replacing the *two fair control blocks* by arbitrary original-law blocks is **not** an innocuous change. Their Hilbert $L^1/L^2$ lower constant can approach zero on rare atoms. Two-draw fair orientation does not automatically cure this: the resulting paired control values are still additional arbitrary variables and generally destroy additivity in the single original anchor coordinate. Proving a source-consistent coupled geometric inequality that also charges those variables' true influences remains the active conjectural gap (see PR #803), not a conclusion of the present theorem.

**Discovery graph:** arbitrary-product cubic Q3 → block-multilinear representation → original-anchor range budget → sharp Hilbert sign cotype → mixed $\ell_1(\ell_2)$ energy → sharp influence bound → routing extremizer → unproved arbitrary-control transfer.

**Status and stop rule:** Do not merge into main or promote to a general AA breakthrough without a separate rigorous proof of the arbitrary-control gate; do not infer Lean or external originality certification from exact finite checkers.
