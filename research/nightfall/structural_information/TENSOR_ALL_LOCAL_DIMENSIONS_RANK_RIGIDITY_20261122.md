# All local binary dimensions: cubic primitive four-fiber via full-rank tail rigidity

NIGHTFALL independent proof refinement — 2026-11-22, v1.0.

**Status: author-side all-level mathematical proof conditional on the exact published Lovitz / Lovitz–Petrov minimal product-tensor circuit support theorem; independently testable finite rank-rigidity certificate. No end-to-end Lean theorem, no human referee, no worldwide priority clearance, and NO full quantum simulator certification.**

## Scope and upgrade

Fix any local dimension q≥2, level L≥1, \(A_q=\mathbb F_2^q\setminus\{0\}\),
\(R(q,L)=\{u_1\otimes\cdots\otimes u_L:u_i\in A_q\}\),
\(D(q,L)=R(q,L)\cup\{0\}\).
For nonzero frequency z, count ordered four-tuples with **four pairwise-distinct labels in D(q,L)**, total XOR z, and primitive (zero-subset-free) nonzero row support. This is exactly the disjoint Group A, *not* the larger older K4 overcounting tuples with repeated zeros.

Put
\(N_q=1+4(2^q-1)^6\),
\(M_2(q,L)=2L(2^{q-1}-1)+2\).
Then for EVERY q≥2, L≥1, and z≠0,

\[
 K_4^A(q,L,z)
 \le 52\,N_q^2\min(N_q,M_2(q,L))
 \sum_{j=0}^{\min(3,L)}\binom Lj. \tag{ALL-q CUBIC}
\]

In particular \(\max_{z\ne0}K_4^A(q,L,z)=\Theta_q(L^3)\) as L→∞. The lower bound comes by embedding the q=2 local alphabet and its exact \(24\cdot30\binom L3\) primitive four-row witnesses. **The order is a combinatorial Fourier multiplicity fact, not a quantum/classical query lower bound.** It is a source-cited, paper-level theorem and potential new enumerative specialization, not a priority certification.

This **supersedes only the scope limitation** in TENSOR_LOCAL_DIMENSION_CUBIC_THRESHOLD_20261122.md: that note correctly exhibited a counterexample to the simple q≤3 *reference-variation lemma* at q=4. Its caution that the counterexample did not disprove the cubic counting theorem was essential. The replacement operator below repairs precisely the failing case; the counterexample is preserved as a negative control.

## New operator: full-rank tensor tail rigidity

Let U,V be finite-dimensional vector spaces over F₂, T any vector space, \(\tau\in T\setminus\{0\}\), and M∈U⊗V have **matrix rank r**. Suppose
\[
 M\otimes\tau=\sum_{j=1}^{r} u_j\otimes v_j\otimes\tau_j
\]
with all displayed factors nonzero. Flatten as a matrix \(U^*\to V\otimes T\). The image has dimension r and equals \(\operatorname{rowspace}(M)\otimes\operatorname{span}(\tau)\). Since the decomposition has exactly r rank-one terms, both the left and right families are linearly independent, and \(\{v_j\otimes\tau_j\}\) is a basis of that image. Therefore every \(v_j\otimes\tau_j\) belongs to \(V\otimes\operatorname{span}(\tau)\). A nonzero elementary tensor in that subspace necessarily has \(\tau_j=\tau\) up to nonzero scalar; over F₂ the only such scalar is 1. Thus
\[
\boxed{\tau_j=\tau \text{ for every } j.} \tag{RIGIDITY}
\]
If the \(\tau_j\) and \(\tau\) are themselves nonzero pure tensors over multiple sites, equality of pure factors in characteristic two forces the identical local factors **at every site** outside the U,V block.

This is elementary linear algebra, not a newly invented full-rank decomposition theorem. The new contribution candidate is its use to close the previously open q≥4 counting case.

## Stronger dual-functional proof certificate (replaces rowspace manipulation)

A shorter *mechanism-preserving* derivation works over **any field**, with the usual scalar ambiguity. If \(M\in U\otimes V\) has matrix rank \(r\), and
\(M\otimes\tau=\sum_{j=1}^r a_j\otimes b_j\otimes\tau_j\)
with nonzero \(a_j,b_j,\tau_j\), then the \(a_j\) must be linearly independent: otherwise their span has dimension below \(r\), contradicting the rank-\(r\) flattening of \(M\otimes\tau\) at U.

Choose dual linear functionals \(\phi_j\in U^*\) with \(\phi_j(a_i)=\delta_{ij}\). Contract the first tensor slot to obtain
\[
 b_j\otimes\tau_j
 =\bigl((\phi_j\otimes\mathrm{id}_V)M\bigr)\otimes\tau.
\]
Because \(b_j\ne0\), choose \(\lambda_j\in V^*\) with \(\lambda_j(b_j)=1\); contracting once more yields
\[
 \tau_j
 =\lambda_j\bigl((\phi_j\otimes\mathrm{id}_V)M\bigr)\,\tau.
\]
Both tail factors are nonzero, so the displayed scalar is nonzero. Over F₂ it is **exactly 1**, giving the conclusion \(\tau_j=\tau\) with no numerical approximation and no matrix-rank basis enumeration. Over an arbitrary field this gives projective equality; the F₂ tensor-source model needs literal equality, and obtains it.

**Checker/certificate recipe:** finite matrices need only verify rank \(r\) and the individual contraction identities using exact field arithmetic. A future Lean proof can use a linearly independent family and its dual-coordinate functionals rather than brute-force all alternate tensor decompositions. This refinement does not change the exponent, the hypotheses, or the unverified quantum-energy dependency.

## Repair of the minimum-reference site lemma

