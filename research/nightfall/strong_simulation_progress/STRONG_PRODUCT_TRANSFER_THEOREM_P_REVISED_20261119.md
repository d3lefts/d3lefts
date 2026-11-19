# Theorem P — strong bounded-round product-source transfer by coherent block coupling

Version 2.0 (2026-11-19). **Paper-level proof relative to the published BDST uniform-bit simulation theorem. Not a Lean-checked end-to-end theorem, independent expert review, or originality certificate.**

## Objective and exact scope

Let \(I\) be a finite coordinate set and each \(\Sigma_i\) a nonempty finite symbol alphabet, with \(2\le A:=\max_i|\Sigma_i|\) (the all-singleton case is trivial). Let \(P=\bigotimes_{i\in I}p_i\) be an arbitrary known independent product law; **zero atoms are allowed**. Let \(\mathcal A\) be a genuine normalized unitary quantum algorithm making at most \(t\ge1\) coherent whole-symbol value queries in \(d\ge1\) parallel query rounds. Fixed input-independent gates and arbitrary finite answer workspaces are free. For a cyclic response group containing injective encodings of every \(\Sigma_i\), the query has the canonical reversible form

\[
 O_x|i,z,r\rangle=|i,z+\operatorname{enc}_i(x_i),r\rangle.
\]

Denote its Born acceptance probability by \(f(x)\in[0,1]\). Fix \(0<\varepsilon,\delta<1\). Let \(S(T,r,\alpha,\beta)\) be **the worst-case classical bit-decision-tree depth supplied by** Blanc–Docter–Strassle–Tan, *Quantum Speedups Require Structure or Depth*, arXiv:2608.19158v1, Theorem 1, for a genuine \(T\)-query, \(r\)-round uniform-Boolean quantum algorithm with accuracy \(\alpha\) and failure \(\beta\). This is an external published theorem, not a Lean declaration.

**Theorem P (paper-level consequence of BDST).** Choose an integer \(m\ge1\) such that

\[
 2^m\ge A(A-1),\qquad A^2 2^{-m}\le\left(\frac{\varepsilon\delta}{16t}\right)^2.
\]

Then there exists a **deterministic** classical whole-symbol decision tree, of worst-case query depth at most

\[
 S(2mt,\,2d,\,\varepsilon/2,\,\delta/2),
\]

whose output \(T(x)\) satisfies

\[
 \Pr_{X\sim P}(|T(X)-f(X)|>\varepsilon)\le\delta.
\]

A valid explicit choice is \(m=\lceil\max\{1,\log_2(A(A-1)),2\log_2 A+2\log_2(16t/(\varepsilon\delta))\}\rceil\). Thus BDST's uniform strong logarithmic dependence on \(1/\delta\) transfers to known finite product laws without a lower bound on any symbol probability. **No classical runtime efficiency, universal quantum input-access convention, or mixture result is claimed.**

## Proof — four source-level reductions

### 1. Exact one-sided dyadic source coupling

Put \(N=2^m\). Fix each coordinate \(i\) and choose an anchor \(a_i\) maximizing \(p_i(a)\), so \(p_i(a_i)\ge1/A\). For \(a\ne a_i\), set \(q_i(a)=\lceil Np_i(a)\rceil/N\); set \(q_i(a_i)=1-\sum_{a\ne a_i}q_i(a)\). Every non-anchor increment lies in \([0,1/N)\), so \(q_i(a_i)>p_i(a_i)-(A-1)/N\ge0\). In fact it is **strictly positive**, including at the endpoint \(N=A(A-1)\). The resulting law \(q_i\) is nonnegative, normalized and dyadic. Every originally positive symbol has positive \(q_i\): this is automatic off anchor by upward rounding and true at anchor by the strict inequality.

On every \(x\) of positive \(p_i\)-mass define the Markov kernel \(C_i\) by

\[
 C_i(y\mid x)=\begin{cases}
 1 &x\ne a_i,\ y=x,\\
 0 &x\ne a_i,\ y\ne x,\\
 q_i(a_i)/p_i(a_i)&x=a_i,\ y=a_i,\\
 (q_i(y)-p_i(y))/p_i(a_i)&x=a_i,\ y\ne a_i.
 \end{cases}
\]

