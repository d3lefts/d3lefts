import MixtureSimulation
import Route1DegreeSourceBridge

/-!
# Route 1 (polylog-M mixture simulation): finite tools

* Degree calculus for `HasProdDegreeLE` (sums, products, sections, coordinatewise maps), built
  from `Route1LatentDegree.degree_of_supported`.
* Pushforward of product sums under coordinatewise maps.
* **Pair fooling** (`pair_fooling`): if a coordinatewise-independent coupling of two inputs has
  mismatch probability at most `η ≤ 1/2` in every coordinate, then for `f` with values in `[0,1]` and
  degree `≤ d`, `E (f x − f y)² ≤ 64 d² η`. This is the squared switching lemma, obtained from the
  certified `Mixture.fooling_tv` on the pair alphabet against the diagonal coupling.
-/

namespace Nightfall.Route1Polylog

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

section Degree

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]

/-- Generic degree criterion: a finite sum of terms, each supported on at most `d` coordinates or
identically zero. -/
theorem deg_of_terms {γ : Type} [Fintype γ] (F : γ → (ι → α) → ℝ) (S : γ → Finset ι) (d : ℕ)
    (hS : ∀ c, (S c).card ≤ d ∨ ∀ x, F c x = 0)
    (hsupp : ∀ c, Nightfall.Route1LatentDegree.SupportedOn (S c) (F c)) :
    HasProdDegreeLE (fun x => ∑ c, F c x) d := by
  apply Nightfall.Route1LatentDegree.degree_sum F d
  intro c
  rcases hS c with h | h
  · exact Nightfall.Route1LatentDegree.degree_of_supported (S c) (F c) (hsupp c) d h
  · have : F c = fun _ => 0 := funext h
    rw [this]; exact Nightfall.Route1LatentDegree.degree_zero d

theorem indMono_supported (T : Finset ι) (τ : ι → α) :
    Nightfall.Route1LatentDegree.SupportedOn T (fun x => indMono T τ x) := by
  intro x y hxy
  unfold indMono
  exact Finset.prod_congr rfl fun i hi => by rw [hxy i hi]

theorem deg_mono {f : (ι → α) → ℝ} {d e : ℕ} (h : HasProdDegreeLE f d) (hde : d ≤ e) :
    HasProdDegreeLE f e := by
  obtain ⟨a, ha0, ha⟩ := h
  exact ⟨a, fun T hT τ => ha0 T (lt_of_le_of_lt hde hT) τ, ha⟩

