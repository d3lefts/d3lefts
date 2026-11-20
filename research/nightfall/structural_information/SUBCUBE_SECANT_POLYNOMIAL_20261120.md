# NIGHTFALL — Polynomial secant-evasiveness from six first-factor slices

Date: 2026-11-20. **Research status: author-side candidate proof, independently finite-audited, NOT YET Lean-kernel certified and NOT prior-art/novelty certified.** Do not cite as a theorem in public-facing research until the structural lemmas and scalar composition are kernel-checked and independently reviewed.

## Recovered certified inputs

Let \(K=\mathbb F_2\), \(E_0=K\), \(E_{n+1}=E_n\oplus E_n\), \(R_0=\{1\}\), and
\(R_{n+1}=\{(r,0),(0,r),(r,r):r\in R_n\}\).
The pinned Lean files `SubcubeAllLevels.lean`, `SubcubeAffineAllLevels.lean`, and `SubcubeSharpAllLevels.lean` already certify \(|R_n\cap U|\le(\dim U)^2\) and \(|R_n\cap(a+U)|\le(\dim U+1)^2\) (and the stronger sharp exponent). The dimension of arbitrary slices is controlled by `slice_rank_pairs`.

Write \(S_n=R_n+R_n\) (all XOR sums including zero), \(S_n^*=S_n\setminus\{0\}\), and \(A_n=R_n\cup\{0\}\). For \(n\ge1\), \(A_n+A_n=S_n\): each row is a sum of the other two row types with the same prefix.

## Claim A: mixed-product intersection

For any subspace \(U\le E_n\oplus E_n\) of dimension \(q\),
\[
  |(R_n\times R_n)\cap U|\le 4q^4.
\]
For \(q=0\), both tensor rows are nonzero, so the intersection is empty. For \(q\ge1\), let \(P=\pi_1(U)\) and \(K_0=\{s:(0,s)\in U\}\). Both have dimensions at most \(q\). There are at most \(q^2\) choices of first row \(r\in R_n\cap P\). For each fixed \(r\), if any \(s_r\) exists then all compatible second rows lie in the single affine coset \(s_r+K_0\); there are at most \((q+1)^2\). Thus \(q^2(q+1)^2\le 4q^4\). This argument needs only the *separately certified* row bounds, no ambient-dimensional estimates.

## Claim B: exact six-way tensor secant decomposition

For any distinct row-pair types, the possible sums of two rows from \(R_{n+1}\) lie in:
\[
  (S_n,0),\quad(0,S_n),\quad(S_n,S_n)_{\rm diag},
\]
and three mixed families
\[
  M_{AB}=\{(r,s)\},\quad
  M_{AC}=\{(r+s,s)\},\quad
  M_{BC}=\{(s,r+s)\},\qquad r,s\in R_n.
\]
This is a SET union (no multiplicity assumptions). The mixed maps are invertible linear transformations of \(E_n\oplus E_n\), so Claim A bounds their intersections with every \(q\)-space by \(4q^4\). The direct-sum/diagonal pure branches meet \(W\) in the three ordinary slice subspaces \(W_A,W_B,W_C\), with dimensions \(a,b,c\) satisfying pairwise \(a+b,a+c,b+c\le q\).

## Claim C: candidate universal polynomial secant bound

For all \(n\ge0\) and all \(q\)-dimensional \(W\le E_n\),
\[
  |S_n^*\cap W|\le 12n q^4.\tag{C}
\]
Proof sketch with all dependencies explicit: at \(n=0\), \(S_0^*=\varnothing\). Let \(F_n(W)=|S_n^*\cap W|\). Six-way decomposition and Claim A yield
\[
 F_{n+1}(W)\le F_n(W_A)+F_n(W_B)+F_n(W_C)+12q^4.
\]
The integer inequality \(a^4+b^4+c^4\le q^4\) under the three pairwise constraints follows from the existing `SubcubeSharpScalar.triple_rpow` with exponent \(4\) (since \(4\ge1\), \(2^4\ge3\)), or by sorting the three nonnegative integers and expanding \((a+b)^4\). Inductively, \(F_{n+1}(W)\le12nq^4+12q^4\).

Every affine \(a+W\) lies in \(W+\langle a\rangle\), of dimension at most \(q+1\). Consequently, for \(n\ge1\),
\[
\boxed{|(A_n+A_n)\cap(a+W)|\le 1+12n(q+1)^4.}\tag{S3-poly}
\]
In particular, the older secant-fiber parameter \(E_2(W)\), which maximizes over nonzero quotient cosets, obeys the same polynomial bound. Using the previously proved source multiplicity \(\mu(A_n)=n+1\) for \(n\ge2\) yields
\[
\mu(\pi_W(A_n))\le (n+1)\,[1+12n(q+1)^4].
\]
This removes the old \(2^q\) factor ***if and only if*** Claims A–C survive the independent formal audit.

