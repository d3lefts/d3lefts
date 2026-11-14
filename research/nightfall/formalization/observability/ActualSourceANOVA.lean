import ActualProductSoftNoise

/-!
# Turturean-free canonical Efron–Stein finite-product decomposition

All source expectations are literal finite sums of originalMass p.
The coordinate laws can be nonuniform and have zero-mass atoms.

This port is independently compiled on the current repository pin,
not inherited from the older Lean 4.33 Turturean import graph.
Proof construction traces to the existing repository's
EfronSteinDegree.lean Möbius algebra, adapted to current source operators.

This does NOT assert the Q2 variance-influence bound.
-/

namespace Nightfall.Observability.ActualSourceANOVA

open Finset
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- `x` on `U`, `y` off `U`. -/
def merge (U : Finset ι) (x y : ι → α) : ι → α := fun i => if i ∈ U then x i else y i

/-- Conditional expectation given the coordinates in `U`. -/
noncomputable def condExp (p : ι → α → ℝ) (U : Finset ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ y, originalMass p y * f (merge U x y)

/-- Efron–Stein component of `f` on the coordinate set `S`. -/
noncomputable def esComp (p : ι → α → ℝ) (S : Finset ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ U ∈ S.powerset, (-1 : ℝ) ^ (S.card - U.card) * condExp p U f x

/-- `g` depends only on the coordinates in `T`. -/
def DependsOn (T : Finset ι) (g : (ι → α) → ℝ) : Prop :=
  ∀ x x' : ι → α, (∀ i ∈ T, x i = x' i) → g x = g x'

/-- Efron–Stein degree at most `d`: all components of order `> d` vanish. -/
def ESDegreeLE (p : ι → α → ℝ) (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∀ S : Finset ι, d < S.card → ∀ x, esComp p S f x = 0

theorem sum_originalMass' (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) :
    ∑ x : ι → α, originalMass p x = 1 := by
  have h : ∑ x : ι → α, ∏ i, p i (x i) = ∏ i, ∑ a, p i a :=
    (Fintype.prod_sum (fun i (a : α) => p i a)).symm
  unfold originalMass
  rw [h]
  simp [hp1]

/-! ## Basic properties -/

theorem condExp_univ (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ)
    (x : ι → α) : condExp p univ f x = f x := by
  unfold condExp
  have hm : ∀ y : ι → α, merge univ x y = x := by
    intro y
    funext i
    simp [merge]
  simp only [hm]
  rw [← Finset.sum_mul, sum_originalMass' p hp1, one_mul]

theorem condExp_dependsOn (p : ι → α → ℝ) (U : Finset ι) (f : (ι → α) → ℝ) :
    DependsOn U (condExp p U f) := by
  intro x x' hxx
  unfold condExp
  apply Finset.sum_congr rfl
  intro y _
  have hm : merge U x y = merge U x' y := by
    funext i
    unfold merge
    by_cases hi : i ∈ U
    · rw [if_pos hi, if_pos hi, hxx i hi]
    · rw [if_neg hi, if_neg hi]
  rw [hm]

theorem esComp_dependsOn (p : ι → α → ℝ) (S : Finset ι) (f : (ι → α) → ℝ) :
    DependsOn S (esComp p S f) := by
  intro x x' hxx
  unfold esComp
  apply Finset.sum_congr rfl
  intro U hU
  rw [condExp_dependsOn p U f x x' (fun i hi => hxx i (Finset.mem_powerset.mp hU hi))]

theorem condExp_lin {κ : Type*} [Fintype κ] (p : ι → α → ℝ) (U : Finset ι) (c : κ → ℝ)
    (g : κ → (ι → α) → ℝ) (x : ι → α) :
    condExp p U (fun y => ∑ k, c k * g k y) x = ∑ k, c k * condExp p U (g k) x := by
  unfold condExp
  calc ∑ y, originalMass p y * ∑ k, c k * g k (merge U x y)
      = ∑ y, ∑ k, c k * (originalMass p y * g k (merge U x y)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro k _
        ring
    _ = ∑ k, ∑ y, c k * (originalMass p y * g k (merge U x y)) := Finset.sum_comm
    _ = ∑ k, c k * ∑ y, originalMass p y * g k (merge U x y) := by
        apply Finset.sum_congr rfl
        intro k _
        rw [Finset.mul_sum]

theorem esComp_lin {κ : Type*} [Fintype κ] (p : ι → α → ℝ) (S : Finset ι) (c : κ → ℝ)
    (g : κ → (ι → α) → ℝ) (x : ι → α) :
    esComp p S (fun y => ∑ k, c k * g k y) x = ∑ k, c k * esComp p S (g k) x := by
  unfold esComp
  calc ∑ U ∈ S.powerset, (-1 : ℝ) ^ (S.card - U.card) * condExp p U (fun y => ∑ k, c k * g k y) x
      = ∑ U ∈ S.powerset, ∑ k, c k * ((-1 : ℝ) ^ (S.card - U.card) * condExp p U (g k) x) := by
        apply Finset.sum_congr rfl
        intro U _
        rw [condExp_lin, Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro k _
        ring
    _ = ∑ k, ∑ U ∈ S.powerset, c k * ((-1 : ℝ) ^ (S.card - U.card) * condExp p U (g k) x) :=
        Finset.sum_comm
    _ = _ := by
        apply Finset.sum_congr rfl
        intro k _
        rw [Finset.mul_sum]

/-! ## Toggling one coordinate in a subset -/

/-- Remove `k` from `V` if present, insert it otherwise. -/
def toggle (k : ι) (V : Finset ι) : Finset ι := if k ∈ V then V.erase k else insert k V

theorem toggle_toggle (k : ι) (V : Finset ι) : toggle k (toggle k V) = V := by
  unfold toggle
  by_cases h : k ∈ V
  · have h1 : k ∉ V.erase k := by simp
    rw [if_pos h, if_neg h1, Finset.insert_erase h]
  · have h1 : k ∈ insert k V := Finset.mem_insert_self k V
    rw [if_neg h, if_pos h1, Finset.erase_insert h]

theorem toggle_card (k : ι) (V : Finset ι) :
    (toggle k V).card + 1 = V.card ∨ V.card + 1 = (toggle k V).card := by
  unfold toggle
  by_cases h : k ∈ V
  · rw [if_pos h]
    left
    have h1 := Finset.card_erase_of_mem h
    have h2 : 0 < V.card := Finset.card_pos.mpr ⟨k, h⟩
    omega
  · rw [if_neg h]
    right
    rw [Finset.card_insert_of_notMem h]

theorem mem_toggle_ne {k i : ι} (hik : i ≠ k) (V : Finset ι) : i ∈ toggle k V ↔ i ∈ V := by
  unfold toggle
  split_ifs <;> simp [hik]

theorem toggle_subset {k : ι} {S V : Finset ι} (hk : k ∈ S) (hV : V ⊆ S) : toggle k V ⊆ S := by
  unfold toggle
  split_ifs
  · exact (Finset.erase_subset k V).trans hV
  · exact Finset.insert_subset hk hV

theorem neg_one_pow_flip {e1 e2 : ℕ} (h : e1 = e2 + 1 ∨ e2 = e1 + 1) :
    (-1 : ℝ) ^ e1 = -(-1 : ℝ) ^ e2 := by
  rcases h with h | h
  · rw [h, pow_succ]
    ring
  · rw [h, pow_succ]
    ring

/-- A sum over a toggle-closed family vanishes when toggling flips the sign of the summand. -/
theorem sum_toggle_cancel (s : Finset (Finset ι)) (k : ι) (F : Finset ι → ℝ)
    (hs : ∀ V ∈ s, toggle k V ∈ s) (hF : ∀ V ∈ s, F (toggle k V) = -F V) :
    ∑ V ∈ s, F V = 0 := by
  have h : ∑ V ∈ s, F V = ∑ V ∈ s, -F V := by
    refine Finset.sum_bij (fun V _ => toggle k V) (fun V hV => hs V hV) ?_ ?_ ?_
    · intro V1 _ V2 _ h12
      have h' := congrArg (toggle k) h12
      simpa [toggle_toggle] using h'
    · intro W hW
      exact ⟨toggle k W, hs W hW, toggle_toggle k W⟩
    · intro V hV
      rw [hF V hV, neg_neg]
  rw [Finset.sum_neg_distrib] at h
  linarith

theorem merge_toggle (k : ι) (V : Finset ι) (x y : ι → α) :
    merge (toggle k V) x y = Function.update (merge V x y) k (merge (toggle k V) x y k) := by
  funext i
  by_cases hik : i = k
  · rw [hik]
    simp
  · rw [Function.update_of_ne hik]
    show (if i ∈ toggle k V then x i else y i) = (if i ∈ V then x i else y i)
    by_cases hi : i ∈ V
    · rw [if_pos ((mem_toggle_ne hik V).mpr hi), if_pos hi]
    · rw [if_neg (fun h => hi ((mem_toggle_ne hik V).mp h)), if_neg hi]

theorem condExp_toggle (p : ι → α → ℝ) (g : (ι → α) → ℝ) (x : ι → α) (k : ι) (V : Finset ι)
    (hg : ∀ z c, g (Function.update z k c) = g z) :
    condExp p (toggle k V) g x = condExp p V g x := by
  unfold condExp
  apply Finset.sum_congr rfl
  intro y _
  rw [merge_toggle k V x y, hg]

/-- Components on a set containing a coordinate that `g` ignores vanish. -/
theorem esComp_indep (p : ι → α → ℝ) (S : Finset ι) (g : (ι → α) → ℝ) (x : ι → α) (k : ι)
    (hk : k ∈ S) (hg : ∀ z c, g (Function.update z k c) = g z) : esComp p S g x = 0 := by
  unfold esComp
  apply sum_toggle_cancel S.powerset k
  · intro V hV
    rw [Finset.mem_powerset] at hV ⊢
    exact toggle_subset hk hV
  · intro V hV
    rw [Finset.mem_powerset] at hV
    beta_reduce
    rw [condExp_toggle p g x k V hg]
    have hc := toggle_card k V
    have hle1 : V.card ≤ S.card := Finset.card_le_card hV
    have hle2 : (toggle k V).card ≤ S.card := Finset.card_le_card (toggle_subset hk hV)
    rw [neg_one_pow_flip (e1 := S.card - (toggle k V).card) (e2 := S.card - V.card) (by omega)]
    ring

/-! ## The Möbius identity and the decomposition `f = ∑_S esComp S f` -/

theorem inner_mobius (U : Finset ι) :
    ∑ S ∈ univ.filter (fun S : Finset ι => U ⊆ S), (-1 : ℝ) ^ (S.card - U.card) =
      if U = univ then 1 else 0 := by
  by_cases hU : U = univ
  · rw [if_pos hU]
    have hfil : univ.filter (fun S : Finset ι => U ⊆ S) = {univ} := by
      ext S
      simp [hU, Finset.univ_subset_iff]
    rw [hfil, Finset.sum_singleton, hU, Nat.sub_self, pow_zero]
  · rw [if_neg hU]
    obtain ⟨k, hk⟩ : ∃ k, k ∉ U := by
      by_contra h
      push_neg at h
      exact hU (Finset.eq_univ_iff_forall.mpr h)
    apply sum_toggle_cancel _ k
    · intro S hS
      have hUS : U ⊆ S := (Finset.mem_filter.mp hS).2
      refine Finset.mem_filter.mpr ⟨mem_univ _, ?_⟩
      intro i hi
      have hik : i ≠ k := fun h => hk (h ▸ hi)
      exact (mem_toggle_ne hik S).mpr (hUS hi)
    · intro S hS
      have hUS : U ⊆ S := (Finset.mem_filter.mp hS).2
      have hUT : U ⊆ toggle k S := by
        intro i hi
        have hik : i ≠ k := fun h => hk (h ▸ hi)
        exact (mem_toggle_ne hik S).mpr (hUS hi)
      have hc := toggle_card k S
      have hle1 : U.card ≤ S.card := Finset.card_le_card hUS
      have hle2 : U.card ≤ (toggle k S).card := Finset.card_le_card hUT
      beta_reduce
      exact neg_one_pow_flip (by omega)

/-- **Efron–Stein decomposition**: `f = ∑_S esComp p S f` pointwise. -/
theorem es_decomp (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (f : (ι → α) → ℝ)
    (x : ι → α) : ∑ S : Finset ι, esComp p S f x = f x := by
  unfold esComp
  have h1 : ∑ S : Finset ι, ∑ U ∈ S.powerset, (-1 : ℝ) ^ (S.card - U.card) * condExp p U f x =
      ∑ U : Finset ι, ∑ S ∈ univ.filter (fun S : Finset ι => U ⊆ S),
        (-1 : ℝ) ^ (S.card - U.card) * condExp p U f x :=
    Finset.sum_comm' (fun S U => by simp [Finset.mem_powerset])
  rw [h1]
  have h2 : ∀ U : Finset ι, ∑ S ∈ univ.filter (fun S : Finset ι => U ⊆ S),
      (-1 : ℝ) ^ (S.card - U.card) * condExp p U f x =
        (if U = univ then 1 else 0) * condExp p U f x := by
    intro U
    rw [← Finset.sum_mul, inner_mobius U]
  rw [Finset.sum_congr rfl (fun U _ => h2 U)]
  rw [Finset.sum_eq_single (univ : Finset ι)]
  · rw [if_pos rfl, one_mul]
    exact condExp_univ p hp1 f x
  · intro U _ hU
    rw [if_neg hU, zero_mul]
  · intro h
    exact (h (mem_univ _)).elim


/-- The actual source's order-≤2 canonical Hoeffding representation
is a consequence of the formal ESDegreeLE hypothesis, not a free
decomposition input or energy budget. -/
theorem actual_degree_two_source_decomposition
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ S : Finset ι,
      if S.card ≤ 2 then esComp p S f x else 0) = f x := by
  classical
  calc
    (∑ S : Finset ι,
      if S.card ≤ 2 then esComp p S f x else 0) =
      ∑ S : Finset ι, esComp p S f x := by
        apply Finset.sum_congr rfl
        intro S _
        by_cases hS : S.card ≤ 2
        · simp [hS]
        · have hz : esComp p S f x = 0 :=
            hdegree S (by omega) x
          simp [hS, hz]
    _ = f x := es_decomp p hp1 f x

/-- Canonical original-product conditional expectation equals the
literal source-preserving conditional refresh, no foreign law. -/
theorem canonical_condExp_eq_sourceConditional
    (p : ι → α → ℝ)
    (U : Finset ι) (f : (ι → α) → ℝ) (x : ι → α) :
    condExp p U f x =
      Nightfall.Observability.ActualProductSoftNoise.sourceConditional p U f x := by
  unfold condExp
    Nightfall.Observability.ActualProductSoftNoise.sourceConditional
  simp only [smul_eq_mul]

end Nightfall.Observability.ActualSourceANOVA
