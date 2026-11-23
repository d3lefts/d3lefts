# Universal equivariant causal-obstruction theory: arbitrary group certificates, odd nonlinear sensors, and architecture-free even observations

**NIGHTFALL author-side research manuscript v1.0 — 2026-11-22, America/Chicago.**

**Status:** Complete paper proofs of the precisely quantified theorems below, using standard vector-bundle obstruction theory, characteristic classes, Tietze extension, and elementary causality. **Not independently refereed, not Lean-certified, and not globally novelty-certified.** The underlying equivariant zero theorem is classical. The previously written continuous even-*linear block* sensing theorem and causal virtual-history mechanism occur in NIGHTFALL PR #1148 and earlier PR #995/#1000; this paper adds (i) genuinely nonlinear **odd** sensing operators while preserving the sharp two-bin sensor-dimension obstruction, (ii) an **architecture-free** theorem for arbitrary continuous even measurements with an exact binary-cohomology cutoff, and (iii) a general compact-group causal-certificate transfer theorem accommodating arbitrary continuous output spaces. Do not represent the abstract transfer theorem as a claim that every measurement architecture has the necessary certificate.

## 1. Universal framework: equivariant causal certificates

**Definition 1 (causal consensus certificate).** Let \(G\) be a compact Lie group, \(Z\ne\varnothing\) a compact metrizable space with a continuous free \(G\)-action, and \(X\) a topological signal space. Let \(p_+,p_-:Z\to X\) be continuous and suppose \(p_+(z)\not\sim p_-(z)\) for an intended signal-equivalence relation \(\sim\), for every \(z\).

A length-\(m\) causal protocol has arbitrary topological observation spaces \(Y_j\), history spaces \(H_0=\{()\}\), \(H_j=Y_1\times\cdots\times Y_j\), and continuous stage rules
\[
 F_j:H_{j-1}\times X\longrightarrow Y_j,\qquad
 T_0(x)=(),\quad T_j(x)=\bigl(T_{j-1}(x),F_j(T_{j-1}(x),x)\bigr).
\tag{1.1}
\]
At each stage assume a finite-dimensional real representation \(W_j\) of \(G\), a continuous **equivariant obstruction**
\[
 \kappa_j:H_{j-1}\times Z\to W_j,
\quad\kappa_j(h,gz)=g\cdot\kappa_j(h,z),
\tag{1.2}
\]
and a continuous **invariant consensus response**
\[
 \eta_j:H_{j-1}\times Z\to Y_j,
\quad\eta_j(h,gz)=\eta_j(h,z),
\tag{1.3}
\]
such that, for every \(h,z\),
\[
 \kappa_j(h,z)=0
 \quad\Longrightarrow\quad
 F_j(h,p_+(z))=F_j(h,p_-(z))=\eta_j(h,z).
\tag{1.4}
\]
The group acts trivially on histories. These hypotheses encode an actual testable stagewise equality mechanism; **evenness alone is not assumed here**.

Let \(W=\bigoplus_jW_j\), \(D=\dim_{\mathbb R} W\), \(B=Z/G\), and let \(E=Z\times_GW\to B\) be the associated vector bundle.

**Theorem 2 (universal equivariant causal-obstruction principle).** If
\[
 w_D(E)\ne0\quad\text{in }H^D(B;\mathbb F_2),
\tag{1.5}
\]
then there is \(z\in Z\) with
\[
 T_m(p_+(z))=T_m(p_-(z)),\qquad p_+(z)\not\sim p_-(z).
\tag{1.6}
\]
If \(D=0\), read (1.5) as \(w_0(E)=1\ne0\), which holds since \(B\ne\varnothing\).

