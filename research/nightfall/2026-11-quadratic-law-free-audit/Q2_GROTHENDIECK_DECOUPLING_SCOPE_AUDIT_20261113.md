# Q2 prior art and terminal coupling — adversarial audit (2026-11-13)

**Status:** elementary exact identities and finite-rational replay. No categorical Grothendieck subsumption theorem, no terminal Q2 Lean certificate, and no novelty sign-off.

## Research contract

Objective: test the claimed one-page degree-two decoupling/Grothendieck corollary and static disjoint-block martingale shortcut.

Feasible set: bounded real Hoeffding degree ≤2 functions on independent finite products with arbitrary normalized nonnegative coordinate laws, including zero atoms. Distinguish binary input and general categorical input.

Strongest internal comparator: merged PR #392, v8 manuscript, Proposition prop:groth, already proves the classical binary bound V²≤16(K_G^R)²B²M (coefficient <51). The manuscript explicitly leaves categorical Grothendieck subsumption open. This is not a new result of this audit.

External references checked this session: de la Peña–Giné, Decoupling (1999), https://link.springer.com/book/10.1007/978-1-4612-0537-1 ; de la Peña–Montgomery-Smith, U-statistic decoupling, https://arxiv.org/abs/math/9309210 ; Pisier, Grothendieck notes, https://www.math.kyoto-u.ac.jp/sites/default/files/2023-04/Pisier_lecturenote.pdf ; Mishura, triangular truncation in the cut norm, LAA 2022, https://www.sciencedirect.com/science/article/abs/pii/S0024379522002117 .

Novelty threshold: a fully specified theorem-type reduction with dimension, alphabet, and atom-independent constants, or an independently refereed genuinely new mechanism; neither follows merely by identifying related tools.

Independent checker: check_q2_decoupling_scope_exact.py, exact Fraction arithmetic. Stop rule: if the proposed reduction assumes a false normalization, false root-influence summability, disjoint owners, or independent martingale differences, reject that inference instead of labeling Q2 classical.

## A. Exact decoupling, not an assumed factor of one half

For the genuine centered canonical pairs h_ij let f_2(X)=Σ_{i<j} h_ij(X_i,X_j), with X,Y independent draws from the same original product.

Define one-sided K_right(x,y)=Σ_{i<j} h_ij(x_i,y_j), and *symmetric* K_sym(x,y)=Σ_{i<j}[h_ij(x_i,y_j)+h_ij(y_i,x_j)].

By separate centering, the cross terms vanish in the full product, so

**Var(f_2)=E[K_right(X,Y)²]=(1/2)E[K_sym(X,Y)²].**

Counterexample to the proposed half coefficient for the *one-sided* K: two fair signs, f_2=X_1X_2. Then Var(f_2)=1=E K_right², not (1/2) E K_right².

We can also establish a genuine law-uniform *supremum* bound for the symmetric cross-kernel. Let P_t independently refresh each coordinate with probability 1−t from its original marginal; for degree-≤2 f, P_t f=f_0+t f_1+t² f_2 and ||P_t f||∞≤B. Interpolation gives the exact identity f_2=2[P_1 f−2P_{1/2}f+P_0 f], so ||f_2||∞≤8B.

For z(σ) obtained by independently taking each coordinate from x or y with fair probability, the categorical polarization identity is exact:

**K_sym(x,y)=4 E_σ f_2(z(σ))−f_2(x)−f_2(y)**.

Thus **||K_sym||∞≤48B**, uniformly in dimension, alphabet and minimum positive atom. This is a useful exact bound but not a maximum-influence inequality. Dropping one orientation is an upper-triangular truncation, not a harmless factor-two operation; triangular truncation is known to have nontrivial/unbounded cut-norm behavior.

## B. Failure of alphabet-uniform root-influence summability

Let A be uniform on [m] and let Z_1,…,Z_m be independent fair signs. The bounded degree-two address f=Z_A has pure degree-two component

f_2=Σ_j (1[A=j]−1/m) Z_j.

