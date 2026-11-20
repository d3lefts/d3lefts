# PFR + Bogolyubov closes the bounded-doubling frame subcase (2026-11-19)

**Research status:** Paper proof using established external results; independent exact finite tests, **not** a Lean certificate, independent human review, or novelty determination. Keep Conjecture E for **unrestricted** row sets open. Credit: Gowers–Green–Manners–Tao (polynomial Freiman–Ruzsa); classical Fourier/Bogolyubov. NIGHTFALL contribution in this note is the reduction to the local-frame observable and the quantitative rank-vs-subspace consequence, not PFR or Bogolyubov themselves.

**Source context:** This self-contained theorem addresses the frame definition and Conjecture E in [LINEAR_DISTRIBUTIONS](https://github.com/d3lefts/d3lefts/blob/structural-information-theory/research/nightfall/structural_information/LINEAR_DISTRIBUTIONS_20261119.md) and [LINEAR_NECESSITY](https://github.com/d3lefts/d3lefts/blob/structural-information-theory/research/nightfall/structural_information/LINEAR_NECESSITY_20261119.md), which remain on a separate unmerged research branch.

**Exact sources checked:**
- Gowers–Green–Manners–Tao, *On a conjecture of Marton* (2023; Annals 2025), theorem as stated by Tao, https://terrytao.wordpress.com/2023/11/13/on-a-conjecture-of-marton/ : for nonempty \(R\subseteq \mathbb F_2^m\) with \(|R+R|\le K|R|\), there exists \(H\le\mathbb F_2^m\), \(|H|\le |R|\), and \(L\le 2K^{12}\) translates of \(H\) covering \(R\).
- Standard elementary Fourier Bogolyubov lemma, proved with explicit constants below. Sanders' stronger quasipolynomial codimension is **optional**, not used for the explicit bound.

## Theorem F (small-doubling row-frame closure; PAPER PROOF)

Let \(R\subseteq\mathbb F_2^m\) be nonempty and \(K\ge1\) satisfy \(|R+R|\le K|R|\). Write
\[
   N_4(R):=\max\{\dim V: V\le\mathbb F_2^m,\; V\subseteq 4\cdot R\}
\]
where \(4\cdot R\) contains sums of at most four rows; when multiplicities occur, regard \(R\) as its distinct-row support for doubling. Then
\[
   \boxed{\operatorname{rank}(R)\le N_4(R)+2K^{12}+8K^{24}.}
\]
In particular there exists a basis \(B\subseteq R\) for \(\operatorname{span}(R)\) such that:
1. every row of \(R\) is a sum of at most \(c=\max(1,\operatorname{rank}(R))\) elements of \(B\);
2. every \(b\in B\) is exactly one original row (\(c'=1\));
3. every nonempty subset of \(B\), of **any** cardinality, is independent.

Thus \(B\) is a \((c,1,h)\)-frame for every \(h\), with
\[
 \Lambda_T(R)\le \max(1,\operatorname{rank}(R))
 \le N_4(R)+2K^{12}+8K^{24}
\]
for all \(T\). (The right-hand side is >=10 for \(K\ge1\), including rank-zero cases.)

### Lemma F1 (elementary dense-coset Bogolyubov with explicit constant)

If \(A\subseteq\mathbb F_2^h\) has density \(0<\alpha\le1\), then \(4A\) contains a subspace \(V\) with
\[
 \operatorname{codim} V\le 2/\alpha^2.
\]

**Proof.** Use normalized Fourier coefficients \(\widehat{1_A}(\gamma)=2^{-h}\sum_x1_A(x)(-1)^{\gamma\cdot x}\). Parseval gives \(\sum_\gamma|\hat f(\gamma)|^2=\alpha\), and \(\hat f(0)=\alpha\). Define the heavy spectrum
\[
S=\{\gamma: |\hat f(\gamma)|^2\ge\alpha^3/2\}.
\]
Parseval implies \(|S|\le 2/\alpha^2\). Let \(V=S^\perp\), so \(\operatorname{codim} V=\operatorname{rank} S\le|S|\). For every \(v\in V\), the normalized fourfold convolution obeys
\[
(f*f*f*f)(v)=\sum_\gamma \hat f(\gamma)^4(-1)^{\gamma\cdot v}
\ge \hat f(0)^4-\sum_{\gamma\notin S}\hat f(\gamma)^4
\ge\alpha^4-(\alpha^3/2)\alpha=\alpha^4/2>0.
\]
All heavy-spectrum contributions are nonnegative because their characters are \(+1\) on \(V\). Positive convolution implies \(v\in4A\). This includes \(0\), and uses no density or mass floor beyond \(A\ne\emptyset\). QED.

### Proof of Theorem F

By GGMT PFR, choose \(H\) with \(|H|\le |R|\) and a covering by \(L\le2K^{12}\) cosets \(s_1+H,\dots,s_L+H\). Choose a coset with at least \(|R|/L\) elements of \(R\), and let \(A\) be the translate of those rows into \(H\). Then
\[
 \alpha=|A|/|H|\ge|R|/(L|H|)\ge 1/L.
\]
Lemma F1 inside \(H\) yields \(V\le H\), \(V\subseteq4A=4(R\cap(s_i+H))\subseteq4\cdot R\), and
\[
 \dim H-\dim V\le 2L^2.
\]
The equality \(4A=4(R\cap(s_i+H))\) uses characteristic two: four copies of the common coset shift cancel.

Since \(R\subseteq H+\operatorname{span}\{s_1,\dots,s_L\}\),
\[
 \operatorname{rank}(R)\le\dim H+L\le\dim V+2L^2+L\le N_4(R)+8K^{24}+2K^{12}.
\]
Now select a basis \(B\) **from original rows \(R\)** by Gaussian elimination. It is independent at every order, each \(b\) costs one query to the original input, and each row is the sum of at most \(|B|\) elements. This proves the frame claim without treating a PFR coset representative as a cheaply queryable row. QED.

### Optional Sanders refinement

Replacing Lemma F1 by the Sanders dense-set Bogolyubov–Ruzsa bound gives
\[
 \operatorname{rank}(R)\le N_4(R)+2K^{12}+O(\log^4(2K)),
\]
with implicit universal constant. This refinement is **not** required for a polynomial frame theorem.

## What this resolves, and what it does not

- If \(K=O(1)\), then \(\operatorname{rank}(R)=N_4(R)+O_K(1)\). Thus the maximal dimension of a subspace reached by four row queries controls *all* row information up to an additive constant. Basis queries give an exact classical simulator of depth \(O(N_4(R)+1)\) for any function of the input. Combining with paper-level Theorem C yields the expected constant-query BV vs \(\Omega(N_4)\) classical-parity lower bound when \(N_4\) grows.
- If \(K\le\operatorname{poly}(k,T)\) and \(N_4(R)\le k\), the frame cost is \(\operatorname{poly}(k,T)\), exactly the desired Conjecture E conclusion **restricted to this doubling class** (provided its chosen \(a(T)\ge4\)).
- **Unrestricted Conjecture E remains open.** For an independent set of \(n\) rows, \(K\sim n/2\), \(\operatorname{rank}(R)=n\) and \(N_4(R)\le4\), but the perfect frame \(B=R\) has \(c=c'=1\). Hence a rank-only argument with a \(\operatorname{poly}(K)\) loss does not prove the required \(K\)-free dichotomy.
- Theorem F's mathematical ingredients are established prior art; the formulation in the NIGHTFALL frame language needs a proper dated novelty review before any original-contribution claim. There is no Lean formalization of Theorem F in this note, and no non-author human proof review.

## Reproduction and adversarial audit

`python3 -I research/nightfall/structural_information/check_small_doubling_frame.py`

Local Python 3 standard-library audit passed **4,055** exact finite \(R,H\) cases: all nonempty sets in dimensions two and three over all eligible subspace covers, and randomized structured covers in dimensions four through seven. Exact-integer Walsh thresholds, spectrum annihilator, \(V\subseteq4A\), codimension bound, \(V\subseteq4R\), rank/cover inequality, basis reconstruction, and all-orders independence checked. For dimensions up to four, \(N_4(R)\) was independently computed by enumeration of all subspaces. Finite replay does not establish PFR or the universal theorem.

**Next high-value problem:** remove dependence on \(K\) from the frame conclusion by retaining a sparse original-row frame rather than only a basis of the full row span. Test high-doubling sets with *many short dependencies but no large subspace*; independence of the rows is not a counterexample, since \(B=R\) costs one. Target precise rank/quotient decompositions for intermediate/high doubling, not smaller constants in Theorem F.