**Proof.** Define a virtual history \(q_0(z)=()\) and recursively
\[
 q_j(z)=\bigl(q_{j-1}(z),\eta_j(q_{j-1}(z),z)\bigr).
\tag{1.7}
\]
The maps \(q_j\) are continuous and \(G\)-invariant by induction using (1.3). Therefore
\[
 K(z)=\bigoplus_{j=1}^m\kappa_j(q_{j-1}(z),z)\in W
\tag{1.8}
\]
is a continuous \(G\)-equivariant map. If \(D>0\) and \(K\) were nowhere zero, it would descend to a nowhere-zero section of \(E\); after choosing a bundle metric, that section splits a trivial real line from \(E\), making \(w_D(E)=0\) by the Whitney formula. This contradicts (1.5). If \(D=0\), \(K=0\) identically. Thus some \(z\) satisfies **every** \(\kappa_j(q_{j-1}(z),z)=0\).

We prove \(T_j(p_+(z))=T_j(p_-(z))=q_j(z)\) by induction. At stage zero this is immediate. When true at stage \(j-1\), both actual signals use exactly \(h=q_{j-1}(z)\) in (1.1); applying (1.4) gives the same stage output \(\eta_j(h,z)\), so the equality persists. At \(j=m\) it gives (1.6). The pairs were assumed inequivalent. \(\square\)

**Metric strengthening.** If \(X\) is a metric space, \(\sim\) identifies the orbits of an isometric involution \(\tau\), and
\[
 \delta:=\inf_{z\in Z}
  \min\{d(p_+(z),p_-(z)),\,d(p_+(z),\tau p_-(z))\}>0,
\tag{1.9}
\]
then any decoder from the common transcript to \(X/\tau\) has worst-case quotient-metric error at least \(\delta/2\) on the candidate inputs. This follows immediately from (1.6) and the triangle inequality; the decoder need not be continuous.

**Mathematical boundary.** The theorem allows arbitrary compact Lie symmetry groups and arbitrary observation spaces \(Y_j\), **provided the specific stagewise certificate exists**. It does not assert existence of \(\kappa_j,\eta_j\) for an arbitrary measurement rule. The results below show two substantial, non-tautological families in which those certificates can be built explicitly.

## 2. Genuinely nonlinear odd sensing operators — the sharp pure-character obstruction

Let \(n\ge1\), \(m\ge0\), \(d_j,\ell_j\ge0\), and \(L_j=\sum_{i\le j}\ell_i\). Denote by
\[
 H_j=T_j(\mathbb R^n)\subseteq\mathbb R^{L_j}
\]
the set of **actually attainable** histories with its subspace topology.

At stage \(j\), assume continuous maps
\[
 A_j:H_{j-1}\times\mathbb R^n\longrightarrow\mathbb R^{d_j},
 \qquad
 \Phi_j:H_{j-1}\times\mathbb R^{d_j}\longrightarrow\mathbb R^{\ell_j},
\tag{2.1}
\]
with no linearity or homogeneity assumption, satisfying **only**
\[
 A_j(h,-x)=-A_j(h,x),\qquad
 \Phi_j(h,-z)=\Phi_j(h,z).
\tag{2.2}
\]
The actual output is \(y_j(x)=\Phi_j(T_{j-1}(x),A_j(T_{j-1}(x),x))\) and is appended to the history.

**Theorem 3 (nonlinear odd-operator causal universality).** Suppose stages admit a partition \(U\sqcup V=\{1,\ldots,m\}\) with
\[
 r=\sum_{j\in U}d_j\le n-1,\qquad
 s=\sum_{j\in V}d_j\le n-1.
\tag{2.3}
\]
For every \(R>0\) there exist \(x_+,x_-\in\overline B_{\mathbb R^n}(0,R)\) such that
\[
 T_m(x_+)=T_m(x_-),\qquad
 d_\pm(x_+,x_-)
 :=\min(\|x_+-x_-\|,\|x_++x_-\|)=R.
\tag{2.4}
\]
Thus every decoder has worst-case projective Euclidean error at least \(R/2\) on that ball. This holds for **all continuous history-dependent odd nonlinear operators**, not only for matrices \(B_j(h)x\).

### 2.1 Compact extension of attainable-only nonlinear policies

Fix \(R>0\) and \(K=\overline B(0,R)\). By induction the actual transcript maps \(T_j:\mathbb R^n\to\mathbb R^{L_j}\) are continuous: their stage rules are continuous on the subspace \(H_{j-1}\), and the previous transcript maps into that subspace. Hence
\[
 C_{j-1}=T_{j-1}(K)
\]
is compact, so closed in the full Euclidean history space.

