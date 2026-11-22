# Route 1 beyond globally close sources: access-weighted coupling

**Paper theorem and exact analytic example.** The native Route 1 and
finite-alphabet fractional row bounds are already kernel-checked; this
note does not claim that the new transfer composition or the quantum
hybrid has been kernel-checked. External review and priority remain
open. This note neither assumes nor solves Liu–Mutreja's CHFS conjecture.

## 1. The exact source transfer

Let \(X\sim\nu\) be the true source and let \(Y\sim Q\) be a clean
reference on the same finite Cartesian alphabet \(\Omega=\prod_i A_i\).
Fix **any joint coupling** \(\pi\) of these sources. For \(y\) of positive
\(Q\)-mass put \(\eta_i(y)=\Pr_\pi(X_i\ne y_i\mid Y=y)\); define it to be
zero on null atoms. Let \(f:\Omega\to[0,1]\), and let \(t\) be a
deterministic original-coordinate query tree of maximum depth \(q\).
Write \(J_t(y)\) for the set of coordinates on its clean path (using a
list and charging repeat queries is also an admissible upper bound).
Suppose \(\Pr_Q(|f(Y)-t(Y)|>\varepsilon-u)\le\delta_0\) for
\(0<u<\varepsilon\). If nonnegative weights \(a_i(y)\) satisfy
\[
|f(x)-f(y)|\le\sum_i a_i(y)\mathbf 1_{\{x_i\ne y_i\}}
\quad\text{for all }x,y,
\]
then the **same tree, querying only the actual source**, satisfies
\[
\Pr_\nu(|f(X)-t(X)|>\varepsilon)
\le\delta_0
+\underbrace{\mathbb E_{Y}\sum_{i\in J_t(Y)}\eta_i(Y)}_{C_{\rm path}}
+\frac1u\underbrace{\mathbb E_{Y}\sum_i a_i(Y)\eta_i(Y)}_{C_{\rm task}} .
\tag{1}
\]

**Proof.** If \(x\) agrees with \(y\) on every query in \(J_t(y)\),
induction on the tree shows \(x\) follows the same path and has the
same output. Hence
\[
\Pr_\pi(t(X)\ne t(Y)\mid Y=y)\le \sum_{i\in J_t(y)}\eta_i(y).
\]
The pointwise row inequality gives \(\mathbb E_\pi|f(X)-f(Y)|
\le C_{\rm task}\), hence drift exceeds \(u\) with probability at
most \(C_{\rm task}/u\). Union bound the three bad events (clean
failure, output disagreement, excessive drift); on their complement
the error is at most \(\varepsilon\). There are no independence
assumptions on corruption, no need to sample \(Y\), and no extra
queries. Because \(t\) is deterministic, the path probabilities
are conditional on the actual clean input, not hypothetical access
patterns.

For finite formalization no division by \(Q(y)\) is required: both
charges are simply joint sums with weight \(\pi(x,y)\), and the
uniform bound below is equivalently the slice inequality
\(\sum_{x:x_i\ne y_i}\pi(x,y)\le\eta Q(y)\).

For globally bounded interaction-degree-\(d\) functions, the merged
[NIGHTFALL finite-product row theorem](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/ProductRowBound.lean)
gives weights of total \((\pi^2/2)d^2\) for \([0,1]\)-valued \(f\), by
rescaling \(2f-1\); its source names the original fractional row
machinery of Agarwal–Ben-David and Turturean. A finite heterogeneous
alphabet embeds in a common finite alphabet by a coordinatewise
section/retraction, preserving interaction degree. If \(\eta_i(y)\le\eta\),
(1) becomes
\[
\Pr_\nu(|f(X)-t(X)|>\varepsilon)
\le\delta_0+\left(q+\frac{\pi^2d^2}{2u}\right)\eta.
\tag{2}
\]
The alternative hypotheses in (1) are stronger for particular tasks:
unbounded conditional displacements can be harmless on coordinates
irrelevant to both the tree path and weighted target variation.

