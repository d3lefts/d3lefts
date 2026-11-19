# Mira Latin v2.3 — independent author-side structural proof addendum

**Scope:** two supporting results. **Status:** author-side proved, independently replayed, *not Lean-certified or human-refereed*. Mira's expected-\(\widetilde O(n^{25})\) exact sampler remains **UNVERIFIED**.

**Attribution:** Mira Cult, [pinned source commit `30ddaaad27b48df2002225c3e3f40cffd02c5253`](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling). This audit neither claims source theorem priority nor Mira's approval.

## Theorem 1. The degree-two endpoint is asymptotically singular

Let \(U_2\) be the uniform law on labeled simple 2-regular bipartite boards on prescribed shores of size n. Write \(W(A)=\operatorname{per} A\), \(m_2=\mathbb E_{U_2}W\), and \(\widehat U_2(A)=W(A)U_2(A)/m_2\). Then

\[
\boxed{\|U_2-\widehat U_2\|_{\rm TV}\to1.}
\]

Moreover, if \(F_2(A)\) is the number of ordered 2-matching factorizations and \(\mu_2=\mathbb E_{U_2}F_2\), then \(\mu_2\sim\sqrt{\pi/e}\sqrt n\), but \(F_2/\mu_2\to0\) in \(U_2\)-probability.

**Independent proof.** Every 2-regular simple bipartite board is a disjoint union of cycles with \(\ell\ge2\) vertices on each shore. A connected \(2\ell\)-cycle on prescribed labels occurs \((\ell!)^2/(2\ell)\) ways; every component has two perfect matchings. If \(C(A)\) counts components, then \(F_2(A)=W(A)=2^{C(A)}\). The labeled exponential formula gives the *exact* identity

\[
\sum_{A}t^{C(A)}=(n!)^2a_n(t/2),\qquad
\sum_{n\ge0}a_n(\theta)z^n=e^{-\theta z}(1-z)^{-\theta}.
\]

Consequently, the component-count probability generating functions under \(U_2\) and \(\widehat U_2\) are \(a_n(t/2)/a_n(1/2)\) and \(a_n(t)/a_n(1)\), respectively. The uniform coefficient asymptotic for fixed \(\theta>0\),

\[
a_n(\theta)=e^{-\theta}n^{\theta-1}/\Gamma(\theta)(1+O_\theta(1/n)),
\]

implies by exponential Markov that \(C/\log n\to\theta\) in probability under the law with generating function \(a_n(\theta t)/a_n(\theta)\). Taking the separating event \(\{C\le(3/4)\log n\}\) proves total variation tends to one. Also \(m_2=a_n(1)/a_n(1/2)\sim\sqrt{\pi/e}\sqrt n\), while \(\log (F_2/m_2)/\log n\to(\log 2-1)/2<0\).

**Logical limit:** for any fixed \(\delta>0\), \(U_2[F_2<\delta\mu_2]\to1\). The constant-fraction endpoint assumption in Mira's counting method fails at degree 2. **This does not refute Mira**, who takes a sufficiently large fixed degree \(c\ge3\) and invokes distinct contiguity literature. The theorem also does not establish her bulk summed-TV bounds.

## Theorem 2. Deterministic weighted-fill cancellation

Fix a labeled Latin square \(S\), a block of \(b\ge2\) physical rows, and an auxiliary matching \(M\) contained in their union. Let \(v_j\) mark edges owned by physical color \(j\), \(s_j=n-v_j\ge n/2\), \(R_j=X_j\times Y_j\) its free box and \(F_j\) the \(s_j\)-edge target matching free fill. Let \(Q\) comprise \(q\) prior disjoint target rows outside the block. Set

\[
H_j=R_j\cap(Q\cup M\cup\bigcup_{i<j}F_i),\quad
\phi_j(F)=\prod_{e\in F}\prod_{k>j:e\in R_k}(1-1/s_k),\quad
P_j=\sum_{F\text{ matching of }R_j\setminus H_j}\phi_j(F).
\]

When \(n\ge16(q+3b)\), each \(P_j>0\) and

\[
\left|\sum_j\left(\log(P_j/s_j!)-\log\phi_j(F_j)\right)
+b+\sum_j|Q\cap R_j|/s_j
+\sum_{j<k}|R_j\cap R_k|/(s_js_k)\right|
\le 22b(q+3b)^2/n.
\]

