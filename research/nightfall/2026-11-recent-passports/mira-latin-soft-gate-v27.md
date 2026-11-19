# NIGHTFALL / Mira v2.7 — independent exact soft-gate implementation lemma

**Status:** complete **conditional** author-side soft-gate theorem for any likelihood represented by independently sampleable Bernoulli-prefix factors. Not a proof that Mira's concrete decorated proposal has the stated representation or cheap factors. Not Lean-verified or externally refereed. The original algorithmic idea and source are credited to Mira Cult, pinned [Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling), \`paper/flattening-v2.tex\`; our reconstruction makes independence and anchor-conditioned invariance explicit.

## Theorem: exact two-sided soft coins from polynomially many inverse-probability probes

Suppose \(T>0\) is an unknown fixed likelihood ratio and \(a>0\) a known positive rational threshold. An auxiliary \(\mathcal A\) is drawn exactly with law \(\lambda\). Given \(\mathcal A=\alpha\) we can sample independent Bernoulli-\(p_i(\alpha)\) coins, with \(0<p_i(\alpha)\le1\), for \(i=1,\ldots,D\). Suppose there is a known positive rational \(C(\alpha)\) and signs \(\varepsilon_i\in\{\pm1\}\) such that the **pointwise anchor invariant**
\[
C(\alpha)\prod_{i=1}^{D}p_i(\alpha)^{\varepsilon_i}=T
\qquad\text{for every }\alpha\text{ in the anchor support}.
\tag{A}
\]
The coins must be independently re-drawn for each query (not reused from the anchor). Assume \(C(\alpha)\) and exact rational functions of the integer waiting counters below can be evaluated by fair bits and exact arithmetic. Assume each \(p_i(\alpha)\)-coin takes one call to an underlying exact primitive, and
\[
\mathbb E_{\alpha\sim\lambda}\sum_{i=1}^D p_i(\alpha)^{-1}\le B.
\tag{B}
\]
Then for \(D\ge1\) there are exact algorithms using only these primitives, fair bits and rational comparisons to generate both
\[
\mathrm{Bernoulli}\left(\frac{T}{T+a}\right)
\quad\text{and}\quad
\mathrm{Bernoulli}\left(\frac{a}{T+a}\right),
\]
with \(O(DB)\) expected primitive calls per output (uniform in the unknown value of \(T/a\)). No evaluation of \(T\) is required. Exact arithmetic cost is charged separately to the representation and counter-length bounds.

### Proof

Set \(k=D+3\). Given \(\alpha\), for each factor draw an independent negative-binomial waiting time \(N_k(p_i)\) (number of independent \(p_i\)-trials until the \(k\)th success). Define
\[
X_i=
\begin{cases}
N_k(p_i)/k & \varepsilon_i=-1,\\
(k-1)/(N_k(p_i)-1) & \varepsilon_i=+1.
\end{cases}
\quad Y=C(\alpha)\prod_iX_i.
\]
The negative-binomial mass is \(\Pr(N_j=t)=\binom{t-1}{j-1}p^j(1-p)^{t-j}\), \(t\ge j\). Summing the binomial series gives
\[
E N_k/k=1/p,\quad
E[(k-1)/(N_k-1)]=p,
\]
\[
E[(N_k/k)^2]\le(1+1/k)/p^2,\quad
E[((k-1)/(N_k-1))^2]\le p^2 (k-1)/(k-2).
\]
By (A), **for each anchor \(\alpha\)**, \(E[Y\mid\alpha]=T\), and
\[
E[Y^2\mid\alpha]\le T^2 (1+1/(k-2))^D\le eT^2
\]
since \(k-2=D+1\). The unconditional bounds therefore hold too.

**Exact size bias, preserving the anchor.** Define the \(Y\)-size-biased law \(P^*(dy)=yP(dy)/T\). Because \(E[Y\mid\alpha]=T\) is the *same number for every \(\alpha\)*, the marginal law of \(\alpha\) under \(P^*\) is exactly \(\lambda\); no posterior resampling of a rare anchor is needed. Within each anchor, the factor size biases are independent and given exactly by
\[
X_i^*=
\begin{cases}
(N_{k+1}(p_i)-1)/k&\varepsilon_i=-1,\\
(k-1)/N_{k-1}(p_i)&\varepsilon_i=+1.
\end{cases}
\]
Indeed for \(t\ge k\),
\[
\Pr(N_k=t)\frac{tp}{k}=\Pr(N_{k+1}=t+1),
\]
\[
\Pr(N_k=t)\frac{k-1}{(t-1)p}
=\Pr(N_{k-1}=t-1).
\]
The known scalar \(C(\alpha)>0\) cancels in conditional normalization. Thus a fresh \(\alpha\sim\lambda\) and independently drawn displayed \(X_i^*\) implement the exact \(Y^*\)-law.

