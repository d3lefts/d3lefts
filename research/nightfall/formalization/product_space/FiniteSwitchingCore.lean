import Mathlib

/-!
NIGHTFALL finite switching core. This is deterministic and finite.
It formalizes degree preservation for an EXPLICIT low-coordinate-support
decomposition. It does NOT assume the full exact recovery theorem, a
measurable-selection theorem, or Boolean sensitivity bounds.
-/

namespace Nightfall.Recovery

open Finset

variable {Coord Symbol Query Label : Type*}

/-- A function of configurations depends only on coordinates in S. -/
def DependsOn (S : Finset Coord) (g : (Coord → Symbol) → ℝ) : Prop :=
  ∀ x y, (∀ i ∈ S, x i = y i) → g x = g y

/-- A finite sum of pieces, each supported on at most d coordinates. -/
def HasDegreeRepresentation [Fintype Label] (f : (Coord → Symbol) → ℝ) (d : ℕ) : Prop :=
  ∃ (support : Label → Finset Coord) (piece : Label → (Coord → Symbol) → ℝ),
    (∀ l, (support l).card ≤ d ∧ DependsOn (support l) (piece l)) ∧
      (∀ x, f x = ∑ l, piece l x)

/-- Each coordinate belongs to at most one switch block. -/
def hybrid (x y : Coord → Symbol) (blockOf : Coord → Option Query)
    (mask : Query → Bool) : Coord → Symbol :=
  fun i => match blockOf i with
    | none => x i
    | some j => if mask j then y i else x i

/-- Potentially nonminimal switch support, with a dummy default for unassigned coordinates. -/
def switchSupport (S : Finset Coord) (blockOf : Coord → Option Query)
    (defaultQuery : Query) : Finset Query :=
  S.image (fun i => (blockOf i).getD defaultQuery)

theorem switchSupport_card_le [DecidableEq Query] (S : Finset Coord)
    (blockOf : Coord → Option Query) (defaultQuery : Query) :
    (switchSupport S blockOf defaultQuery).card ≤ S.card := by
  unfold switchSupport
  exact Finset.card_image_le

theorem hybrid_agree_on_support [DecidableEq Query]
    (S : Finset Coord) (blockOf : Coord → Option Query)
    (defaultQuery : Query) (x y : Coord → Symbol)
    (m n : Query → Bool)
    (hm : ∀ j ∈ switchSupport S blockOf defaultQuery, m j = n j) :
    ∀ i ∈ S, hybrid x y blockOf m i = hybrid x y blockOf n i := by
  intro i hi
  cases h : blockOf i with
  | none =>
      simp [hybrid, h]
  | some j =>
      have hj : j ∈ switchSupport S blockOf defaultQuery := by
        unfold switchSupport
        apply Finset.mem_image.mpr
        refine ⟨i, hi, ?_⟩
        simp [h]
      simp [hybrid, h, hm j hj]

theorem hybrid_term_depends [DecidableEq Query]
    (S : Finset Coord) (g : (Coord → Symbol) → ℝ)
    (hg : DependsOn S g)
    (blockOf : Coord → Option Query) (defaultQuery : Query)
    (x y : Coord → Symbol) :
    DependsOn (switchSupport S blockOf defaultQuery)
      (fun mask => g (hybrid x y blockOf mask)) := by
  intro m n hm
  apply hg
  exact hybrid_agree_on_support S blockOf defaultQuery x y m n hm

/-- Degree of finite sums of low-support terms survives disjoint-block switching. -/
theorem hybrid_preserves_degree [Fintype Label] [DecidableEq Query]
    (f : (Coord → Symbol) → ℝ) (d : ℕ)
    (hdeg : HasDegreeRepresentation (Label := Label) f d)
    (x y : Coord → Symbol) (blockOf : Coord → Option Query)
    (defaultQuery : Query) :
    HasDegreeRepresentation (Label := Label)
      (fun mask => f (hybrid x y blockOf mask)) d := by
  rcases hdeg with ⟨support, piece, hpiece, hsum⟩
  refine ⟨fun l => switchSupport (support l) blockOf defaultQuery,
    fun l mask => piece l (hybrid x y blockOf mask), ?_, ?_⟩
  · intro l
    obtain ⟨hcard, hdep⟩ := hpiece l
    exact ⟨(switchSupport_card_le (support l) blockOf defaultQuery).trans hcard,
      hybrid_term_depends (support l) (piece l) hdep blockOf defaultQuery x y⟩
  · intro mask
    exact hsum (hybrid x y blockOf mask)

theorem hybrid_zero (x y : Coord → Symbol) (blockOf : Coord → Option Query) :
    hybrid x y blockOf (fun _ => false) = x := by
  funext i
  cases h : blockOf i with
  | none => simp [hybrid, h]
  | some j => simp [hybrid, h]

theorem hybrid_singleton [DecidableEq Query]
    (x y : Coord → Symbol) (blockOf : Coord → Option Query) (j : Query) :
    hybrid x y blockOf (fun k => decide (k = j)) =
      (fun i => if blockOf i = some j then y i else x i) := by
  funext i
  cases h : blockOf i with
  | none => simp [hybrid, h]
  | some k =>
      by_cases hk : k = j
      · subst k
        simp [hybrid, h]
      · simp [hybrid, h, hk]

/-- An actually changed block is a sensitive single-bit switch at the zero mask. -/
theorem sensitive_block_to_switch [DecidableEq Query]
    (f : (Coord → Symbol) → ℝ)
    (x y : Coord → Symbol) (blockOf : Coord → Option Query) (j : Query)
    (hchange : f (fun i => if blockOf i = some j then y i else x i) ≠ f x) :
    f (hybrid x y blockOf (fun k => decide (k = j))) ≠
      f (hybrid x y blockOf (fun _ => false)) := by
  simpa only [hybrid_zero, hybrid_singleton] using hchange

end Nightfall.Recovery
