# Infinite-product Q2 from the certified finite theorem: paper closure

**Research note, 2026-11-17.** Status: **author-analytic proof (human-led, AI-assisted), NOT an end-to-end Lean certificate.** It reduces the arbitrary infinite-product degree-two influence inequality to the kernel-certified finite heterogeneous theorem `native_heterogeneous_q2_105416_unconditional` plus standard measure theory, and maps each step to the Lean file that already certifies it or to the gate still open. Independent human review, priority and novelty are **not** established.

## 1. Statement

Let \(I\) be any index set (possibly uncountable) and \((X_i,\Sigma_i,\mu_i)\), \(i\in I\), arbitrary probability spaces. Let \(\mu=\bigotimes_i\mu_i\) (`Measure.infinitePi μ`) on \(\Omega=\prod_i X_i\), and write \(X_i\) also for the coordinate map.

For a sub-σ-algebra \(\mathcal H\), \(E_{\mathcal H}\) is the orthogonal projection of \(L^2(\mu)\) onto \(L^2(\mathcal H)\) (`condExpL2`). Put

- \(\Sigma_{-i}=\sigma(X_j:j\ne i)\), \(Q_i=E_{\Sigma_{-i}}\), \(R_i=\mathrm{Id}-Q_i\);
- \(I_i(f)=\|R_if\|_2^2\) (`sourceCoordinateInfluence`), \(\operatorname{Var}(f)=\|f\|_2^2-(\int f\,d\mu)^2\) (`sourceL2Variance`);
- \(\mathcal G_F=\sigma(X_i:i\in F)\) and \(P_F=E_{\mathcal G_F}\) for finite \(F\subseteq I\).

**Degree at most two.** \(f\in L^2(\mu)\) has degree \(\le2\) if \(R_iR_jR_kf=0\) for all pairwise distinct \(i,j,k\in I\). (By Lemma 1 the \(R_i\) commute, so this is the usual statement that every Efron–Stein component of order \(\ge3\) vanishes.)

**Theorem (infinite-product Q2).** Let \(f\in L^2(\mu)\) have degree \(\le2\) and \(|f|\le B\) μ-a.e. Let \(M=\sup_{i\in I}I_i(f)\). Then

\[
\operatorname{Var}(f)^2\;\le\;C_0\,B^2\,M,\qquad
C_0=\Bigl(2(1+\sqrt2)\sqrt3+\tfrac{11901}{6250}\Bigr)^2\approx105.4 .
\]

\(C_0\) is exactly the constant of the certified finite theorem. No countability, atom floor, finite or common alphabet, positive-mass condition, or finiteness of \(|I|\) is assumed. If \(M=\infty\) there is nothing to prove, so assume \(M<\infty\).

## 2. Product-type conditional expectations

Call a sub-σ-algebra *product-type* if it is \(\mathcal A=\sigma\bigl(X_i^{-1}(A):A\in\mathcal A_i,\ i\in I\bigr)\) for sub-σ-algebras \(\mathcal A_i\subseteq\Sigma_i\). Write \(\mathcal A=\bigotimes_i\mathcal A_i\).

**Lemma 1 (factorization and commutation).**
(i) For finite \(J\subseteq I\) and bounded measurable \(g_j\) on \(X_j\),
\[
E_{\mathcal A}\Bigl[\prod_{j\in J}g_j(X_j)\Bigr]=\prod_{j\in J}E_{\mu_j}[g_j\mid\mathcal A_j](X_j)\quad\text{a.s.}
\]
(ii) Let \(\mathcal A=\bigotimes\mathcal A_i\) and \(\mathcal C=\bigotimes\mathcal C_i\) be product-type with \(\mathcal A_i,\mathcal C_i\) nested for each \(i\) (either one contains the other). Then \(E_{\mathcal A}E_{\mathcal C}=E_{\mathcal C}E_{\mathcal A}=E_{\mathcal A\wedge\mathcal C}\), where \(\mathcal A\wedge\mathcal C=\bigotimes_i(\mathcal A_i\cap\mathcal C_i)\).

