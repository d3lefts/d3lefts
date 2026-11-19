# NIGHTFALL / Mira — independent sparse-strip second-moment proof (v2.4)

**Status:** complete **author-side sparse-strip argument conditional only on the explicitly cited external uniform enumeration theorem**, with exact internal arithmetic replay; neither Lean nor independent human referee has reviewed this note. **NOT a proof of Mira's full sampler.**

**Source / attribution:** Mira Cult, *Exact uniform generation of labeled Latin squares*, pinned source [Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling), particularly \`paper/incidence-v2.tex\`. Independent derivation uses [Greenhill–Hasheminezhad–Iliffe–McKay (2026), Theorems 2.1–2.2](https://arxiv.org/html/2601.04822v1). The theorem is *already Mira's claimed sparse estimate*; this reconstruction is an audit, not novelty or priority.

## A. Proof contract
- **Objective:** derive an \(n,d\)-uniform bound on the permanent-size bias of \(U_d\) for \(3\le d\le n^{1/10}\), with a summable error.
- **External input checked:** GHIM Theorem 2.1 for simple bipartite fixed-degree enumeration, and Theorem 2.2 for avoidance of a specified forbidden bipartite edge set. Both explicitly require sparseness of max degrees, and explicit bounds on \(F,\delta_{\max}\); see below.
- **Proof claim:** Theorem below, no assumptions about a random Latin square or unknown proposal.
- **Independent checker:** \`scripts/audit_mira_sparse_moment.py\`, exact rational cancellation, factorial and negative-binomial coefficients. The script cannot substitute for the external asymptotic enumeration theorem.
- **Adversary:** all overlap values \(0\le j\le n\), including full matchings; explicit cycles can change exact completion counts (PR #915), so do NOT replace exact completions by a \(j\)-only formula.
- **Stop rule:** any nonuniform error in \(j\), omitted forbidden-edge term, or unproved factorial approximation invalidates the proof; no automatic promotion of the full count-lower or sampler.

## Theorem: sparse total-variation budget

Let \(n\) be large, \(3\le d\le \lfloor n^{1/10}\rfloor\). Let \(\mathcal G_{n,d}\) be labeled \(n\times n\) simple 0–1 matrices with all row and column sums \(d\). Let \(U_d\) be uniform, \(W(A)=\operatorname{per}A\), \(m_d=\mathbb E_{U_d}W\), and \(\widehat U_d(A)=(W(A)/m_d)U_d(A)\). There exists an absolute \(C\) such that

\[
\chi^2(\widehat U_d\Vert U_d)
=\frac{\mathbb E_{U_d}W^2}{m_d^2}-1
\le C\left(d^{-4}+\frac{d^3}{n}+\frac1{\sqrt{nd}}\right),
\]

and hence

\[
t_d:=\|U_d-\widehat U_d\|_{\mathrm{TV}}
\le C\left(d^{-2}+\frac{d^{3/2}}{\sqrt n}+(nd)^{-1/4}\right).
\]

Consequently, for any fixed integer \(c\ge3\) and \(D_0=\lfloor n^{1/10}\rfloor\),

\[
\sum_{c<d\le D_0}t_d\le C/c+O(n^{-1/4}+n^{-7/40})=C/c+o(1).
\]

(The constants may change from line to line.)

### Proof

**1. Counting one and two planted perfect matchings.**
Write \(B_0\) for the total number of \(d\)-boards. Fix a perfect matching \(M\). The boards containing \(M\) correspond bijectively to \((d-1)\)-regular boards with no edge from \(M\); let this number be \(B_1\). For a second matching \(M'\) with \(j=|M\cap M'|\), the boards containing both correspond to residual boards whose degrees are \(d-1\) at the \(j\) shared endpoints on each shore and \(d-2\) at the others, with the union \(X=M\cup M'\) forbidden; denote this count \(B_2(M,M')\).

The exact \(B_2\) depends on the relative cycle structure of \(M,M'\), not just \(j\). **We make no exact overlap-only assumption**. The uniform GHIM approximation below does depend only on \(j\) *up to a controlled relative error*.

By symmetry, \(m_d=n!B_1/B_0\). The number of ordered pairs \((M,M')\) sharing \(j\) edges is
\[
(n!)^2\,h_{n-j}/j!,\qquad h_k=\sum_{\ell=0}^k(-1)^\ell/\ell!,
\]
since after choosing the first matching there are \({n\choose j}D_{n-j}\) choices for the second, where \(D_k=k!h_k\) counts derangements. Thus
\[
\frac{\mathbb E_{U_d}W^2}{m_d^2}
=\sum_{j=0}^{n}\frac{h_{n-j}}{j!}
\frac{B_2(M,M')B_0}{B_1^2},
\]
with the last ratio understood as an average over pairs at fixed \(j\). The next estimate is uniform over these pairs, so averaging changes no bound.

**2. Verify the GHIM hypotheses and extract uniform error.**
Set \(s_0=n(d-2)\), \(s=s_0+j\), and \(u=(d-1)j/s\). All residual degrees lie in \(\{d,d-1,d-2\}\), all prescribed forbidden sets have maximum degree at most two, and \(S\asymp nd\). In GHIM notation,
\[
s_{\max}t_{\max}=O(d^2)=o(S^{2/3}),\quad
F=O(nd^2),\quad
\delta_{\max}=O(d^2).
\]
Theorem 2.2 demands \(s_{\max}+t_{\max}=o(S/\log S)\),
\(\delta_{\max}=o(S)\), \(\delta_{\max}F=o(S^2)\), and \(F=o(S^{5/3})\). Each follows uniformly for \(d\le n^{1/10}\). More quantitatively, the forbidden-avoidance error
\(\delta_{\max}F/S^2+F^3/S^5=O(d^2/n+d/n^2)\), while the omitted higher terms in the GHIM Theorem 2.1 exponent, beyond \(-S_2T_2/(2S^2)\), are \(O(d^3/n)\). Theorem 2.1's own error \(O(d^6/S^2)=O(d^4/n^2)\) is smaller. Thus, **uniformly in \(j\) and in the exact pair of planted matchings**,
\[
B(\mathbf k,\mathbf k;X)=
\frac{s!}{\prod_i(k_i!)^2}
\exp\left[-\frac12(S_2/s)^2-F_X/s+O(d^3/n)\right].
\]
This is an asymptotic statement with a single absolute error constant in our sparse regime.

**3. Exact rational cancellation of the leading exponents.**
For the 0-, 1- and 2-planted terms, the respective leading \(Q\)-exponents are
\[
Q_0=-\frac12(d-1)^2,\quad Q_1=-\frac12(d-2)^2,\quad
Q_2=-\frac12(d-3+u)^2.
\]
For the forbidden sets \(F_0=0\), \(F_1/S_1=d-1\), and
\[
F_2/s=2(d-2)-(d-3)u.
\]
The last two follow exactly from
\[
S_2=(d-2)[n(d-3)+2j],\quad
F_2=j(d-1)^2+2(n-j)(d-2)^2.
\]
Hence **without any Taylor approximation**
\[
Q_2+Q_0-2Q_1-F_2/s+2F_1/S_1
=1-u^2/2. \tag{1}
\]
This cancellation is replayed by integer rational arithmetic over 4,199 triples in the independent checker.

**4. Factorial normalization and a genuine negative-binomial law.**
The quotient of the three enumerative factorial prefactors simplifies *exactly* to
\[
R_j^{\mathrm{fact}}=
\frac{(s_0+j)!(nd)!}{[n(d-1)]!^2}
\frac{(d-1)^{2(n-j)}}{d^{2n}}
=R_0^{\mathrm{fact}}\frac{(s_0+j)!}{s_0!}x^j,\qquad
x=(d-1)^{-2}.
\]
Stirling with explicit \(0<\varepsilon_k<1/(12k)\) gives
\[
R_0^{\mathrm{fact}}
=(1-x)^{s_0+1/2}\exp[O(1/(nd))].
\]
Indeed the logarithms of the leading \(k^ke^{-k}\) factors *exactly* collapse to \(s_0\log(1-x)\), and the square-root factors to \(\frac12\log(1-x)\).

Define \(K\) by
\[
\Pr(K=j)=\binom{s_0+j}{j}(1-x)^{s_0+1}x^j,\qquad j\ge0.
\]
This is a normalized negative-binomial law, since
\(\sum_{j\ge0}\binom{s_0+j}{j}x^j=(1-x)^{-s_0-1}\).
Equations (1), the Stirling identity and the GHIM uniform error yield
\[
\frac{\mathbb E W^2}{m_d^2}
=(1-x)^{-1/2}[1+O(d^3/n)]\,
\mathbb E\bigl[\mathbf1_{\{K\le n\}}\,
e\,h_{n-K}\,e^{-u(K)^2/2}\bigr], \tag{2}
\]
where \(u(k)=(d-1)k/[n(d-2)+k]\).

**5. Bound the expectation without a local central-limit theorem.**
The negative-binomial mean and variance are exactly
\[
\mathbb EK=\frac nd+\frac1{d(d-2)},\qquad
\operatorname{Var}K=\frac{(s_0+1)x}{(1-x)^2}=O(n/d).
\]
For all sufficiently large \(n\) and \(d\ge3\), \(\mathbb EK\le n/3+1/3\), hence Chebyshev gives
\(\Pr(K>n/2)=O(1/(nd))\).
For \(K\le n/2\), the alternating-series formula for derangements gives
\(\left|e\,h_{n-K}-1\right|\le e/(\lfloor n/2\rfloor+1)!\).
Furthermore, \(u(n/d)=1/(d-1)=\sqrt x\); for \(0\le k\le n\), \(0\le u(k)\le1\) and
\(\sup|u'(k)|\le2/n\). Therefore \(k\mapsto e^{-u(k)^2/2}\) is \(2/n\)-Lipschitz on this interval and
\[
\mathbb E\left|e^{-u(K)^2/2}-e^{-x/2}\right|
\mathbf1_{\{K\le n/2\}}
=O((nd)^{-1/2}).
\]
Combining these estimates,
\[
\mathbb E[\mathbf1_{\{K\le n\}}e\,h_{n-K}e^{-u(K)^2/2}]
=e^{-x/2}+O((nd)^{-1/2}).\tag{3}
\]

**6. Final cancellation and summability.**
Since \(0<x\le1/4\),
\[
(1-x)^{-1/2}e^{-x/2}
=\exp\!\left[-\tfrac12(\log(1-x)+x)\right]
=1+O(x^2)=1+O(d^{-4}).
\]
Substitute (3) into (2); the relative second moment exceeds 1 by at most
\(C[d^{-4}+d^3/n+(nd)^{-1/2}]\). By Cauchy–Schwarz,
\(2t_d\le\sqrt{\chi^2(\widehat U_d\Vert U_d)}\).
Finally,
\[
\sum_{d=c+1}^{D_0}d^{-2}\le1/c,\quad
\frac1{\sqrt n}\sum_{d\le D_0}d^{3/2}=O(n^{-1/4}),\quad
n^{-1/4}\sum_{d\le D_0}d^{-1/4}=O(n^{-7/40}).
\]
This proves the stated theorem. \(\square\)

## External-theorem contract and limits

**Imported:** GHIM Theorems 2.1 and 2.2 *only*, with the stated quantitative big-O errors uniform over allowed residual degrees and forbidden graphs. We did not assume the conclusion of Mira's sparse-strip proof. Standard Stirling remainder, Chebyshev, Bonferroni/derangement inclusion-exclusion and Cauchy–Schwarz are proved algebraically here or used as elementary facts.

**Not supplied:** moderate-strip \(D_0<d<\sqrt n\,\mathrm{polylog}(n)\), dense-strip \(\sqrt n\,\mathrm{polylog}(n)\le d\le n\), all-target \(\mathbb E\log T\), concrete Bernoulli/size-biased program, and expected fair-bit work \(\widetilde O(n^{25})\). The independently established near-complete tail in v2.2 is much thinner than the needed dense strip.

**Adversarial counterexample respected:** PR #915 demonstrates exact completions vary by relative cycle structure at \(n=4,d=3\); equation (2) uses GHIM's *uniform asymptotic* estimate, never a false exact overlap-only identity.

**Reproduction:** \`python3 scripts/audit_mira_sparse_moment.py\`. Tests rational identities, exact factorial expressions and Stirling remainder bounds. Passing it does not promote the full theorem to proven.