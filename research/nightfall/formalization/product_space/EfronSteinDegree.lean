import ProductSpaceTwoSidedBridge
import ProductRowBound

/-!
# NIGHTFALL: indicator-monomial degree equals Efron–Stein degree on finite products

On a finite product `ι → α` with coordinate laws `p i` (`p i a ≥ 0`, `∑ₐ p i a = 1`; zero-mass
atoms allowed), define the conditional expectation given the coordinates in `U`,

`condExp p U f x = E_y f (x on U, y off U)`,  `y` drawn from the product law,

and the Efron–Stein components by Möbius inversion over subsets,

`esComp p S f = ∑_{U ⊆ S} (-1)^{|S| - |U|} condExp p U f`.

Main results (all pointwise, with no positivity assumption on the masses):

* `es_decomp`               — `f = ∑_S esComp p S f`;
* `esComp_dependsOn`        — `esComp p S f` depends only on the coordinates in `S`;
* `esComp_indep`            — `esComp p S g = 0` when `g` does not depend on some `k ∈ S`;
* `junta_expand`            — a function depending only on `S` is a combination of indicator
                              monomials on `S`;
* `prodDegree_iff_esDegree` — `RowBound.HasProdDegreeLE f d` (combination of indicator monomials
  `∏_{i ∈ T} 1[x_i = τ_i]`, `|T| ≤ d`) holds iff every Efron–Stein component of order `> d`
  vanishes.

This identifies the degree hypothesis of `RowBound.product_row_bound` and
`Influence.product_influence` with the usual Efron–Stein (Hoeffding/ANOVA) degree, and gives the
finite form of the decomposition that a measurable version would start from.
-/

namespace Nightfall.ProductSpace.EfronStein

open Finset
open Nightfall.ProductSpace.Transfer

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- `x` on `U`, `y` off `U`. -/
def merge (U : Finset ι) (x y : ι → α) : ι → α := fun i => if i ∈ U then x i else y i

