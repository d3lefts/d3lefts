import Mathlib

/-!
# Law-independent finite fourth-moment bridge — genuine probability weights

For finite arbitrary alphabets A and B, and arbitrary normalized independent
marginals p and q, this module proves the exact fourth moment of a sum of two
centered **scalar** increments. It does not assume fair signs, matching graph
structure, atom floors or hypercontractivity.

It is the 2-increment scalar base case of the Hilbert-valued independent
increment lemma needed by the proposed full quadratic influence proof.
No statement in this module asserts that all higher-cardinality Hilbert
increments, matching assignments or the main quadratic theorem are proven.
-/

namespace Nightfall.Observability.QuadraticMoments

open Finset

variable {A B : Type*} [Fintype A] [Fintype B]

/-- A product of two independent finite weight tables. -/
noncomputable def jointAvg (p : A → ℝ) (q : B → ℝ)
    (F : A → B → ℝ) : ℝ :=
  ∑ a : A, ∑ b : B, p a * q b * F a b

theorem tensor_sum_factor
    (P : A → ℝ) (Q : B → ℝ) :
    (∑ a : A, ∑ b : B, P a * Q b) =
      (∑ a : A, P a) * (∑ b : B, Q b) := by
  calc
    (∑ a : A, ∑ b : B, P a * Q b) =
      ∑ a : A, P a * (∑ b : B, Q b) := by
        apply Finset.sum_congr rfl
        intro a _
        rw [Finset.mul_sum]
    _ = (∑ a : A, P a) * (∑ b : B, Q b) := by
      rw [Finset.sum_mul]

theorem jointAvg_add
    (p : A → ℝ) (q : B → ℝ)
    (F G : A → B → ℝ) :
    jointAvg p q (fun a b => F a b + G a b) =
      jointAvg p q F + jointAvg p q G := by
  unfold jointAvg
  simp only [mul_add, Finset.sum_add_distrib]

theorem jointAvg_smul
    (p : A → ℝ) (q : B → ℝ)
    (t : ℝ) (F : A → B → ℝ) :
    jointAvg p q (fun a b => t * F a b) =
      t * jointAvg p q F := by
  unfold jointAvg
  calc
    (∑ a : A, ∑ b : B, p a * q b * (t * F a b)) =
      ∑ a : A, ∑ b : B, t * (p a * q b * F a b) := by
        apply Finset.sum_congr rfl
        intro a _
        apply Finset.sum_congr rfl
        intro b _
        ring
    _ = ∑ a : A, t * (∑ b : B, p a * q b * F a b) := by
        apply Finset.sum_congr rfl
        intro a _
        rw [Finset.mul_sum]
    _ = t * (∑ a : A, ∑ b : B, p a * q b * F a b) := by
        rw [Finset.mul_sum]

theorem jointAvg_factor
    (p : A → ℝ) (q : B → ℝ)
    (F : A → ℝ) (G : B → ℝ) :
    jointAvg p q (fun a b => F a * G b) =
      (∑ a : A, p a * F a) * (∑ b : B, q b * G b) := by
  unfold jointAvg
  calc
    (∑ a : A, ∑ b : B, p a * q b * (F a * G b)) =
      (∑ a : A, ∑ b : B, (p a * F a) * (q b * G b)) := by
        apply Finset.sum_congr rfl
        intro a _
        apply Finset.sum_congr rfl
        intro b _
        ring
    _ = (∑ a : A, p a * F a) * (∑ b : B, q b * G b) :=
      tensor_sum_factor _ _