The restriction of \(A_j\) to \(C_{j-1}\times K\) is bounded and continuous, and this set is compact and invariant under \((h,x)\mapsto(h,-x)\). Extend each scalar coordinate by the bounded Tietze theorem to a continuous \(F_j\) on all \(\mathbb R^{L_{j-1}}\times\mathbb R^n\). Put
\[
 \widetilde A_j(h,x)=\frac{F_j(h,x)-F_j(h,-x)}2.
\tag{2.5}
\]
Then \(\widetilde A_j\) is globally continuous, odd in \(x\), and agrees with the original \(A_j\) on \(C_{j-1}\times K\) by (2.2).

Choose \(M_j\ge0\) such that
\(\|A_j(h,x)\|\le M_j\) on \(C_{j-1}\times K\).
The set
\[
 D_j=C_{j-1}\times\overline B_{\mathbb R^{d_j}}(0,M_j)
\]
is compact, closed, and invariant under \((h,z)\mapsto(h,-z)\). Apply bounded Tietze coordinatewise to \(\Phi_j|_{D_j}\), obtaining a globally continuous \(P_j\), and set
\[
 \widetilde\Phi_j(h,z)
 =\frac{P_j(h,z)+P_j(h,-z)}2.
\tag{2.6}
\]
This is globally continuous, even in \(z\), and coincides with \(\Phi_j\) on \(D_j\).

Build the resulting **globally defined** protocol \(\widetilde T\). At every \(x\in K\), induction gives \(\widetilde T_j(x)=T_j(x)\): the previous histories coincide and lie in \(C_{j-1}\), the operator agrees at \((h,x)\), and its value has norm at most \(M_j\), where the detector also agrees. Thus
\[
 \widetilde T_m|_K=T_m|_K.
\tag{2.7}
\]
No assumption that the full unbounded attainable-history space is closed is made. If \(d_j=0\) or \(\ell_j=0\), the coordinatewise extension is empty/unique and the argument remains valid.

### 2.2 An exact nonlinear polarization and the two antipodal characters

For the remainder of the proof use globally extended \(\widetilde A_j,\widetilde\Phi_j\), suppressing tildes for readability.

Put \(\rho=R/2\). For unit \(u,v\in S^{n-1}\), define the fixed candidate pair
\[
 x_+(u,v)=\rho(u+v),\qquad
 x_-(u,v)=\rho(u-v).
\tag{2.8}
\]
Choose an arbitrary history \(h\in\mathbb R^{L_{j-1}}\). Define
\[
 Z_+(h,u,v)=A_j(h,x_+(u,v)),\quad
 Z_-(h,u,v)=A_j(h,x_-(u,v)),
\]
and their **exact nonlinear polarization**
\[
 P_j(h,u,v)=\tfrac12(Z_++Z_-),\qquad
 Q_j(h,u,v)=\tfrac12(Z_+-Z_-).
\tag{2.9}
\]
Always, without additivity or differentiability,
\[
 Z_+=P_j+Q_j,\qquad Z_-=P_j-Q_j.
\tag{2.10}
\]

The essential point is that (2.9) inherits **pure** antipodal characters from the oddness of \(A_j\). Under \(u\mapsto-u\), the physical candidates transform as
\[
 (x_+(-u,v),x_-(-u,v))=(-x_-(u,v),-x_+(u,v)).
\]
Oddness therefore makes \((Z_+,Z_-)\mapsto(-Z_-,-Z_+)\), hence
\[
 P_j(h,-u,v)=-P_j(h,u,v),\qquad
 Q_j(h,-u,v)=Q_j(h,u,v).
\tag{2.11}
\]
Under \(v\mapsto-v\), the candidates exchange without a global sign:
\[
 (x_+(u,-v),x_-(u,-v))=(x_-(u,v),x_+(u,v)),
\]
so
\[
 P_j(h,u,-v)=P_j(h,u,v),\qquad
 Q_j(h,u,-v)=-Q_j(h,u,v).
\tag{2.12}
\]
All these identities hold for **arbitrary** \(h\), including a virtual history that no physical signal generates.

