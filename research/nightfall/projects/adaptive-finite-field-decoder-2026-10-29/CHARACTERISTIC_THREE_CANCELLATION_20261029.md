# NIGHTFALL — Characteristic-three cancellation packing

**Date:** 29 October 2026  
**Program:** NIGHTFALL PHASESHIFT / deterministic adaptive finite-field decoder  
**Research provenance:** Axiom proposed the original two-round decoder. This subsequent independent research turn developed the characteristic-three cancellation protocol and its sharp per-query phase-packing obstruction. Program lead: Devin J. Wright.  
**Evidence status:** self-contained algebraic proof candidate plus executable exact small-field checks. External mathematical refereeing and comprehensive same-model novelty review remain open.

## Theorem A — cancellation packing

Let \(K=\mathbb F_{3^r}\), \(r\ge2\), and let \(x\in K^k\). An adaptive measurement is \(\Phi(a\cdot x)=(a\cdot x)^2\), with \(a\in K^k\); the signal is sought modulo multiplication by \(\mathbb F_3^\times=\{\pm1\}\). If \(s=|\operatorname{supp}(x)|\), then a deterministic **two-round** protocol reconstructs every signal class in

\[
\boxed{m=k+\left\lceil\frac{\max(s-1,0)}r\right\rceil\le k+\left\lceil\frac{k-1}{r}\right\rceil}\tag{1}
\]

powered queries. Reconstruction takes polynomial field arithmetic, using the specified explicit extension representation.

### Proof

**Round 1.** Query \(y_j=x_j^2\) for all \(j\). The support is known exactly. For every supported \(j\), find any nonzero root \(u_j^2=y_j\) using the \(\mathbb F_3\)-linear kernel of \(z^3=y_jz\). Then \(x_j=\lambda_j u_j\) with \(\lambda_j\in\{1,-1\}\). If the support is empty, the all-zero signal is recovered.

Choose one supported anchor index \(t\). Partition the remaining \(s-1\) supported coordinates into blocks of size at most \(r\). Fix an \(\mathbb F_3\)-basis \(\beta_1,\ldots,\beta_r\) of \(K\).

**Round 2.** For a block \(G=(j_1,\ldots,j_h)\), \(h\le r\), submit the permitted field-linear measurement with coefficient \(a_t=(\beta_1+\cdots+\beta_h)/u_t\), and \(a_{j_i}=\beta_i/u_{j_i}\). Its unpowered interior is

\[
 z_G=\sum_{i=1}^h\beta_i\left(\lambda_t+\lambda_{j_i}\right).
\]

In \(\mathbb F_3\), each coefficient \(\lambda_t+\lambda_{j_i}\) is either **zero** (opposite signs), or \(-\lambda_t\) (equal signs). The oracle gives \(w_G=z_G^2\). If \(w_G=0\), then \(z_G=0\), every basis coefficient vanishes, and every phase in this block is opposite the anchor. Otherwise find any nonzero square root \(v_G\) of \(w_G\), which equals \(z_G\) up to global sign. Multiplication by a nonzero base-field scalar preserves the **zero/nonzero pattern of its basis coefficients**. That pattern identifies, independently for every \(i\), whether \(\lambda_{j_i}=\lambda_t\). Thus all relative phases are recovered using **one powered measurement per block**. Constructing \(\hat x_t=u_t\) and \(\hat x_{j_i}=\pm u_{j_i}\) with the recovered relative signs gives \(x=\lambda_t\hat x\). Counting coordinate probes and blocks proves (1). QED.

**Difference from the older packing argument:** Its basis method used one dimension to carry an explicit anchor coefficient, hence only \(r-1\) phases per mixed measurement. In characteristic three, all basis coefficients themselves carry an anchor comparison via **cancellation**, eliminating that overhead.

## Theorem B — sharpness of one powered mixing query after coordinate probes

Suppose \(h\) independent relative signs \(\epsilon_i\in\{\pm1\}\) remain after the coordinate measurements and the anchor sign is normalized to one. For **any** affine-linear mixture