Exact calculations give ||f_2||∞≤2(1−1/m)<2, Var(f_2)=I_A(f_2)=1−1/m, and I_{Z_j}(f_2)=(m−1)/m². Hence

**Σ_i sqrt(I_i(f_2))=(1+sqrt(m)) sqrt(1−1/m)→∞.**

Therefore a categorical, uniform Σsqrt(I_i)≤C||f_2||∞ consequence is **false**, even for pure degree two. Grothendieck in the binary proof supplies precisely such a root-sum strategy because the cube has special polarization. A generic factorization T:L∞(μ)→L¹(μ) for categorical inputs does not automatically control original-coordinate influences; new uniform transport/extraction would be required. The false root-sum result is stronger than, and does not contradict, the intended V²≤CB²max I inequality.

The proposed additive estimate Var(f_1)²≤4B²max I_i(f_1) does not follow from each ||h_i||∞≤2B alone: a *global* additive oscillation or section budget is essential. The existing source section sum Σ||h_i||₂≤8B gives the justified weaker bound Var(f_1)²≤64B² M.

**Prior-art verdict:** retain the verified binary Grothendieck comparator, document the exact decoupling and categorical obstruction, and keep the arbitrary-alphabet subsumption task OPEN. Do not state that existence of an alphabet-uniform C_2 is already implied by the cited theorems without the missing theorem-type reduction.

## C. Static ownership: local distinctness, not global disjoint blocks

The greedy graph and cost assignment are deterministic from f and the source laws, not from the sampled input X. At each *fixed owner* i, its finite original neighbor sites N_i are distinct and the exact product-observation law can be transported to the recursive independent-sample fourth moment. PR #434 has a strict historical Lean 4.33 source-law certificate (run 43500988069), while the pointwise owner-oriented section source identity remains a proof candidate in PR #443.

**Global disjointness is false:** three vertices with costs c=(3,1,2) and the canonical complete pair graph have N_1={2,3}, N_3={2}. One owned edge per owner does not make neighboring coordinate sets globally disjoint.

Even for statically disjoint revealed singleton coordinate blocks, martingale differences of an arbitrary quadratic f need not be independent. On three fair signs let f=X_1X_2+X_1X_3+X_2X_3. In the coordinate-reveal filtration the differences are D_1=0, D_2=X_1X_2, D_3=X_3(X_1+X_2), with the **exact dependence** D_3²=2(1+D_2). Doob orthogonality is not independent Hilbert increments, and the existing fourth-moment theorem cannot be substituted without a fresh proof.

**Preferred Lean representation:** enumerate each owner's true original N_i by a Fin-indexed injection; identify the original owner-oriented pair sum pointwise; transport its entire law (including first norm moment) using #434; apply independent-source Hilbert fourth moment within each owner; derive the source s_i≤I_i and z_i≤u_i+||h_i||₂ via true conditional projection and certified integrated Jensen (PR #445, Lean 4.36 run 43503541740); aggregate the 8B section and cost budgets and close one finite terminal Q2 declaration with no supplied auxiliary premises.

## D. Operator and certification ledger

Mechanisms: symmetrized polarization, product-noise interpolation, fixed-owner injective law transport; a non-independent martingale alternative is rejected. Numerical checker is exact for listed finite cases, not a proof. The 48B symmetric kernel estimate and the other analytic identities above are elementary derivations subject to peer review and not asserted novel.

The open technical gates are (i) strict compiled owner/source-section identity on one pinned Lean toolchain, (ii) owner-specific Jensen source composition, (iii) exact source variance/owned energy budgets in the same theorem type, and (iv) strict terminal finite Q2 proof/axiom receipt. The finite→measurable lift and historical novelty are separate.

Cheapest decisive experiment: compile the three PR #443 declarations with the fully resolved actual-source imports, then specialize the certified PR #445 Hilbert Jensen to owner projection, and finally compose the already proved fourth-moment and section estimates. For prior art, demand a source-law-preserving, alphabet-independent influence extraction written line-by-line before promoting categorical Grothendieck subsumption.