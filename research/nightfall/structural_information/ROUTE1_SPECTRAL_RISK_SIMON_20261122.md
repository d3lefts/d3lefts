# Low-degree likelihood-ratio stability for adaptive query risk; exact Simon degree transition

**NIGHTFALL upstream source note (2026-11-22).** Targets task-aware Route 1 research PR #987; uses locality theorem from draft PR #988 and complementary tail envelopes in draft PR #991. **Status:** self-contained finite-dimensional analytic proof + independently written exact enumerations (N=4,8); no Lean replay, non-author human referee, or novelty certification. The low-degree likelihood-ratio projection / chi-squared method is established statistical prior art (Hopkins and coauthors; e.g. APPROX/RANDOM 2025 *Algorithmic Contiguity from Low-Degree Conjecture and Applications in Correlated Random Graphs*). The adaptation to squared-risk certification and the exact Simon calculations here are author-side syntheses only.

## Objective and necessary distinctions

The exact moment-matching mechanism from PR #988 applies only when the relevant coordinate marginals agree. We seek an **additive**, quantitatively stable transfer without an exponential leaf count, a raw Fourier \(\ell_1\) multiplier, or a spurious relative Gram comparison. We will not claim that any global low-degree norm characterizes *query* complexity: a global degree-three polynomial can sum information over all N oracle coordinates and cost N queries.

## Theorem S1: source-defined spectral risk transfer

Let \(X=\prod_{i=1}^n A_i\) be a finite Cartesian alphabet and \(Q,\nu\) probability laws with \(\nu\ll Q\). Put \(D=d\nu/dQ-1\in L^2(Q)\). For integer \(0\le K\le n\), let \(\mathcal W_K\subseteq L^2(Q)\) be the linear space of sums of cylinder functions of at most \(K\) original coordinates, including constants. Define the **low-degree source discrepancy**

\[
\Lambda_K(\nu\Vert Q)=\|\Pi_{\mathcal W_K}D\|_{L^2(Q)}.
\]

If \(f:X\to[0,1]\) has interaction degree at most \(d\), \(t:X\to[0,1]\) is the output of any deterministic original-coordinate depth-\(q\) decision tree, and \(K=\min(n,\max(2d,d+q))\), then

\[
\boxed{\left|\mathbb E_\nu(f-t)^2-\mathbb E_Q(f-t)^2\right|\le\tfrac12\Lambda_K(\nu\Vert Q).}
\]

No assumption that Q or \(\nu\) is product is needed. The constant 1/2 is universally best possible. For randomized input-independent trees, apply this pointwise to each fixed seed and average.

**Proof.** Write \(f=\sum_{|J|\le d}f_J\), and write each tree as its sum of leaf values times disjoint depth-\(q\) cylinder indicators. Then \(f^2\in\mathcal W_{\min(n,2d)}\), \(ft\in\mathcal W_{\min(n,d+q)}\), and \(t^2\in\mathcal W_{\min(n,q)}\) because exactly one leaf is reached. Therefore \(g=(f-t)^2\in\mathcal W_K\), with \(0\le g\le1\). Since \(\mathbb E_Q D=0\),

\[
\mathbb E_\nu g-\mathbb E_Qg
=\langle\Pi_KD,g-\mathbb E_Qg\rangle_Q.
\]

Cauchy-Schwarz bounds this by \(\Lambda_K\sqrt{\operatorname{Var}_Q(g)}\), and the variance of a [0,1]-valued variable is at most 1/4. Sharpness: one fair Bernoulli coordinate with Q(1)=1/2, \(\nu(1)=(1+c)/2\), \(0<c\le1\); choose \(f=\mathbf1_{\{X=1\}}\), \(t=0\). Then \(\Lambda_1=c\) and the risk difference is \(c/2\). QED.

**Finite certificate and cost.** Choose any spanning list \(\phi_1,\dots,\phi_M\) of the mean-zero subspace of \(\mathcal W_K\). Define Gram \(G_{ij}=\mathbb E_Q[\phi_i\phi_j]\) and \(b_i=\mathbb E_\nu\phi_i-\mathbb E_Q\phi_i\). Then

