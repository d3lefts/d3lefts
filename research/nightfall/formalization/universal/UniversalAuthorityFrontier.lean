import Mathlib

/-!
# Universal observation/authorization separation, without finite-state assumptions

This file proves a purely logical, set-theoretic authority frontier for arbitrary
worlds, actions, observation indices, and even dependent observation alphabets.
No computability, empirical model-validity, or physical interposition is asserted.

Theorem scope: unrestricted sets and arbitrary safety predicates. The result is
not a safety guarantee for bypassable or mis-modelled autonomous systems.
-/

namespace Nightfall.UniversalAuthorityFrontier

universe u v w z

variable {World : Type u} {Action : Type v} {Sensor : Type w}
variable {Reading : Sensor → Type z}

def Indistinguishable (O : (j : Sensor) → World → Reading j)
    (F : Set Sensor) (x y : World) : Prop :=
  ∀ j, j ∈ F → O j x = O j y

def Authorize (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop)
    (F : Set Sensor) (x : World) (a : Action) : Prop :=
  ∀ y, Indistinguishable O F x y → Safe y a

def SeparatesConflicts (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor) : Prop :=
  ∀ x y a, ¬ (Safe x a ↔ Safe y a) →
    ∃ j, j ∈ F ∧ O j x ≠ O j y

theorem indistinguishable_refl
    (O : (j : Sensor) → World → Reading j)
    (F : Set Sensor) (x : World) :
    Indistinguishable O F x x := by
  intro j hj
  rfl

theorem indistinguishable_symm
    (O : (j : Sensor) → World → Reading j)
    (F : Set Sensor) (x y : World)
    (h : Indistinguishable O F x y) :
    Indistinguishable O F y x := by
  intro j hj
  exact (h j hj).symm

theorem authorize_sound
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop)
    (F : Set Sensor) (x : World) (a : Action)
    (h : Authorize O Safe F x a) :
    Safe x a :=
  h x (indistinguishable_refl O F x)

theorem authorize_maximal
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor)
    (H : World → Action → Prop)
    (hfiber : ∀ x y a, Indistinguishable O F x y → (H x a ↔ H y a))
    (hsound : ∀ x a, H x a → Safe x a) :
    ∀ x a, H x a → Authorize O Safe F x a := by
  intro x a hx y hxy
  exact hsound y a ((hfiber x y a hxy).mp hx)

theorem authorize_more_observations
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) {F G : Set Sensor}
    (hFG : F ⊆ G) (x : World) (a : Action)
    (h : Authorize O Safe F x a) :
    Authorize O Safe G x a := by
  intro y hxy
  apply h y
  intro j hj
  exact hxy j (hFG hj)

theorem separates_implies_safe_constant_on_fibers
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor)
    (hsep : SeparatesConflicts O Safe F) :
    ∀ x y a, Indistinguishable O F x y → (Safe x a ↔ Safe y a) := by
  classical
  intro x y a hxy
  by_contra hnot
  obtain ⟨j, hj, hne⟩ := hsep x y a hnot
  exact hne (hxy j hj)

theorem separates_implies_exact_authorization
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor)
    (hsep : SeparatesConflicts O Safe F) :
    ∀ x a, Authorize O Safe F x a ↔ Safe x a := by
  intro x a
  constructor
  · exact authorize_sound O Safe F x a
  · intro hs y hxy
    exact (separates_implies_safe_constant_on_fibers
      O Safe F hsep x y a hxy).mp hs

theorem exact_authorization_implies_separates
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor)
    (hcomplete : ∀ x a, Authorize O Safe F x a ↔ Safe x a) :
    SeparatesConflicts O Safe F := by
  classical
  intro x y a hconflict
  by_contra hno
  have hxy : Indistinguishable O F x y := by
    intro j hj
    by_contra hne
    exact hno ⟨j, hj, hne⟩
  have hyx : Indistinguishable O F y x :=
    indistinguishable_symm O F x y hxy
  apply hconflict
  constructor
  · intro hx
    exact ((hcomplete x a).mpr hx) y hxy
  · intro hy
    exact ((hcomplete y a).mpr hy) x hyx

theorem exact_authorization_iff_conflict_separation
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor) :
    (∀ x a, Authorize O Safe F x a ↔ Safe x a) ↔
      SeparatesConflicts O Safe F := by
  constructor
  · exact exact_authorization_implies_separates O Safe F
  · exact separates_implies_exact_authorization O Safe F

/-- A correctly modeled, physically enforced sound guard preserves its invariant
along arbitrary-length discrete trajectories. This does not claim that agents
must obey the guard, that observations are authentic, or that the model is true. -/
theorem invariant_preserved_under_enforced_guard
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (F : Set Sensor)
    (Step : World → Action → World → Prop) (Inv : World → Prop)
    (hclosure : ∀ x a y, Inv x → Safe x a → Step x a y → Inv y)
    (run : ℕ → World) (act : ℕ → Action)
    (hinitial : Inv (run 0))
    (hstep : ∀ n, Step (run n) (act n) (run (n+1)))
    (hgrant : ∀ n, Authorize O Safe F (run n) (act n)) :
    ∀ n, Inv (run n) := by
  intro n
  induction n with
  | zero => exact hinitial
  | succ n ih =>
      exact hclosure (run n) (act n) (run (n+1)) ih
        (authorize_sound O Safe F (run n) (act n) (hgrant n))
        (hstep n)


/-- Budget-feasible complete evidence interfaces are exactly the sets
separating every unsafe/safe conflict, regardless of sensor cardinality. -/
theorem evidence_budget_iff_conflict_cover
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (price : Set Sensor → ℝ≥0∞)
    (budget : ℝ≥0∞) :
    (∃ F : Set Sensor,
      (∀ x a, Authorize O Safe F x a ↔ Safe x a) ∧
        price F ≤ budget) ↔
    (∃ F : Set Sensor,
      SeparatesConflicts O Safe F ∧ price F ≤ budget) := by
  constructor
  · rintro ⟨F, hF, hcost⟩
    exact ⟨F, (exact_authorization_iff_conflict_separation O Safe F).mp hF,
      hcost⟩
  · rintro ⟨F, hF, hcost⟩
    exact ⟨F, (exact_authorization_iff_conflict_separation O Safe F).mpr hF,
      hcost⟩

/-- The exact optimal global authorization evidence cost equals the
conflict-hitting cost infimum, including unattained and infinite costs.
No price separability, finite-world bound or finite sensor set is assumed. -/
theorem exact_authorization_cost_eq_conflict_hitting_cost
    (O : (j : Sensor) → World → Reading j)
    (Safe : World → Action → Prop) (price : Set Sensor → ℝ≥0∞) :
    sInf {c : ℝ≥0∞ | ∃ F : Set Sensor,
      (∀ x a, Authorize O Safe F x a ↔ Safe x a) ∧ price F = c} =
    sInf {c : ℝ≥0∞ | ∃ F : Set Sensor,
      SeparatesConflicts O Safe F ∧ price F = c} := by
  congr 1
  ext c
  constructor
  · rintro ⟨F, hF, hc⟩
    exact ⟨F, (exact_authorization_iff_conflict_separation O Safe F).mp hF,
      hc⟩
  · rintro ⟨F, hF, hc⟩
    exact ⟨F, (exact_authorization_iff_conflict_separation O Safe F).mpr hF,
      hc⟩

end Nightfall.UniversalAuthorityFrontier