*Proof.* (i) The right side is \(\mathcal A\)-measurable and bounded. Test it against \(1_D\) with \(D=\bigcap_{k\in K}X_k^{-1}(A_k)\), \(K\) finite and \(A_k\in\mathcal A_k\). By independence of the coordinates, both \(\int\prod_j g_j(X_j)1_D\,d\mu\) and the corresponding integral of the right side factor over \(J\cup K\). Coordinatewise they agree by the definition of \(E_{\mu_j}[g_j\mid\mathcal A_j]\). Such \(D\) form a π-system generating \(\mathcal A\), and the sets on which the two integrals agree form a λ-system. Dynkin's theorem finishes the proof.
(ii) By (i), on a finite tensor \(\prod g_j(X_j)\) both compositions equal \(\prod_jE_{\mu_j}[E_{\mu_j}[g_j\mid\mathcal C_j]\mid\mathcal A_j](X_j)\). On a single coordinate, nested conditional expectations compose to the one onto the smaller algebra, in either order. Finite tensors of bounded functions span a dense subspace of \(L^2(\mu)\): this includes indicators of finite-coordinate measurable rectangles, whose generated algebra generates the product σ-algebra of a finite measure. All operators are \(L^2\)-contractions, so the identities extend to \(L^2(\mu)\). ∎

Every operator used below is product-type with coordinate algebras taken from the chain \(\{\emptyset,X_i\}\subseteq\mathcal A_i\subseteq\Sigma_i\), so all of them commute pairwise:

- \(Q_i\): trivial at \(i\), \(\Sigma_j\) elsewhere.
- \(P_F\): \(\Sigma_j\) for \(j\in F\), trivial elsewhere.
- \(E_{\mathcal H}\) for \(\mathcal H=\mathcal H_{F,\mathbf A}\): a finite algebra \(A_j\subseteq\Sigma_j\) for \(j\in F\), trivial elsewhere.

In particular:

- (C1) \(R_iE_{\mathcal H}=E_{\mathcal H}R_i\) for every \(i\).
- (C2) \(Q_iE_{\mathcal H}=E_{\mathcal H}\) when \(i\notin F\), so \(R_iE_{\mathcal H}f=0\).

## 3. Finite-cell reduction

Fix a nonempty finite \(F\) and finite sub-algebras \(A_j\subseteq\Sigma_j\) (\(j\in F\)). Let \(\mathcal C_j\) be the atoms of \(A_j\), a finite measurable partition of \(X_j\), and \(\mathcal C_j^+\subseteq\mathcal C_j\) the atoms of positive \(\mu_j\)-mass. Set \(Y_j(\omega)=\) the atom containing \(X_j(\omega)\); a.s. \(Y_j\in\mathcal C_j^+\). The \(Y_j\) are independent with laws \(\nu_j(c)=\mu_j(c)>0\) on \(\mathcal C_j^+\), and \(\mathcal H=\sigma(Y_j:j\in F)\). Every word \(y\in\prod_{j\in F}\mathcal C_j^+\) has \(\mu(Y=y)=\prod_j\nu_j(y_j)>0\), so

\[
\varphi(y)=\frac{\int_{\{Y=y\}}f\,d\mu}{\mu(Y=y)},\qquad E_{\mathcal H}f=\varphi(Y)\ \text{a.s.}
\]

The table \(\varphi\) is uniquely defined at every word, with no version choice and no null cells. For a table \(\psi\) on \(\prod_{j\in F}\mathcal C_j^+\) write \(T_i\psi(y)=\sum_{c}\nu_i(c)\,\psi(y_{-i},c)\) (the heat-bath at \(i\)) and \(r_i=\mathrm{Id}-T_i\). Native variance and influence under \(\nu=\bigotimes\nu_j\) are \(\operatorname{Var}_\nu\psi\) and \(\operatorname{Inf}^\nu_i\psi=\mathbb E_\nu(r_i\psi)^2\), as in `nativeVariance` and `nativeInfluence`.

**Lemma 2 (heat-bath identification).** For any table \(\psi\) and \(i\in F\), \(Q_i[\psi(Y)]=(T_i\psi)(Y)\) a.s.

*Proof.* \(Y_i\) is independent of \(\Sigma_{-i}\), and \(Y_{-i}\) is \(\Sigma_{-i}\)-measurable. The freezing lemma then gives \(E[\psi(Y_{-i},Y_i)\mid\Sigma_{-i}]=\sum_c\nu_i(c)\psi(Y_{-i},c)\). ∎