### 2.3 Virtual history, product-sphere zero, and exact physical collision

Recursively set \(q_0(u,v)=()\). Suppose \(q_{j-1}\) is continuous and invariant under both sign flips; evaluate (2.9) at \(h=q_{j-1}(u,v)\). If \(j\in U\), set
\[
 \kappa_j(u,v)=P_j(q_{j-1},u,v),\qquad
 q_j=(q_{j-1},\Phi_j(q_{j-1},Q_j(q_{j-1},u,v))).
\tag{2.13U}
\]
If \(j\in V\), set
\[
 \kappa_j(u,v)=Q_j(q_{j-1},u,v),\qquad
 q_j=(q_{j-1},\Phi_j(q_{j-1},P_j(q_{j-1},u,v))).
\tag{2.13V}
\]
By (2.11)–(2.12), each \(U\) obstruction has \(u\)-odd/\(v\)-even character and each \(V\) obstruction has \(u\)-even/\(v\)-odd character. The appended virtual response is invariant under both flips, by (2.2) and the corresponding parity of \(P_j,Q_j\). Therefore the induction closes and \(q_j\) is indeed continuous and separately even.

Concatenate all \(U\) obstructions to a continuous
\(g_U:S^{n-1}\times S^{n-1}\to\mathbb R^r\) and all \(V\) obstructions to
\(g_V:S^{n-1}\times S^{n-1}\to\mathbb R^s\).
They obey the two **independent** antipodal characters. Let
\[
 B=\mathbb RP^{n-1}\times\mathbb RP^{n-1},\quad
 E=L_U^{\oplus r}\oplus L_V^{\oplus s}\to B.
\]
The quotient cohomology ring is
\[
 H^*(B;\mathbb F_2)=
 \mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n),
\]
and by Whitney's formula
\[
 w_{r+s}(E)=\alpha^r\beta^s\ne0
\tag{2.14}
\]
precisely because of (2.3). For \(r+s=0\), all obstructions are zero identically. Otherwise a nowhere-zero equivariant map would yield a nowhere-zero section of \(E\), forcing (2.14) to vanish. Thus there exist unit \(u,v\) with **every** \(\kappa_j(u,v)=0\).

At that pair, prove by induction that both actual extended transcripts equal \(q_j(u,v)\). At a \(U\)-stage, the vanishing \(P_j=0\) and (2.10) give \(Z_\pm=\pm Q_j\); the even detector returns the same \(\Phi_j(q_{j-1},Q_j)\) as in (2.13U). At a \(V\)-stage, vanishing \(Q_j=0\) gives \(Z_+=Z_-=P_j\), so both readings equal (2.13V). At every stage the actual histories coincide with the virtual input history and therefore the same operator/detector are used. Hence
\[
 \widetilde T_m(x_+(u,v))=\widetilde T_m(x_-(u,v)).
\tag{2.15}
\]
The candidates have \(\|x_\pm\|\le R\); (2.7) transfers (2.15) to the **original attainable-only protocol**.

Finally
\[
 x_+-x_-=2\rho v=Rv,\qquad x_++x_-=2\rho u=Ru,
\]
so \(d_\pm(x_+,x_-)=R\). The quotient-metric triangle inequality yields reconstruction error at least \(R/2\) for any decoder. \(\blacksquare\)

**Strict scope extension.** The operator \(A_j(h,x)\) can include terms such as \(\sin(b(h)\cdot x)\), \( (a(h)\cdot x)^3\), \(\|x\|^2\,c(h)\cdot x\), or genuinely multi-coordinate odd neural-network maps, selected continuously from the entire prior transcript. The proof uses **only continuity and oddness**, not that \(A_j\) factors through any linear matrix block.

**Corollary 4 (sharp real scalar intensity threshold).** If each \(d_j=\ell_j=1\), \(A_j(h,x)=a_j(h)\cdot x\) and \(\Phi_j(h,z)=z^2\), then fewer than \(2n-1\) readings cannot universally recover \(x\) modulo global sign when \(n\ge2\). The same lower bound holds for arbitrary continuous **odd nonlinear scalar** sensors with continuous even scalar readouts.

