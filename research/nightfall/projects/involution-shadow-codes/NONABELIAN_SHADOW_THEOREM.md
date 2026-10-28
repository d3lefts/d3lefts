# NIGHTFALL — Exact shadow codes beyond abelian groups

**Research lead:** Devin J. Wright  
**Independent agent extension:** 2026-10-28  
**Status:** self-contained algebraic theorem and tested finite computational instances; novelty across the worldwide coding-theory literature awaits a complete priority review. A machine proof assistant has not checked the universal quantifiers.

## Theorem (nonabelian involution-shadow distance and spectrum)

Let \(G\) be any finite group, with identity \(e\), and \(S:G\to G\) a **nonidentity involutive automorphism**. Let \(H=\operatorname{Fix}(S)\), \(h=|H|\), and \(q=|G|/h\ge 2\). For a length-\(m\) translation tuple \(T=(t_1,\ldots,t_m)\), encode a message \(x\in G\) by the tuple of orbit symbols

\[
 C_T(x)=\bigl([xt_1]_S,\ldots,[xt_m]_S\bigr),\qquad [z]_S=\{z,S(z)\}.
\]

Define the twisted translation label \(\delta(t)=S(t)t^{-1}\), its image \(D=\delta(G)\), and label occupancies \(n_c=\#\{j:\delta(t_j)=c\}\), for \(c\in D\). The minimum **message separation** is

\[
\boxed{\min_{x\ne y}d_H(C_T(x),C_T(y))=m-\max_{c\in D}n_c.}
\tag{1}
\]

If the minimum is zero, distinct messages have identical encoded words, so the separation zero is a statement about the encoding map. For positive minimum it equals the usual minimum code distance.

The label fibers are exactly the **right cosets** of \(H\), giving \(|D|=q\). Maximizing (1) over all translation tuples gives the sharp formula

\[
\boxed{\max_T d_{\min}(C_T)=m-\lceil m/q\rceil.}
\tag{2}
\]

Moreover the **ordered-pair Hamming-distance enumerator** is exactly

\[
\boxed{A_T(z)= (|G|-h)\sum_{c\in D}z^{m-n_c}+|G|(|G|-q)z^m.}
\tag{3}
\]

Here \([z^k]A_T(z)\) counts all ordered pairs of *distinct messages* whose output words are separated by distance \(k\). The formula includes distance-zero collisions when the encoder lacks injectivity. As a consequence, two such systems with equal \((|G|,h)\) and the same histogram of the \(q\) label occupancies have identical ordered-pair distance distributions even when their groups are algebraically different.

A balanced label allocation attains (2). It corrects up to \(\lfloor(d_{\min}-1)/2\rfloor\) adversarial symbol errors whenever \(d_{\min}>0\).

## Proof

**Lemma 1 (collision iff label equality).** For distinct \(x,y\), the orbit symbols at translation \(t\) are equal exactly when \(xt=S(yt)\); the other possibility \(xt=yt\) would force \(x=y\). Multiplying \(xt=S(y)S(t)\) by \(t^{-1}\), and then by \(S(y)^{-1}\), yields

\[
[xt]_S=[yt]_S \quad\Longleftrightarrow\quad S(y)^{-1}x=\delta(t).
\]

Thus, for fixed \(x\ne y\), every matching coordinate belongs to one and the same label class \(c=S(y)^{-1}x\).

**Lemma 2 (constant coset fibers).** Equality \(\delta(t)=\delta(u)\) is equivalent to
\[
 S(t)^{-1}S(u)=t^{-1}u,
\]
which says \(t^{-1}u\in H\). Hence all labels are in bijection with the right coset set \(G/H\); each class has \(h\) translation elements, and \(|D|=q\). No normality of \(H\) is assumed.

**Lemma 3 (every label attainable).** For \(c\in D\) with \(c\ne e\), take \(y=e\) and \(x=c\). For \(c=e\), choose \(y\) moved by \(S\), and put \(x=S(y)\ne y\). In both cases \(S(y)^{-1}x=c\). Therefore some pair of distinct messages realizes all \(n_c\) collisions of every label. Lemma 1 gives (1), and balancing \(m\) items over \(q\) available labels gives (2).

**Lemma 4 (exact multiplicity).** For any \(c\in G\), there are exactly \(|G|\) ordered pairs \((x,y)\), including diagonals, with \(S(y)^{-1}x=c\): one \(x=S(y)c\) for each \(y\). Such a pair is diagonal precisely when \(c=S(y)^{-1}y=\delta(y^{-1})\). By Lemma 2 this occurs for exactly \(h\) values of \(y\) when \(c\in D\), and zero when \(c\notin D\). Consequently every label \(c\in D\) is realized by exactly \(|G|-h\) distinct ordered message pairs at distance \(m-n_c\); each \(c\notin D\) accounts for \(|G|\) distinct pairs at distance \(m\). Summing proves (3). Indeed \(A_T(1)=|G|(|G|-1)\). **QED.**

## Structural distinction from the abelian case

For nonabelian \(G\), the coboundary image \(D\) need not be closed under multiplication and the fixed subgroup \(H\) need not be normal. Thus the effective label space is the **coset set** \(G/H\), not a quotient group. In \(S_4\), take \(S\) to be conjugation by the transposition \((12)\). Then \(|G|=24\), \(|H|=4\), \(q=6\), and \(D\) contains six elements yet is **not** a subgroup. The concrete S4 certificate has 13 balanced translations, distance exactly 10, and ordered-pair enumerator

\[
 A_T(z)=20z^{10}+100z^{11}+432z^{13}.
\]

Its 552 ordered distinct pairs are all explicitly checked against the orbit code. A second test uses an outer involution of the **nonabelian simple group \(A_5\)** induced by conjugation by an odd permutation in \(S_5\): \(|A_5|=60\), \(|H|=6\), \(q=10\), and the twisted-coboundary labels again fail to form a subgroup. This confirms that the extension applies to simple groups, beyond solvable structures.

## Theorem (simultaneous optimality under erasures and adversarial errors)

Retain a coordinate set \(J\subseteq\{1,\ldots,m\}\). The restricted measurement map \(x\mapsto ( [xt_j]_S )_{j\in J}\) is injective **if and only if** the retained coordinates contain at least **two distinct coboundary labels**.

**Proof.** If all surviving coordinates have label \(c\), Lemma 3 supplies a pair of distinct messages colliding in every such coordinate. If at least two different labels survive, Lemma 1 prevents any pair from agreeing in all surviving coordinates. This includes \(J=\varnothing\), whose measurement map is noninjective because \(|G|\ge 2\). **QED.**

For each retained cardinality \(r\), the exact number \(B_r\) of ambiguous surviving coordinate subsets is

\[
 B_0=1,\qquad \boxed{B_r=\sum_{c\in D}\binom{n_c}{r}\quad(1\le r\le m)}.
\tag{4}
\]

Here \(\binom nr=0\) for \(n<r\). If \(m=aq+b\), \(0\le b<q\), the minimum of **every** \(B_r\), taken simultaneously over all translation designs, is

\[
 \boxed{B_r^*=(q-b)\binom a r+b\binom{a+1}{r}}\qquad(r\ge1).
\tag{5}
\]

**Proof of global optimality.** If two label occupancies satisfy \(u\ge v+2\), transfer one measurement from the larger class to the smaller. At each size \(r\ge1\), the change in the objective is

\[
\bigl[\binom{u-1}{r}+\binom{v+1}{r}\bigr]-\bigl[\binom u r+\binom v r\bigr]
= -\binom{u-1}{r-1}+\binom v{r-1}\le 0.
\]

Repeated transfers yield the balanced occupancy vector (5), without increasing any \(B_r\). Thus the same balanced design that maximizes worst-case Hamming distance also minimizes **every fixed-cardinality erasure ambiguity probability** \(B_r/\binom mr\) and, by taking nonnegative mixtures across cardinalities, the failure probability for **every independent erasure survival probability**. **QED.**

For independent survival probability \(p\in(0,1)\), the exact failure probability is

\[
 \boxed{P_{\rm fail}(p)=(1-p)^m\bigl[1-q+\sum_{c\in D}(1-p)^{-n_c}\bigr]}.
\tag{6}
\]

The expression extends continuously to \(p=0,1\). A universal guarantee under an arbitrary adversarial erasure pattern holds whenever at most \(d_{\min}-1\) symbols disappear. The same measurement allocation is optimal for both adversarial symbol corruption and every cardinality of random erasures.

**Machine audit of the nonabelian \(S_4\) example.** A separate verifier enumerated all \(2^{13}=8,192\) surviving coordinate subsets and compared the actual encoded messages, finding \(B_0=1\), \(B_1=13\), \(B_2=8\), \(B_3=1\), and \(B_r=0\) for \(r\ge4\). It exhaustively compared all \(\binom{18}{5}=8,568\) occupancy vectors of total 13 across six labels: exactly six allocations (choice of the one size-three label) tie for simultaneous optimality.

## Machine-verification record

- **Fourteen test actions:** inversions on four cyclic groups, \(S_3\), \(S_4\), outer involutions on \(A_4\) and the nonabelian simple group \(A_5\), four dihedral groups, and two involutions of \(Q_8\).
- **20,736 translation tuples**, including every ordered tuple of lengths 1–5 for \(S_3\) and \(D_6\).
- **1,417,256 ordered distinct message pairs** explicitly checked; every full distance enumerator matched (3).
- Independently, `certify_cayley_instance.py` verifies the Cayley table's group axioms, the involution's homomorphism law, the exact orbit words and the entire spectrum of the separate \(S_4\) instance, requiring only Python's standard library. Seven mutated inputs are rejected.
- To reproduce: `python3 verify_nonabelian.py`, `python3 certify_cayley_instance.py S4_certificate.json`, `python3 adversarial_controls.py`, `python3 verify_erasure_optimality.py`.
- Exact source hashes and runtime output are frozen in `MANIFEST.json` and `audit_result.json`.

## Claims, limits, and prior art

1. **Proved in this note:** all finite groups with a nontrivial involutive automorphism satisfy (1)–(6), including the simultaneous optimization of distance and erasure resilience. No conjectural assumption enters the algebra.
2. **Computational scope:** finite instances and explicit corrupted-certificate checks are reproducible; the universal proof is written mathematics, not a Lean/Coq kernel certificate.
3. **Novelty scope:** the October 13 NIGHTFALL manuscript addressed finite *abelian* groups. This is a new, concrete nonabelian extension within that program. Twisted automorphism actions, group coboundaries and related orbit/permutation codes have established prior art. An initial literature search has not identified this precise three-equation package, yet this is insufficient for a worldwide originality declaration.
4. **Security scope:** minimum distance gives classical error correction bounds; it proves no cryptographic one-wayness, discrete-logarithm attack, or quantum advantage.

### Relevant literature for eventual priority checking

- An and Wang, *Nonabelian cohomology with coefficients in Lie groups* (twisted orbit/coboundary framework): https://www.researchgate.net/publication/2120775_Nonabelian_cohomology_with_coefficients_in_Lie_groups
- Bailey et al., *Increasing the minimum distance of codes by twisting*, Electronic Journal of Combinatorics 25(3), 2018: https://www.combinatorics.org/ojs/index.php/eljc/article/download/v25i3p36/pdf/
- Gluesing-Luerssen and Lehmann, *Automorphism groups and isometries for cyclic orbit codes*, Advances in Mathematics of Communications 17(1), 2023: https://www.aimsciences.org/article/doi/10.3934/amc.2021040
- NIGHTFALL Part I & II original finite abelian shadow-code construction: `research/nightfall/projects/involution-shadow-codes/`.