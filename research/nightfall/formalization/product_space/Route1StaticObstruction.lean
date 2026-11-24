import Mathlib

/-! Exact finite support geometry for the static Route 1 representation obstruction.
The alphabet and latent dimension are unrestricted finite types. No probability
or entropy premise is used in the footprint theorem. The later entropy terminal
states its information-theoretic inputs explicitly. -/

open Finset
namespace Nightfall.Route1StaticObstruction

variable {J I A B : Type*} [Fintype J] [DecidableEq J]
  [Fintype I] [DecidableEq I] [DecidableEq A] [DecidableEq B]

def footprint (dep : I → Finset J) (j : J) : Finset I :=
  univ.filter (fun i => j ∈ dep i)

def diff (x y : I → B) : Finset I :=
  univ.filter (fun i => x i ≠ y i)

def box (S : J → Finset A) : Set (J → A) :=
  {z | ∀ j, z j ∈ S j}

def active (S : J → Finset A) : Finset J :=
  univ.filter (fun j => 1 < (S j).card)

/-- A one-coordinate change in a product rectangle changes only its footprint.
Injective recovery and minimum code distance force every active footprint to
have size at least D. -/
theorem active_footprint_ge
    (dep : I → Finset J) (Phi : (J → A) → I → B)
    (S : J → Finset A) (z : J → A) (hz : z ∈ box S)
    (D : ℕ)
    (hloc : ∀ i x y, (∀ j ∈ dep i, x j = y j) → Phi x i = Phi y i)
    (hinj : Set.InjOn Phi (box S))
    (hdist : ∀ x y, x ∈ box S → y ∈ box S → Phi x ≠ Phi y →
      D ≤ (diff (Phi x) (Phi y)).card)
    (j : J) (hj : j ∈ active S) :
    D ≤ (footprint dep j).card := by
  classical
  have hjc : 1 < (S j).card := (mem_filter.mp hj).2
  have hza : z j ∈ S j := hz j
  obtain ⟨a, ha, hne⟩ := Finset.exists_mem_ne hjc (z j)
  let y := Function.update z j a
  have hy : y ∈ box S := by
    intro k
    by_cases hk : k = j
    · subst k
      simpa [y] using ha
    · simpa [y, Function.update_of_ne hk] using hz k
  have hzy : z ≠ y := by
    intro he
    have h := congrFun he j
    have h' : z j = a := by simpa [y] using h
    exact hne h'.symm
  have hp : Phi z ≠ Phi y := fun h => hzy (hinj hz hy h)
  apply (hdist z y hz hy hp).trans
  apply card_le_card
  intro i hi
  apply mem_filter.mpr
  refine ⟨mem_univ _, ?_⟩
  by_contra hn
  have he : Phi z i = Phi y i := hloc i z y (by
    intro k hk
    have hkj : k ≠ j := by
      intro h
      subst k
      exact hn hk
    simp [y, Function.update_of_ne hkj])
  exact (mem_filter.mp hi).2 he

/-- Double count dependency incidences. -/
theorem footprint_sum (dep : I → Finset J) :
    (∑ j, (footprint dep j).card) = ∑ i, (dep i).card := by
  classical
  simp only [footprint, Finset.card_filter]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  simp

/-- Active-coordinate count in a recoverable code-supported product rectangle. -/
theorem active_count_bound
    (dep : I → Finset J) (Phi : (J → A) → I → B)
    (S : J → Finset A) (z : J → A) (hz : z ∈ box S)
    (D b : ℕ) (hb : ∀ i, (dep i).card ≤ b)
    (hloc : ∀ i x y, (∀ j ∈ dep i, x j = y j) → Phi x i = Phi y i)
    (hinj : Set.InjOn Phi (box S))
    (hdist : ∀ x y, x ∈ box S → y ∈ box S → Phi x ≠ Phi y →
      D ≤ (diff (Phi x) (Phi y)).card) :
    (active S).card * D ≤ Fintype.card I * b := by
  classical
  calc
    (active S).card * D = ∑ j ∈ active S, D := by simp
    _ ≤ ∑ j ∈ active S, (footprint dep j).card :=
      sum_le_sum (fun j hj => active_footprint_ge dep Phi S z hz D hloc hinj hdist j hj)
    _ ≤ ∑ j, (footprint dep j).card :=
      sum_le_sum_of_subset_of_nonneg (subset_univ _) (fun _ _ _ => Nat.zero_le _)
    _ = ∑ i, (dep i).card := footprint_sum dep
    _ ≤ ∑ i : I, b := sum_le_sum (fun i _ => hb i)
    _ = Fintype.card I * b := by simp

/-- Numerical terminal: if a source of entropy k log 2 has component entropy
at most (bnr/D) log 2, its information is at least the stated difference.
This does not itself establish the entropy identity or the recovery alphabet bound. -/
theorem exact_information_terminal
    (k n b r D Hcond info : ℝ) (hD : 0 < D)
    (hentropy : Hcond ≤ b * n * r / D * Real.log 2)
    (hinfo : info = k * Real.log 2 - Hcond) :
    (k - b * n * r / D) * Real.log 2 ≤ info := by
  rw [hinfo, sub_mul]
  linarith

/-- A linear product-score bound follows from the exact information terminal.
Parameters alpha and beta encode k >= alpha*n and D >= beta*n. -/
theorem score_lower_bound
    (n alpha beta cost info : ℝ) (hn : 0 < n) (ha : 0 < alpha) (hb : 0 < beta)
    (hc : 1 ≤ cost) (hi : 0 ≤ info)
    (hinfo : (alpha * n - cost / beta) * Real.log 2 ≤ info) :
    min (alpha * beta / 2) (alpha * Real.log 2 / 2) * n ≤ cost * (1 + info) := by
  have hlog : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  by_cases h : alpha * beta * n / 2 ≤ cost
  · have hm : min (alpha * beta / 2) (alpha * Real.log 2 / 2) * n ≤ alpha * beta / 2 * n :=
      mul_le_mul_of_nonneg_right (min_le_left _ _) hn.le
    have hp : cost ≤ cost * (1 + info) := by nlinarith
    linarith
  · have h' : cost / beta ≤ alpha * n / 2 := by
      apply (div_le_iff₀ hb).2
      push_neg at h
      nlinarith
    have hx : alpha * n / 2 * Real.log 2 ≤ info := by
      have hh : alpha * n / 2 ≤ alpha * n - cost / beta := by linarith
      exact (mul_le_mul_of_nonneg_right hh hlog).trans hinfo
    have hm : min (alpha * beta / 2) (alpha * Real.log 2 / 2) * n ≤ alpha * Real.log 2 / 2 * n :=
      mul_le_mul_of_nonneg_right (min_le_right _ _) hn.le
    have hp : info ≤ cost * (1 + info) := by nlinarith
    nlinarith

end Nightfall.Route1StaticObstruction

#print axioms Nightfall.Route1StaticObstruction.active_footprint_ge
#print axioms Nightfall.Route1StaticObstruction.footprint_sum
#print axioms Nightfall.Route1StaticObstruction.active_count_bound
#print axioms Nightfall.Route1StaticObstruction.exact_information_terminal
#print axioms Nightfall.Route1StaticObstruction.score_lower_bound