At zero-mass \(x\) choose any probability row. Row normalization follows from the definition of \(q_i(a_i)\), and directly \(\sum_xp_i(x)C_i(y\mid x)=q_i(y)\). Conditional mismatch is zero for all nonanchors; for the anchor it is at most \((A-1)/(Np_i(a_i))\le A(A-1)/N\le A^2 2^{-m}=:\lambda\). Independently couple coordinates by \(C_i\), obtaining \(X\sim P\), \(Y\sim Q=\otimes_i q_i\), and for all \(x\) of positive source mass, all \(i\),

\[
 \Pr[Y_i\ne X_i\mid X=x]\le\lambda.
\]

### 2. Exact uniform Boolean seed, and a persistent lazy classical decoder

For each \(i\), partition \(\{0,1\}^m\) into buckets of cardinality \(Nq_i(a)\) and define the deterministic decoder \(g_i(u)=a\) for seeds \(u\) in the corresponding bucket. For every \(p_i(x)>0\), define

\[
 K_i(u\mid x)=\frac{C_i(g_i(u)\mid x)}{Nq_i(g_i(u))}.
\]

Denominators are nonzero whenever the numerator can be positive, because the support of \(p_i\) is included in the support of \(q_i\). No seed falls in a bucket of size zero. Therefore \(K_i(\cdot\mid x)\) is a probability distribution. Crucially, **direct finite summation** gives, for every \(u\),

\[
 \sum_x p_i(x)K_i(u\mid x)=\frac1N.
\]

Sample \(U_i\sim K_i(\cdot\mid X_i)\) independently across coordinates. Hence the *entire array* \(U\) is uniform Boolean, \(Y=g(U)\) has law \(Q\), and \((X,Y)\) has exactly the coupling from Step 1. A deterministic adaptive decision tree on the bits of \(U\) can now be simulated using whole-symbol queries to \(X\): at the **first** request for any bit in block \(i\), query \(X_i\), sample the **entire** \(U_i\sim K_i(\cdot\mid X_i)\), and cache it. Future bit requests to that block return cached bits without another source query. Every path makes at most as many source queries as seed-bit queries, even if bits are adaptively revisited. For input letters of zero source mass, fix any normalized fallback seed kernel; they do not affect the probability guarantee.

### 3. Real coherent Boolean-oracle compilation, preserving bounded rounds

We verify the actual unitary input-oracle convention, not merely an equality of scalar functions. An original symbol-query slot acts on a *computational-basis index* \(i\) in arbitrary coherent superposition, an answer register \(z\), and other workspaces. Coherently fan out that **basis index label** into \(m\) clean bit-query index registers using fixed reversible gates (this copies a classical basis label coherently; it does **not** clone an unknown quantum state). Make \(m\) bit-oracle calls **in parallel**, one to each \((i,j)\), \(j\in[m]\), writing the block \(U_i\) into a clean \(m\)-bit workspace. Apply the fixed, input-independent reversible gate \(z\mapsto z+\operatorname{enc}_i(g_i(U_i))\). Make the same \(m\) bit queries **in parallel a second time** to uncompute the workspace, then undo the fixed index fanout. On each basis state with clean ancilla the resulting map is

\[
 |i,z,0\rangle\mapsto|i,z+\operatorname{enc}_i(g_i(U_i)),0\rangle,
\]

and by linearity it holds on **all superpositions**, with no postselection or measurement. Each stage is a reversible basis permutation, so its linear extension is unitary. Every original symbol-query slot is thus simulated by exactly **\(2m\) Boolean oracle calls in two parallel query layers**. For an original round containing \(k\) parallel slots, run all \(km\) fetches simultaneously, then all \(km\) uncomputes simultaneously, separated by fixed decode gates: exactly \(2mk\) calls and two layers, not \(2mk\) layers. Across \(t\) slots and \(d\) rounds this totals at most \(2mt\) calls and \(2d\) query rounds. The pulled-back unitary circuit has exact acceptance function \(u\mapsto f(g(u))\).

The key **remaining Lean boundary** is formalizing this two-layer call accounting in the actual BDST Boolean query circuit syntax. PR #912 has source for the reversible fetch/decode/uncompute and full-amplitude norm preservation; that alone does not certify the entire parallel circuit compiler.

