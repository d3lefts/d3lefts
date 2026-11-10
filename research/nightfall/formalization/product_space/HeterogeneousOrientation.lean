import Init

/-!
NIGHTFALL product-space influence — heterogeneous two-draw orientations.
Source: Wright 2026, weighted two-draw transfer (Lemma A / Theorem 1.2).
This theorem formalizes the equal-mass orientation sublemma for arbitrary
coordinate-dependent mass functions and arbitrary finite alphabets. It is
not the weighted all-pairs/reciprocal inequality or an influence bound.
-/

namespace Nightfall.ProductSpace

universe u

/-- Unnormalized mass of independent coordinate pairs, allowing different
marginal mass functions at every coordinate. -/
def heterogeneousPairWeight {α : Type u} :
    List (α → Nat) → List (α × α) → Nat
  | [], [] => 1
  | p :: ps, (a, b) :: pairs => (p a * p b) * heterogeneousPairWeight ps pairs
  | _, _ => 0

/-- Product mass after selecting an orientation at each coordinate. -/
def heterogeneousOrientedWeight {α : Type u} :
    List (α → Nat) → List (α × α) → List Bool → Nat
  | [], [], [] => 1
  | p :: ps, (a, b) :: pairs, flag :: flags =>
      (if flag then p a * p b else p b * p a) *
        heterogeneousOrientedWeight ps pairs flags
  | _, _, _ => 0

/-- Coordinatewise exchangeability makes every orientation have the same
mass, for all finite dimensions, arbitrary alphabets and heterogeneous
coordinate masses, including vanishing masses. -/
theorem heterogeneous_orientation_mass {α : Type u} (marginals : List (α → Nat)) :
    ∀ (pairs : List (α × α)) (flags : List Bool),
      marginals.length = pairs.length →
      pairs.length = flags.length →
      heterogeneousOrientedWeight marginals pairs flags =
        heterogeneousPairWeight marginals pairs := by
  induction marginals with
  | nil =>
      intro pairs flags hp hbits
      cases pairs with
      | nil =>
          cases flags with
          | nil => rfl
          | cons flag rest => simp at hbits
      | cons pair rest => simp at hp
  | cons marginal ms ih =>
      intro pairs flags hp hbits
      cases pairs with
      | nil => simp at hp
      | cons ab rest =>
          cases flags with
          | nil => simp at hbits
          | cons flag fs =>
              cases ab with
              | mk a b =>
                  have hms : ms.length = rest.length := by simpa using hp
                  have hfs : rest.length = fs.length := by simpa using hbits
                  cases flag with
                  | false =>
                      simp [heterogeneousOrientedWeight, heterogeneousPairWeight,
                        ih rest fs hms hfs, Nat.mul_comm]
                  | true =>
                      simp [heterogeneousOrientedWeight, heterogeneousPairWeight,
                        ih rest fs hms hfs]

/-- Corollary: every two orientation masks have equal product-pair mass. -/
theorem heterogeneous_all_masks_equal {α : Type u}
    (marginals : List (α → Nat)) (pairs : List (α × α))
    (flags₁ flags₂ : List Bool)
    (hm : marginals.length = pairs.length)
    (h₁ : pairs.length = flags₁.length)
    (h₂ : pairs.length = flags₂.length) :
    heterogeneousOrientedWeight marginals pairs flags₁ =
      heterogeneousOrientedWeight marginals pairs flags₂ := by
  rw [heterogeneous_orientation_mass marginals pairs flags₁ hm h₁,
      heterogeneous_orientation_mass marginals pairs flags₂ hm h₂]

end Nightfall.ProductSpace