theorem deg_add {f g : (ι → α) → ℝ} {d : ℕ} (hf : HasProdDegreeLE f d)
    (hg : HasProdDegreeLE g d) : HasProdDegreeLE (fun x => f x + g x) d := by
  obtain ⟨a, ha0, ha⟩ := hf
  obtain ⟨b, hb0, hb⟩ := hg
  refine ⟨fun T τ => a T τ + b T τ, fun T hT τ => by
    simp only; rw [ha0 T hT τ, hb0 T hT τ, add_zero], fun x => ?_⟩
  simp only
  rw [ha x, hb x, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun T _ => ?_
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun τ _ => by ring

theorem deg_smul {f : (ι → α) → ℝ} {d : ℕ} (c : ℝ) (hf : HasProdDegreeLE f d) :
    HasProdDegreeLE (fun x => c * f x) d := by
  obtain ⟨a, ha0, ha⟩ := hf
  refine ⟨fun T τ => c * a T τ, fun T hT τ => by simp only; rw [ha0 T hT τ, mul_zero],
    fun x => ?_⟩
  simp only
  rw [ha x, Finset.mul_sum]
  refine Finset.sum_congr rfl fun T _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun τ _ => by ring

theorem deg_const (c : ℝ) (d : ℕ) : HasProdDegreeLE (fun _ : ι → α => c) d := by
  have h := deg_of_terms (ι := ι) (α := α) (γ := Unit) (fun _ _ => c) (fun _ => (∅ : Finset ι)) d
    (fun _ => Or.inl (by simp)) (fun _ x y _ => rfl)
  simpa using h

theorem deg_mul {f g : (ι → α) → ℝ} {d e : ℕ} (hf : HasProdDegreeLE f d)
    (hg : HasProdDegreeLE g e) : HasProdDegreeLE (fun x => f x * g x) (d + e) := by
  classical
  obtain ⟨a, ha0, ha⟩ := hf
  obtain ⟨b, hb0, hb⟩ := hg
  have hexp : (fun x => f x * g x) = fun x =>
      ∑ c : (Finset ι × (ι → α)) × (Finset ι × (ι → α)),
        a c.1.1 c.1.2 * b c.2.1 c.2.2 * (indMono c.1.1 c.1.2 x * indMono c.2.1 c.2.2 x) := by
    funext x
    have hfa : f x = ∑ p : Finset ι × (ι → α), a p.1 p.2 * indMono p.1 p.2 x := by
      rw [ha x, Fintype.sum_prod_type]
    have hgb : g x = ∑ q : Finset ι × (ι → α), b q.1 q.2 * indMono q.1 q.2 x := by
      rw [hb x, Fintype.sum_prod_type]
    rw [hfa, hgb, Finset.sum_mul_sum, ← Fintype.sum_prod_type'
      (f := fun (i j : Finset ι × (ι → α)) =>
        a i.1 i.2 * indMono i.1 i.2 x * (b j.1 j.2 * indMono j.1 j.2 x))]
    exact Finset.sum_congr rfl fun c _ => by ring
  rw [hexp]
  apply deg_of_terms _ (fun c => c.1.1 ∪ c.2.1)
  · intro c
    by_cases h1 : c.1.1.card ≤ d
    · by_cases h2 : c.2.1.card ≤ e
      · left; exact (Finset.card_union_le _ _).trans (Nat.add_le_add h1 h2)
      · right; intro x; rw [hb0 _ (by omega) _]; ring
    · right; intro x; rw [ha0 _ (by omega) _]; ring
  · intro c x y hxy
    have h1 := indMono_supported c.1.1 c.1.2 x y fun i hi => hxy i (Finset.mem_union_left _ hi)
    have h2 := indMono_supported c.2.1 c.2.2 x y fun i hi => hxy i (Finset.mem_union_right _ hi)
    simp only at h1 h2 ⊢
    rw [h1, h2]

theorem deg_sect {f : (ι → α) → ℝ} {d : ℕ} (hf : HasProdDegreeLE f d) (j : ι) (c : α) :
    HasProdDegreeLE (sect f j c) d := by
  classical
  obtain ⟨a, ha0, ha⟩ := hf
  have hexp : sect f j c = fun x => ∑ p : Finset ι × (ι → α),
      a p.1 p.2 * indMono p.1 p.2 (Function.update x j c) := by
    funext x
    unfold sect
    rw [ha, Fintype.sum_prod_type]
  rw [hexp]
  apply deg_of_terms _ (fun p => p.1.erase j)
  · intro p
    by_cases h : p.1.card ≤ d
    · left; exact (Finset.card_erase_le).trans h
    · right; intro x; rw [ha0 _ (by omega) _, zero_mul]
  · intro p x y hxy
    simp only
    congr 1
    apply indMono_supported p.1 p.2
    intro i hi
    by_cases hij : i = j
    · subst hij; simp
    · rw [Function.update_of_ne hij, Function.update_of_ne hij]
      exact hxy i (Finset.mem_erase.mpr ⟨hij, hi⟩)

variable {β : Type} [Fintype β] [DecidableEq β] [Nonempty β]

theorem deg_comp {f : (ι → α) → ℝ} {d : ℕ} (hf : HasProdDegreeLE f d) (φ : β → α) :
    HasProdDegreeLE (fun w : ι → β => f (fun i => φ (w i))) d := by
  classical
  obtain ⟨a, ha0, ha⟩ := hf
  have hexp : (fun w : ι → β => f (fun i => φ (w i))) = fun w => ∑ p : Finset ι × (ι → α),
      a p.1 p.2 * indMono p.1 p.2 (fun i => φ (w i)) := by
    funext w
    rw [ha, Fintype.sum_prod_type]
  rw [hexp]
  apply deg_of_terms _ (fun p => p.1)
  · intro p
    by_cases h : p.1.card ≤ d
    · left; exact h
    · right; intro x; rw [ha0 _ (by omega) _, zero_mul]
  · intro p x y hxy
    simp only
    congr 1
    unfold indMono
    exact Finset.prod_congr rfl fun i hi => by simp only [hxy i hi]

end Degree

section Push

variable {ι α U : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
  [Fintype U] [DecidableEq U]

/-- Pushforward of a product sum under coordinatewise maps. -/
theorem sum_push (m : ι → U → ℝ) (φ : ι → U → α) (F : (ι → α) → ℝ) :
    ∑ u : ι → U, (∏ i, m i (u i)) * F (fun i => φ i (u i)) =
      ∑ x : ι → α, (∏ i, ∑ v ∈ univ.filter (fun v => φ i v = x i), m i v) * F x := by
  classical
  rw [← Finset.sum_fiberwise univ (fun u : ι → U => fun i => φ i (u i))]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.prod_univ_sum, Finset.sum_mul]
  apply Finset.sum_congr
  · ext u
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Fintype.mem_piFinset]
    constructor
    · intro h i; rw [← h]
    · intro h; funext i; exact h i
  · intro u hu
    rw [Fintype.mem_piFinset] at hu
    have : (fun i => φ i (u i)) = x := funext fun i => (Finset.mem_filter.mp (hu i)).2
    rw [this]

