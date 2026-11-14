import SCIFRecenter

/-!
# SCIF III: exact local influence-energy update on genuine finite laws

The formulas below use literal old/new marginal weighted sums and
the same old pair kernel H. They make no positivity-floor assumption.
The source-identification gate to `sourceInfluence p f` is separate.
-/

namespace Nightfall.SCIF
open Finset

variable {A B : Type*} [Fintype A] [Fintype B]

/-- Pair-sector energy conditioned on the unchanged symbol b. -/
noncomputable def pairEnergyAt (q : A → ℝ) (H : A → B → ℝ)
    (b : B) : ℝ :=
  ∑ a : A, q a * (H a b)^2

/-- Variance after conditional recentering, with the actual new weights. -/
theorem pair_energy_recenter_exact
    (q : A → ℝ) (hq : (∑ a : A, q a) = 1)
    (H : A → B → ℝ) (b : B) :
    pairEnergyAt q (pairRecenter q H) b =
      pairEnergyAt q H b - (firstMean q H b)^2 := by
  classical
  let m : ℝ := firstMean q H b
  have hm : (∑ a : A, q a * H a b) = m := rfl
  calc
    pairEnergyAt q (pairRecenter q H) b =
      ∑ a : A, (q a * (H a b)^2 -
        (2 * m) * (q a * H a b) + m^2 * q a) := by
          unfold pairEnergyAt
          apply Finset.sum_congr rfl
          intro a _
          dsimp [pairRecenter, m]
          ring
    _ = (∑ a : A, q a * (H a b)^2) -
        (2 * m) * (∑ a : A, q a * H a b) +
        m^2 * (∑ a : A, q a) := by
          rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
          simp_rw [Finset.mul_sum]
          all_goals ring
    _ = pairEnergyAt q H b - (firstMean q H b)^2 := by
          rw [hm, hq]
          dsimp [pairEnergyAt, m]
          ring

/-- The singleton-plus-pair contribution to a neighbor's actual
ANOVA energy, with all other unchanged interaction energies R. -/
noncomputable def localInfluenceEnergy (q : A → ℝ) (r : B → ℝ)
    (s : B → ℝ) (H : A → B → ℝ) (R : ℝ) : ℝ :=
  ∑ b : B, r b * ((s b)^2 + pairEnergyAt q H b) + R

/-- The precise local repair identity. No sampling approximation:
singleton correction, new pair variance and the old law enter literally. -/
theorem local_influence_recenter_exact
    (p q : A → ℝ) (hq : (∑ a : A, q a) = 1)
    (r : B → ℝ) (s : B → ℝ)
    (H : A → B → ℝ) (R : ℝ) :
    localInfluenceEnergy q r
        (fun b => s b + firstMean q H b)
        (pairRecenter q H) R =
      localInfluenceEnergy p r s H R +
      2 * (∑ b : B, r b * s b * firstMean q H b) +
      (∑ b : B, r b *
        (pairEnergyAt q H b - pairEnergyAt p H b)) := by
  classical
  have hpoint (b : B) :
      ((s b + firstMean q H b)^2 +
          pairEnergyAt q (pairRecenter q H) b) =
        ((s b)^2 + pairEnergyAt p H b) +
          2 * s b * firstMean q H b +
          (pairEnergyAt q H b - pairEnergyAt p H b) := by
    rw [pair_energy_recenter_exact q hq H b]
    ring
  unfold localInfluenceEnergy
  calc
    (∑ b : B,
       r b * ((s b + firstMean q H b)^2 +
         pairEnergyAt q (pairRecenter q H) b)) + R =
       (∑ b : B,
         r b * (((s b)^2 + pairEnergyAt p H b) +
           2 * s b * firstMean q H b +
           (pairEnergyAt q H b - pairEnergyAt p H b))) + R := by
             congr 1
             apply Finset.sum_congr rfl
             intro b _
             rw [hpoint b]
    _ = ((∑ b : B, r b * ((s b)^2 + pairEnergyAt p H b)) + R) +
        2 * (∑ b : B, r b * s b * firstMean q H b) +
        (∑ b : B, r b *
          (pairEnergyAt q H b - pairEnergyAt p H b)) := by
            simp_rw [mul_add, Finset.sum_add_distrib]
            rw [Finset.mul_sum]
            ring

/-- Directly expressed as the change of expectation over k of
the old interaction-sector squared norm. -/
theorem pair_energy_law_difference
    (p q : A → ℝ) (r : B → ℝ) (H : A → B → ℝ) :
    (∑ b : B, r b *
      (pairEnergyAt q H b - pairEnergyAt p H b)) =
    ∑ a : A, (q a - p a) *
      (∑ b : B, r b * (H a b)^2) := by
  classical
  have hpoint (b : B) :
      pairEnergyAt q H b - pairEnergyAt p H b =
        ∑ a : A, (q a - p a) * (H a b)^2 := by
    unfold pairEnergyAt
    simp_rw [sub_mul, Finset.sum_sub_distrib]
  calc
    (∑ b : B, r b *
      (pairEnergyAt q H b - pairEnergyAt p H b)) =
      ∑ b : B, ∑ a : A, r b * ((q a - p a) * (H a b)^2) := by
        apply Finset.sum_congr rfl
        intro b _
        rw [hpoint b, Finset.mul_sum]
    _ = ∑ a : A, ∑ b : B, r b * ((q a - p a) * (H a b)^2) :=
      Finset.sum_comm
    _ = ∑ a : A, (q a - p a) *
      (∑ b : B, r b * (H a b)^2) := by
        apply Finset.sum_congr rfl
        intro a _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro b _
        ring

end Nightfall.SCIF