### 4. Quantum hybrid stability, BDST simulation, union bound, deterministic tape

For any normalized coherent value-query state \(\psi\) and two inputs \(x,y\), the oracle maps coincide on query index \(i\) whenever \(x_i=y_i\). On a differing index they are unitary, so the triangle inequality gives

\[
 \|(O_x-O_y)\psi\|^2\le4\sum_{i:x_i\ne y_i}w_i(\psi),
\]

where \(w_i\) is the squared norm of the index-\(i\) component. Telescoping the genuine \(t\)-query unitary state evolution, using the \(x\)-trajectory for query weights, and applying the \(2\)-Lipschitz Born readout gives

\[
 |f(x)-f(y)|\le4\sum_{q=1}^t\sqrt{\sum_{i:x_i\ne y_i}w_{q,i}(x)}.
\]

Condition on \(X=x\) and apply Jensen to each square root. Since all query weights are determined by \(x\), and \(\sum_iw_{q,i}(x)=1\), the mismatch guarantee from Step 1 yields

\[
 \mathbf E[|f(X)-f(Y)|]\le4t\sqrt\lambda,
 \quad \Pr(|f(X)-f(Y)|>\varepsilon/2)\le\frac{8t\sqrt\lambda}{\varepsilon}\le\delta/2.
\]

Apply **the external BDST uniform-Boolean theorem** to the actual pulled-back \((2mt,2d)\) quantum circuit, with accuracy \(\varepsilon/2\), failure \(\delta/2\). It gives a deterministic Boolean decision tree \(B\) of depth \(S\) such that

\[
 \Pr_{U\text{ uniform}}(|B(U)-f(g(U))|>\varepsilon/2)\le\delta/2.
\]

Use Step 2's cached conditional seed sampler to emulate \(B\) from input \(X\). Its output is initially randomized and uses at most \(S\) whole-symbol source queries. As \(U\) is *exactly uniform* after averaging over \(X\) and the sampler tape, the two failure-event bounds combine to \(\le\delta\) against the **original law** \(P\). Preassign independent uniform tapes for all coordinates and all possible input letters; fix one entire tape whose source-law failure mass does not exceed its expected value. That produces a deterministic source decision tree, still of worst-case depth \(S\), and completes the argument. □

## Independent audit / certification gates

1. **Strongest checked external reference this session:** BDST arXiv:2608.19158v1; its uniform bounded-round strong theorem is taken as an external theorem, **not** recast as a Lean axiom purporting to be formally verified. Also compared Girish–Mittal–Nehoran–Raz, arXiv:2609.35327 (biased-product analogues); no novelty priority judgment is made.
2. **Exact enumerative falsifier (separate implementation):** `check_strong_product_transfer_exact.py` uses rational distributions and Gaussian-rational amplitudes to check rounding, Markov kernel normalization, uniform seed marginals, source/seed joint law, oracle fetch/uncompute with arbitrary workspace, local squared-norm oracle discrepancy, and adaptive cached-block behavior. It does *not* validate the universal or external BDST theorem.
3. **Proof to Lean gate:** write one terminal importing a fully costed coherent Boolean compiler (#912), concrete finite-symbol per-query discrepancy + Born readout combined with the telescope (#914), dyadic source kernel, a correct seed-cache decision-tree interpreter, and an explicit **external BDST hypothesis** whose statement is printed in full. The terminal then proves the conditional source-error bound, rather than postulating a product simulator; a completely assumption-free Lean theorem would additionally require formally importing/proving BDST itself.
4. **Independent reviewer gate:** check the precise BDST query model and depth function, the free coherent fanout index encoding, the empty/singleton-alphabet cases, the uniform-seed conditional distribution, and the deterministic-tape selection. Provisional certification persists until a non-author reviewer verifies the construction. Theorem P is a reduction to an established theorem; novelty and significance are separate questions.

**Stop rule:** Do not upgrade the manuscript's strong product or strong mixture headline on the strength of finite tests, a scoped gate lemma, or a conditionally stated Lean terminal. Preserve the exact source and axiom receipts for each claim.