For ordinary squared-linear measurements, \(2n-1\) fixed measurements suffice: choose distinct real \(t_1,\ldots,t_{2n-1}\) and Vandermonde sensing rows
\[
 a(t_j)=(1,t_j,\ldots,t_j^{n-1}).
\]
Any \(n\) such rows are independent. If two inputs have the same squared readings, then for each \(j\),
\[
 (a(t_j)\cdot(x-y))(a(t_j)\cdot(x+y))=0.
\]
Partition the \(2n-1\) indices according to which factor vanishes (assign ties arbitrarily). One side has at least \(n\) rows; full spark implies \(x=y\) or \(x=-y\). Consequently the ordinary continuous-causal *linear-intensity* optimal threshold is exactly \(2n-1\). We **do not** assert every even nonlinear detector family attains the matching upper bound: that depends on the permitted detectors.

**Two-bin sufficient arithmetic test.** If \(S=\sum_jd_j\), \(M=\max_jd_j\) (with \(M=0\) for \(m=0\)), and \(S\le2(n-1)+1-M\), a split (2.3) exists. When \(S\le n-1\), place everything in one bin. Otherwise take the shortest chronological prefix with sum at least \(S-(n-1)\); it has sum at most \(S-(n-1)-1+M\le n-1\), and its complement also sums to at most \(n-1\). This is sufficient but not necessary; **exact** two-bin feasibility is the sharp certificate criterion for (2.14).

## 3. Architecture-free universality: arbitrary continuous even transcripts

The previous theorem requires the nonlinear sensor to be odd *before* its even detector. We now remove the sensing-operator structure entirely, keeping only global sign symmetry of the **resulting observations**.

Let \(X\) be a topological space with continuous involution \(\tau:X\to X\), and let \(G\) be a compact Lie group acting freely on a nonempty compact metrizable \(Z\). Suppose continuous pair maps \(p_\pm:Z\to X\) satisfy
\[
 p_\epsilon(gz)
   =\tau^{a(g)}p_{\sigma_g(\epsilon)}(z),
\qquad
 \epsilon\in\{+,-\},
\tag{3.1}
\]
where \(a:G\to\mathbb Z/2\) and \(b:G\to\mathbb Z/2\) are continuous homomorphisms, and \(\sigma_g\) swaps the two labels exactly when \(b(g)=1\). Let \(\chi(g)=(-1)^{b(g)}\) be the swapping sign character and \(L_\chi=Z\times_G\mathbb R_\chi\to Z/G\) its real associated line bundle.

**Theorem 5 (architecture-free even-observation obstruction).** Let \(T:X\to\mathbb R^D\) be **any** continuous \(\tau\)-invariant observation map, \(T(\tau x)=T(x)\). If \(D=0\), some pair has equal observations trivially. For \(D>0\), if
\[
 \bigl(w_1(L_\chi)\bigr)^D\ne0
    \quad\text{in }H^D(Z/G;\mathbb F_2),
\tag{3.2}
\]
then some \(z\in Z\) satisfies
\[
 T(p_+(z))=T(p_-(z)).
\tag{3.3}
\]
This includes **every continuous causal protocol of arbitrary sensing architecture** whose full transcript is \(\tau\)-invariant and has \(D\) real scalar coordinates. No sensor decomposition, linearity, odd lifting, detector factorization, or continuous global sensing direction is assumed.

**Proof.** Define
\[
 \Delta(z)=T(p_+(z))-T(p_-(z))\in\mathbb R^D.
\]
By (3.1), \(\tau\)-invariance, and whether \(\sigma_g\) swaps the labels,
\[
 \Delta(gz)=\chi(g)\Delta(z).
\]
Thus \(\Delta\) is \(G\)-equivariant into the \(D\)-fold sign representation \(\mathbb R_\chi^{\oplus D}\). It descends to a section of \(L_\chi^{\oplus D}\), whose top Stiefel–Whitney class is exactly (3.2). A nowhere-zero section would force that class to vanish. Therefore \(\Delta(z)=0\) for some \(z\). \(\square\)