## Adversarial review and remaining limits

1. Verify `(R_n+R_n)\setminus\{0\}` rather than conflating row pairs with distinct sums. The six-set union may overlap; this is safe for upper bounds.
2. In the mixed lemma, all nonempty fibers must be cosets of the **same vertical slice**; certify the preimage and dimension arguments for arbitrary linear subspaces, including \(q=0\).
3. The pure diagonal branch is \((s,s)\) with \(s\in S_n\), **not** a Cartesian square \(S_n\times S_n\).
4. For \(n=0\), \(A_0+A_0\ne S_0\); use the \(n\ge1\) hypothesis explicitly.
5. The improvement controls combinatorial quotient pair multiplicity only. It does **not** certify a coherent \(T\ge2\) quantum algorithm simulator: cross-frequency interference remains separate.
6. Independently check exact finite intersections through \(n=3\), mixed-product intersections for all subspaces of the 8-dimensional \(E_2\oplus E_2\), and six-way equality through \(n=4\to5\).
7. Literature audit: Segre secant geometry and subspace tensor rank are established research areas; the present search did not establish whether this specific finite-field polynomial bound is historically new. No novelty claim.

Next certification target: kernel-checked `mixed_product_bound`, `six_way_secants`, and `all_levels_secant_quartic`; then source-grounded affine and quotient corollaries. Preserve exact build logs, SHA, and independent checker; do not merge a theorem claim while these Lean dependencies are missing.


## Sharper exponent transfer — author-side revision v2 (same date)

The quartic exponent in (S3-poly) is not the structural limit. Set
\(\alpha=\log_2 3\), already defined and kernel-certified in `SubcubeSharpScalar.lean`.
The established all-level linear and affine row bounds have exponent \(\alpha\).
For a q-dimensional \(U\le E_n\oplus E_n\), the mixed-product projection/fiber
argument gives \(|(R_n\times R_n)\cap U|\le p^\alpha(k+1)^\alpha\), with
\(p,k\le q\). At \(q=0\) this is zero, since no row is the zero vector.
For \(q\ge1\), \(q+1\le2q\) and \(2^\alpha=3\), whence
\[
  |(R_n\times R_n)\cap U|\le
     q^\alpha(q+1)^\alpha\le 3q^{2\alpha}.\tag{M-sharp}
\]
This avoids the rank-nullity identity \(p+k=q\), so the formalization can
reuse only rank monotonicity plus the previously certified row bounds.

Let \(\beta=2\alpha\). The already-certified generic scalar
`SubcubeSharpScalar.triple_rpow` applies at \(p=\beta\), because
\(\beta\ge1\) and \(2^\beta=9\ge3\). Combining the same six-way decomposition
and (M-sharp) inductively predicts
\[
  \boxed{|S_n^*\cap W|\le9n (\dim W)^{2\alpha}},\qquad
  \boxed{|(A_n+A_n)\cap(a+W)|\le1+9n(q+1)^{2\alpha}}\quad(n\ge1).
  \tag{S3-sharp-degree candidate}
\]
The degree \(2\alpha\approx3.169925\) is consistent with the full-space count
\(|S_n|\asymp9^n\) observed in finite levels. Conditional on the independent
one-query pair multiplicity \(\mu(A_n)=n+1\) for \(n\ge2\), counting distinct
nonzero sums among the \(\binom{3^n}{2}\) unordered distinct row pairs gives
\[
  |S_n^*|\ge \frac{3^n(3^n-1)}{2(n+1)}.
\]
Thus no polynomial-in-\(n\) prefactor can support a **uniform exponent below
\(2\alpha\)** when \(W=E_n\) ranges over all depths. This is a conditional
exponent-optimality calculation, **not** a Lean theorem or verified novelty
claim.

**Certification split:** The six-way covering theorem `six_way_cover` is
kernel-checked on [run 44784499681](https://github.com/d3lefts/d3lefts/actions/runs/44784499681).
The integer quartic mixed-product lemma is in pinned CI iteration; the real
\(3q^{2\alpha}\) upgrade and global induction are NOT kernel certified.
Exact finite checks are independent of these proof steps.

## Closest literature checked this session

Broad background on Segre rank-two geometry includes the 2018
[Hitchhiker guide to secant varieties](https://www.mdpi.com/2227-7390/6/12/314)
and [Ranks of tensors and a generalization of secant varieties](https://arxiv.org/abs/0909.4262).
Neither reference was found to settle this precise finite-field arbitrary-subspace
count. This is **not evidence of novelty**; a theorem-specific prior-art search
and adversarial mathematical review remain required.
