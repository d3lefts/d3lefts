# Q2 actual-source composition ledger — 2026-11-13 (version 2; strict CI pending)

## Scope and truthful status

Branch: `nightfall-q2-owned-source-composition-20261113`; draft PR #476
stacked on PR #468. Lean target: 4.36.0-rc2, pinned Mathlib.
The theorem `ActualSourceQ2CompositionGate.actual_source_q2_structural_moment_package`
composes **one input f and one product law p** into a package whose
assumptions are only nonnegative normalized finite categorical laws,
a common nonempty alphabet (zero-mass atoms permitted), `ESDegreeLE p f 2`,
and a pointwise bound `|f(x)|≤B` with `B≥0`.

**The dimension-free Q2 inequality is not yet a compiled theorem.**
`ActualSourceQ2CompositionGate.SourceQ2Target` is only the precise
**unproved proposition**; merely declaring the proposition establishes nothing.
Do not submit, advertise, or merge this package as terminal Q2.

## Exact source quantities

Let `originalMass p` be the normalized original product law, and
`K_{ij}(a,b)` the double-centered canonical pair from the same f.

- `V := sourceVariance p f`
- `I_i := sourceInfluence p f i` (the genuine source heatbath L² influence)
- `U_i(x;a) := f(x[i←a]) - E_{b∼p_i} f(x[i←b])`
- `u_i := E_x ||U_i(x;·)||_{L²(p_i)}`
- `A_i(a) := E_x U_i(x;a)`; `a_i := ||A_i||_{L²(p_i)}`
- `M ≥ 0` a common upper bound on all `I_i`
- `c_i` the source-selected greedy endpoint amplitude cover
- `J_i` the distinct actual coordinate labels of edges owned by i
- `s_i := Σ_{j∈J_i} E[K_{ij}(X_i,X_j)^2]`
- `z_i := E_x ||Σ_{j∈J_i}K_{ij}(·,x_j)||_{L²(p_i)}`

The intended inequality is

`V² ≤ [16(1+sqrt 3)]² B² M = 256(1+sqrt 3)² B² M`.

The new source-only package `ActualSourceQ2CompositionGate` now
imports `ActualSourceOwnerOrientation`, `ActualSourceOwnedGraph`,
`ActualSourcePairEnergyBridge`, the current-source ANOVA and bounded
section modules. It includes: pointwise Σ_i ||U_i||≤8B;
canonical V and I_i Parseval identities; exact genuine pair Hilbert
energy = current-source canonical pair energy; original source pair
kernel/energy symmetry and greedy owner energy orientation; one
actual source greedy c with Σ_i c_i≤8B and genuine owned energy
partition; product sampling identification for the first norm moment;
and finite Hilbert second moment for injective original neighbors.
No legacy `ActualESOwnedSampleLaw` or `ProductSpaceTwoSidedBridge`
import is used by the new proof graph.
These are separate logical conclusions from the same f and p, not a
hidden additional source oracle.

## Remaining indispensable source-level bridges

1. **Kernel orientation and energy unification**:
   The new source pair-energy Fubini theorem and pointwise
   source-derived pair swap/energy-swap and owner orientation lemmas are
   written, but CI still must compile them. Next identify the exact
   distinct-neighbor finite Hilbert moment with the **owned** canonical
   energy `s_i` by a provable reindexing of the source graph, and prove
   `s_i ≤ I_i ≤ M`. A separate old-kernel equivalence is no longer
   required by this source-only branch.
2. **Actual owned-section first norm**:
   The new source-owned graph derives the injective neighbor product
   law and first Hilbert norm from the same original p and f.
   It still does not identify the observable with the **conditional**
   original-source section. Historical PR #443 contains
   `ActualESOwnedObservedSource` (old compiler/representation);
   port the exact source-section equality rather than introducing a
   supplied first-moment/projection axiom.
3. **Conditional Jensen with original law**:
   Identify this owned section with
   `E[U_i(·;a) | X_{J_i}] - A_i(a)` and derive
   `z_i ≤ u_i + a_i`, with the actual original mass and no
   synthetic independent coordinates.
4. **Source scalar bookkeeping**:
   Prove `a_i≤u_i` and `Σ_i u_i≤8B` by integrating the
   pointwise source budget; show `V=Σ_i a_i²+Σ_i s_i`;
   derive `a_i≤sqrt M`, `z_i≤sqrt M` from actual energies.
   Compose the actual owner endpoint
   `s_i≤z_i(c_i+sqrt(3M))` using the existing finite Hilbert fourth
   moment and the cap established in step 1.
5. **One terminal Lean theorem**:
   Invoke `q2_scalar_squared_from_single_source_section_budget`
   with these *derived* data. The final declaration must have
   **no supplied energy, cover, moment, projection, or variance hypotheses**;
   only source p, f, B, degree, and finite probability-law assumptions.
   Check the nontrivial and empty/singleton coordinate cases,
   deterministic coordinates, arbitrary nonuniform and zero-mass atoms.

## Audit and certificate plan

- The new CI builds the exact local import closure, checks all source
  declarations against the pinned compiler, rejects sorry-style shortcuts
  and unapproved axioms, and records a per-commit receipt and source SHA.
- A previous historical proof on a different compiler pin is not a
  certificate for the current branch.
- Numerical tests should use independently implemented exact rational
  laws including deterministic/zero-mass atoms and multiple orientations,
  but **finite tests cannot establish the universal inequality**.
- After a green Lean receipt: independent theorem statement inspection,
  axiom-closure inspection, dependency/orientation audit, and dated
  prior-art comparison before any novelty claim.

## Independent audit prediction

A failure is expected if an owned edge's chosen orientation and the
source Hilbert increment's `i,j` orientation are silently swapped,
or if the finite sample law is used to infer a *conditional* source
projection identity without separately establishing it. Such a failure
must block terminal promotion, even when the aggregate energy partitions
and the first two sample moments are each individually correct.

## CI failures and repairs logged (v2)

1. Historical owner graph closure failed with `unknown module prefix 'AaronsonAmbainis'` through `ProductSpaceTwoSidedBridge`. The new source-only `ActualSourceOwnedGraph` removes this dependency, using original-source `ActualSourceFiniteSampleLaw` and `ActualSourceFinitePairMoment` directly.
2. A later strict run reached `ActualSourceMatchingCover` and failed on `open Nightfall.Observability.WeightedGreedyMatching`; the actually defined namespace is `Nightfall.Observability.WeightedGreedy`. Corrected the import alias on the PR #476 source branch. Other downstream failures/remaining CI checks must be inspected before certification.
3. No successful full strict source-composition receipt was available at this revision. Do not promote either the source-only structural package or the terminal exponent-two target without a passing pinned Lean run and separate scope review.