end Push

section PairFooling

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]

/-- Squared difference of the two halves of a pair configuration. -/
noncomputable def pairSq (f : (ι → α) → ℝ) (w : ι → α × α) : ℝ :=
  (f (fun i => (w i).1) - f (fun i => (w i).2)) ^ 2

theorem deg_pairSq {f : (ι → α) → ℝ} {d : ℕ} (hf : HasProdDegreeLE f d) :
    HasProdDegreeLE (pairSq f) (2 * d) := by
  have h1 : HasProdDegreeLE (fun w : ι → α × α => f (fun i => (w i).1)) d := deg_comp hf Prod.fst
  have h2 : HasProdDegreeLE (fun w : ι → α × α => f (fun i => (w i).2)) d := deg_comp hf Prod.snd
  have hdiff : HasProdDegreeLE (fun w : ι → α × α =>
      f (fun i => (w i).1) + (-1) * f (fun i => (w i).2)) d := deg_add h1 (deg_smul (-1) h2)
  have := deg_mul hdiff hdiff
  rw [show d + d = 2 * d by ring] at this
  convert this using 1
  funext w; unfold pairSq; ring

/-- Diagonal law with the same first marginal. -/
noncomputable def diagLaw (ρ : ι → α × α → ℝ) (i : ι) (c : α × α) : ℝ :=
  if c.1 = c.2 then ∑ b, ρ i (c.1, b) else 0

/-- Mismatch mass of a pair law. -/
noncomputable def pairMismatch (ρ : α × α → ℝ) : ℝ :=
  ∑ c, if c.1 = c.2 then 0 else ρ c

theorem diagLaw_nonneg (ρ : ι → α × α → ℝ) (h0 : ∀ i c, 0 ≤ ρ i c) (i : ι) (c : α × α) :
    0 ≤ diagLaw ρ i c := by
  unfold diagLaw; split_ifs
  · exact Finset.sum_nonneg fun b _ => h0 i _
  · exact le_refl 0

