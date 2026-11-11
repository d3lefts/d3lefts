# A quadratic-backdoor transfer principle for bounded product observables

**NIGHTFALL research note · 11 November 2026 · v1.0**

**Status:** Exact analytic *transfer proof* from the degree-two theorem claimed in [NIGHTFALL PR #375](https://github.com/d3lefts/d3lefts/pull/375). The quadratic source theorem is not fully Lean-certified or independently externally reviewed; accordingly the complete quantitative result retains **conditional-on-the-analytic-quadratic-result** status. No global originality or precedence claim. A separate rational enumerator tests 340 instances but cannot certify a theorem. Suitable for adversarial review, not for priority claims without a literature and proof audit.

## A. General transfer theorem, finite arbitrary product laws

Let \((\Omega_i,\mu_i)_{i\in[n]}\) be independent probability spaces and \(f\colon\prod_i\Omega_i\to\mathbb R\) measurable with \(|f|\le B\) a.s., \(B>0\). Let \(f=\sum_{S\subseteq[n]}f_S\) be its Efron–Stein/Hoeffding decomposition, \(V=\operatorname{Var}(f)\), \(I_i=\mathbb E(f-\mathbb E_i f)^2\), and \(M=\max_i I_i\). Suppose a finite set \(C\subseteq[n]\), \(|C|=k\), satisfies

\[ f_S\not\equiv0 \implies |S\setminus C|\le2. \tag{H} \]

Equivalently, observing/conditioning on all coordinates in \(C\) leaves a degree-at-most-two function on the remaining product (for a.e. core configuration). No assumptions about atom probabilities or common alphabets occur.

**Theorem 1 (quadratic-backdoor influence transfer).** If the law-free scalar quadratic estimate

\[\operatorname{Var}(h)^2\le K\|h\|_\infty^2\max_j I_j(h),\qquad K=5043, \tag{Q}\]

holds for every bounded degree-at-most-two scalar observable on the relevant product spaces, then

\[\boxed{\operatorname{Var}(f)^2\le(K+2k)B^2M.}\tag{1}\]

The following strictly stronger dependence on \(k\) also follows:

\[\boxed{\operatorname{Var}(f)^2\le
\left(\frac{\sqrt K+\sqrt{K+4k}}{2}\right)^2 B^2M.}\tag{2}\]

For all cubic \(f\), (H) means that \(C\) hits every nonzero cubic ANOVA interaction (ordinary hypergraph vertex cover). More generally (H) allows unbounded original degree provided at most two active coordinates of every interaction lie outside \(C\).

**Proof.** Set \(g=\mathbb E[f\mid X_{C^c}]\), averaging over the core. Orthogonality gives

\[V=A+D,\quad A=\operatorname{Var}(g),\quad D=\mathbb E(f-g)^2
=\sum_{S:S\cap C\ne\varnothing}\|f_S\|_2^2
\le\sum_{i\in C} I_i(f)\le kM.\tag{3}\]

By (H), \(g\) has degree at most two; \(|g|\le B\) because conditional expectation contracts \(L^\infty\). For each \(j\notin C\), orthogonal averaging contracts influence: \(I_j(g)\le I_j(f)\). Thus (Q) gives \(A^2\le KB^2M\). Moreover \(A\le V\le B^2\). Therefore

\[V^2=A^2+D(2A+D)\le KB^2M+2B^2D\le(K+2k)B^2M.\]

For (2), set \(v=V/B^2\in[0,1]\), \(m=\sqrt M/B\), and note \(v\le\sqrt K m+km^2\). If \(m=0\), then \(v=0\). Otherwise rearrangement gives

\[m\ge\frac{2v}{\sqrt{K+4kv}+\sqrt K}\ge\frac{2v}{\sqrt{K+4k}+\sqrt K},\]

which is (2). The \(k=0\) case is understood by continuity. QED.

## B. Adaptive observation: additive parameter dependence, with matching-order lower bounds

**Theorem 2 (quadratic-backdoor policy).** Under (H), and assuming the scalar degree-two deterministic adaptive posterior guarantee of [#375](https://github.com/d3lefts/d3lefts/pull/375), for any \(\eta>0\) there is a deterministic adaptive policy with hard coordinate-query cap

\[\boxed{N\le k+\lceil20172 B^2/\eta\rceil}\tag{4}\]

and Bayes squared-error risk \(\mathbb E[(f-\mathbb E[f\mid\text{transcript}])^2]\le\eta\). Neither depth nor the constant depends on the number of coordinates, the alphabet sizes, or minimum atom masses. The policy first queries all of \(C\); for almost every resulting transcript, (H) turns the unqueried section into a bounded quadratic observable on an independent residual product. Apply the degree-two adaptive policy conditionally to that section. Integrating the conditional risk completes the proof. For arbitrary real-Hilbert rank-\(r\) outputs, the same argument using the rank-\(r\) bound in #375 gives \(k+\lceil20172rB^2/\eta\rceil\); and projection onto an \(r\)-dimensional covariance subspace gives risk \(\le\tau_r+\eta\).

**Theorem 3 (matching-order query lower bound).** The additive order \(k+\eta^{-1}\) in (4) cannot be improved universally (up to numerical constants). Fix any \(k\ge0\), \(m\ge1\). Let \(P=\prod_{i=1}^{k+2}X_i\) and \(L=m^{-1}\sum_{j=1}^mY_j\), with all signs independent and uniform. Put \(f=(P+L)/2\), \(|f|\le1\). Its degree-\((k+2)\) parity interaction requires deletion of at least \(k\) variables to reach degree at most two. At target risk \(\eta=1/(16m)\), any deterministic adaptive strategy with hard query cap \(N\) has

\[\boxed{N\ge\frac34(k+2+m).}\tag{5}\]

Indeed, conditional on any adaptive transcript, if all \(k+2\) parity variables have not been queried, the remaining parity contributes squared posterior risk exactly \(1/4\); otherwise it contributes zero. If \(q\) of the \(m\) leaf signs were queried, their independent residual risk is \((m-q)/(4m^2)\). Hence total expected risk at most \(1/(16m)\) implies \(\Pr(\text{parity incomplete})\le1/(4m)\) and \(\mathbb Eq\ge 3m/4\). With probability at least \(1-1/(4m)\), the policy must query every parity variable, so its *expected* query count is at least \((k+2)(1-1/(4m))+3m/4\ge3(k+2+m)/4\). The hard cap is at least this expectation. QED.

## C. Robust cubic-backdoor variant (nonzero outside-core cubic mass)

For degree-\(\le3\) \(f\), take **any** core \(C\) (not necessarily a hitting set). Let

\[\delta_C=\sum_{\substack{S\cap C=\varnothing\\|S|=3}}\|f_S\|_2^2.\]

Writing \(g=\mathbb E_C f\) and \(H=\sum_{|S|=3,S\cap C=\varnothing}f_S\), the quadratic component \(q=g-H\) has variance \(V-D-\delta_C\), and its influences are bounded by those of \(f\). The Markov-noise polynomial \(P_tg=\sum_{j=0}^3t^jg^{=j}\), \(0\le t\le1\), satisfies \(|P_tg|\le B\), and Chebyshev/Lagrange interpolation at \(t=0,1/4,3/4,1\) gives

\[H=\tfrac{16}{3}\big[-P_0g+2P_{1/4}g-2P_{3/4}g+P_1g\big],\quad |H|\le32B.\]

Thus \(|q|\le33B\). Using the variance identity from part A yields the quantitative *defect-sensitive* consequence

\[\boxed{(V-\delta_C)^2\le (1089K+2k)B^2M=(5{,}491{,}827+2k)B^2M.}\tag{6}\]

The constant is not optimized. The exact-backdoor theorem has the much stronger coefficient \(K+2k\). After querying \(C\), one may approximate the quadratic part of the residual slice (bounded by \(33B\)) in \(\lceil20172\cdot1089B^2/\eta\rceil\) additional queries. By Minkowski, the resulting expected square error on the original \(f\) is at most \((\sqrt{\delta_C}+\sqrt\eta)^2\). In particular, approximate backdoors still give an alphabet-independent number of queries whenever their uncovered cubic \(L^2\) energy is small.

**Proof detail for (6).** \(A=\operatorname{Var}(q)\), \(D=\mathbb E(f-\mathbb E_C f)^2\le kM\), so \(V-\delta_C=A+D\le V\le B^2\). Apply (Q) with \(\|q\|_\infty\le33B\), expand \((A+D)^2\), and use \(D(2A+D)\le2B^2D\).

## D. Proof passport and independent audit boundary

- **Mechanism:** remove a small structural backdoor; apply strong degree-two theorem; use Efron–Stein orthogonality to transfer its estimate. A separate exact polynomial interpolation bounds the cost of approximate removal.
- **Scope:** finite independent heterogeneous probability spaces, arbitrary alphabets and biases, bounded scalar outputs; vector extension inherits rank and tail assumptions from #375. Measurability in non-finite products inherits the relevant Hoeffding/conditional-selection prerequisites from that proof.
- **Certificate:** source proof above; `check_backdoor_transfer.py` validates 340 exact-backdoor and 108 approximate-backdoor seeded examples, plus 392 exact posterior-risk masks with exact rational product enumeration and an independent coefficient calculation, plus a deliberately invalid support case. This does not prove (Q), Theorems 1–3, or global novelty.
- **Prior art compared (public abstracts, 11 Nov 2026):** Turturean's unrestricted cube influence theorem (arXiv:2611.09773); Blanc–Docter–Strassle–Tan exposition (arXiv:2611.11626); Huffstutler–Miloschewsky–Podder completion proof (arXiv:2611.12795); and NIGHTFALL #375. Prior-art search did not establish a globally novel structural special case. The transfer principle is a new, explicit *research-program deduction* from the repository's stated quadratic result, not yet a priority-certified contribution.
- **Dependency:** If the quadratic estimate (Q) or #375 adaptive theorem fails independent review, quantitative claims here must be withdrawn or restated using another proven base theorem. No Lean final theorem is claimed.
- **Most valuable next attack:** generalize the quadratic-backdoor parameter to a fractionally covered cubic hypergraph without paying cover number \(k\), while respecting the shared-neighbor fourth-moment counterexample; alternatively prove the quadratic base theorem end-to-end independently and promote the present exact transfer.

### Reproduction

```sh
python3 check_backdoor_transfer.py
```

Expected terminal line: `PASS exact_product_models=340`; checker writes an exact maximum ratio, seed, negative test and audit digest. Python 3 standard library only.