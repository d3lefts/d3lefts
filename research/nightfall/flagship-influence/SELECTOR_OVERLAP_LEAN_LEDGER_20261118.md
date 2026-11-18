# NIGHTFALL selector overlap: kernel-certificate and discovery ledger v0.1
2026-11-18 • source custody: branch nightfall-selector-overlap-lean-20261118

## Claim and scope

Let A=(A_1,...,A_k) be independent finite-valued categorical address
coordinates with arbitrary original probabilities (zero atoms allowed).
Let Y_i be independent arbitrary-valued leaf coordinates. Every address
value a chooses an arbitrary set L_a of at most t leaf coordinates,
**without any disjointness assumption**, and a bounded measurable
g_a(Y_{L_a}). Define f(A,Y)=g_A(Y_{L_A}). All conditional expectations,
coordinate residuals, variances and influences are under the SAME
original product law. Define B=half the essential range, M=maximum
original-law coordinate resampling influence and
w_i = P_A(i belongs to L_A).

**Author-side analytic theorem**:
  Var(f) <= sum_(j=1)^k I_(A_j)(f) + sum_i w_i I_(Y_i)(f)
         <= (k + t) M.
  Var(f)^2 <= (k+t) B^2 M.

Proof: total-variance decomposition conditional on the entire Y:
  Var(f)=E_Y Var_A(f|Y)+Var_Y(E_A f|Y).
The first term is <=sum_j I_(A_j)(f) by the *classical original-law*
Efron--Stein inequality for k independent address coordinates.
For each leaf i, D_i(E_A f)=sum_{a:i in L_a}p_a D_i g_a.
The **newly factored exact weighted row inequality** is
  |sum_a p_a D_i g_a(y)|^2
   <= w_i sum_{a:i in L_a}p_a |D_i g_a(y)|^2,
including zero p_a. Integrate in original leaf law. The right side
is w_i I_(Y_i)(f) because the address is part of the conditioning
complement in the actual source residual. Classical Efron--Stein on
E_A f closes the weighted bound. Sum_i w_i = E_A |L_A| <= t.
Popoviciu yields Var(f)<=B^2. No hidden max/expectation exchange.

The number of addresses, address alphabet size and their biases do not
enter t. The sets L_a may all share the same leaves or overlap densely.

## Exactly what Lean proves, and what it does not

Module: research/nightfall/formalization/universal/SelectorOverlapWeighted.lean

- finite_weighted_cauchy: **unconditional** weighted Cauchy--Schwarz
  over any finite address set; zero weights permitted.
- finite_source_weighted_row_energy: **unconditional** quadratic row
  bound after integrating over an arbitrary finite source sample law q.
- finite_source_weighted_overlap_energy: **unconditional** simultaneous
  source-weighted bound over all leaf sites; masks may overlap.
- selector_weighted_terminal_from_source_obligations: **conditional**
  scalar final consequence. Hypotheses explicitly provide the actual
  original-law variance/conditional Efron--Stein/activation budget.
  These hypotheses are NOT discharged from an explicit product measure
  by this Lean file. A passing Lean gate certifies the weighted operator
  and conditional implication, NOT end-to-end original-source theorem.

The analytical source-specific proof above closes the omitted classical
Poincare/conditional-expectation derivation on paper; a *separate Lean*
native-source bridge must show that all assumptions are realized by
finite discrete original-product selector functions. Needed subsequent
Lean declarations:
1. normalized original finite product mass and g_A table mean;
2. true-source residual identity for address/leaf coordinates,
   including arbitrary zero-weight letters and overlapping L_a;
3. source-total-variance decomposition;
4. finite original-source Efron--Stein on both blocks;
5. actual budget sum_i w_i <=t under |L_a|<=t.
No source-specific theorem or all-degree N-UE2 claim may be promoted
until all five are independently compiled and audited.

## Research classification and next decisive test

- **Proved analytic subfamily:** selectors, arbitrary categorical
  alphabets and overlapping sets with uniform active-set size<=t.
- **Not proved:** one-block decoupled h(a,u)=sum_i a_i H_i(u)
  whose H_i may each depend on arbitrarily many controls despite
  total polynomial degree<=d. There t need not be bounded by d.
- **Proposed operator:** replace literal support size |L_a| by an
  effective *switching-active dimension* cost. Test against
  categorical f=Y_A, fair addressing, and dense cubic routing.
- Adversarial warning: replacing weighted source charge by
  sum_i sqrt(I_i) or swapping E max with max E is invalid.
- Novelty: classical Efron--Stein/Popoviciu/Cauchy--Schwarz;
  structural assembly not priority-audited; no publication claim.
- Independent exact checker: check_selector_overlap_source_exact.py.
  Exact finite cases are regression, NOT a proof for all products.