\[
F(\epsilon)=a_0+\sum_{i=1}^h a_i\epsilon_i\in\mathbb F_{3^r},
\]

when \(h>r\), there exist two distinct relative sign assignments \(\epsilon\ne\epsilon'\) with **equal unpowered values** \(F(\epsilon)=F(\epsilon')\), and therefore equal powered outputs. Indeed, \(a_1,\ldots,a_h\) are \(\mathbb F_3\)-linearly dependent, so choose \(0\ne(d_1,\ldots,d_h)\) with \(\sum_i a_i d_i=0\). Every \(d_i\in\mathbb F_3\) can be expressed as \(\epsilon_i-\epsilon'_i\) for \(\epsilon_i,\epsilon'_i\in\{\pm1\}\); at least one difference is nonzero. The resulting pair collides even before taking powers. Thus a **single** mixed powered query can never resolve more than \(r\) independently unknown signs in this anchored coordinate-first model. Theorem A attains this sharp bound.

This sharpness result pertains to one mixed query. It does not claim an optimal total query count among all interactive protocols when \(k>r+1\).

## Corollary — new exact-optimal range

The generic counting argument gives \(m\ge k+1\) for any deterministic adaptive algorithm when \(q=3\) and \(k\ge2\). Our upper bound equals \(k+1\) whenever \(2\le k\le r+1\), hence **global optimality holds in this wider range**. Some further \((r,k)\) pairs satisfy equality with the precise counting bound: for example \(r=2\), \(k=4,5,7\); \(r=3\), \(k=6,7,10\). These additional equalities follow from integer powers, without assuming an unknown lower bound.

| \(r\) | \(k\) | Earlier two-round upper bound | Cancellation upper bound | Information minimum |
|---:|---:|---:|---:|---:|
| 2 | 3 | 5 | **4** | **4** |
| 2 | 4 | 7 | **6** | **6** |
| 2 | 5 | 9 | **7** | **7** |
| 2 | 7 | 13 | **10** | **10** |
| 3 | 4 | 6 | **5** | **5** |
| 3 | 6 | 9 | **8** | **8** |
| 4 | 9 | 12 | **11** | **11** |

### A concrete example over \(\mathbb F_9\)

Take \(\alpha^2=-1\) and basis \(\beta_1=1\), \(\beta_2=\alpha\). Once the coordinate phases are known, one mixed query

\[
\left((\lambda_t+\lambda_i)+\alpha(\lambda_t+\lambda_j)\right)^2
\]

recovers **both** signs \(\lambda_i/\lambda_t\) and \(\lambda_j/\lambda_t\). Its two basis coefficients vanish exactly when the corresponding sign is opposite the anchor. For \(k=3\), this gives four queries total, which is globally optimal by counting.

## Reproducibility and scope

Run `python3 verify_q3_cancellation.py`. Independent integer-polynomial arithmetic tests over \(\mathbb F_9\), \(\mathbb F_{27}\), \(\mathbb F_{81}\) include 54,461 exact reconstruction trials, among them complete exhaustive regimes, with 15,259 inputs exhibiting fewer queries than the previous bound. Six explicit obstructions demonstrate collisions when trying to pack \(r+1\) or \(r+2\) phases into one linear query. The finite audit corroborates the theorem; it is no substitute for the algebraic proof.

**Assumptions:** exact noiseless powered measurements, adaptive second-round coefficients, known explicit finite-field representation; the query count concerns a worst-case deterministic oracle, not computational protection against measurement noise. The improvement is specific to a base field of order three (\(q=3\)); no claim is made that the same coefficient-zero packing works for other base-field orders.

**Prior work and originality boundary:** The result builds on the NIGHTFALL extension-degree packing research and classical phase retrieval ideas (Balan–Casazza–Edidin, 2006; Charikar–Wu–Ye, 2020; and finite-field sign-retrieval literature). A targeted web search on October 29 located related phase retrieval and discrete sign problems, without identifying this exact finite-field cancellation theorem. That search is not a comprehensive priority review. The precise claim of externally new mathematics requires independent literature verification and review.