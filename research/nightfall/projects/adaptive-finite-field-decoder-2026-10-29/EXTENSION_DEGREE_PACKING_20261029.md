# NIGHTFALL — Extension-degree packing for deterministic adaptive finite-field reconstruction

Date: 29 October 2026  
Program: NIGHTFALL PHASESHIFT / Adaptive finite-field decoder  
Research origin: Axiom's two-round phase synchronization decoder; this turn's extension-degree packing, exact optimality analysis, and complement-property comparison  
Status: complete algebraic proof argument and independently executable finite-field tests; external referee and same-model priority review open

## Theorem 1. Batched adaptive reconstruction

Let \(L=\mathbb F_q\), \(K=\mathbb F_{q^r}\), \(r\ge 2\), and \(x\in K^k\). A query selects \(a\in K^k\) and returns \(\Phi(a\cdot x)=(a\cdot x)^{q-1}\). The goal is to recover the class of \(x\) modulo global multiplication by \(L^\times\). Let \(s=|\operatorname{supp}x|\).

When \(q>2\), a deterministic two-round procedure exactly reconstructs every class using

\[
\boxed{\ m=k+\left\lceil\frac{\max(s-1,0)}{r-1}\right\rceil\ \le\ k+\left\lceil\frac{k-1}{r-1}\right\rceil.\ }
\]

When \(q=2\), the same model has exact minimum \(m=k\): \(\Phi(z)=z\).

**Proof.** The kernel of \(\Phi:K^\times\to K^\times\) is precisely \(L^\times\). Query the \(k\) coordinate powers \(y_j=x_j^{q-1}\). Their zero pattern gives the exact support. For every \(j\) on the support, compute a nonzero root \(u_j\) of \(z^q=y_j z\); its nonzero solution line is \(u_jL^\times=x_jL^\times\). This root can be found by deterministic \(L\)-linear Gaussian elimination in the supplied field representation. Thus \(x_j=\lambda_j u_j\) with \(\lambda_j\in L^\times\).

Choose one supported index \(t\) as anchor. Partition the other supported indices into groups \(G\) with \(|G|\le r-1\). Fix an \(L\)-basis \(\beta_0=1,\beta_1,\ldots,\beta_{r-1}\) of \(K\). For the indices \(G=(j_1,\ldots,j_h)\) query

\[
 w_G=\Big(\frac{x_t}{u_t}+\sum_{a=1}^{h}\beta_a\frac{x_{j_a}}{u_{j_a}}\Big)^{q-1}
 =\Big(\lambda_t+\sum_{a=1}^{h}\beta_a\lambda_{j_a}\Big)^{q-1}.
\]

The interior is nonzero because its basis coefficient at \(\beta_0\) equals \(\lambda_t\ne0\). Solve \(z^q=w_Gz\) for any nonzero \(z\). By the multiplicative-kernel property, there is a \(\mu_G\in L^\times\) such that

\[z=\mu_G\lambda_t\beta_0+\sum_{a=1}^{h}\mu_G\lambda_{j_a}\beta_a.\]

Read these \(h+1\) base-field coordinates; their ratios to the nonzero coefficient of \(\beta_0\) are \(\lambda_{j_a}/\lambda_t\). Recover \(\hat x_t=u_t\), \(\hat x_{j_a}=(\lambda_{j_a}/\lambda_t)u_{j_a}\), and zero elsewhere. Therefore \(x=\lambda_t\hat x\). Every second-round row depends only on the first-round outputs, so exactly two rounds suffice. The number of mixed queries is \(\lceil\max(s-1,0)/(r-1)\rceil\). Field linear algebra yields polynomial runtime in \(k,r,\log q\) for explicitly represented finite fields. QED.

## Theorem 2. Exact global optimum for high extensions

For \(q>2\), \(k\ge2\), **every deterministic adaptive algorithm**, regardless of its number of rounds, needs at least \(k+1\) queries in the worst case. Consequently, when \(2\le k\le r\), the construction above is **globally measurement-optimal**, achieving exactly \(k+1\). For \(q=2\), exactly \(k\) queries are necessary and sufficient for every \(r\).

**Proof.** A query produces precisely
\[N_1=1+(q^r-1)/(q-1)\]
possible outputs, including zero. The number of equivalence classes of full signals is
\[N_k=1+(q^{rk}-1)/(q-1).\]
A depth-\(m\) adaptive decision tree has at most \(N_1^m\) transcripts, hence \(N_1^m\ge N_k\). Write \(U=q^r\), \(N_j=(U^j+q-2)/(q-1)\). Then, for all positive \(a,b\),
\[
N_{a+b}-N_aN_b=\frac{(q-2)(U^a-1)(U^b-1)}{(q-1)^2}.
\]
For \(q>2\), the right-hand side is strictly positive. Inductively \(N_k>N_1^k\) for \(k\ge2\); thus \(m\ge k+1\). For \(2\le k\le r\) our construction uses \(k+1\). For \(q=2\), \(N_k=(2^r)^k\), giving \(m\ge k\), attained by reading \(x_j\) directly. QED.

