import EfronSteinDegree

/-!
# NIGHTFALL — query-local degree pullback

A coordinatewise finite encoding Phi : (J → beta) → (I → alpha), with
each observed coordinate depending on at most b latent coordinates,
transports indicator-polynomial degree ≤ d to degree ≤ b*d.

No global injectivity, source minimum-atom assumption, or polynomial-time
representation is used. The certificate is a finite-indicator expansion.
-/

namespace Nightfall.ProductSpace.QueryLocalDegree

open Finset
open Nightfall.ProductSpace
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.EfronStein

variable {I J α β : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- A finite-coordinate junta has an indicator expansion of that degree. -/
private theorem degree_of_junta (p : J → β → ℝ)
    (hp1 : ∀ j, ∑ v, p j v = 1)
    (S : Finset J) (d : ℕ) (hcard : S.card ≤ d)
    (g : (J → β) → ℝ) (hg : DependsOn S g) :
    HasProdDegreeLE g d := by
  classical
  let a : Finset J → (J → β) → ℝ :=
    fun T τ => if T = S then
      g τ * ∏ j, (if j ∈ S then (1 : ℝ) else p j (τ j))
      else 0
  refine ⟨a, ?_, ?_⟩
  · intro T hT τ
    by_cases hTS : T = S
    · subst T
      exact (False.elim ((Nat.not_lt_of_ge hcard) hT))
    · simp [a, hTS]
  · intro x
    change g x = ∑ T : Finset J, ∑ τ : J → β, a T τ * indMono T τ x
    rw [Finset.sum_eq_single S]
    · simpa only [a, ite_true] using (junta_expand p hp1 S g hg x).symm
    · intro T _ hTS
      simp [a, hTS]
    · intro hS
      exact (hS (Finset.mem_univ S)).elim

/-- Finite sums preserve indicator degree bounds. -/
private theorem degree_sum {γ : Type} [Fintype γ]
    (g : γ → (J → β) → ℝ) (d : ℕ)
    (hg : ∀ k, HasProdDegreeLE (g k) d) :
    HasProdDegreeLE (fun z => ∑ k, g k z) d := by
  classical
  choose a ha0 heq using hg
  refine ⟨fun S τ => ∑ k, a k S τ, ?_, ?_⟩
  · intro S hS τ
    exact Finset.sum_eq_zero fun k _ => ha0 k S hS τ
  · intro z
    calc
      (∑ k, g k z) =
          ∑ k, ∑ S : Finset J, ∑ τ : J → β, a k S τ * indMono S τ z :=
        Finset.sum_congr rfl fun k _ => heq k z
      _ = ∑ S : Finset J, ∑ τ : J → β,
          ∑ k, a k S τ * indMono S τ z := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro S _
          rw [Finset.sum_comm]
      _ = ∑ S : Finset J, ∑ τ : J → β,
          (∑ k, a k S τ) * indMono S τ z := by
          simp_rw [Finset.sum_mul]

/-- Each observed symbol is a function of at most b latent coordinates. -/
def LocalEncoding (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ) : Prop :=
  (∀ i, (deps i).card ≤ b) ∧
  ∀ i z z', (∀ j ∈ deps i, z j = z' j) → Phi z i = Phi z' i

/-- Union of the latent coordinates needed by an observed coordinate set. -/
def latentSupport (deps : I → Finset J) (S : Finset I) : Finset J :=
  S.biUnion deps

/-- Pulling back a set of |S| observed queries touches at most b*|S| latent indices. -/
theorem latentSupport_card
    (deps : I → Finset J) (b : ℕ)
    (hdeps : ∀ i, (deps i).card ≤ b)
    (S : Finset I) :
    (latentSupport deps S).card ≤ b * S.card := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [latentSupport]
  | @insert i S hi ih =>
      have heq : latentSupport deps (insert i S) =
          deps i ∪ latentSupport deps S := by
        simp [latentSupport]
      rw [heq]
      calc
        (deps i ∪ latentSupport deps S).card ≤
            (deps i).card + (latentSupport deps S).card :=
          Finset.card_union_le _ _
        _ ≤ b + b * S.card := Nat.add_le_add (hdeps i) ih
        _ = b * (insert i S).card := by
          rw [Finset.card_insert_of_notMem hi]
          omega

/-- An observed indicator monomial becomes a latent junta on the union of dependencies. -/
theorem indMono_pullback_dep
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (S : Finset I) (τ : I → α) :
    DependsOn (latentSupport deps S)
      (fun z => indMono S τ (Phi z)) := by
  intro z z' hagree
  unfold indMono
  apply Finset.prod_congr rfl
  intro i hi
  have hcoord : Phi z i = Phi z' i :=
    hPhi.2 i z z' (fun j hj =>
      hagree j (Finset.mem_biUnion.mpr ⟨i, hi, hj⟩))
  rw [hcoord]

/-- Main structural lemma: deg(f ∘ Phi) ≤ b*d. -/
theorem degree_pullback
    (p : J → β → ℝ) (hp1 : ∀ j, ∑ v, p j v = 1)
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (f : (I → α) → ℝ) (d : ℕ)
    (hf : HasProdDegreeLE f d) :
    HasProdDegreeLE (fun z => f (Phi z)) (b * d) := by
  classical
  obtain ⟨a, ha0, hfa⟩ := hf
  have hpart : ∀ (S : Finset I) (τ : I → α),
      HasProdDegreeLE
        (fun z : J → β => a S τ * indMono S τ (Phi z)) (b * d) := by
    intro S τ
    by_cases hs : S.card ≤ d
    · have hc : (latentSupport deps S).card ≤ b * d := by
        calc
          (latentSupport deps S).card ≤ b * S.card :=
            latentSupport_card deps b hPhi.1 S
          _ ≤ b * d := Nat.mul_le_mul_left b hs
      exact degree_of_junta p hp1 (latentSupport deps S) (b * d) hc
        (fun z => a S τ * indMono S τ (Phi z))
        (fun z z' hz => by
          rw [indMono_pullback_dep Phi deps b hPhi S τ z z' hz])
    · have hz : a S τ = 0 := ha0 S (Nat.lt_of_not_ge hs) τ
      refine ⟨fun _ _ => 0, ?_, ?_⟩
      · simp
      · intro z
        simp [hz]
  have hsums : HasProdDegreeLE
      (fun z : J → β =>
        ∑ S : Finset I, ∑ τ : I → α, a S τ * indMono S τ (Phi z))
      (b * d) := by
    apply degree_sum
    intro S
    apply degree_sum
    intro τ
    exact hpart S τ
  obtain ⟨a', ha0', hrep'⟩ := hsums
  refine ⟨a', ha0', ?_⟩
  intro z
  exact (hfa (Phi z)).trans (hrep' z)

end Nightfall.ProductSpace.QueryLocalDegree