/-- Conditional expectation given the coordinates in `U`. -/
noncomputable def condExp (p : ι → α → ℝ) (U : Finset ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ y, prodMass p y * f (merge U x y)

/-- Efron–Stein component of `f` on the coordinate set `S`. -/
noncomputable def esComp (p : ι → α → ℝ) (S : Finset ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ U ∈ S.powerset, (-1 : ℝ) ^ (S.card - U.card) * condExp p U f x

/-- `g` depends only on the coordinates in `T`. -/
def DependsOn (T : Finset ι) (g : (ι → α) → ℝ) : Prop :=
  ∀ x x' : ι → α, (∀ i ∈ T, x i = x' i) → g x = g x'

/-- Efron–Stein degree at most `d`: all components of order `> d` vanish. -/
def ESDegreeLE (p : ι → α → ℝ) (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∀ S : Finset ι, d < S.card → ∀ x, esComp p S f x = 0

theorem sum_prodMass' (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) :
    ∑ x : ι → α, prodMass p x = 1 := by
  have h : ∑ x : ι → α, ∏ i, p i (x i) = ∏ i, ∑ a, p i a :=
    (Fintype.prod_sum (fun i (a : α) => p i a)).symm
  unfold prodMass
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
  rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]

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
  calc ∑ y, prodMass p y * ∑ k, c k * g k (merge U x y)
      = ∑ y, ∑ k, c k * (prodMass p y * g k (merge U x y)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro k _
        ring
    _ = ∑ k, ∑ y, c k * (prodMass p y * g k (merge U x y)) := Finset.sum_comm
    _ = ∑ k, c k * ∑ y, prodMass p y * g k (merge U x y) := by
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

/-! ## Juntas are combinations of indicator monomials -/

theorem junta_expand (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (S : Finset ι)
    (g : (ι → α) → ℝ) (hg : DependsOn S g) (x : ι → α) :
    ∑ τ : ι → α, (g τ * ∏ i, (if i ∈ S then (1 : ℝ) else p i (τ i))) *
      RowBound.indMono S τ x = g x := by
  have hterm : ∀ τ : ι → α, (g τ * ∏ i, (if i ∈ S then (1 : ℝ) else p i (τ i))) *
      RowBound.indMono S τ x =
        g x * ∏ i, (if i ∈ S then (if x i = τ i then (1 : ℝ) else 0) else p i (τ i)) := by
    intro τ
    have hprod : (∏ i, (if i ∈ S then (1 : ℝ) else p i (τ i))) * RowBound.indMono S τ x =
        ∏ i, (if i ∈ S then (if x i = τ i then (1 : ℝ) else 0) else p i (τ i)) := by
      unfold RowBound.indMono
      rw [← Fintype.prod_ite_mem S (fun i => if x i = τ i then (1 : ℝ) else 0),
        ← Finset.prod_mul_distrib]
      apply Finset.prod_congr rfl
      intro i _
      split_ifs <;> ring
    by_cases hall : ∀ i ∈ S, x i = τ i
    · rw [mul_assoc, hprod, hg τ x (fun i hi => (hall i hi).symm)]
    · push_neg at hall
      obtain ⟨i, hiS, hne⟩ := hall
      have hz : ∏ i, (if i ∈ S then (if x i = τ i then (1 : ℝ) else 0) else p i (τ i)) = 0 :=
        Finset.prod_eq_zero (mem_univ i) (by simp [hiS, hne])
      rw [mul_assoc, hprod, hz, mul_zero, mul_zero]
  rw [Finset.sum_congr rfl (fun τ _ => hterm τ), ← Finset.mul_sum]
  have hsum : ∑ τ : ι → α,
      ∏ i, (if i ∈ S then (if x i = τ i then (1 : ℝ) else 0) else p i (τ i)) = 1 := by
    have hfac : ∑ τ : ι → α,
        ∏ i, (if i ∈ S then (if x i = τ i then (1 : ℝ) else 0) else p i (τ i)) =
        ∏ i, ∑ a : α, (if i ∈ S then (if x i = a then (1 : ℝ) else 0) else p i a) :=
      (Fintype.prod_sum (fun i (a : α) =>
        if i ∈ S then (if x i = a then (1 : ℝ) else 0) else p i a)).symm
    rw [hfac]
    apply Finset.prod_eq_one
    intro i _
    by_cases hi : i ∈ S
    · simp [hi]
    · simp [hi, hp1 i]
  rw [hsum, mul_one]

theorem indMono_indep (T : Finset ι) (τ : ι → α) (k : ι) (hk : k ∉ T) (z : ι → α) (c : α) :
    RowBound.indMono T τ (Function.update z k c) = RowBound.indMono T τ z := by
  unfold RowBound.indMono
  apply Finset.prod_congr rfl
  intro i hi
  have hik : i ≠ k := fun h => hk (h ▸ hi)
  rw [Function.update_of_ne hik]

/-! ## The equivalence -/

theorem esDegree_of_prodDegree (p : ι → α → ℝ) (f : (ι → α) → ℝ) (d : ℕ)
    (hd : RowBound.HasProdDegreeLE f d) : ESDegreeLE p f d := by
  obtain ⟨a, ha0, hfa⟩ := hd
  intro S hS x
  have hf : f = fun y => ∑ k : Finset ι × (ι → α), a k.1 k.2 * RowBound.indMono k.1 k.2 y := by
    funext y
    rw [hfa y]
    exact (Fintype.sum_prod_type (fun k : Finset ι × (ι → α) =>
      a k.1 k.2 * RowBound.indMono k.1 k.2 y)).symm
  rw [hf, esComp_lin]
  apply Finset.sum_eq_zero
  intro k _
  by_cases hk : d < k.1.card
  · rw [ha0 k.1 hk k.2, zero_mul]
  · obtain ⟨i, hiS, hiT⟩ : ∃ i ∈ S, i ∉ k.1 := by
      by_contra hcon
      push_neg at hcon
      have hsub : S.card ≤ k.1.card := Finset.card_le_card (fun i hi => hcon i hi)
      omega
    rw [esComp_indep p S _ x i hiS (fun z c => indMono_indep k.1 k.2 i hiT z c), mul_zero]

theorem prodDegree_of_esDegree (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (d : ℕ) (hes : ESDegreeLE p f d) : RowBound.HasProdDegreeLE f d := by
  refine ⟨fun S τ => if S.card ≤ d then
      esComp p S f τ * ∏ i, (if i ∈ S then (1 : ℝ) else p i (τ i)) else 0, ?_, ?_⟩
  · intro T hT τ
    beta_reduce
    rw [if_neg (not_le.mpr hT)]
  · intro x
    rw [← es_decomp p hp1 f x]
    apply Finset.sum_congr rfl
    intro S _
    beta_reduce
    by_cases hS : S.card ≤ d
    · simp only [if_pos hS]
      exact (junta_expand p hp1 S (esComp p S f) (esComp_dependsOn p S f) x).symm
    · simp only [if_neg hS, zero_mul, Finset.sum_const_zero]
      exact hes S (not_le.mp hS) x

/-- **Indicator-monomial degree equals Efron–Stein degree** on a finite product with any
coordinate probability laws (zero-mass atoms allowed). -/
theorem prodDegree_iff_esDegree (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (d : ℕ) : RowBound.HasProdDegreeLE f d ↔ ESDegreeLE p f d :=
  ⟨esDegree_of_prodDegree p f d, prodDegree_of_esDegree p hp1 f d⟩

end Nightfall.ProductSpace.EfronStein