\[
\boxed{\Lambda_K^2=b^\top G^+b}
\]

with \(G^+\) the Moore-Penrose pseudoinverse (or use an independent basis and inverse). Because \(\nu\ll Q\), \(b\) is orthogonal to the Gram nullspace. The data for \(b\) uses at most K-coordinate marginals of \(\nu,Q\), and \(G\) uses at most 2K-coordinate marginals of Q; rational sources admit rational linear-algebra certificates. The basis size may be \(\sum_{j\le K}\sum_{|J|=j}\prod_{i\in J}(|A_i|-1)\), so certification may be expensive. No free oracle access or polynomial-time claim is made.

For a **product** reference \(Q=\otimes_iQ_i\), the Efron-Stein tensor components \(D_S\) are orthogonal, giving the particularly transparent

\[
\Lambda_K^2=\sum_{1\le|S|\le K}\|D_S\|_{L^2(Q)}^2.
\]

Exact agreement of all \(K\)-marginals is the special case \(\Lambda_K=0\), recovering PR #988's exact risk conservation. The norm is a low-degree likelihood-ratio quantity, not an original mathematical object.

## Theorem S2: quantitative high-probability transfer with approximate marginals

For \(m\ge1\) put \(K_m=\min(n,\max(2md,(2m-1)d+q))\), and \(\Lambda=\Lambda_{K_m}(\nu\Vert Q)\). With \(Z=(f-t)^2\), \(0\le a<a+\gamma\le1\), and \(\beta=e^{-m\gamma^2/2}\),

\[
\boxed{\Pr_\nu(Z\ge a+\gamma)
\le\frac{\Pr_Q(Z>a)+\beta+\Lambda/2}{1-\beta}.}
\]