Define two experiment biases
\[
l=E\min(1,Y/a),\qquad
h=E_{Y^*}\min(1,a/Y^*).
\]
Sampling \(Y\) or \(Y^*\), then comparing a uniform rational coin to the displayed minimum, implements independent l and h coins. Size bias gives
\[
Th=E[Y\min(1,a/Y)]=E\min(Y,a)=a\,l.
\]
By Paley–Zygmund, \(P(Y\ge T/2)\ge (E Y)^2/(4E Y^2)\ge1/(4e)\). Hence
\(l\ge (8e)^{-1}\min(1,T/a)\), so
\[
l+h=l(1+a/T)\ge(8e)^{-1}.
\]
Repeatedly choose a fair side and test its l or h coin, returning the first side to pass. The probability the l side wins is
\(l/(l+h)=T/(T+a)\); the other side returns \(a/(T+a)\). The expected number of rounds is at most \(16e\), independent of \(T/a\).

**Probe budget, including size bias.** Every \(N_{k\pm1}(p_i)\) needs \((k\pm1)/p_i\) expected primitive calls; conditional on \(\alpha\), the number of p-coins in one l or h experiment has expectation \(O(k\sum_i1/p_i(\alpha))\). By the unchanged anchor distribution under size bias and assumption (B), a fresh experiment has expected \(O(kB)\) calls. Rounds use fresh independent \(\alpha\)'s and all new coin randomness; the event of reaching round r depends only on prior rounds, hence the expected *total* calls equal expected per-round calls times mean # rounds, even though stopping and work of a given round are correlated. Therefore \(O(kB)=O(DB)\) calls suffice. \(\square\)

### Relevant binary-prefix corollary

Let each factor correspond to the conditional probability of the observed next branch of an *exactly uniform matching anchor* under a fixed binary split of candidate column indices. Given the past matching prefix, suppose the two branch probabilities are \(p_0,p_1\) with \(p_0+p_1=1\). The anchor chooses branch b with probability \(p_b\). Consequently
\[
E_\text{next anchor choice}\frac1{p_b}
=\sum_{b:p_b>0}p_b\frac1{p_b}
=\#\{\text{positive branches}\}\le2.
\]
Use the tower property over all sites. If there are at most \(D=O(n^2\log n)\) sites across the boards in a likelihood factorization, then \(B\le2D\) and \(k=D+3\), yielding **\(O(D^2)=\widetilde O(n^4)\) exact uniform-matching probes per soft coin**. A fixed number of additional scalar-coin factors with \(p_i\ge1/n\), or \(O(n)\) factors with \(p_i\ge e^{-4}\), contributes at most \(O(n^2)\) to B and does not change the \(\widetilde O(n^4)\) probe count.

The essential **undischarged source-specific proof obligation** is to construct Mira's actual decorated joint forward Q and normalized reverse R so their ratio \(T=R/Q\) is **exactly pointwise** of form (A), including all null/veto events, marked-polygon and double-cubic normalization factors, and to verify the stated number of primitive conditional-matching factors, positive scalar lower bounds, and rational counter-arithmetic costs. Algebraic existence of T alone does not imply (A).

### Independent adversarial checks

- \`scripts/audit_mira_nb_soft.py\`: compares exact rational negative-binomial size-bias probability coefficients for k in 4,5,10,25 and p in 1/2,2/7,1/19,1; also exact soft-likelihood winning probabilities and binary-branch reciprocal identity. These are finite checks of algebra, not a proof of the source-specific factorization.
- The statement fails *as written* if (A) holds only **on average across anchors** rather than pointwise: the size-biased anchor marginal becomes proportional to \(\lambda(\alpha)E[Y\mid\alpha]\), which need not equal \(\lambda\). This is the critical failure mode and its explicit safeguard.
- The bound on *bit work* additionally requires a separate bound on the size of the waiting counters and rational factors; this theorem certifies a count of underlying matching draws, not unit-time arithmetic. The independent matching bit clock v2.5 supplies the former backend bit cost under verified GLMP/JSV inputs; the actual decorated-factor rational bit budget is not yet independently discharged.

**Overall Mira theorem: UNVERIFIED.** The fixed-target mean-cover and middle/dense count bounds remain major open author-side gates.
