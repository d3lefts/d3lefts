# LEMNIS — Sharp ternary parity-kernel rigidity and the first rank-three obstruction

**Date:** October 28, 2026. **Project:** NIGHTFALL PHASESHIFT, Werner rank-two witness class. **Research lead:** Devin J. Wright; independent derivation and computational checks: GPT-6 (Lemnis).

**Evidence class:** Self-contained exact mathematical proof and independently implemented finite checks. **Novelty and external referee status:** Open. **Relation to flagship:** A precise no-go theorem for a full-space Schur-complement strategy. This theorem does **not** establish four-copy Werner undistillability at the unrestricted endpoint.

## Frozen problem

Let \(\mathcal H_k=(\mathbb C^3)^{\otimes k}\), and for a complex matrix \(C\) on \(\mathcal H_k\) set

\[
 Q_k(C)=\sum_{J\subseteq[k]}(-1/2)^{|J|}\|\operatorname{Tr}_J C\|_F^2.
\]

For a set \(S\subseteq\{0,1,2\}^k\), define \(\mathcal D(S)\) as the complex linear space of matrices diagonal in the computational basis, with diagonal support contained in \(S\). **Ambient positivity** means \(Q_k(C)\ge0\) for every complex \(C\in\mathcal D(S)\), without a rank restriction.

## Theorem (rigidity, sharp bound, and quantitative obstruction)

For every integer \(k\ge1\):

1. \(Q_k\) is nonnegative on all of \(\mathcal D(S)\) if and only if for every three distinct words \(a,b,c\in S\), the sum \(d_H(a,b)+d_H(b,c)+d_H(c,a)\) is even. Equivalently, the number of coordinates at which \(a_i,b_i,c_i\) are all distinct is even.
2. Every such \(S\) satisfies \(|S|\le2^k\). Equality is attained if and only if \(S=A_1\times\cdots\times A_k\), where every \(A_i\subseteq\{0,1,2\}\) has exactly two symbols. Consequently exactly \(3^k\) distinct maximum-cardinality supports exist.
3. Every \(S\) containing \(2^k+1\) distinct words contains a triple \(a,b,c\) and signs \(\alpha,\beta,\gamma\in\{+1,-1\}\) such that \(C=\alpha|a\rangle\langle a|+\beta|b\rangle\langle b|+\gamma|c\rangle\langle c|\) has **rank exactly three** and \(Q_k(C)=-3/2^k\). Thus rank three is the smallest possible rank of a diagonal negative witness: every diagonal rank-at-most-two matrix has nonnegative \(Q_k\).
4. For every maximum support \(B=A_1\times\cdots\times A_k\), adding any single outside word \(y\) creates **exactly \(4^{k-1}\)** triples \(\{a,b,y\}\) with \(a,b\in B\) that have the negative witness of item 3. In particular, for four qutrits the maximum ambient-positive diagonal support is **16**, there are **81** maximal supports, and each added 17th word creates exactly **64** distinct minimal rank-three obstructions of value \(-3/16\).

### Proof

**Step 1, exact kernel.** Write \(C=\sum_{a\in S}z_a|a\rangle\langle a|\). Expanding one local tensor factor \(I-\tfrac12|\Omega_3\rangle\langle\Omega_3|\) gives
\[
2^k Q_k(C)=\sum_{a,b\in S}(-1)^{d_H(a,b)}\bar z_a z_b. \tag{1}
\]
The real symmetric sign matrix \(G_{a,b}=(-1)^{d_H(a,b)}\) has diagonal one and every off-diagonal entry \(\pm1\). Its principal two-by-two minors vanish. If \(G\succeq0\), a Gram representation by unit vectors forces the Gram vectors to be collinear, so \(G_{a,b}=\sigma_a\sigma_b\) for signs \(\sigma_a\). Conversely such a factorization is positive semidefinite. Equivalently, \(G_{a,b}G_{b,c}G_{c,a}=+1\) for every triangle. At a single ternary coordinate, the total number of pairwise disagreements among three symbols is odd precisely when all three symbols differ. This proves item 1.

**Step 2, symplectic reduction.** Fix an anchor \(a_0\in S\); translate the alphabet in each coordinate so that \(a_0=0\). Embed a word \(a\in\mathbb F_3^k\) in \(\mathbb F_2^{2k}\) by writing each symbol as
\[
0\mapsto(0,0),\quad1\mapsto(1,0),\quad2\mapsto(0,1).
\]
On this binary vector space use the nondegenerate alternating form
\[
\omega(u,v)=\sum_{i=1}^k(u_{i,1}v_{i,2}+u_{i,2}v_{i,1})\pmod2.
\]
For \(a,b\in S\) the anchored triangle parity is \(\omega(f(a),f(b))\). Under item 1 every pair is orthogonal. Their binary span \(L\) is totally isotropic, so \(\dim L\le k\). Since \(f\) is injective, \(|S|\le|L|\le2^k\).