**Proof.** The degree-m binomial threshold \(B_{m,r}(z)\), \(r=\lceil m(a+\gamma/2)\rceil\), is [0,1]-valued on [0,1] and has the pointwise sandwich \((1-\beta)\mathbf1_{z\ge a+\gamma}\le B_{m,r}(z)\le\mathbf1_{z>a}+\beta\) (PR #991; Hoeffding). The polynomial \(B_{m,r}(Z)\) lies in \(\mathcal W_{K_m}\) by expanding each \(Z^j\); therefore S1's Cauchy-Schwarz estimate gives \(|\mathbb E_\nu B_{m,r}(Z)-\mathbb E_Q B_{m,r}(Z)|\le\Lambda/2\). Integrate the sandwich under the respective laws and divide by \(1-\beta\). QED.

This is an additive stable transfer **without exact marginal agreement** and without counting all leaf paths or coefficient terms. When \(\Lambda=0\), it reproduces PR #991's exponential bound. The effect of nonzero \(\Lambda\) is explicitly paid; small individual marginal errors need not make \(\Lambda\) small.

## Theorem S3: exact Simon spectral profile at degrees two and three

For \(N=2^r\ge4\), define \(\nu_N\) by choosing a uniformly random nonzero hidden shift \(s\in\mathbb F_2^r\) and an injective labelling of its \(N/2\) cosets by \(N\) possible symbols, uniformly over injections. Let \(Q_N\) assign independent uniform \(N\)-symbol labels to the \(N\) original addresses. The coordinate degree is **the number of queried table entries**, not polynomial degree in the binary encoding of symbols. Then

\[
\boxed{\Lambda_2(\nu_N\Vert Q_N)^2=\frac{N}{2(N-1)^2}}
\qquad\text{and}\qquad
\boxed{\Lambda_3(\nu_N\Vert Q_N)^2=
\frac{N(N^2+4N+7)}{6(N-1)^2}.}
\]

The first tends to zero as \(\Theta(N^{-1})\) in squared norm, whereas the second grows as \(N/6+O(1)\). This is an **exact spectral transition**, not a quantum/classical query separation theorem.

**Independent calculation.** Each singleton marginal equals Q. For any distinct addresses \(a,b\), under \(\nu_N\),

\[
\Pr(X_a=u,X_b=v)=
\begin{cases}
1/[N(N-1)], & u=v,\\
(N-2)/[N(N-1)^2], & u\ne v.
\end{cases}
\]

Consequently the pure pair interaction density \(D_{ab}\) relative to Q equals \(1/(N-1)\) when labels agree and \(-1/(N-1)^2\) when they differ. It has zero one-coordinate conditionals, and its squared Q norm equals \(1/(N-1)^3\). Orthogonal pair components give \(\Lambda_2^2=\binom N2/(N-1)^3\).

For three distinct addresses, the three XOR differences are distinct. The joint \(\nu_N\) probabilities by equality type are: zero for all three labels equal; \(1/[N(N-1)^2]\) for a specified exactly-two-equal triple; and \((N-4)/[N(N-1)^2(N-2)]\) for a specified all-distinct triple. Subtract the constant and its three pair densities from the joint likelihood ratio. The resulting pure triple density \(D_{abc}\) has these values:

| Label pattern | \(D_{abc}\) |
|---|---|
| all three equal | \(-(N+2)/(N-1)\) |
| exactly two equal | \((N+2)/(N-1)^2\) |
| all distinct | \(-2(N+2)/[(N-1)^2(N-2)]\) |

A direct Q-weighted sum of squares gives \(\|D_{abc}\|_2^2=(N+2)^2/[(N-1)^3(N-2)]\). Orthogonality across interaction sets and \(\binom N3\) such triples yields \(\Lambda_3^2=\Lambda_2^2+\binom N3\|D_{abc}\|_2^2\), which simplifies to the boxed expression. QED.

An additional degree-four witness on XOR-parallelogram addresses is \(h=\mathbf1_{X_a=X_b}\mathbf1_{X_c=X_d}\). It has \(\mathbb E_\nu h=1/(N-1)\), \(\mathbb E_Q h=1/N^2\), implying

\[
\Lambda_4^2\ge
\frac{(N^2-N+1)^2}{(N-1)^2(N^2-1)}\to1.
\]

This is consistent with PR #988's relative Gram obstruction, but the **degree-three global spectral blow-up is already stronger** as a caution against overusing a global L2 norm.

**Why it does NOT solve Simon:** the degree-three statistical functional witnessing large spectral energy aggregates all \(\binom N3\) address triples; evaluating it generally requires observing many original oracle entries. A genuine task-aware, transcript-adaptive source operator must account for this cost. For degree-one targets with depth-one trees, S1 nevertheless gives the finite statement \(|\Delta\mathrm{MSE}|\le\frac12\sqrt{N/[2(N-1)^2]}\), while higher degree/depth cannot be inferred to have a small certificate.

## Audit and next structural operator

A checker independent of the original source's script enumerates **all 36** injective-label Simon tables at N=4 and **all 11,760** at N=8. It compares every pair and triple marginal atom to the analytic formulas, checks vanishing triple lower-order conditionals, and recomputes exact rational projection energies and the four-point obstruction. This is a finite exact check, not a general theorem certificate. The all-N proof above is elementary combinatorics and orthogonal projection; external mathematical review remains open.

**Next experiment, preregistered:** compare a transcript-conditioned hazard/coupling representation to the global \(\Lambda_K\) score. Prediction: it should price the \(\Theta(\sqrt N)\) Simon collision threshold without charging for all unavailable triple tests; alternative: the operator hides unqueried information or becomes a tautological redefinition of decision-tree depth. Test N=4,8,16 exact oracles with honest queried-address traces. Stop if the same rule cannot handle duplicated bits, parity sources, and the Forrelation acceptance interface with appropriate scope.

**Prior art and limits:** low-degree likelihood ratios, chi-squared projection, Cauchy-Schwarz, Efron-Stein decomposition, Hoeffding tails and Simon birthday-collision arguments are well-established. This document makes no priority claim. The K=2,3 formulas were independently derived and checked in this research pass; their possible prior statements have not undergone specialist historical review. Do not conflate paper proof, test counts, Lean compilation, or genuinely independent review.
