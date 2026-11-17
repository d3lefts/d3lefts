import Mathlib
import F9CalibratedRow

/-!
# All-support GF9 sign normal form

Every finite square-profile source is a global sign times a normalized
source whose other coordinates are independent binary sign choices,
including sparse/zero-support sources. This is an actual all-length algebraic
source theorem. It is a prerequisite, NOT the full legally observed adaptive
squared-linear transcript injection.
-/

namespace Nightfall.FiniteField.F9AllSupportNormalForm
open Nightfall.FiniteField.F9CalibratedRow
abbrev F9 := Nightfall.FiniteField.F9ActualField.F9
noncomputable section

def normalizedSource {n : ℕ}
    (r : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) : Fin (n + 1) → F9 :=
  Fin.insertNth a (r a)
    (fun j => if bits j then r (a.succAbove j) else -r (a.succAbove j))

theorem square_profile_normalized {n : ℕ}
    (r : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) (i : Fin (n + 1)) :
    (normalizedSource r a bits i) ^ 2 = (r i) ^ 2 := by
  rcases Fin.eq_self_or_eq_succAbove a i with rfl | ⟨j, rfl⟩
  · simp [normalizedSource]
  · by_cases hb : bits j
    · simp [normalizedSource, hb]
    · simp [normalizedSource, hb, pow_two]

noncomputable def orientationBits {n : ℕ}
    (x r : Fin (n + 1) → F9) (a : Fin (n + 1)) :
    Fin n → Bool := by
  classical
  exact fun j =>
    if x a = r a then
      decide (x (a.succAbove j) = r (a.succAbove j))
    else
      decide (-x (a.succAbove j) = r (a.succAbove j))

/-- Every source with the given square roots has a global-sign representative
whose entire remaining support is represented by a Boolean sequence. -/
theorem square_profile_has_normal_form {n : ℕ}
    (x r : Fin (n + 1) → F9) (a : Fin (n + 1))
    (hsq : ∀ j, (x j) ^ 2 = (r j) ^ 2) :
    x = normalizedSource r a (orientationBits x r a) ∨
      x = -normalizedSource r a (orientationBits x r a) := by
  classical
  have hsign (j : Fin (n + 1)) :
      x j = r j ∨ x j = -r j := by
    have hh : x j * x j = r j * r j := by
      simpa only [pow_two] using hsq j
    exact (mul_self_eq_mul_self_iff).mp hh
  by_cases ha : x a = r a
  · left
    funext i
    rcases Fin.eq_self_or_eq_succAbove a i with rfl | ⟨j, rfl⟩
    · simpa [normalizedSource] using ha
    · by_cases hj : x (a.succAbove j) = r (a.succAbove j)
      · simp [normalizedSource, orientationBits, ha, hj]
      · have hjneg := (hsign (a.succAbove j)).resolve_left hj
        simp [normalizedSource, orientationBits, ha, hj, hjneg]
  · right
    funext i
    rcases Fin.eq_self_or_eq_succAbove a i with rfl | ⟨j, rfl⟩
    · have hneg := (hsign a).resolve_left ha
      simp [normalizedSource, hneg]
    · have hj : -x (a.succAbove j) = r (a.succAbove j) ∨
          -x (a.succAbove j) = -r (a.succAbove j) := by
        rcases hsign (a.succAbove j) with h | h
        · right
          simp [h]
        · left
          simp [h]
      by_cases heq : -x (a.succAbove j) = r (a.succAbove j)
      · simp [normalizedSource, orientationBits, ha, heq]
      · have hjneg := hj.resolve_left heq
        simp [normalizedSource, orientationBits, ha, heq, hjneg]

#print axioms Nightfall.FiniteField.F9AllSupportNormalForm.square_profile_normalized
#print axioms Nightfall.FiniteField.F9AllSupportNormalForm.square_profile_has_normal_form

end
end Nightfall.FiniteField.F9AllSupportNormalForm
