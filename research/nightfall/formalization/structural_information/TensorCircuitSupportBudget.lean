import Mathlib

/-!
# Independent Lean formalization: circuit active-site budget

For an abstract finite family of disjoint circuit blocks, a per-block
Lovitz-Petrov-type *cardinality hypothesis* |active(E)|+2 ≤ |E| and
a total eight-row budget imply at most six active tensor sites.

The published Lovitz-Petrov circuit theorem, symmetric-difference circuit
decomposition, and source identification with tensor products are NOT
formalized here. This is a genuine kernel-checked combinatorial bridge
from those explicit hypotheses, not a full all-frequency tensor theorem
or a quantum simulation certificate.
-/

namespace Nightfall.StructuralInformation.TensorCircuitSupportBudget

variable {I : Type*} {Site : Type*}

/-- The precise finite active-support union accounting:
overlaps are allowed between different circuit supports, and each circuit
consumes two units of the total row budget before contributing sites. -/
theorem union_active_sites_plus_twice_circuit_count
    [DecidableEq Site]
    (circuits : Finset I) (active : I → Finset Site) (rows : I → ℕ)
    (hLP : ∀ c ∈ circuits, (active c).card + 2 ≤ rows c) :
    (circuits.biUnion active).card + 2 * circuits.card ≤
      ∑ c ∈ circuits, rows c := by
  classical
  have hcard : (circuits.biUnion active).card ≤
        ∑ c ∈ circuits, (active c).card :=
    Finset.card_biUnion_le
  have hsum : (∑ c ∈ circuits, ((active c).card + 2)) ≤
        ∑ c ∈ circuits, rows c :=
    Finset.sum_le_sum hLP
  calc
    (circuits.biUnion active).card + 2 * circuits.card
        ≤ (∑ c ∈ circuits, (active c).card) + 2 * circuits.card := by
          omega
    _ = ∑ c ∈ circuits, ((active c).card + 2) := by
      simp [Finset.sum_add_distrib, mul_comm]
    _ ≤ ∑ c ∈ circuits, rows c := hsum

/-- A nonempty set of disjoint circuit blocks with at most 2k total rows
has at most 2k-2 active tensor sites, *provided* every block satisfies
the published circuit support condition. This avoids subtraction in
the Lean terminal and applies for all k, not just k=4. -/
theorem fixed_order_active_support_budget
    [DecidableEq Site]
    (circuits : Finset I) (active : I → Finset Site) (rows : I → ℕ)
    (k : ℕ) (hne : circuits.Nonempty)
    (hLP : ∀ c ∈ circuits, (active c).card + 2 ≤ rows c)
    (htotal : (∑ c ∈ circuits, rows c) ≤ 2 * k) :
    (circuits.biUnion active).card + 2 ≤ 2 * k := by
  have hb := union_active_sites_plus_twice_circuit_count circuits active rows hLP
  have hp : 0 < circuits.card := Finset.card_pos.mpr hne
  omega

/-- Concrete four-slot consequence: ≤8 row occurrences across nonempty
disjoint circuits leaves ≤6 active sites. -/
theorem six_site_of_eight_rows
    [DecidableEq Site]
    (circuits : Finset I) (active : I → Finset Site) (rows : I → ℕ)
    (hne : circuits.Nonempty)
    (hLP : ∀ c ∈ circuits, (active c).card + 2 ≤ rows c)
    (htotal : (∑ c ∈ circuits, rows c) ≤ 8) :
    (circuits.biUnion active).card ≤ 6 := by
  have h := fixed_order_active_support_budget
    circuits active rows 4 hne hLP (by simpa using htotal)
  omega

#print axioms Nightfall.StructuralInformation.TensorCircuitSupportBudget.union_active_sites_plus_twice_circuit_count
#print axioms Nightfall.StructuralInformation.TensorCircuitSupportBudget.fixed_order_active_support_budget
#print axioms Nightfall.StructuralInformation.TensorCircuitSupportBudget.six_site_of_eight_rows

end Nightfall.StructuralInformation.TensorCircuitSupportBudget