**Why causality does not restrict Theorem 5.** For any continuous stage rules on attained histories, the actual transcript is continuous by induction. If each actual stage is invariant under \(\tau\) whenever the preceding history is invariant, the full transcript is also \(\tau\)-invariant. The theorem is therefore applicable without extending an inaccessible virtual history. Its numerical bound is generally **weaker** than Theorem 3, precisely because Theorem 3 uses additional odd-sensor structure.

### 3.1 Universal, explicit Euclidean output cutoff

Take \(X=\mathbb R^n\), \(\tau x=-x\),
\(Z=S^{n-1}\times S^{n-1}\), \(G=(\mathbb Z/2)^2\), and, for \(R>0\),
\[
 p_\pm(u,v)=\frac R2(u\pm v).
\tag{3.4}
\]
The first generator \(u\mapsto-u\) sends \((p_+,p_-)\) to \((-p_-,-p_+)\), and the second \(v\mapsto-v\) sends it to \((p_-,p_+)\). Thus \(a\) is the first character and \(b\) the sum of the first and second characters. On the quotient
\[
 B=\mathbb RP^{n-1}\times\mathbb RP^{n-1},
 \quad H^*(B;\mathbb F_2)=
   \mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n),
\]
the swapping line has \(w_1(L_\chi)=\alpha+\beta\).

**Corollary 6 (binary-height architecture-free bound).** Let \(n\ge1\) and let
\[
 N(n)=\min\{2^k:k\ge0,\ 2^k\ge n\}.
\]
For every \(R>0\) and every continuous even map
\(T:\mathbb R^n\to\mathbb R^D\) with \(D<N(n)\), there are
\(x_\pm\in\overline B(0,R)\) with
\[
 T(x_+)=T(x_-),\qquad d_\pm(x_+,x_-)=R.
\tag{3.5}
\]
Thus **any** continuous adaptive measurement architecture with an even full transcript and fewer than \(N(n)\) scalar real outputs has minimax projective error at least \(R/2\).

**Proof.** Theorem 5 applies whenever \((\alpha+\beta)^D\ne0\) in the indicated truncated cohomology ring. We show the exact cutoff.

If \(n=1\), \(N(n)=1\). Only \(D=0\) satisfies \(D<N(n)\); the constant empty transcript makes (3.5) immediate.

For \(n>1\), choose the least integer \(k\ge1\) with \(2^k\ge n\). Then \(2^{k-1}<n\le2^k\). In characteristic two the Frobenius identity gives
\[
 (\alpha+\beta)^{2^k}=\alpha^{2^k}+\beta^{2^k}=0
 \quad\text{mod }(\alpha^n,\beta^n).
\tag{3.6}
\]
On the other hand, at \(D=2^k-1\), every binomial coefficient \(\binom{2^k-1}{a}\) is odd, by Lucas's parity theorem (or the product
\(\prod_{j=0}^{k-1}(\alpha^{2^j}+\beta^{2^j})\)).
In particular the monomial
\[
 \alpha^{2^{k-1}-1}\beta^{2^{k-1}}
\tag{3.7}
\]
has coefficient one, and both exponents are strictly below \(n\). Distinct monomials are independent in the truncated polynomial ring, so
\((\alpha+\beta)^{2^k-1}\ne0\). If any lower nonnegative power vanished, multiplying by a suitable further power of \((\alpha+\beta)\) would make the \(2^k-1\) power vanish too. Therefore
\[
 (\alpha+\beta)^D\ne0
 \quad\Longleftrightarrow\quad 0\le D<2^k=N(n)
\tag{3.8}
\]
for this particular obstruction class. Theorem 5 gives the collision; (3.4) yields \(d_\pm=R\), as in Theorem 3. \(\square\)

