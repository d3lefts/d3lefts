# Q2 actual-source conditional representation and energy checkpoint

Date: 2026-11-13. PR: https://github.com/d3lefts/d3lefts/pull/425.
Branch: nightfall-q2-conditional-section-bridge-20261113.

## Exact objective
Formalize, without imported section or energy oracle, the map
original finite product source -> genuine coordinate-centered sections ->
conditional expectation on distinct actual neighbor coordinates ->
canonical Efron–Stein support sum -> Hilbert Jensen / original influence
and ANOVA energy.

The manuscript target remains the finite degree-two exponent-two inequality
Var(f)^2 <= C_2 B^2 max_i I_i(f). Neither 1679.42 nor 1228.356 is a
terminal kernel certificate. No external novelty/referee gate has passed.

## Machine-certified source theorems

**Lean 4.33.0 / historical Turturean upstream commit
2a6ceaef872ae993708950f951989134084b851a.**
Only standard axioms: Classical.choice, Quot.sound, propext.

1. https://github.com/d3lefts/d3lefts/actions/runs/43485876852
   - ActualESConditionalSection.average_source_section_eq_condExp_difference:
     average of the original centered source section over non-retained
     coordinates = conditional expectation retained on S+{i} minus that on S.
   - ActualESConditionalSection.actual_condExp_jensen_square and
     actual_section_conditional_jensen_square: scalar finite Jensen.
   - ActualESConditionalProjection.actual_condExp_es_expansion,
     actual_source_section_es_projection,
     actual_degree_two_section_es_projection: canonical interaction support
     sum from the real source, truncated at size <=2 by ESDegreeLE.
     SHA256 (projection): 2aa1dc0f90f845c9646735aef26bbf090a1f269d20f4efa070b18c4ab52b54e1.
   - ActualESConditionalJensen.weighted_hilbert_jensen,
     actual_source_section_hilbert_jensen: weighted Hilbert L1 norm
     contraction; SHA256:
     98dddf6ae78925c072547564d8dfcfa719da5bc141f64e0e9aafe0358ea1dc56.
2. https://github.com/d3lefts/d3lefts/actions/runs/43487578536
   - ActualESSourceEnergy.weighted_centered_eq_pair and
     actual_source_section_energy_eq_influence, proving exact equality
     between original-source centered section L2 energy and original
     resampling influence; SHA256:
     4c99b284a0392ba8da3651a30a56b26f2d56bd283764b0aed0a73ef4b59eba53.
3. https://github.com/d3lefts/d3lefts/actions/runs/43487847135
   - ActualESOrthogonality.centered_orthogonal_to_dependsOn and
     actual_esComp_orthogonal: different canonical support components
     are orthogonal in the original finite product source law.
     SHA256:
     e4912944d3f5d229ab3b8f227ee2c8c113a91685972df25a42158cf58698fb76.

All results are classical finite-theorem certificates; successful
compilation does not establish novelty or an unconditional Q2 exponent.

## Independent falsification
check_actual_conditional_sections.py independently reconstructs the
conditional section and canonical singleton/pair interaction from original
source values with exact Fraction arithmetic. Models vary the marginal
laws, include small heterogeneous alphabets and zero/rare-mass atoms, and
check Jensen, source-section energy equals influence, and off-diagonal
orthogonality. The finite checker is not a universal proof. Its current
source hash and pass counts must be obtained from the latest CI receipt.

## Pending checked declaration
ActualESVarianceEnergy.lean contains a source-derived general Parseval
identity and a degree-two variance-to-singleton/pair-energy equality,
using the certified orthogonality theorem. Await strict compiler
confirmation; never promote the file on authorship alone.

## Exact remaining chain for terminal finite Q2

- Unpack the degree-two source support sum as a true singleton term
  plus the pair interactions indexed by a Finset of assigned distinct
  neighbors, including an orientation-preserving graph edge bijection.
- Identify the real conditional Hilbert section and the independent
  increment table's product measure (finite pushforward/Fubini lemma),
  and prove its second moment equals the assigned canonical pair energy.
- Combine that identification with original-source variance and
  influence energies; prove s_i <= I_i(f) with no supplied energy budget.
- Import the proved actual-source matching mass/8B owner cover from
  draft PR #424, then compose the section-oscillation/additive budgets
  and fourth-moment endpoint to one kernel theorem whose displayed
  premises are only the source product law, pointwise boundedness and
  degree two. Distinguish v7 vs v8 numerical constants.
- Extend from a common finite ambient alphabet with coordinate-varying
  p_i to actual heterogeneous coordinate types and support-reduced
  almost-sure bounds. A boundedness proof on zero-mass inputs is not
  implied by an almost-sure bound.
- Replay dependencies on the repository 4.35.0 pin; historical 4.33.0
  proofs do not supply a 4.35.0 certificate automatically. Then
  undertake measurable-product lift and external prior-art review.

## Operator/transfer
Mechanism: source coordinate resampling -> vanishing of centered missing
support -> retained canonical ANOVA components -> Hilbert norm
contraction -> original-source influence energy. This works at all
finite Hoeffding degrees for the untruncated projection, and therefore
transfers beyond the quadratic endpoint in the bounded-degree
representation layer. It does not transfer a fourth-moment or Q2
constant without additional arguments.

Status: first three stages strictly certified (receipts above);
source Parseval and terminal Q2 pending. No merge/release authorization.
