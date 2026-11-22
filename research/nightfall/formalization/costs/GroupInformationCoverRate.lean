import GroupInformationCoverDual

/-!
# Information-cover theorem A2: exact rate converse and matched 3-cycle LP

This moves the duality lemma into the *original group-incidence expected
experiment-count* scaling. The decisive oracle-specific implication
(η-small Bayes error ⇒ minimum reciprocal-KL expected exposure at every
active coordinate), the unbounded-stopping KL theorem, and the attaining
sequential SPRT construction still require genuine independent source proofs.
These statements alone do NOT certify A2.
-/

namespace Nightfall.InformationCoverRate

open Finset Nightfall.InformationCover

variable {I Q : Type*} [Fintype I] [Fintype Q]

/-- Exact information cost forced by KL exposure constraints for all
nonnegative expected group-query counts N_q. This theorem does not
assume an oracle KL inequality: hcoverage IS the missing statistical
consequence, and the claimed conclusion follows for arbitrary groups.
The multiplier L is the effective log(1/η) minus the instance constant. -/
theorem expected_group_cost_lower
    (G : Q → I → Prop)
    (d : I → ℝ) (cost : Q → ℝ)
    (N : Q → ℝ) (dual : I → ℝ) (L : ℝ)
    (hN : ∀ q, 0 ≤ N q)
    (hy : ∀ i, 0 ≤ dual i)
    (hdual : ∀ q, groupPrice G dual q ≤ cost q)
    (hcoverage : ∀ i, L / d i ≤ load G N i) :
    L * (∑ i, dual i / d i) ≤ ∑ q, cost q * N q := by
  have h := group_information_cover_weak_duality G
    (fun i => L / d i) cost N dual hN hy hcoverage hdual
  calc
    L * (∑ i, dual i / d i) =
        ∑ i, (L / d i) * dual i := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i hi
      ring
    _ ≤ ∑ q, cost q * N q := h

/-- The source three-cycle family has three cost-one experiments, each
observing exactly the *other* two signs. This is equivalent by
relabeling to the edge groups {0,1}, {1,2}, {0,2}. -/
def triangleGroup (q i : Fin 3) : Prop := q ≠ i

theorem triangle_uniform_load (i : Fin 3) :
    load triangleGroup (fun _ : Fin 3 => (1 / 2 : ℝ)) i = 1 := by
  fin_cases i <;> norm_num [load, triangleGroup, Fin.sum_univ_three]

theorem triangle_uniform_dual (q : Fin 3) :
    groupPrice triangleGroup (fun _ : Fin 3 => (1 / 2 : ℝ)) q = 1 := by
  fin_cases q <;> norm_num [groupPrice, triangleGroup, Fin.sum_univ_three]

/-- Exact LP matching *late-task* lower bound κ({0,1,2}) ≥3/2
for equal coordinate KL rates d_i=1 and unit group costs. -/
theorem triangle_late_cost_lower
    (N : Fin 3 → ℝ)
    (hN : ∀ q, 0 ≤ N q)
    (hcoverage : ∀ i, 1 ≤ load triangleGroup N i) :
    (3 / 2 : ℝ) ≤ ∑ q, N q := by
  have h := group_information_cover_weak_duality triangleGroup
    (fun _ : Fin 3 => (1 : ℝ))
    (fun _ : Fin 3 => (1 : ℝ))
    N (fun _ : Fin 3 => (1 / 2 : ℝ))
    hN (by intro i; norm_num) hcoverage
    (by intro q; simpa [one_div] using (triangle_uniform_dual q).le)
  norm_num [Fin.sum_univ_three] at h ⊢
  exact h

/-- Matching feasible three-cycle point: each group sampled 1/2 unit,
total group expenditure 3/2, proving exact LP optimality. -/
theorem triangle_late_cost_upper :
    (∀ i : Fin 3, 1 ≤ load triangleGroup
      (fun _ : Fin 3 => (1 / 2 : ℝ)) i) ∧
    (∑ q : Fin 3, (1 / 2 : ℝ)) = (3 / 2 : ℝ) := by
  constructor
  · intro i
    rw [triangle_uniform_load i]
  · norm_num [Fin.sum_univ_three]

/-- The early task knows i, and can buy half a sample of each of the two
groups that contain i, attaining cost exactly 1. -/
theorem triangle_singleton_cost_upper (i : Fin 3) :
    (∀ q : Fin 3, 0 ≤ (if q = i then (0 : ℝ) else 1 / 2)) ∧
    1 ≤ load triangleGroup
      (fun q : Fin 3 => if q = i then (0 : ℝ) else 1 / 2) i ∧
    (∑ q : Fin 3, if q = i then (0 : ℝ) else 1 / 2) = 1 := by
  constructor
  · intro q
    split_ifs <;> norm_num
  · fin_cases i <;> norm_num [load, triangleGroup, Fin.sum_univ_three]

end Nightfall.InformationCoverRate

#print axioms Nightfall.InformationCoverRate.expected_group_cost_lower
#print axioms Nightfall.InformationCoverRate.triangle_late_cost_lower
#print axioms Nightfall.InformationCoverRate.triangle_late_cost_upper
#print axioms Nightfall.InformationCoverRate.triangle_singleton_cost_upper