Credit: NIGHTFALL program; previous disjoint-selector PR #811;
classical Efron--Stein, Cauchy--Schwarz and Popoviciu. Keep all earlier
disjoint theorem receipts unchanged, maintain draft until Lean actual
exact-head PASS and source-leaf bridge audit.


## v0.2 source activation-budget certificate (2026-11-18)

Added unconditional Lean theorem source_activation_budget in
Nightfall.SelectorOverlap. It derives directly from nonnegative
normalized original finite categorical weights and Boolean masks:

  sum_i Pr_A(i active at A) = sum_a p_a |L_a| <= t.

Disjointness and positive atom floors are NOT assumed. Exact-head
strict named kernel run 44248073683 PASSED at HEAD
79a9af79c810b0a81b161ccdc71d9717db58d4d6.

**Full native-source bridge still OPEN:** prove source-to-selector
residual identification for f and E_A f and the total-variance tower,
and apply the already certified all-degree native original-source
Efron--Stein theorem in ActualSourceEfronStein.lean to address and
leaf blocks. This Lean module DOES NOT supply these original f-based
operator identities. The end-to-end selector theorem is author-side,
not fully Lean certified; no stronger passport can be issued.

## Dense-versus-sparse continuation (not an all-degree theorem)

Occupancy alone can be arbitrarily weak even at degree one: on n
fair signs, f_n=(sum_i Y_i)/n has B=1, V=1/n and M=1/n^2,
while all n leaves are active. The occupancy charge nM=1/n
is n-fold weaker than the sharp V<=B sqrt(M)=1/n. Thus no bound
of occupancy solely by a degree polynomial can hold, even for d=1.

Complementary source-operator mechanism (already foreshadowed by
merged cubic top-cover PR #787): if the leaf average g=E_A f has
ANOVA degree at most 2, the certified Q2 C2 bound gives
Var(g)<=sqrt(C2) B sqrt(M) without leaf support limits.
Consequently the two existing mechanisms can be combined as

  Var(f) <= sum_(j in A) I_j(f)
     + min{sum_i w_i I_i(f), sqrt(C2) B sqrt(M)}.

For degree-one g, replace sqrt(C2) by 1. This is an analytic
recombination of classical tools and the previously certified
Q2/top-cover program, NOT an original or unrestricted UE2 result.

**Missing breakthrough:** an effective switching-energy charge for
dense, high-degree, overlapping control functions. No inference to
N-UE2(6), N-UE2(2) or Turturean's real-row question.


## v0.3 exact-head integrated six-theorem certificate (2026-11-18)

**PINNED LEAN / SOURCE EXACT PASS**: [GitHub Actions run 44248959076](https://github.com/d3lefts/d3lefts/actions/runs/44248959076), source head `164666e94da621ee8d7f4100a747262aabedf084`. All named declarations compiled under pinned Lean 4.36.0-rc2 and the repository's pinned Mathlib; strict Lean bridge accepted only foundational axioms, and the independent original-law exact Fraction checker passed all 72 original-product cases, including variable-size overlapping supports and null atoms.

A sixth unconditional named Lean theorem, `source_overlap_leaf_energy_le_activation_max`, now composes `finite_source_weighted_overlap_energy` and `source_activation_budget`. For arbitrary nonnegative normalized original address weights p, source sample weights q, active masks with at most t active leaf sites per address, and explicit original masked leaf energies J_i≤M, it proves the **total original source-weighted selector mean row energy ≤ tM**. No disjointness of active masks or atom floor.

The six named kernel-checked declarations are: `finite_weighted_cauchy`, `finite_source_weighted_row_energy`, `finite_source_weighted_overlap_energy`, `source_activation_budget`, `source_overlap_leaf_energy_le_activation_max`, `selector_weighted_terminal_from_source_obligations` (last one **conditional**).

**Precise terminal boundary:** It is incorrect to call this a full Lean-certified original-product selector theorem. The masked row energies have not yet been identified through a native Lean statement as the resampling influences of `f(A,Y)=g_A(Y_{L_A})`, and the finite-product total-variance tower plus original address/leaf Efron–Stein compositions are still not carried through the exact selector f in Lean. Existing proven original-source all-degree Efron–Stein: `Nightfall.Observability.ActualSourceEfronStein.original_source_all_degree_efron_stein` in `research/nightfall/formalization/observability/ActualSourceEfronStein.lean`. Certification of the six lemmas DOES NOT certify unrestricted N-UE2(6) or N-UE2(2).

**Priority audit:** All main inputs weighted Cauchy–Schwarz, Efron–Stein and Popoviciu are classical; not a novelty or external peer-review receipt. This PR remains draft until native-source identification and independent audit, and no public breakthrough claim is made.
