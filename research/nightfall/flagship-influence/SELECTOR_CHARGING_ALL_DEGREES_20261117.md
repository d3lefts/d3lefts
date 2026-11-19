# NIGHTFALL: source-exact categorical selector-charge theorem at every degree

**Checkpoint:** 2026-11-17 US Eastern. **Status:** author-side analytical proof using classical total variance + Efron–Stein + Popoviciu; independently tested against 115 exact full-state rational examples. NOT the unrestricted cubic/all-degree exponent-two conjecture; no Lean, non-author referee, or novelty certification. This is a reusable **structural class theorem**.

## Theorem: an arbitrary-alphabet selector charges its own influence

Let \(A=(A_1,\ldots,A_k)\) be k mutually independent **finite categorical** address coordinates with arbitrary probability laws, zero-mass address values permitted. For each address tuple \(a\) in the support, let \(L_a\) be a collection of at most \(t\) **fresh, disjoint** leaf coordinates, all independent of A and of one another, with arbitrary probability spaces and laws. Choose an arbitrary real measurable bounded leaf-block function \(g_a(Y_{L_a})\), and define
\[
f(A,Y)=g_A(Y_{L_A}).
\]
Assume \(k+t\ge1\), and write \(V=\operatorname{Var}(f)\), \(M=\sup_i I_i(f)\) for genuine original-law resampling influence, and \(B(f)=\frac12\operatorname{ess\,osc}(f)\). Then
\[
\boxed{\quad V\le(k+t)M,\qquad V^2\le(k+t)B(f)^2M.\quad}
\]
The canonical Efron–Stein degree of f is at most \(k+t\) because it is a sum of address-cylinder indicators (depending on at most k coordinates) times leaf-block functions (depending on at most t coordinates). Consequently **N-UE2(2,1) holds for this entire class**, with the stronger coefficient \(k+t\) instead of \((k+t)^2\). The bound is independent of the number of leaf blocks, their alphabets/biases, address alphabet cardinalities, and number of distinct address tuples.

### Proof with actual-law influences

Let \(p_a=\Pr(A=a)\), \(\mu_a=\mathbb E[g_a]\), \(v_a=\operatorname{Var}(g_a)\). Conditioning on the entire leaf collection Y gives the exact tower
\[
V=\mathbb E_Y\operatorname{Var}_A(f\mid Y)+\operatorname{Var}_Y(\mathbb E_A[f\mid Y]).
\]
For the first term, Efron–Stein on the **k actual independent address coordinates**, conditional on Y, yields
\[
\mathbb E_Y\operatorname{Var}_A(f\mid Y)\le\sum_{j=1}^k I_{A_j}(f)\le kM.
\]
Because disjoint leaf blocks are independent,
\[
\operatorname{Var}_Y(\mathbb E_A[f\mid Y])
=\operatorname{Var}_Y\big(\sum_a p_ag_a(Y_{L_a})\big)
=\sum_a p_a^2 v_a.
\]
Apply Efron–Stein inside each leaf block:
\[
 v_a\le\sum_{i\in L_a}I_i(g_a),\quad I_i(f)=p_aI_i(g_a)\ (i\in L_a).
\]
Thus
\[
\sum_a p_a^2v_a\le\sum_a p_a\sum_{i\in L_a}I_i(f)
\le\sum_a p_a t M=t M.
\]
This proves \(V\le(k+t)M\). Classical Popoviciu \(V\le B(f)^2\) gives \(V^2\le(k+t)B(f)^2M\). QED.

## Strong cubic corollary

For **two arbitrary categorical address coordinates** and one independent leaf coordinate per address tuple, every bounded selector function has Efron–Stein degree ≤3 and
\[
\boxed{\quad \operatorname{Var}(f)^2\le3B(f)^2\max_i I_i(f).\quad}
\]
This requires neither fair bits nor any bound on address alphabet size or overlap of the address-leaf triplets. It is a restricted cubic **source-law exponent-two** theorem with coefficient 3, independent of the selector table size. It improves the generic cubic top-cover coefficient on this particular structural subfamily; it does NOT establish unrestricted cubic exponent two.

For one categorical address site and one leaf per address (degree two), the theorem gives \(V^2\le2B^2M\). The exact uniform address counterexample in `DEGREE_TWO_CATEGORICAL_ADDRESS_NO_GO_20261117.md` lies in this class: it refutes the stronger *inverse-degree root-sum* shortcut, yet this charge theorem handles it by assigning the selector's large original influence to the first tower term.

## Independent audit, transfer and limits

- `python3 -I research/nightfall/flagship-influence/check_categorical_selector_terminal_exact.py` independently enumerates full product states, the original conditional variance for **every** address/leaf coordinate, centered radius, and the leaf-projection tower. Tests 115 distinct exact-Fraction skew-bias cases for (k,t)=(1,1),(1,2),(2,1),(2,2).
- Source classification: finite-product analytic proof, **not a Lean theorem**, no non-author proof review or dated priority signoff. All proof ingredients classical. Avoid presenting as a universal novel bound.
- **Required independence:** address coordinates independent, leaf blocks pairwise disjoint and independent; arbitrary correlated/reused leaf variables or general overlapping ANOVA hypergraphs are excluded.
- **Transfer/operator:** source-law tower decomposition converts hidden selector activation variance to original address-coordinate influences, overcoming the false uncoupled ℓ¹(L²) budget. Next test: replace disjoint leaves by overlapping leaves and identify the weakest collision/overlap statistic that preserves an O(d²) coefficient, then tackle source-consistent cubic replica networks (#803).

**Discovery graph:** categorical address compression → false root-gradient budget → original-source conditional variance tower → address influence charge + leaf Efron–Stein → V≤(k+t)M → cubic C=3 selector theorem → overlapping-leaf open gate.