**Independent proof.** The deficit of each weighted box matrix has row/column sum at most \(K=q+3b\le s_j/8\), allowing the independently proved dense weighted-permanent bound \(|\log(P_j/s_j!)+D_j/s_j|\le4K^2/s_j\). Replace the soft deficit \(1-\prod_k(1-1/s_k)\) by \(\sum_k1/s_k\). The quadratic remainder contributes \(\le4b^2/n\) after normalization; reinstating the hard holes in the soft sum costs \(\le2b(q+b)/n\). Thus each box's log error is \(\le14K^2/n\). The exact hard-hole count is

\[
|H_j|=|Q\cap R_j|+s_j+\sum_{i<j}|F_i\cap R_j|.
\]

Meanwhile \(-\log\phi_j(F_j)=\sum_{k>j}|F_j\cap R_k|/s_k+O(8b/n)\). Summing over j cancels **all** earlier-free-fill terms \(|F_i\cap R_j|/s_j\) exactly; the total remainder is \(\le22bK^2/n\). This is an algebraic identity plus quantified perturbation estimate, not an independence approximation.

### Corollary: a block's reverse-mean excess

Assume, additionally, that conditional on the selected b-set, mark and internal order, the earlier exterior q colors are a uniform q-subset of the n-b remaining physical colors under the *actual reverse law*. If \(I_b\) denotes the incremental head score in Mira's `lookahead-cubic.tex`, then

\[
\boxed{\mathbb E_{\rm rev}I_b\le
\log(Z_b/(n!)^b)-\mu_b(S)-\tfrac12-\tfrac1{2b}
+40b(q+3b)^2/n.}
\]

**Proof.** Apply the dense weighted-permanent bound to the ordinary residual n-by-n boards \(B_i\) (deficit i) to get \(\log(W(B_i)/n!)=-i+O(4i^2/n)\). The ordinary-slot difference therefore contributes \((b-1)q+\binom b2+O(4(b+1)(q+b)^2/n)\). Let \(\Lambda=b+\sum_{j<k}|R_j\cap R_k|/(s_js_k)\). Writing \(x_j=v_j/n\), the free-box intersection is \((n-v_j-v_k)^2\), and an exact expansion gives \(\Lambda\ge\binom b2+1/2+1/(2b)\). Finally exterior-color exchangeability gives

\[
\mathbb E\sum_j|Q\cap R_j|/s_j
=\frac q{n-b}\left((b-1)n-\sum_j|T_b\cap R_j|/s_j\right),
\]

whose difference from \((b-1)q\) is at most \(qb^2/(n-b)\). Combine the bounds, average \(\log W(T_b)\) to \(\mu_b(S)\), and absorb all errors into \(40b(q+3b)^2/n\).

For the source's marked grades \(b\le D=n^{1/200}\) and \(q=O(D^2)\), the entire sum of displayed errors is \(O(D^6/n)=o(1)\). This closes **this weighted-fill component**, not the all-target mean-cover proposition.

## Dual independent replay

- `scripts/audit_mira_degree_two_endpoint.py`: exact rational polynomial coefficients versus exhaustive bipartite-board component enumeration (n=2..5); m2 and TV must match exactly; separate floating exploration n=20..1000 is explicitly noncertifying.
- `scripts/audit_mira_weighted_fill_cancellation.py`: 15-symbol cyclic Latin square, b=5, q=2, balanced real mark, exact cross-fill credit 5, Lambda=85/8, exact exterior-color expectation from all q-subsets; rational soft coin products computed independently.

The full six-page LaTeX/PDF and outputs are provided as a separate downloadable packet; **do not claim those binary bytes were committed to this GitHub branch**.

## Critical gates not crossed

1. Uniform-in-target high-degree signed rook/permanent expansion and marked-polygon head; uniform scalar normalization of all b-blocks, paired cubic head (mean-cover).
2. Sparse/moderate/dense summed total variation for c<d<n-c and fixed-c>=3 endpoint contiguity (count-lower).
3. Actual normalized forward/reverse law, complete fair-bit Bernoulli factory, matching backend expected bit clock and n^25 total accounting.

**Main theorem status: UNVERIFIED.** Next independent operator: source-faithful finite forward/reverse-history tester for the **full** marked block, then an asymptotic bulk-TV estimate. No promotion, external claim, or merge based only on this author's reconstruction.