**Interpretation and sharpness boundary.** Equation (3.8) is an **exact threshold for this characteristic-class certificate**, *not* the exact embedding dimension of \(\mathbb RP^{n-1}\), nor the exact minimal number of arbitrary even scalar outputs needed to recover a signal. For example, at \(n=4\) it detects collisions for \(D\le3\), whereas odd-scalar sensing in Theorem 3 detects collisions through **six** stages. Vanishing at \(D=4\) does not imply recovery becomes possible there.

### 3.2 Arbitrary topological output targets: the deleted-square criterion

Theorem 5 also has a universal, target-independent formulation. Let \(Y\) be **any Hausdorff topological space** and let \(T:X\to Y\) be continuous and \(\tau\)-invariant. Write
\[
 \operatorname{Conf}_2(Y)
  =\{(y_+,y_-)\in Y\times Y:y_+\ne y_-\},
\]
with involution swapping the coordinates. If no \(G\)-equivariant continuous map
\[
 Z\longrightarrow \operatorname{Conf}_2(Y)
\tag{3.9}
\]
exists, where \(G\) acts on the target through the swap character \(b\), then some candidate pair has equal observations.

**Proof.** If all observations of the candidate pairs were different, then
\[
 z\longmapsto(T(p_+(z)),T(p_-(z)))
\]
would be a continuous map into \(\operatorname{Conf}_2(Y)\) and would be \(G\)-equivariant by (3.1) and \(\tau\)-invariance, contradicting the absence of (3.9). \(\square\)

This statement is deliberately a **topological reduction**, not a claimed computable nonexistence test for arbitrary \(Y\). In Euclidean output spaces, the Stiefel–Whitney criterion (3.2) provides an explicit sufficient certificate; for other \(Y\), its configuration-space equivariant index or other independently proved obstructions must be supplied.

## 4. Group-general mathematical transfer and explicit limitations

**Corollary 7 (general representation-valued causal testing).** Under Theorem 2, \(G\) may be any compact Lie group and the \(W_j\) may be arbitrary finite-dimensional real representations. Their direct sum yields a genuine associated vector bundle, and a nonzero top Stiefel–Whitney class is sufficient to force a causal collision. For a product-of-spheres action of \(G=(\mathbb Z/2)^q\) with character blocks \(W_j=\mathbb R^{d_j}_{c_j}\), the class has the exact polynomial certificate
\[
 P=\prod_j\left(\sum_{a=1}^q(c_j)_a\alpha_a\right)^{d_j}
 \quad\text{in}\quad
 \mathbb F_2[\alpha_1,\ldots,\alpha_q]/
 (\alpha_1^{n_1},\ldots,\alpha_q^{n_q}).
\tag{4.1}
\]
If \(P\ne0\) **and** the stagewise \(\kappa_j,\eta_j\) exist for the specified sensing architecture, Theorem 2 gives a collision. The polynomial is a sufficient obstruction, not a claim that every character assignment can be realized causally.

**Proof.** For a character vector \(c_j\), its real associated line bundle is
\(L_{c_j}=\bigotimes_{a:(c_j)_a=1}L_a\). The first Stiefel–Whitney class is \(\sum_a(c_j)_a\alpha_a\); Whitney's product formula yields (4.1) for the top class of the direct sum. Apply Theorem 2. \(\square\)

**Necessary limits, with concrete counterexamples.**