[Route 1 / Wyner](https://github.com/d3lefts/d3lefts/pull/970) supplies
\(q=\operatorname{poly}(d,1/(\varepsilon-u),1/\delta_0)
(1+C_W(Q))\) for a reference \(Q\) with low common information (or
\(1+\log M\) for an explicit \(M\)-component representation).
Thus a sufficiently small access-coupling cost, and not global
total variation or actual-source common information, suffices for
simulation.

## 2. Independent operational quantum form

Let \(f\) now be the acceptance probability of a normalized \(T\)-query
quantum circuit with ordinary whole-symbol oracle. For the clean input
\(y\), let \(w_{k,i}(y)\) be the probability mass of query index \(i\)
in its pre-query state at step \(k\). Let \(\psi_x,\psi_y\) denote
the final pure states, using purification if required. The
standard BBBV hybrid telescope runs a clean prefix and true suffix
around each substituted call. The two oracle actions agree on the
unmodified index sectors; each has operator norm one, hence
\[
\|\psi_x-\psi_y\|\le
2\sum_{k=1}^T\left(\sum_i w_{k,i}(y)\mathbf 1_{\{x_i\ne y_i\}}\right)^{1/2}.
\]
By Cauchy–Schwarz its square is at most
\(4T\sum_{k,i}w_{k,i}(y)\mathbf 1_{\{x_i\ne y_i\}}\).
For a common measurement effect the acceptance difference is bounded
by the trace distance of the pure states, which is at most
\(\|\psi_x-\psi_y\|\), since
\(1-|\langle\psi_x,\psi_y\rangle|^2\le
2(1-\operatorname{Re}\langle\psi_x,\psi_y\rangle)\).
Thus the same event argument gives
\[
\Pr_\nu(|f(X)-t(X)|>\varepsilon)
\le\delta_0+C_{\rm path}
+\frac{4T}{u^2}\mathbb E_Y\sum_{k,i}w_{k,i}(Y)\eta_i(Y).
\tag{3}
\]
Under a uniform one-sided \(\eta\) bound the last term is
\(4T^2\eta/u^2\). Taking a minimum of (1) and (3) is allowed when
both premises hold. Formula (3) comes from the operational oracle,
not only from the existence of an acceptance polynomial.

**Why unconditional flip probabilities do not suffice for this
coupling argument.** Let a clean uniform address \(J\) index one
of \(N\) clean uniform data bits, and let the coupling flip exactly
the data bit at \(J\), leaving the address fixed. Every individual
data bit is changed with unconditional probability \(1/N\), yet
the deterministic address-reading tree, and the selected-bit
target, always change outputs. This falsifies a path bound based
only on unconditional marginal mismatch under the *specified*
coupling. It does not say that some better coupling is unavailable
for the same two marginals (indeed in this example the marginals
are identical).

## 3. Strict example with large TV and failure of low-Wyner exact moments

Take \(b\) independent blocks of \(k\ge5\) binary coordinates, and let
\(Y\) be uniform independent bits. In each block independently:
with probability \(0<\rho<1\), overwrite bit 2 with bit 1; afterward,
if its parity is odd, flip one uniformly chosen bit among positions
\(3,\ldots,k\). Let \(X\) be the output. The conditional coordinate
mismatch bound is
\[
\eta_i(y)\le \max(\rho,1/(k-2)) \qquad\text{for all }i,y .
\]
The copy operation selects the uniform law on its equality hyperplane
when it is applied. The parity edit maps either uniform group (full
or equality-constrained) to its uniform even-parity half. For example,
each even output has a direct even preimage of full weight and
\(k-2\) odd preimages of weight \(1/(k-2)\) each. Thus one block is a
mixture of uniform even parity and uniform even parity with the first
pair equal. Its single bits are fair; in \(\{\pm1\}\) notation its
first pair has product expectation \(\rho\) and all other distinct
pairs have product expectation zero. This follows from character
orthogonality and the dual subgroup generators of weights \(k,2\)
(their sum has weight \(k-2\ge3\)).

The actual support has no Hamming edge and lies in the intersection
of the block even-parity conditions. Consequently
\[
\|\nu-Q\|_{\mathrm{TV}}\ge 1-2^{-b},\qquad
C_W(\nu)=H(\nu)\ge b(k-2)\ln 2.
\]
Indeed, every conditional product with positive mass must be
supported inside the actual support; its support is a rectangle,
and a nonsingleton rectangle contains a Hamming edge. Hence every
such product is a point mass, even for arbitrary latent spaces.
The entropy bound follows block-wise by concavity. Nevertheless,
for fixed \(d,\varepsilon,\delta\), take \(u=\varepsilon/2\),
\(\delta_0=\delta/2\), and let \(q\) be the constant-in-\(b\) Route 1
bound for the clean product. Choosing \(\rho\) small and \(k\) large,
both independently of \(b\), gives the fixed target guarantee by (2);
the clean reference has \(C_W(Q)=0\).

This is not merely an example in which one chosen reference misses
the exact moment condition. No product reference matches all its
first and second marginals. More generally, **every** exact-two-marginal
matching reference \(Q'\) has common information growing with \(b\).
To see this, let \(W\) be any conditional-product latent for \(Q'\)
and \(m_i(W)=\mathbb E[X_i\mid W]\). In each distinguished pair
choose \(i_j\) with \(\mathbb E m_{i_j}^2\ge\rho\), possible because
\(\mathbb E[m_{j,1}m_{j,2}]=\rho\). Put
\(S=\sum_j\mathbb E m_{i_j}^2\ge b\rho\) and
\(F(W,X)=\sum_j m_{i_j}(W)X_{i_j}\). Under the joint law \(J\),
\(\mathbb E_J F=S\), \(F\le b\), so
\[
J[F\ge S/2]\ge S/(2b-S)\ge \rho/(2-\rho).
\]
Under the decoupled law \(K=\mathsf{Law}(W)\times Q'\), the selected
coordinates have zero cross correlations, so \(\mathbb E_K F^2=S\)
and \(K[F\ge S/2]\le4/S\le4/(b\rho)\). Data process
\(I(W;X)=D(J\|K)\) to this binary event, giving for \(b\rho\ge4\)
\[
I(W;X)\ge\frac{\rho}{2-\rho}\ln(b\rho/4)-\ln2 .
\]
The inequality is the binary divergence bound \(D(p\|q)\ge
p\ln(1/q)-\ln2\). Taking the infimum over latents proves the
claimed obstruction.

Its logarithmic order is attainable for matching two marginals.
Take \(m=\lceil\log_2(b+1)\rceil\), pairwise-independent first bits
\(A_j=(-1)^{s\cdot v_j}\) from distinct nonzero \(v_j\in\mathbb F_2^m\)
and uniform \(s\). Set \(B_j=A_jE_j\), with independent signs
\(E_j\) of mean \(\rho\), and all other coordinates independent fair.
Conditional on \(s\) this is a product, its pair marginals match
exactly, and \(C_W(Q')\le m\ln 2\). The best exact-second-marginal
common information is therefore \(\Theta_\rho(\log b)\), versus
zero for the access-coupling reference. This comparison is about
the structural **certificate cost**, not a lower bound on all
classical decision trees or a claim of quantum advantage.

## 4. Prior art and certification boundary

- Bennett–Bernstein–Brassard–Vazirani, *Strengths and Weaknesses of
  Quantum Computing*, [arXiv:quant-ph/9701001](https://arxiv.org/abs/quant-ph/9701001),
  supply the hybrid argument, not claimed here as new.
- Agarwal–Ben-David, *Oracle Separations for the Quantum-Classical
  Polynomial Hierarchy*, [ITCS 2026](https://doi.org/10.4230/LIPIcs.ITCS.2026.2),
  and [Turturean’s AA proof](https://arxiv.org/abs/2611.09773) supply
  the Boolean fractional row framework. The alphabet-free kernel
  ingredient used above is already in NIGHTFALL's ProductRowBound.
- Liu–Mutreja, [arXiv:2608.20297](https://arxiv.org/abs/2608.20297),
  §§6.2–7, give a dense-source coupling with small **unconditional**
  coordinate mismatch and discuss the computationally hidden flipped
  set needed in adaptive settings. Formula (3) is a conditional/task-
  exposure **sufficient condition**, not a proof that ordinary denseness
  always produces the requisite coupling. Prior art uses hybrids and
  coupling explicitly and must be credited.
- NIGHTFALL #893 used a related hybrid for a special dyadic product
  rounding transfer. #987 uses density domination and task-aware
  recoding; #988/#991 treat exact moments and tail transfer. This result
  does not assert that coupling defeats every such mechanism; the
  exact-two-marginal obstruction addresses the specific low-Wyner
  comparison stated above.
