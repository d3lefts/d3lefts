import Mathlib

/-!
NIGHTFALL Route 1: algebraic latent-coordinate degree lift (attempt).
Uses only finite combinatorics. No positive-probability assumptions.
Do not mistake this component for the full polylog-M simulation theorem.
-/
namespace Nightfall.Route1LatentDegree
open Finset

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

noncomputable def indMono (T : Finset ι) (τ x : ι → α) : ℝ :=
  ∏ i ∈ T, if x i = τ i then (1 : ℝ) else 0

def DegreeLE (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∃ a : Finset ι → (ι → α) → ℝ,
    (∀ T, d < T.card → ∀ τ, a T τ = 0) ∧
    ∀ x, f x = ∑ T, ∑ τ, a T τ * indMono T τ x

def SupportedOn (S : Finset ι) (f : (ι → α) → ℝ) : Prop :=
  ∀ x y, (∀ i ∈ S, x i = y i) → f x = f y

theorem mono_reconstruct (S : Finset ι) (f : (ι → α) → ℝ)
    (hf : SupportedOn S f) (x : ι → α) :
    f x = ∑ τ : ι → α,
      (if ∀ i, i ∉ S → τ i = Classical.choice ‹Nonempty α›
       then f τ else 0) * indMono S τ x := by
  classical
  let base : α := Classical.choice ‹Nonempty α›
  let τ₀ : ι → α := fun i => if i ∈ S then x i else base
  have hfix : ∀ i, i ∉ S → τ₀ i = base := by
    intro i hi
    simp [τ₀, hi]
  have hone : indMono S τ₀ x = 1 := by
    unfold indMono
    apply Finset.prod_eq_one
    intro i hi
    simp [τ₀, hi]
  have heq : f τ₀ = f x := by
    apply hf
    intro i hi
    simp [τ₀, hi]
  symm
  rw [Finset.sum_eq_single τ₀]
  · have ht : (∀ i, i ∉ S → τ₀ i = Classical.choice ‹Nonempty α›) := hfix
    exact if_pos ht
  · intro τ _ hne
    by_cases hc : ∀ i, i ∉ S → τ i = base
    · have hex : ∃ i, i ∈ S ∧ x i ≠ τ i := by
        by_contra h
        push_neg at h
        apply hne
        funext i
        by_cases hi : i ∈ S
        · simpa [τ₀, hi] using (h i hi).symm
        · calc τ i = base := hc i hi
               _ = τ₀ i := (hfix i hi).symm
      obtain ⟨i, hi, hdiff⟩ := hex
      have hz : indMono S τ x = 0 := by
        unfold indMono
        apply Finset.prod_eq_zero hi
        simp [hdiff]
      simp [hc, hz]
    · have hc' : ¬(∀ i, i ∉ S → τ i = Classical.choice ‹Nonempty α›) := hc
      simp [hc']
  · intro h
    exact (h (Finset.mem_univ τ₀)).elim

theorem degree_of_supported (S : Finset ι) (f : (ι → α) → ℝ)
    (hf : SupportedOn S f) (d : ℕ) (hcard : S.card ≤ d) :
    DegreeLE f d := by
  classical
  refine ⟨fun T τ => if T = S then
    (if ∀ i, i ∉ S → τ i = Classical.choice ‹Nonempty α›
     then f τ else 0) else 0, ?_, ?_⟩
  · intro T hT τ
    by_cases heq : T = S
    · subst T
      omega
    · simp [heq]
  · intro x
    calc
      f x = ∑ τ : ι → α,
          (if ∀ i, i ∉ S → τ i = Classical.choice ‹Nonempty α›
           then f τ else 0) * indMono S τ x := mono_reconstruct S f hf x
      _ = ∑ T : Finset ι, ∑ τ : ι → α,
          (if T = S then (if ∀ i, i ∉ S → τ i = Classical.choice ‹Nonempty α›
             then f τ else 0) else 0) * indMono T τ x := by
          symm
          rw [Finset.sum_eq_single S]
          · simp
          · intro T _ hT
            simp [hT]
          · simp

theorem degree_sum {β : Type*} [Fintype β] (g : β → (ι → α) → ℝ)
    (d : ℕ) (hg : ∀ b, DegreeLE (g b) d) :
    DegreeLE (fun x => ∑ b, g b x) d := by
  classical
  choose a ha0 ha using hg
  refine ⟨fun T τ => ∑ b, a b T τ, ?_, ?_⟩
  · intro T hT τ
    simp [ha0 _ T hT τ]
  · intro x
    calc
      (∑ b, g b x) = ∑ b, ∑ T, ∑ τ, a b T τ * indMono T τ x := by
        apply Finset.sum_congr rfl
        intro b _
        exact ha b x
      _ = ∑ T, ∑ τ, (∑ b, a b T τ) * indMono T τ x := by
        simp_rw [Finset.sum_mul]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro T _
        rw [Finset.sum_comm]

theorem degree_zero (d : ℕ) :
    DegreeLE (fun _ : ι → α => (0 : ℝ)) d := by
  refine ⟨fun _ _ => 0, ?_, ?_⟩
  · intros
    rfl
  · intro x
    simp

section Latent
variable {Θ U A : Type*}
  [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
  [Fintype U] [DecidableEq U] [Nonempty U]
  [Fintype A] [DecidableEq A]

noncomputable def pickTheta (z : Option ι → Θ ⊕ U) : Θ :=
  match z none with
  | .inl θ => θ
  | .inr _ => Classical.choice ‹Nonempty Θ›

noncomputable def pickSeed (z : Option ι → Θ ⊕ U) (i : ι) : U :=
  match z (some i) with
  | .inl _ => Classical.choice ‹Nonempty U›
  | .inr u => u

noncomputable def latentLift (f : (ι → A) → ℝ)
    (h : Θ → ι → U → A) (z : Option ι → Θ ⊕ U) : ℝ :=
  f (fun i => h (pickTheta z) i (pickSeed z i))

private noncomputable def term (h : Θ → ι → U → A) (T : Finset ι)
    (τ : ι → A) (z : Option ι → Θ ⊕ U) : ℝ :=
  ∏ i ∈ T, if h (pickTheta z) i (pickSeed z i) = τ i then (1 : ℝ) else 0

theorem term_supported (h : Θ → ι → U → A) (T : Finset ι) (τ : ι → A) :
    SupportedOn (insert none (T.image some)) (term h T τ) := by
  intro x y hxy
  have htheta : pickTheta x = pickTheta y := by
    unfold pickTheta
    rw [hxy none (Finset.mem_insert_self _ _)]
  have hseed : ∀ i ∈ T, pickSeed x i = pickSeed y i := by
    intro i hi
    unfold pickSeed
    rw [hxy (some i) (Finset.mem_insert_of_mem
        (Finset.mem_image.mpr ⟨i, hi, rfl⟩))]
  unfold term
  apply Finset.prod_congr rfl
  intro i hi
  rw [htheta, hseed i hi]

theorem latent_degree_succ (f : (ι → A) → ℝ)
    (h : Θ → ι → U → A) (d : ℕ)
    (hf : DegreeLE f d) :
    DegreeLE (latentLift f h) (d+1) := by
  classical
  obtain ⟨a, ha0, ha⟩ := hf
  have hterm : ∀ T : Finset ι, ∀ τ : ι → A,
      DegreeLE (fun z => a T τ * term h T τ z) (d+1) := by
    intro T τ
    by_cases hT : T.card ≤ d
    · apply degree_of_supported (insert none (T.image some)) _ _ (d+1)
        (by
          calc
            (insert none (T.image some)).card ≤ (T.image some).card + 1 :=
              Finset.card_insert_le _ _
            _ ≤ T.card + 1 := Nat.add_le_add_right (Finset.card_image_le) 1
            _ ≤ d + 1 := Nat.add_le_add_right hT 1)
      intro x y hxy
      exact congrArg (fun v : ℝ => a T τ * v) ((term_supported h T τ) x y hxy)
    · have hz : a T τ = 0 := ha0 T (by omega) τ
      simpa [hz] using
        (degree_zero (ι := Option ι) (α := Θ ⊕ U) (d+1))
  have hτ : ∀ T : Finset ι,
      DegreeLE (fun z => ∑ τ : ι → A, a T τ * term h T τ z) (d+1) := by
    intro T
    exact degree_sum _ (d+1) (hterm T)
  have hsum : DegreeLE (fun z => ∑ T : Finset ι,
      ∑ τ : ι → A, a T τ * term h T τ z) (d+1) :=
    degree_sum _ (d+1) hτ
  convert hsum using 1
  funext z
  unfold latentLift
  rw [ha]
  rfl
end Latent
end Nightfall.Route1LatentDegree

#print axioms Nightfall.Route1LatentDegree.mono_reconstruct
#print axioms Nightfall.Route1LatentDegree.degree_of_supported
#print axioms Nightfall.Route1LatentDegree.latent_degree_succ