theorem diagLaw_sum (ρ : ι → α × α → ℝ) (h1 : ∀ i, ∑ c, ρ i c = 1) (i : ι) :
    ∑ c, diagLaw ρ i c = 1 := by
  unfold diagLaw
  rw [← Finset.univ_product_univ, Finset.sum_product]
  have : ∀ a : α, ∑ b : α, (if (a, b).1 = (a, b).2 then ∑ b', ρ i (a, b') else 0) =
      ∑ b', ρ i (a, b') := fun a => by
    simp only
    rw [Finset.sum_ite_eq univ a]
    simp
  rw [Finset.sum_congr rfl fun a _ => this a, ← Finset.sum_product', Finset.univ_product_univ]
  exact h1 i

theorem tvd_diag (ρ : ι → α × α → ℝ) (h0 : ∀ i c, 0 ≤ ρ i c) (h1 : ∀ i, ∑ c, ρ i c = 1)
    (i : ι) : tvd (ρ i) (diagLaw ρ i) = pairMismatch (ρ i) := by
  unfold tvd pairMismatch
  have hmin : ∀ c : α × α, min (ρ i c) (diagLaw ρ i c) = if c.1 = c.2 then ρ i c else 0 := by
    intro c
    unfold diagLaw
    split_ifs with h
    · apply min_eq_left
      obtain ⟨a, b⟩ := c
      simp only at h
      subst h
      exact Finset.single_le_sum (fun b _ => h0 i (a, b)) (Finset.mem_univ a)
    · exact min_eq_right (h0 i c)
  rw [Finset.sum_congr rfl fun c _ => hmin c]
  have hsplit : ∀ c : α × α, ρ i c = (if c.1 = c.2 then ρ i c else 0) +
      (if c.1 = c.2 then 0 else ρ i c) := fun c => by split_ifs <;> ring
  have : ∑ c, ρ i c = ∑ c, (if c.1 = c.2 then ρ i c else 0) +
      ∑ c, (if c.1 = c.2 then 0 else ρ i c) := by
    rw [← Finset.sum_add_distrib]; exact Finset.sum_congr rfl fun c _ => hsplit c
  rw [h1 i] at this
  linarith

theorem pexp_diag_pairSq (ρ : ι → α × α → ℝ) (f : (ι → α) → ℝ) :
    pexp (diagLaw ρ) (pairSq f) = 0 := by
  unfold pexp
  refine Finset.sum_eq_zero fun w _ => ?_
  by_cases hw : ∀ i, (w i).1 = (w i).2
  · have : (fun i => (w i).1) = fun i => (w i).2 := funext hw
    unfold pairSq; rw [this]; ring
  · push_neg at hw
    obtain ⟨i, hi⟩ := hw
    have : prodMass (diagLaw ρ) w = 0 := by
      unfold prodMass
      exact Finset.prod_eq_zero (Finset.mem_univ i) (by unfold diagLaw; simp [hi])
    rw [this, zero_mul]

/-- **Pair fooling.** -/
theorem pair_fooling (ρ : ι → α × α → ℝ) (h0 : ∀ i c, 0 ≤ ρ i c) (h1 : ∀ i, ∑ c, ρ i c = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hdeg : HasProdDegreeLE f d)
    (η : ℝ) (hη0 : 0 < η) (hη1 : η ≤ 1 / 2) (hmis : ∀ i, pairMismatch (ρ i) ≤ η) :
    pexp ρ (pairSq f) ≤ 64 * (d : ℝ) ^ 2 * η := by
  have hbd : ∀ w, |pairSq f w| ≤ 1 := by
    intro w
    unfold pairSq
    have ha := hf01 (fun i => (w i).1)
    have hb := hf01 (fun i => (w i).2)
    rw [abs_of_nonneg (sq_nonneg _)]
    nlinarith
  have hfool := fooling_tv ρ (diagLaw ρ) h0 (diagLaw_nonneg ρ h0) h1 (diagLaw_sum ρ h1) η hη0 hη1
    (fun i => by rw [tvd_diag ρ h0 h1 i]; exact hmis i) (2 * d) (pairSq f) hbd
    (by exact_mod_cast deg_pairSq hdeg)
  rw [pexp_diag_pairSq, sub_zero] at hfool
  have := (le_abs_self _).trans hfool
  push_cast at this
  linarith

end PairFooling

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.deg_mul
#print axioms Nightfall.Route1Polylog.deg_sect
#print axioms Nightfall.Route1Polylog.sum_push
#print axioms Nightfall.Route1Polylog.pair_fooling