If equality holds, \(f(S)=L\). Each coordinate projection of \(L\) avoids \((1,1)\), because every element of \(L\) belongs to the one-hot alphabet image. Hence each projected binary subspace has dimension at most one. Their product has dimension at most \(k\), and equality of total dimensions forces the full direct product of a nonzero allowable line in each coordinate. Undoing the ternary translation, \(S\) is exactly a binary coordinate box. Conversely such a box has an explicit rank-one sign Gram matrix, proving item 2.

**Step 3, explicit minimal obstruction.** If a triple satisfies \(G_{a,b}G_{b,c}G_{c,a}=-1\), choose \(z_a=1\), \(z_b=-G_{a,b}\), \(z_c=-G_{a,c}\). Every pairwise cross contribution in (1) equals \(-1\). Thus \(2^k Q_k(C)=3-6=-3\). The three basis vectors are distinct, so the diagonal matrix has rank three. Every diagonal rank-two matrix has support on at most two basis words, whose two-by-two sign matrix is PSD. The sharp size bound forces an offending triple in any \(2^k+1\) words. This proves item 3.

**Step 4, exact multiplicity.** Normalize a maximum box to \(B=\{0,1\}^k\). An outside word \(y\) has a symbol 2 in at least one coordinate. For an ordered pair \((a,b)\in B^2\), the parity of coordinates where \(a_i,b_i,y_i\) are all distinct is uniformly distributed: at each coordinate with \(y_i=2\), exactly two of the four ordered binary pairs contribute one. Thus exactly half of the \(4^k\) ordered pairs have odd parity. An odd pair always has \(a\ne b\), and each unordered pair is counted twice. Hence the number is \(4^k/4=4^{k-1}\). This proves item 4. □

## Why this matters to the actual Werner assignment

- The archived four-copy restricted theorem proves \(Q_4(C)\ge0\) for rank\(C\le2\) in the 729-dimensional complementary-syndrome rectangle. Its ambient quadratic form has **negative rank-three** diagonal directions.
- The new theorem proves a **global sharp bound**: no diagonal coordinate family of 17 or more qutrit words can support full-space PSD, whatever syndrome construction is chosen. The obstruction has an explicit rank-three matrix, a fixed negative value, and 64 separate witnesses for every one-point enlargement of a maximal 16-word ambient-positive diagonal support.
- This rules out a class of incorrectly justified Schur-complement extensions. A viable Werner rank-two proof must preserve the rank constraint on the original matrix, find a rank-preserving projection, or derive a genuinely constrained inequality on its factors.
- Numerical search over 90 real rank-one-block starts for three pairwise colliding syndrome-coset representatives found values approaching zero from above. This search does **not** prove positivity for two colliding cosets and does **not** establish an unrestricted four-copy endpoint.

## Independent reproducibility

* `verify_symplectic.py` — exact sign-triangle and symplectic checks; all 512 subsets for \(k=2\), graph-clique enumeration at \(k=3\), every one-point extension of the canonical 16-word cube at \(k=4\), and all 84 triples from the archived nine-word code.
* `verify_partial_traces.py` — independently computes all \(2^4\) physical partial traces for each sparse diagonal witness; all 6,480 signed two-word controls, 4,160 exact rank-three negative triples adjoining the 16-word cube, and the archived 84 code triples. Uses no kernel logic from the first verifier.

The mathematical proof is for **all** integers \(k\ge1\); finite runs test representative dimensions and perturbations. The all-\(k\) claim is supported by the written proof, rather than extrapolation from runs.

## Literature and claim status

Background: Hamming association schemes, symplectic forms over \(\mathbb F_2\), semidefinite bounds for mixed binary/ternary codes (Bart Litjens, *Discrete Mathematics* 2018, DOI 10.1016/j.disc.2018.03.013), and quantum partial-trace inequalities (Pablo Costa Rico, *Letters in Mathematical Physics* 2025, DOI 10.1007/s11005-025-01935-y). Source Werner programme: Tejasvi Singh Tomar, *Undistillability of Werner states from three, four and five copies* (October 2026). Focused searches on 2026-10-28 did not locate this exact parity-kernel rigidity formulation; this is **not sufficient to establish publication priority**. This is a derived theorem with self-contained proof, independently checked finite examples, and outstanding external novelty/referee review.