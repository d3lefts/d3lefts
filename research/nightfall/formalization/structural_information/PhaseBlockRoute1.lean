import Mathlib

/-!
# NIGHTFALL phase-block / Route 1: exact finite sensing code and support rigidity

This is a source-exact Lean kernel certificate for the *real* (not finite-field)
2D eight-state four-sensor intensity code and the general rectangular-support
obstruction underlying the exact raw Wyner information calculation.

It does NOT derive the quantum low-degree polynomial theorem, entropy
calculation, or final Route1 simulator. Those are separate proof obligations.
No `sorry`, `admit`, custom `axiom` or target-premise masquerading as a theorem.
-/
namespace Nightfall.PhaseBlockRoute1

def sensor : Fin 4 → ℤ × ℤ :=
  ![(1,0), (0,1), (1,1), (1,-1)]

def signal : Fin 8 → ℤ × ℤ :=
  ![(0,1), (1,-2), (1,0), (1,2), (3,-2), (3,2), (2,1), (2,3)]

def reading (s : Fin 8) (j : Fin 4) : ℤ :=
  let a := sensor j
  let x := signal s
  (a.1 * x.1 + a.2 * x.2) ^ 2

/-- The four concrete sensing outputs are genuine squared real-linear
intensities of the above integer vectors. `decide` normalizes all 32
integer values in the trusted Lean kernel. -/
theorem all_measurements_bounded :
    ∀ s : Fin 8, ∀ j : Fin 4, 0 ≤ reading s j ∧ reading s j ≤ 25 := by
  decide

/-- Omitting ANY one of the four sensing directions leaves an injective map
on the EIGHT exact sign-orbit representatives. This is the finite decoder.
The stronger all-real-signal statement is proved in the companion paper via
four nonzero exact quadratic-form determinants. -/
theorem any_three_injective :
    ∀ s t : Fin 8, ∀ missing : Fin 4,
      (∀ j : Fin 4, j ≠ missing → reading s j = reading t j) → s = t := by
  decide

def badFirstValue : Fin 4 → ℤ := ![1, 4, 1, 1]

/-- One explicit first-reading value for each of the four sensing vectors
defeats EVERY possible second sensing vector, including policies whose
second choice depends on the observed first outcome. -/
theorem two_reading_obstruction :
    ∀ first second : Fin 4, ∃ s t : Fin 8,
      s ≠ t ∧
      reading s first = badFirstValue first ∧
      reading t first = badFirstValue first ∧
      reading s second = reading t second := by
  decide

/-- Quantifies over all deterministic adaptive second-reading policies. -/
theorem every_two_step_policy_fails
    (first : Fin 4) (chooseSecond : ℤ → Fin 4) :
    ∃ s t : Fin 8,
      s ≠ t ∧
      reading s first = reading t first ∧
      reading s (chooseSecond (reading s first)) =
        reading t (chooseSecond (reading t first)) := by
  obtain ⟨s,t,hne,hs,ht,hsecond⟩ :=
    two_reading_obstruction first (chooseSecond (badFirstValue first))
  refine ⟨s,t,hne,?_,?_⟩
  · exact hs.trans ht.symm
  · simpa [hs,ht] using hsecond

/-- A discrete code support has no coordinate edge if agreeing at every
coordinate OTHER THAN one implies equality. -/
def NoHammingEdge {ι α : Type*} (C : Set (ι → α)) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, ∀ i : ι,
    (∀ j : ι, j ≠ i → x j = y j) → x = y

/-- Support of a coordinatewise product law is rectangular: any hybrid
formed by replacing one coordinate of a supported word by that of another
supported word also belongs to the support. -/
def Rectangular {ι α : Type*} [DecidableEq ι] (R : Set (ι → α)) : Prop :=
  ∀ x ∈ R, ∀ y ∈ R, ∀ i : ι,
    Function.update x i (y i) ∈ R

/-- GENERAL EXACT SUPPORT RIGIDITY.
If a rectangular set lies inside a no-Hamming-edge code, it contains at
most one word. This is the key finite-support mathematical input to
C_W(raw table) = H(raw table), before invoking the classical entropy identity.
-/
theorem rectangular_support_subsingleton {ι α : Type*}
    [DecidableEq ι] (C R : Set (ι → α))
    (hR : Rectangular R) (hsub : R ⊆ C)
    (hC : NoHammingEdge C) :
    ∀ x ∈ R, ∀ y ∈ R, x = y := by
  intro x hx y hy
  apply funext
  intro i
  let z : ι → α := Function.update x i (y i)
  have hz : z ∈ R := hR x hx y hy i
  have hsingle : x = z := by
    apply hC x (hsub hx) z (hsub hz) i
    intro j hj
    simp [z, Function.update, hj, Ne.symm hj]
  calc
    x i = z i := congrArg (fun f : ι → α => f i) hsingle
    _ = y i := by simp [z]

def blockCode {B : Type*} (s : B → Fin 8) : B × Fin 4 → ℤ :=
  fun pos => reading (s pos.1) pos.2

def blockCodeSupport (B : Type*) : Set (B × Fin 4 → ℤ) :=
  Set.range (fun s : B → Fin 8 => blockCode s)

/-- For EVERY number and type of hidden blocks, the raw four-reading
table has no codewords differing in only one original sensor coordinate.
No product or entropy assertion is hidden in this hypothesis. -/
theorem block_code_no_hamming_edge (B : Type*) :
    NoHammingEdge (blockCodeSupport B) := by
  intro x hx y hy omitted h
  obtain ⟨s, rfl⟩ := hx
  obtain ⟨t, rfl⟩ := hy
  rcases omitted with ⟨b₀,j₀⟩
  have hs : s = t := by
    funext b
    apply any_three_injective (s b) (t b) j₀
    intro j hj
    apply h (b,j)
    intro heq
    have hjEq : j = j₀ := congrArg Prod.snd heq
    exact hj hjEq
  rw [hs]

/-- Hence every nonempty conditional product support of a raw B-block
table is a singleton. This is the finite combinatorial certificate for
the Wyner information collapse after decoding (the entropy equality
must still be deduced from a formal distribution/entropy interface). -/
theorem raw_block_product_support_subsingleton {B : Type*}
    [DecidableEq B]
    (R : Set (B × Fin 4 → ℤ))
    (hR : Rectangular R)
    (hsub : R ⊆ blockCodeSupport B) :
    ∀ x ∈ R, ∀ y ∈ R, x = y :=
  rectangular_support_subsingleton (blockCodeSupport B) R hR hsub
    (block_code_no_hamming_edge B)

#print axioms Nightfall.PhaseBlockRoute1.any_three_injective
#print axioms Nightfall.PhaseBlockRoute1.two_reading_obstruction
#print axioms Nightfall.PhaseBlockRoute1.every_two_step_policy_fails
#print axioms Nightfall.PhaseBlockRoute1.rectangular_support_subsingleton
#print axioms Nightfall.PhaseBlockRoute1.block_code_no_hamming_edge
#print axioms Nightfall.PhaseBlockRoute1.raw_block_product_support_subsingleton
#print Nightfall.PhaseBlockRoute1.raw_block_product_support_subsingleton

end Nightfall.PhaseBlockRoute1