1. **Completely unrestricted measurements defeat any universal impossibility statement.** The continuous identity readout \(T(x)=x\) in \(n\) real coordinates perfectly recovers \(x\) (hence modulo sign) and is not even in \(x\). The obstruction cannot apply without the relevant symmetry.
2. **Even measurements can recover with sufficient richness.** One continuous even measurement \(T(x)=xx^\top\), valued in the \(n(n+1)/2\)-dimensional space of symmetric matrices, is injective modulo \(\pm\). Indeed \(xx^\top=yy^\top\) implies \(x=y=0\) or the nonzero rank-one ranges coincide and \(y=\pm x\). This avoids the low-dimensional hypotheses of the obstruction.
3. **Oddness of the sensor is essential for the stronger two-colour conclusion.** A general even stage response \(F_j(h,x)\) has only the **mixed** difference character under (3.4), not the two independent pure characters constructed by the nonlinear polarization (2.9). Treating it as pure would be an invalid strengthening.
4. **Projective hardware may not admit a signed continuous lift.** A continuous choice of unoriented sensing lines or projectors can fail to define any global odd operator \(A_j(h,x)\) with the hypothesized continuity. Theorem 3 does not silently include such a sensor. Theorem 5 still applies to its continuous even full transcript when the mixed-character class is nonzero.
5. **A vanishing characteristic class is not a recovery construction.** The top class provides a one-way obstruction. If it vanishes, other characteristic classes, deleted-product obstructions, or geometric constraints may still prevent identification.
6. **Non-Euclidean outputs require actual topology.** Theorem 2 does not require Euclidean output spaces if full-history stage rules and consensus certificates are supplied. The attainable-only Tietze extension in Theorem 3 requires Euclidean coordinate targets (or a separately justified extension property); it cannot simply be applied to arbitrary topological observation spaces.

## 5. Independent attack plan, reproducibility, and priority boundary

**Primary derivation graph.** Free equivariant candidate-pair space \(\to\) stagewise virtual-history invariance and annihilator representations \(\to\) associated vector bundle \(\to\) nonzero top class \(\to\) simultaneous stagewise annihilation \(\to\) genuine causal transcript collision \(\to\) quantitative reconstruction obstruction. Separate branches: (a) arbitrary continuous odd operators give pure characters by exact nonlinear polarization, and (b) arbitrary even transcripts give a mixed swap character and binary-height cutoff.

**Proof attack checklist.** Independently challenge: (i) the *pair transformation* for \(u\)-flip, especially the extra global minus sign; (ii) parities of \(P_j\) and \(Q_j\) when \(A_j\) is **nonlinear**; (iii) invariance of virtual histories under both flips; (iv) the fact that the zero condition produces the exact detector input at each stage; (v) compact Tietze extension of \(A_j\) in **both** history and signal variables, preserving oddness only on the symmetric compact set; (vi) the detector extension on an input ball of sufficient radius \(M_j\); (vii) the \(R\)-separation and projective metric triangle inequality; (viii) the nonzero class and edge case \(n=1,D=0\); (ix) Lucas's binary parity and exact cutoff; and (x) zero-dimensional stage blocks and arbitrary time order. A computer check of polynomial arithmetic can falsify mistakes in the binary cutoff but cannot certify the topology.

**Novelty and credit.** The product-sphere equivariant zero lemma, characteristic-class computation, and general associated-bundle obstruction are classical; see Chan, Chen, Frick, and Hull (2020), *Borsuk–Ulam theorems for products of spheres and Stiefel manifolds revisited*, arXiv:1902.00935, building on Ramos. Mario Ullrich, *A Borsuk–Ulam theorem for adaptive continuous measurements*, arXiv:2610.33781 (2026), treats adaptive continuous functionals in a different model; a specialist same-model comparison is not yet complete. NIGHTFALL PR #995 and its independent audit #1000 contain the preceding continuous linear-row causal lower bound and even-*linear block* Theorem B; PR #1148 presents its repaired compact extension, quantitative \(R/2\) bound, and multicharacter statement. This manuscript strengthens the **sensor** hypothesis from continuous linear blocks to **arbitrary continuous odd nonlinear operators** by (2.9), and separates an architecture-free mixed-character theorem from the stronger pure-character causal theorem. No claim of first discovery or competitive record is made without a dated comprehensive prior-art search and independent human review.

**Verification and certification status.** The displayed arguments are complete author-side paper proofs using foundational named theorems, not arbitrary unproved obstruction hypotheses. Theorem 2's \(w_D(E)\ne0\) is an **explicit sufficient condition** which is discharged concretely in Theorem 3 and Corollary 6. Theorem 3's mathematical validity is not equivalent to, and does not establish, a fully compiled Lean theorem. A separate NIGHTFALL author-side unconditional paper proof of the pure-character product-sphere topology is in PR #1147; the classical characteristic-class route is also given directly above. Formalization, adversarial review, and novelty assessment are separate completion gates.