## Proposition 3. Same-model nonadaptive separation

For \(q>2\), every **fixed, nonadaptive collection** of powered \(K\)-linear measurements that reconstructs every \(x\in K^k/L^\times\) must have at least \(2k-1\) rows, for any \(r\ge2\).

**Proof (complement-property argument).** If the measurement matrix has a nonzero common kernel \(u\), then \(u\) and zero are indistinguishable. Otherwise, suppose it has \(m\le2k-2\) rows. Partition them into \(I,J\) with each part having at most \(k-1\) rows. Select independent nonzero vectors \(u\in\ker A_I\) and \(v\in\ker A_J\). Independence follows because the common kernel of all rows is zero. Fix any \(c\in L^\times\setminus\{1\}\). Set \(x=u+v\), \(x'=u+cv\). Every row in \(I\) sees two linear outcomes differing by \(c\); every row in \(J\) sees equal linear outcomes. Their \((q-1)\)-st powers therefore coincide. Yet independence of \(u,v\) ensures \(x\) and \(x'\) are inequivalent under multiplication by \(L^\times\). Contradiction. QED.

This is a finite-field adaptation of the classical **complement-property obstruction**, rather than a claim to originate the complement-property method. In particular, when \(r\ge3\) and \(k\ge3\), the batched adaptive upper bound is strictly less than this nonadaptive universal lower bound. For \(r\ge k\), the comparison is \(k+1\) adaptive versus at least \(2k-1\) nonadaptive: a saved budget of at least \(k-2\) measurements.

## Exact independently coded checks

- `verify_extension_packing.py` implements finite-field arithmetic as integer polynomials modulo explicit irreducible polynomials, obtains coordinate representatives from a separately computed exhaustive phase table, and uses basis-coordinate extraction for the batched mixes.
- It checks all small cases up to \(\mathbb F_{27}^3\), \(\mathbb F_9^4\), and \(\mathbb F_{25}^3\), with seeded larger-field cases over \(\mathbb F_{81}\) and \(\mathbb F_{125}\).
- **53,478 exact input vectors passed** equivalence and exact-query-count checks, including the \(q=2\) exception.
- **1,500 separate nonadaptive collision certificates passed**, with fixed random frames and explicit kernel-pair witnesses over \(\mathbb F_{27}\), \(\mathbb F_{81}\), and \(\mathbb F_{125}\).
- The test scope covers prime base fields \(q\in\{2,3,5\}\). The general prime-power theorem is mathematical, while broader finite computational coverage remains a review item.

Run: `python3 verify_extension_packing.py`. No third-party Python packages required. The program's final line should read `PASS 53478 exact inputs and 1500 nonadaptive collision certificates`.

## Positioning, limits, and prior art

1. Compared with the October 29 `2k−1` adaptive decoder, this is a **strict measurement improvement whenever \(r\ge3\) and sufficiently many coordinates are supported**. It introduces a dependence on extension degree and a globally optimal high-degree regime.
2. The result applies to noiseless adaptive \((q-1)\)-st-power oracles over explicitly represented extensions. It **does not improve** any separate random/nonadaptive fourth-power lattice-decoder bound under identical assumptions.
3. The exact finite-field nonadaptive obstruction has the classical complement-property method as precedent: Balan, Casazza and Edidin, *On signal reconstruction without phase*, Applied and Computational Harmonic Analysis 20 (2006), 345–356, DOI 10.1016/j.acha.2005.07.001. Adaptive discrete phase retrieval is also established research: Charikar, Wu and Ye (2020), DOI 10.1137/1.9781611976014.9; their complex-intensity model differs from the present finite-field power oracle. Bourgain, Garaev, Konyagin and Shparlinski, *On the Hidden Shifted Power Problem*, SIAM J. Comput. 42 (2013), DOI 10.1137/110850414, covers a related powered-field oracle but a different unknown and query model.
4. No comprehensive same-model prior-art clearance has been completed. The batched construction and exact optimality are **NIGHTFALL proof candidates**, with external review requested before publication-level novelty claims.
5. High-value next problems: exact optimal query complexity for \(k>r\), extension of mixed-query batch size using structured finite-field code designs, corruption tolerance with certified overhead, optimal sparse-support localization, and uniform construction of the representation basis.