/-- Two independent arbitrary-law centered scalar increments satisfy
the standard exact fourth-moment identity. The moments refer to the
actual input tables, not an assumed abstract fourth-moment oracle. -/
theorem independent_centered_two_fourth
    (p : A → ℝ) (q : B → ℝ)
    (Y : A → ℝ) (Z : B → ℝ)
    (hp1 : (∑ a : A, p a) = 1)
    (hq1 : (∑ b : B, q b) = 1)
    (hY0 : (∑ a : A, p a * Y a) = 0)
    (hZ0 : (∑ b : B, q b * Z b) = 0) :
    jointAvg p q (fun a b => (Y a + Z b) ^ 4) =
      (∑ a : A, p a * (Y a) ^ 4) +
        6 * (∑ a : A, p a * (Y a) ^ 2) *
            (∑ b : B, q b * (Z b) ^ 2) +
          (∑ b : B, q b * (Z b) ^ 4) := by
  have hpoint (a : A) (b : B) :
      (Y a + Z b) ^ 4 =
        (Y a) ^ 4 * 1 +
        4 * ((Y a) ^ 3 * Z b) +
        6 * ((Y a) ^ 2 * (Z b) ^ 2) +
        4 * (Y a * (Z b) ^ 3) +
        1 * (Z b) ^ 4 := by ring
  have heq :
      jointAvg p q (fun a b => (Y a + Z b) ^ 4) =
        jointAvg p q (fun a b =>
          (Y a) ^ 4 * 1 +
          4 * ((Y a) ^ 3 * Z b) +
          6 * ((Y a) ^ 2 * (Z b) ^ 2) +
          4 * (Y a * (Z b) ^ 3) +
          1 * (Z b) ^ 4) := by
    unfold jointAvg
    apply Finset.sum_congr rfl
    intro a _
    apply Finset.sum_congr rfl
    intro b _
    rw [hpoint]
  rw [heq]
  simp only [jointAvg_add, jointAvg_smul]
  rw [jointAvg_factor, jointAvg_factor, jointAvg_factor,
    jointAvg_factor, jointAvg_factor]
  simp only [mul_one, one_mul, Finset.sum_const_zero]
  -- Normalize the two mass-one factors and kill the odd centered cross terms.
  simp only [Finset.sum_const_zero]
  have honesA : (∑ a : A, p a * (1 : ℝ)) = 1 := by simpa using hp1
  have honesB : (∑ b : B, q b * (1 : ℝ)) = 1 := by simpa using hq1
  rw [honesA, honesB, hY0, hZ0]
  ring

/-- A fourth-moment self term is controlled by the squared essential
supremum of the Euclidean norm, for any finite nonnegative weights. -/
theorem weighted_hilbert_fourth_self
    {Ω K : Type*} [Fintype Ω] [Fintype K]
    (μ : Ω → ℝ) (Y : Ω → K → ℝ) (c : ℝ)
    (hμ : ∀ ω, 0 ≤ μ ω)
    (hbound : ∀ ω, (∑ k : K, (Y ω k) ^ 2) ≤ c ^ 2) :
    (∑ ω : Ω, μ ω * (∑ k : K, (Y ω k) ^ 2) ^ 2) ≤
      c ^ 2 * (∑ ω : Ω, μ ω * (∑ k : K, (Y ω k) ^ 2)) := by
  have hpoint (ω : Ω) :
      μ ω * (∑ k : K, (Y ω k) ^ 2) ^ 2 ≤
        c ^ 2 * (μ ω * (∑ k : K, (Y ω k) ^ 2)) := by
    have hn : 0 ≤ (∑ k : K, (Y ω k) ^ 2) :=
      Finset.sum_nonneg (fun k _ => sq_nonneg _)
    have hm := mul_le_mul_of_nonneg_right (hbound ω) hn
    have hw := mul_le_mul_of_nonneg_left hm (hμ ω)
    nlinarith
  calc
    (∑ ω : Ω, μ ω * (∑ k : K, (Y ω k) ^ 2) ^ 2) ≤
      ∑ ω : Ω, c ^ 2 * (μ ω * (∑ k : K, (Y ω k) ^ 2)) :=
        Finset.sum_le_sum (fun ω _ => hpoint ω)
    _ = c ^ 2 * (∑ ω : Ω, μ ω * (∑ k : K, (Y ω k) ^ 2)) := by
      rw [Finset.mul_sum]

end Nightfall.Observability.QuadraticMoments
