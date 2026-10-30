import Init

/-!
# Adaptive finite-field power sensing: an exact information obstruction

For d >= 2 and r >= 1, an oracle symbol alphabet of size r+1
cannot distinguish (1+((1+d*r)^k-1)/d) scalar orbits in k <= k queries
when k >= 2. This file kernel-checks the crucial strict arithmetic
inequality. The orbit-counting and adaptive decision-tree arguments
are currently documented mathematically, not formalized here.

No mathematical novelty or full decoder impossibility formalization
is claimed by this file alone.
-/

namespace Nightfall.FiniteField

private theorem square_expansion (u v : Nat) :
    ((u + 2) * (v + 1) + 1) ^ 2 =
      (u + 2) * (v + 2) ^ 2 +
      (u + 1) * ((u + 2) * v ^ 2 + (2 * u + 4) * v + (u + 1)) := by
  simp only [pow_two, Nat.add_mul, Nat.mul_add, Nat.mul_assoc,
    Nat.mul_comm, Nat.mul_left_comm]
  omega

private theorem square_core (u v : Nat) :
    (u + 2) * (v + 2) ^ 2 <
      ((u + 2) * (v + 1) + 1) ^ 2 := by
  rw [square_expansion]
  have hp : 0 <
      (u + 1) * ((u + 2) * v ^ 2 + (2 * u + 4) * v + (u + 1)) := by
    apply Nat.mul_pos
    · omega
    · omega
  omega

theorem information_square_bound (d r : Nat) (hd : 2 ≤ d) (hr : 1 ≤ r) :
    d * (r + 1) ^ 2 < (d * r + 1) ^ 2 := by
  cases d with
  | zero => omega
  | succ d =>
    cases d with
    | zero => omega
    | succ u =>
      cases r with
      | zero => omega
      | succ v =>
        simpa [Nat.succ_eq_add_one, Nat.add_assoc, Nat.add_comm,
          Nat.add_left_comm] using square_core u v

theorem information_power_bound (d r k : Nat)
    (hd : 2 ≤ d) (hr : 1 ≤ r) (hk : 2 ≤ k) :
    d * (r + 1) ^ k < (d * r + 1) ^ k := by
  have hq : r + 1 ≤ d * r + 1 := by
    have hh : 1 * r ≤ d * r := Nat.mul_le_mul_right r (by omega)
    omega
  have hp : 0 < r + 1 := by omega
  have step (j : Nat)
      (hj : d * (r + 1) ^ j < (d * r + 1) ^ j) :
      d * (r + 1) ^ (j + 1) < (d * r + 1) ^ (j + 1) := by
    rw [pow_succ, pow_succ]
    calc
      d * ((r + 1) ^ j * (r + 1)) =
          (d * (r + 1) ^ j) * (r + 1) := by ac_rfl
      _ < (d * r + 1) ^ j * (r + 1) :=
          Nat.mul_lt_mul_of_pos_right hj hp
      _ ≤ (d * r + 1) ^ j * (d * r + 1) :=
          Nat.mul_le_mul_left _ hq
  have main : ∀ t : Nat,
      d * (r + 1) ^ (t + 2) < (d * r + 1) ^ (t + 2) := by
    intro t
    induction t with
    | zero =>
        simpa using information_square_bound d r hd hr
    | succ t ih =>
        have hs := step (t + 2) ih
        simpa [Nat.succ_eq_add_one, Nat.add_assoc] using hs
  obtain ⟨t, ht⟩ : ∃ t : Nat, k = t + 2 := by
    exact ⟨k - 2, by omega⟩
  rw [ht]
  exact main t

#print axioms Nightfall.FiniteField.information_square_bound
#print axioms Nightfall.FiniteField.information_power_bound

end Nightfall.FiniteField