Choose a minimum-cardinality primitive reference C⊂R(q,L) for z with r=|C|≤4. Compare to any primitive C' of at most four original rows with XOR z, and partition C△C' into disjoint minimal zero-XOR circuits E_i, with s_i≥1 C-only rows and t_i≥1 C'-only rows. As before, every circuit is a genuine minimal tensor dependence in characteristic two and the **published Lovitz–Petrov support inequality** says the number of varying tensor sites |S_i|≤s_i+t_i−2.

For each reference-side A_i=C∩E_i, its own varying sites F_i satisfy:

- s_i=1: |F_i|≥0;
- s_i=2: distinct rows force |F_i|≥1;
- s_i=3: if |F_i|≤1, the three-row XOR is either zero (forbidden by reference primitivity) or a **single nonzero pure row**; replacement strictly shortens the representation C of z. Therefore |F_i|≥2 for **every q**;
- s_i=4: necessarily A_i=C (all reference rows). If |F_i|≥3, ordinary forced-support accounting applies. If |F_i|≤1, the XOR of C is zero or a single pure row, contradicting z≠0 and reference minimality. The remaining exceptional possibility is |F_i|=2. Then
  \(z=M\otimes\tau\), with fixed nonzero tail outside F_i and a q×q binary matrix M. Since C has four rows and is a *minimum-length four-row representation of z*, rank(M)=4: rank≤3 would supply a shorter representation using a rank-factorization of M into ≤3 nonzero rank-one original rows. Hence q≥4. The alternative C' must have **exactly four** nonzero rows, as matrix rank gives a lower bound. By (RIGIDITY) every alternative row has the *same fixed tail τ* outside F_i; therefore no alternative row varies outside F_i, and in fact S_i=F_i. The exceptional circuit consumes **zero** freely variable sites. This is **stronger** than required |S_i\\F_i|≤t_i−1.

In every case, the exact-site cost is now
\[
 |S_i\setminus F_i|\le t_i-1,\qquad
 \left|\bigcup_i(S_i\setminus F_i)\right|
 \le\sum_i(t_i-1)
 =\sum_i t_i-\#\{E_i\}\le 4-1=3.
\]
The union of all active circuit sites still has size at most six (published LP). Each alternative row matches a reference row outside those six sites.

The reference-side disjoint circuit blocks are a partition of a subset of the ≤4 reference rows, hence at most Bell(5)=52 patterns; for each pattern the forced reference variation F=∪F_i is determined. The ≤3 *freely chosen* additional sites have at most Σ_{j≤3}binom(L,j) possibilities. For each active-set pattern every source row must lie in one of four reference-tethered candidate cubes, each with (2^q−1)^6 labels. Include zero: N_q possibilities.

For four all-distinct slots with XOR z, fixing the first two labels leaves a nonzero XOR target for the final two; the latter have at most M2 ordered original-label pair completions and at most N_q due to forced last-label uniqueness. Hence at most N_q²min(N_q,M2) tuples per support choice, proving (ALL-q CUBIC).

## Pair fibers and lower construction

The separate all-L original-row pair-frequency classification extends to q≥2:
- a source row z has exactly \(L(2^{q-1}-1)\) unordered row pairs XORing to z;
- a non-row frequency arising from a pair differing in two local factors has exactly three unordered pairs;
- a non-row from a pair differing in ≥3 factors has exactly one unordered pair.

The q≥2 statement uses the same published 4-row tensor circuit support bound for the last two classes, together with a rank-2 2×2 change-of-basis identity. Including the zero sector gives the exact ordered M2(q,L) above.

For any q≥2 choose a fixed 2D subspace of each local factor, and embed the q2 primitive four-row XOR witnesses. Their exact count is \(30\binom L3+5\binom L2\) unordered sets at a product target. Multiplying by 4! yields the cubic lower bound.

## Decisive falsifiers / certification gates

- **Keep the q4 counterexample:** four diagonal tensors \(\sum_{i=1}^4e_i\otimes e_i=I_4\) are a minimum four-row reference varying in only two sites. It disproves *unconditional* |F|≥s−1 but is **not** a counterexample to (ALL-q CUBIC).
- **Required independent counterexample:** find any four-term pure tensor decomposition of \(I_4\otimes\tau\) in which one tail factor differs from τ. Its existence would refute (RIGIDITY). Linear-rank argument predicts impossible. Exact small-dimensional checker must include rank-4 examples rather than only lower-rank mixtures.
- **Thin point:** verify matrix rank(M) equals minimal number of original q×q row factors, including the fixed tail and the q-dimensional local source constraints; prove rank-one factorization uses *nonzero* local vectors. Over F₂ this is standard Gaussian elimination, but source-level Lean all-q not yet supplied.
- **Independence:** author-side proof and finite checker cannot serve as non-author peer review. Formalize tail rigidity and the exceptional s4 step in a kernel theorem, then compose with existing conditional 3-free-site and source LP proof. Do not add LP as an unproved Lean axiom.
- **Quantum boundary:** this supplies an all-q **combinatorial** primitive fiber O(L³) bound only. The general arbitrary-Hilbert T2 acceptance simulator from #1068 and the improved coefficient 35 remain paper-level until the grouped operator-energy and Walsh projection theorem are kernel checked and independently attacked.
- **Priority:** Lovitz 2018, Lovitz–Petrov 2023, Wang–Yuan 2026 and standard full-rank matrix decomposition theory receive their original credit. The derived all-q binary XOR counting corollary is a dated candidate whose novelty requires a targeted specialist search and human sign-off.

**Graph:** minimum XOR reference → circuit decomposition → published LP site support → reference variation OR full-rank rigidity → ≤3 free sites → Bell52 patterns → pair-fiber completion cap → sharp Θ_q(L³) primitive Fourier multiplicity. Status: paper proof + independent exact finite tests pending, not Lean-certified.
