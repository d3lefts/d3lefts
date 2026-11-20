# NIGHTFALL — Oracle-relative structural information (ORI v0.1)

Date: 2026-11-19 (America/New_York). **Status: independently derived author-side conditional transfer and two exact finite families; NOT an end-to-end Lean certification, external review, or priority-cleared new mathematical theorem.** This is a continuation of the earlier NIGHTFALL query-local structural note, not a rediscovery of it.

**Primary NIGHTFALL dependencies:** [Route 1, merged #928](../mixture_aa/ROUTE1_PROOF_20261119.md), improved paper proof [#930](../mixture_aa/ROUTE1_FINITE_STAR_COUPLING_PROOF_20261119.md); [previous factor/quotient theorem, #883](../formalization/product_space/QUERY_LOCAL_PRODUCT_FACTOR_TRANSFER_20261119.md); #883's pinned Lean diagonal-rank certificate, run 44464612579. The Route 1 end-to-end full theorem is presently **paper-level only**; its finite star kernel has separately passed pinned Lean and must not be confused with a full terminal.

**Closest external mechanisms independently checked:** Wyner's 1975 conditional-independence information; information-theoretic approximation of nonnegative rank [Braun–Pokutta et al.](https://eccc.weizmann.ac.il/report/2013/158/); distributional quantum query composition [arXiv:2610.06835](https://arxiv.org/abs/2610.06835); [Wyner's Common Information and the Common Entropy are NP-Hard to Compute (2026)](https://arxiv.org/abs/2610.15402). **These are prior-art context, not proof dependencies.**

## 1. Contract and definitions

Fix finite coordinate spaces \(\mathcal X=\prod_{i\in I}A_i\) and \(\mathcal Y=\prod_{j\in J}B_j\), each alphabet nonempty. Let \(Y\sim\mu\), \(X=\Phi(Y)\), where \(\Phi:\mathcal Y\to\mathcal X\) is a known deterministic map and \(\nu=\Phi_*\mu\).

- **Forward locality \(a\):** for each \(i\in I\), \(\Phi_i(y)\) depends only on an index set \(S_i\subseteq J\) with \(|S_i|\le a\).
- **Recovery \(b\):** for each latent coordinate \(j\), a deterministic adaptive algorithm with at most \(b\) queries to \(x=\Phi(y)\) recovers \(y_j\), *for every \(y\in\operatorname{supp}\mu\)*. The coordinate may be queried repeatedly, but such repetitions count. Recovery implies \(\Phi\) is injective on \(\operatorname{supp}\mu\); no independent hidden auxiliary data is available at query time.
- **Mixture complexity \(M_{\rm prod}(\mu)\):** smallest number of nonnegative product-law components generating \(\mu\) **exactly**. This is a support/cardinality parameter; it is not Wyner's infimum of mutual information.

The **query-budgeted rank profile** is
\[
\mathsf K_{a,b}(\nu)
:=\inf_{\substack{\mu,\Phi:\,\Phi_*\mu=\nu\\
 \mathrm{loc}(\Phi)\le a,\,\mathrm{recover}(\Phi)\le b}}
 \ln M_{\rm prod}(\mu).
\]
The identity representation makes the feasible set nonempty for \(a,b\ge1\); hence \(0\le\mathsf K_{a,b}(\nu)\le\ln M_{\rm prod}(\nu)\). If the alphabets or index sets of \(\mu\) vary, the index/answer word costs and encoder description must be charged separately for claims about running time or bit work. This is a **profile under specified oracle budgets**, not a scalar invariant under unconstrained recodings.

## 2. Conditional Route 1 query-local transfer theorem

**Theorem (author-side, conditional solely on the complete Route 1 simulation theorem).** Let \(0<\epsilon,\delta<1\). If \(f:\mathcal X\to[0,1]\) has finite indicator coordinate degree at most \(d\), then there exists a deterministic nonuniform decision tree reading \(X\) with depth at most
\[
b\,P(ad,\epsilon^{-1},\delta^{-1})\,\bigl(1+\ln M_{\rm prod}(\mu)\bigr),
\tag{T}
\]
and error event \(\Pr_\nu(|\hat f-f(X)|>\epsilon)\le\delta\). The polynomial \(P\) is exactly the universal polynomial furnished by Route 1 (use \(P(1+\cdot,\ldots)\) for the \(d=0\) boundary). If \(\|\nu-\Phi_*\mu\|_{\rm TV}\le\xi\) instead, with the decoder valid on \(\operatorname{supp}\mu\), then **the same tree** has failure probability at most \(\delta+\xi\) under \(\nu\).

If \(f\) is the acceptance probability of a standard \(T\)-query quantum algorithm on the observed oracle, its indicator degree is at most \(2T\); replace \(ad\) in (T) by \(2aT\). This statement does not claim that a classical simulator can be constructed/evaluated in polynomial *time*.

**Proof (independent reduction).** Every indicator monomial of \(f\) on an observed coordinate set \(S\subseteq I\), \(|S|\le d\), becomes after \(\Phi\) a function of \(\cup_{i\in S}S_i\), whose cardinality is at most \(ad\). Every finite function on those latent symbols is a linear combination of their atomic indicator cylinders. Therefore \(g=f\circ\Phi\) has indicator degree \(\le ad\), remains in \([0,1]\), and the Route 1 theorem applied to \(\mu\) gives the latent decision tree with the asserted cost. Replace every latent-coordinate query \(y_j\) by its at-most-\(b\)-query recovery routine on \(x\). On \(\operatorname{supp}\mu\) the resulting X-tree agrees exactly with the latent tree on \(y\), including every adaptive branch. Since \(\Phi_*\mu=\nu\), the failure mass is preserved and the worst-case depth grows by at most \(b\). For an approximation \(\|\nu-\Phi_*\mu\|_{\rm TV}\le\xi\), the event is a fixed subset of the observed support, so its mass changes by at most \(\xi\). Finally the quantum polynomial method gives \(d\le2T\). QED, conditional on Route 1.

**Coherent oracle equivalence.** For a bit-flip input oracle, a fixed \(a\)-local observed symbol can be computed coherently from the latent oracle using \(O(a)\) latent queries plus known reversible logic (explicitly including compute/uncompute). In the other direction the above deterministic \(b\)-query recovery provides a coherent circuit with \(O(b)\) observed queries when the recovery is a reversible finite decision tree and its work registers are uncomputed. The theorem (T) itself needs locality, not this additional circuit model. To demand four-direction equivalence, record four separate classical/quantum access costs and track their composition; do not silently identify them.

**Compositionality.** If \(\Phi\) is \(a\)-local with recovery \(b\), and \(\Psi\) is \(a'\)-local with recovery \(b'\), then \(\Phi\circ\Psi\) is \(aa'\)-local and has recovery cost at most \(bb'\), provided the promised support/decode conditions compose. The resource profile therefore transforms under *budget rescaling*; it is not numerically invariant if costs are discarded.

## 3. Exact infinite separation with locally mixed parity bits

Let \(m\ge2\) and \(Z=(Z_1,\ldots,Z_m)\) be independent fair bits. Define \(DZ\) by
\[
(DZ)_1=Z_1,\qquad (DZ)_i=Z_i\oplus Z_{i-1}\quad (i=2,\ldots,m),
\]
and let observed \(X=(A,B)=(Z,DZ)\in\{0,1\}^{2m}\). The map \(D\in GL_m(\mathbb F_2)\) is lower bidiagonal with ones on its diagonal, so it is invertible. It is not merely a duplicate: \(m-1\) observed coordinates in B are parity interactions.

**Wyner value.** For the two blocks \(A\) and \(B\), \(B=DA\) is a deterministic bijection and both have m bits of entropy, hence \(I(A;B)=m\) bits. Any latent \(W\) that renders all observed coordinates independent (in particular \(A\perp B\mid W\)) satisfies \(I(A,B;W)\ge I(A;B)=m\). Choosing \(W=Z\) makes every bit deterministic conditionally on W and gives \(I(A,B;W)=m\). Thus
\[
C_W(A;B)=m\ \text{bits},
\]
and the multivariate Wyner common information of the individual \(2m\) observed bits is also exactly \(m\).

**Full-coordinate product-mixture rank.** The block \(A\times B\) probability matrix is \(2^{-m}\) times a permutation matrix of size \(2^m\). Its ordinary rank is \(2^m\). Every full-coordinate product-mixture component is in particular a nonnegative block-product rank-one matrix across \(A|B\); thus \(M_{\rm prod}(X)\ge2^m\). Conversely, the \(2^m\) point masses on \(X=(z,Dz)\) are full-coordinate products, so equality holds:
\[
M_{\rm prod}(X)=2^m,\qquad \ln M_{\rm prod}(X)=m\ln 2.
\]

**Query quotient.** Take \(Y=Z\), which is a single product law, hence \(M_{\rm prod}(Y)=1\). Each observed A bit depends on one latent bit; each observed B bit on at most two. So \(a=2\). Each latent bit \(Z_j\) is the observed \(A_j\) and costs \(b=1\) classical query. The observed binary oracle is coherently simulable from the latent oracle using a constant number of quantum queries, and the reverse uses one observed bit query. Thus
\[
\boxed{\mathsf K_{2,1}(\nu)=0,\qquad C_W(\nu)=m\text{ bits},\qquad M_{\rm prod}(\nu)=2^m.}
\]
Given Route 1, **every \(T\)-query quantum acceptance observable** on these \(2m\) dependent bits admits a distributional classical approximation with \(\operatorname{poly}(T,\epsilon^{-1},\delta^{-1})\) observed queries, uniformly in \(m\). This extends #883's duplication witness to local parity correlations and a general class of sparse invertible linear codes. The linear-algebra mechanism itself is elementary and not claimed novel.

More generally, any \(D\in GL_m(\mathbb F_2)\) with row weight \(\le a\) works for \(X=(Z,DZ)\), with latent decoder \(b=1\), \(\mathsf K_{a,1}=0\), Wyner \(m\), and full-product rank \(2^m\). This is an unbounded family, not a numerical constant refinement.

### Stronger local parity example: no copied raw bit and no repeated observed functional

The previous family includes \(A=Z\) and is a simple query quotient. To eliminate both that convenience and the duplicated-functional appearance, work in independent 4-bit blocks, using the following two matrices over \(\mathbb F_2\). Each parenthesized integer encodes a row mask in low-bit-first order:
\[
L=(3,5,7,9),\quad L^{-1}=(7,6,5,15),\qquad
R=(6,10,11,14),\quad R^{-1}=(6,11,10,9).
\]
The exact 4-bit identities \(L^{-1}L=I\) and \(R^{-1}R=I\) are checked by exhausting all 16 input words in the companion verifier. The eight row masks across L and R are **all distinct**, and every observed row has weight 2 or 3, so **no observed bit is a raw latent bit and no two observed bits are functionally identical**.

For \(m=4k\) independent fair latent bits, apply L and R blockwise and reveal \(X=(L^{\oplus k}Z,R^{\oplus k}Z)\). Every X bit depends on at most **3** latent bits, while each latent bit can be recovered by at most **4** observed A-block queries using \(L^{-1}\). Both observed halves are invertible linear transforms of Z. Consequently their joint matrix is a scaled permutation, and the same proof yields
\[
\boxed{\mathsf K_{3,4}(\nu)=0,\quad C_W(X_A;X_B)=m\text{ bits},\quad M_{\rm prod}(X)=2^m.}
\]
All forward and reverse **quantum** bit-oracle simulations likewise have constant query overhead because their row formulas involve at most four bits (with the usual reversible compute/uncompute convention).

This is a stronger witness than literal duplication: it preserves an unbounded information gap under an explicitly **two-way, bounded-query, locally mixed representation** in which every observed coordinate is a nontrivial parity. The matrices are elementary linear coding, not independently novel mathematical machinery.

## 4. Obstruction to silently replacing log M by Wyner C_W

This is independent of the previous encoding. Set \(K=2^m\), \(m\ge3\), \(\eta=1/m\), and choose an observed block pair \(A,B\in\{0,1\}^m\) as follows: with probability \(1-\eta\), draw \(A,B\) *independently* uniformly; with probability \(\eta\), draw a uniform Z and set \(A=B=Z\).

The pair probability matrix is
\[
P_\eta=\frac{1-\eta}{K^2}\mathbf1\mathbf1^{\mathsf T}
+\frac{\eta}{K}I_K.
\]
The matrix has eigenvalues \(\eta/K\) on the \(K-1\)-dimensional zero-sum space and \(1/K\) on the all-ones direction. It has full rank K, so every exact product-mixture decomposition requires **at least \(K=2^m\) components**, even allowing arbitrary block-products. The explicit mixing construction uses \(K+1\) full-coordinate product components, hence
\[
2^m\le M_{\rm prod}(P_\eta)\le 2^m+1.
\]

However, let W be the branch flag and the sampled Z *only* on the diagonal branch. Conditional on W the \(2m\) individual bits are independent, and the entropy bound gives
\[
C_W(P_\eta)\le I(A,B;W)\le H(W)=h_2(\eta)+\eta m
=1+h_2(1/m)<2\text{ bits}.
\]
This is an **exact exponential separation between cardinality and Wyner mutual-information cost**, not a counterexample to a *separately proved* Wyner-parameter theorem. It establishes that Route 1's \(\log M\) statement alone **cannot logically be rewritten as a polynomial in \(C_W\)** without a new argument. The source is within TV distance at most \(\eta\) of a product law, so an error-tolerant profile naturally removes the rare diagonal component: accuracy dependence is crucial.

## 5. Three adversarial hazards / nontriviality gates

**Packing collapse.** If “efficient” means merely \(\operatorname{poly}(m)\) queries, every \(m\)-bit observed distribution can be represented as **one** giant latent symbol holding the entire X string. Its law is a one-coordinate product, so the proposed uncharged invariant becomes zero for *all* sources; one packed-symbol query takes m original bit queries. Avoid this collapse either by fixing \(a,b=O(1)\), tracking actual \(b\) in the theorem, or charging word size / bit work.

**Source-only versus task-relative.** No distribution-only sufficient upper parameter automatically supplies a matching lower bound for a particular f. The constant observable f has zero query complexity on any source; arbitrary low-degree observables may also ignore a hard-to-generate correlated sector. A future task-relative profile must charge the cost of extracting a task-sufficient representation in the actual observed oracle. Arbitrary conversion \(Y=f(X)\) is *not* free.

**Wyner versus cardinality and approximation.** \(C_W=\inf I(X;W)\) and \(\log M_{\rm prod}\) are different quantities. Their discrepancy can be exponential and can disappear under small total-variation perturbations. Do not invoke a nonexistent Wyner terminal from the \(\log M\) theorem. A genuine \(\mathrm{poly}(C_W)\) simulator requires additional structural/approximate arguments and precise error bookkeeping.

## 6. Certification, reproducibility, next threshold

**Verified in this session:** exact algebra for the invertible-parity witness, block permutation rank and the diagonal-rank counterexample; a standalone finite checker for m=2,3,4,5 (modular full-rank witnesses and probability normalization) replayed successfully. The symbolic arguments above establish all m≥2 without extrapolating the finite test. Script: \`scripts/check_oracle_relative_information.py\`.

**Proof status:** author-side self-contained transfer conditional on end-to-end Route 1; elementary exact Wyner/rank separations. No new Lean terminal, no human reviewer, no novelty certification. The earlier diagonal case was already proved in Lean by #883 and has priority within this research program.

**Next decisive experiment:** find a natural correlated source **without explicit duplicated raw bits**, exhibiting bounded-degree forward *and inverse* query-local encoders, provably large all-coordinate Wyner/rank cost, and a strict improvement on the naive observed-coordinate result. Independently attack the representation quotient by allowing adaptive decoders, zero atoms, approximate support, and large alphabets. Next mathematical gate: a task-relative lower-bound theorem that does not collapse under constant tasks or uncharged lookup tables. Do not claim a characterization absent such bounds.

**Discovery graph:** Product mixture count → Wyner versus exact-support separation → Query-local representation profile → Exact sparse parity construction → Conditional simulation transfer → Adversarial packing/rare-component obstructions → Task-aware cost/lower-bound research.