**Lemma 3 (degree on a positive table).** Suppose a table \(\psi\) on a finite product with all letter masses positive satisfies \(r_ir_jr_k\psi\equiv0\) for distinct \(i,j,k\). Then \(\psi\) is *pointwise* degree two: every third mixed difference \(\delta^{a,a'}_i\delta^{b,b'}_j\delta^{c,c'}_k\psi\) vanishes.

*Proof.* The \(T_i\) are commuting idempotents, so \(\mathrm{Id}=\prod_{i\in F}(T_i+r_i)\) expands as \(\psi=\sum_{S\subseteq F}\psi_S\) with \(\psi_S=\prod_{i\in S}r_i\prod_{j\notin S}T_j\,\psi\). If \(|S|\ge3\), pick distinct \(i,j,k\in S\) and reorder the factors, so \(\psi_S=(\cdots)r_ir_jr_k\psi=0\). Each \(\psi_S\) with \(|S|\le2\) does not depend on coordinates outside \(S\), because \(T_j\) erases coordinate \(j\). A mixed difference in three distinct coordinates annihilates any function independent of one of them. ∎

**Lemma 4 (finite-cell reduction).** With \(h=E_{\mathcal H}f=\varphi(Y)\):

- (a) \(|\varphi(y)|\le B\) for every word \(y\).
- (b) \(\operatorname{Var}(h)=\operatorname{Var}_\nu\varphi\).
- (c) \(I_i(h)=\operatorname{Inf}^\nu_i\varphi\) for \(i\in F\).
- (d) \(\varphi\) is pointwise degree two.
- (e) \(\operatorname{Inf}^\nu_i\varphi\le I_i(f)\le M\) for every \(i\in F\).

*Proof.* (a) \(\varphi(y)\) is a \(\mu\)-average of \(f\) over a positive-mass set. (b) \(h\) is a function of \(Y\), whose law is \(\nu\). (c) Lemma 2: \(R_ih=(r_i\varphi)(Y)\), then take the \(L^2\) norm. (d) By (C1) and the degree hypothesis, \(R_iR_jR_kh=E_{\mathcal H}R_iR_jR_kf=0\). If \(i,j,k\in F\), Lemma 2 applied three times gives \((r_ir_jr_k\varphi)(Y)=0\) a.s. Every word has positive mass, so \(r_ir_jr_k\varphi\equiv0\) pointwise; then apply Lemma 3. (The table has index set \(F\) only, so no other triples arise.) (e) By (c) and (C1), \(\operatorname{Inf}^\nu_i\varphi=\|E_{\mathcal H}R_if\|^2\le\|R_if\|^2\). ∎

Lemma 4 meets every hypothesis of `native_heterogeneous_q2_105416_unconditional`: index set \(F\), coordinate alphabets \(A_i=\mathcal C_i^+\), source laws \(\nu_i\), bound \(B\), cap \(M\). Hence

\[
\operatorname{Var}(E_{\mathcal H_{F,\mathbf A}}f)^2\le C_0B^2M\qquad\text{for every }(F,\mathbf A).\tag{★}
\]

(For \(F=\emptyset\), \(E_{\mathcal H}f\) is constant and (★) is trivial.)

## 4. Removing the cells, then the coordinates

**Lemma 5 (cell net).** Fix finite \(F\). Order tuples \(\mathbf A=(A_j)_{j\in F}\) of finite sub-algebras by coordinatewise inclusion; this is directed, since joins of finitely many finite algebras are finite. Then \(E_{\mathcal H_{F,\mathbf A}}f\to P_Ff\) in \(L^2\), and \(\operatorname{Var}(E_{\mathcal H_{F,\mathbf A}}f)\to\operatorname{Var}(P_Ff)\).

*Proof.* \(\mathcal H_{F,\mathbf A}\subseteq\mathcal G_F\), so \(E_{\mathcal H}f=E_{\mathcal H}P_Ff\). The union \(\mathcal R=\bigcup_{\mathbf A}\mathcal H_{F,\mathbf A}\) contains every finite disjoint union of rectangles \(\bigcap_{j\in F}X_j^{-1}(B_j)\) with \(B_j\in\Sigma_j\): take \(A_j\) generated by the finitely many \(B_j\)'s involved. So \(\mathcal R\) is an algebra generating \(\mathcal G_F\). Because \(\mu\) is finite, every \(\mathcal G_F\)-set is approximated in measure by \(\mathcal R\)-sets, so \(\mathcal R\)-simple functions are dense in \(L^2(\mathcal G_F)\). Given \(\varepsilon>0\), pick such a \(g\) with \(\|P_Ff-g\|<\varepsilon\); \(g\) is \(\mathcal H_{F,\mathbf A^0}\)-measurable for some \(\mathbf A^0\). For \(\mathbf A\succeq\mathbf A^0\), best approximation by the orthogonal projection gives \(\|P_Ff-E_{\mathcal H_{F,\mathbf A}}P_Ff\|\le\|P_Ff-g\|<\varepsilon\). Conditional expectation preserves the mean and norms converge, so \(\operatorname{Var}=\|\cdot\|^2-(\text{mean})^2\) converges. ∎

**Proof of the Theorem.** By (★) and Lemma 5, letting the cell net run in a closed inequality gives \(\operatorname{Var}(P_Ff)^2\le C_0B^2M\) for **every** finite \(F\). This is exactly the hypothesis `hfinite` of the kernel-certified `source_q2_quadratic_limit` (`InfinitePiQ2Limit.lean`) with \(R=C_0B^2M\ge0\). That theorem gives \(\operatorname{Var}(f)^2\le C_0B^2M\) under the original `Measure.infinitePi μ`, with no countability or approximation hypothesis. ∎

**Remark (Hilbert-space form).** Nothing above uses boundedness beyond Lemma 4(a) and the finite theorem. Both influence comparisons are contraction statements, so the reduction transfers any finite-table Q2 constant to arbitrary products without loss.

## 5. Certification ledger: proof step → Lean status

| Step | Lean source (all under `research/nightfall/formalization/`) | Status |
|---|---|---|
| Finite heterogeneous Q2, constant \(C_0\), zero atoms allowed | `universal/InfinitePiQ2NativeHeterogeneousTerminal.lean` (`native_heterogeneous_q2_105416_unconditional`) | certified on main |
| Limit from all finite \(F\) to \(f\), arbitrary \(I\) | `universal/InfinitePiQ2Limit.lean` (`source_q2_quadratic_limit`); ε-version `InfinitePiQ2EventualTerminal.lean` | certified on main |
| Coordinate vs complement independence (input to Lemma 2) | `universal/InfinitePiQ2OriginalIndependence.lean` | certified on main |
| Lemma 1(i) on finite tensors | `universal/InfinitePiQ2FiniteRankConditional.lean`, `InfinitePiQ2SourceHilbertTensor.lean`, `InfinitePiQ2ConditionalSourceTest.lean` | certified **for tensor tests only** |
| (C2), inactive coordinates | `universal/InfinitePiQ2InactiveSourceSigma.lean` | certified (for \(P_F\); the \(\mathcal H_{F,\mathbf A}\) case is the same argument) |
| Lemma 2 pointwise heat-bath / label intertwining | `universal/InfinitePiQ2OriginalHeatBath.lean` | certified pointwise; identification with `condExpL2` for arbitrary \(L^2\) still open |
| Lemma 4(a) bound preservation | `universal/InfinitePiQ2SourceBoundedCondExp.lean` | certified at L¹-condExp level; identifying it with the L² table is open |
| Lemma 3 (positive table ⇒ pointwise degree two) | `universal/InfinitePiQ2FiniteDegreeBridge.lean` proves pointwise ⇒ ES; **this converse direction is open** | **OPEN** |
| Lemma 1(ii) extension from tensors to all of \(L^2\) | finite-cell density `InfinitePiQ2FiniteCellSupport.lean`, `InfinitePiQ2Density.lean` | **OPEN** (density exists; operator-extension step not composed) |
| Lemma 5 net over finite sub-algebras inside fixed \(F\) | none | **OPEN** |
| One terminal Lean theorem composing all of the above | none | **OPEN** |

**Promotion rule.** Until the open rows are kernel-checked and composed into one named declaration with a strict axiom receipt, this result is an *author-analytic infinite-product theorem conditional on human review*, not a machine-certified one.

## 6. Exact falsification check

`check_finite_cell_reduction.py` builds random pointwise degree-two tables on heterogeneous finite products with zero atoms and random coarse partitions. In exact rational arithmetic it checks Lemma 4(a)–(e), and that the identity partition reproduces \(f\). Mutation tests confirm it rejects degree-three inputs and an unweighted cell average.

```sh
python3 research/nightfall/2026-11-infinite-product-q2/check_finite_cell_reduction.py 20261117 60
# PASS: 60/60 trials, seed 20261117
```

It attacks algebraic errors in the reduction. It does not test density, Lemma 1 on non-tensor functions, or the limit.

## 7. Scope, novelty and what to review

- **What is new here is small.** The passage from finite tables to arbitrary products is a standard martingale/approximation argument. All the mathematical substance is in the finite inequality, specifically that \(C_0\) is uniform in alphabet sizes, coordinate laws and dimension. Present the infinite-product statement as a corollary of the finite theorem, not as a separate breakthrough.
- **Priority is unresolved** (as the README already records): compare with low-degree Aaronson–Ambainis-type influence bounds and with Grothendieck/decoupling arguments on product spaces before any originality claim.
- **Reviewer focus:** the definition of degree two in \(L^2\) (§1) against the reader's preferred ANOVA definition; Lemma 1(ii)'s nestedness requirement; and the claim in Lemma 4(d) that positivity of every cell makes the a.s. identity pointwise. That last point is what lets the finite theorem's pointwise hypotheses apply without null-cell repair.
