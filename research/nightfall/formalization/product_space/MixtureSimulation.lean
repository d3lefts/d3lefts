import ProductSimulation

/-!
# NIGHTFALL — classical simulation over mixtures of product laws

Inputs are drawn from `ν = ∑_θ w_θ μ_θ`, a mixture of product laws `μ_θ = ⊗_i P θ i` on a finite
`ι → α` (any masses, zeros allowed). For `f` with values in `[0,1]` and interaction degree at most
`d`, we build a decision tree whose depth depends only on `d`, the number of components, `ε` and
`δ` (`mixture_simulation`).

Part 1 (this section): the fooling lemma. A bounded function of degree `≤ d` changes its mean by
at most `16 d² γ` when every coordinate marginal moves by at most `γ` in total variation
(`fooling_tv`), independently of the number of coordinates. The proof embeds the coupling path
`κ + t (μ - κ)` into a cube of `m = ⌊1/γ⌋` bits and applies the vendored endpoint sensitivity bound
`Row.sum_abs_sub_unit_le` (Markov's inequality).
-/

namespace Nightfall.ProductSpace.Mixture

open Finset
open AaronsonAmbainis AaronsonAmbainis.Row
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-! ## The coupling path on a cube -/

/-- Number of true bits. -/
noncomputable def tcount {β : Type} [Fintype β] (w : Cube β) : ℝ :=
  ∑ b, if w b then (1 : ℝ) else 0

theorem hasDegreeLE_tcount {β : Type} [Fintype β] [DecidableEq β] :
    HasDegreeLE (tcount (β := β)) 1 :=
  hasDegreeLE_congr (hasDegreeLE_sum univ (fun b (w : Cube β) => if w b then (1 : ℝ) else 0)
    (fun b _ => hasDegreeLE_indicator b)) (fun _ => rfl)

theorem tcount_nonneg {β : Type} [Fintype β] (w : Cube β) : 0 ≤ tcount w :=
  Finset.sum_nonneg fun b _ => by split_ifs <;> norm_num

theorem tcount_le {β : Type} [Fintype β] (w : Cube β) : tcount w ≤ Fintype.card β := by
  unfold tcount
  calc ∑ b, (if w b then (1 : ℝ) else 0) ≤ ∑ _b : β, (1 : ℝ) :=
        Finset.sum_le_sum fun b _ => by split_ifs <;> norm_num
    _ = Fintype.card β := by simp

theorem tcount_zero {β : Type} [Fintype β] : tcount (Row.zero β) = 0 := by
  simp [tcount, Row.zero]

theorem tcount_unit {β : Type} [Fintype β] [DecidableEq β] (b : β) :
    tcount (Row.unit b) = 1 := by
  simp [tcount, Row.unit]

/-- The path `κ + t (μ - κ)` of coordinate laws. -/
def lawPath (κ μ : ι → α → ℝ) (t : ℝ) : ι → α → ℝ := fun i s => κ i s + t * (μ i s - κ i s)

theorem lawPath_sum (κ μ : ι → α → ℝ) (hκ : ∀ i, ∑ s, κ i s = 1) (hμ : ∀ i, ∑ s, μ i s = 1)
    (t : ℝ) (i : ι) : ∑ s, lawPath κ μ t i s = 1 := by
  simp only [lawPath, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hκ, hμ]
  ring

theorem lawPath_nonneg (κ μ : ι → α → ℝ) (m : ℝ) (hm : 0 < m) (h0 : ∀ i s, 0 ≤ κ i s)
    (hm' : ∀ i s, 0 ≤ κ i s + m * (μ i s - κ i s)) (t : ℝ) (ht0 : 0 ≤ t) (htm : t ≤ m)
    (i : ι) (s : α) : 0 ≤ lawPath κ μ t i s := by
  unfold lawPath
  have e : κ i s + t * (μ i s - κ i s) =
      (1 - t / m) * κ i s + (t / m) * (κ i s + m * (μ i s - κ i s)) := by
    field_simp; ring
  rw [e]
  have h1 : 0 ≤ 1 - t / m := by rw [sub_nonneg, div_le_one hm]; exact htm
  have h2 : 0 ≤ t / m := div_nonneg ht0 hm.le
  exact add_nonneg (mul_nonneg h1 (h0 i s)) (mul_nonneg h2 (hm' i s))

/-- The cube function `w ↦ E_{⊗ lawPath(|w|)} f`. -/
noncomputable def Gpath (κ μ : ι → α → ℝ) (f : (ι → α) → ℝ) {β : Type} [Fintype β]
    (w : Cube β) : ℝ :=
  ∑ σ : ι → α, f σ * ∏ i, lawPath κ μ (tcount w) i (σ i)

theorem pexp_eq_sum (p : ι → α → ℝ) (f : (ι → α) → ℝ) :
    pexp p f = ∑ σ : ι → α, f σ * ∏ i, p i (σ i) := by
  unfold pexp prodMass
  exact Finset.sum_congr rfl fun σ _ => mul_comm _ _

theorem Gpath_zero (κ μ : ι → α → ℝ) (f : (ι → α) → ℝ) {β : Type} [Fintype β] :
    Gpath κ μ f (Row.zero β) = pexp κ f := by
  rw [pexp_eq_sum]; simp [Gpath, tcount_zero, lawPath]

theorem Gpath_unit (κ μ : ι → α → ℝ) (f : (ι → α) → ℝ) {β : Type} [Fintype β] [DecidableEq β]
    (b : β) : Gpath κ μ f (Row.unit b) = pexp μ f := by
  rw [pexp_eq_sum]; simp [Gpath, tcount_unit, lawPath]

theorem hasDegreeLE_Gpath (κ μ : ι → α → ℝ) (hκ : ∀ i, ∑ s, κ i s = 1)
    (hμ : ∀ i, ∑ s, μ i s = 1) (d : ℕ) (f : (ι → α) → ℝ) (hd : HasProdDegreeLE f d)
    {β : Type} [Fintype β] [DecidableEq β] : HasDegreeLE (Gpath κ μ f (β := β)) d := by
  obtain ⟨a, ha0, ha⟩ := hd
  have hfac : ∀ i s, HasDegreeLE (fun w : Cube β => lawPath κ μ (tcount w) i s) 1 := by
    intro i s
    exact hasDegreeLE_congr
      (hasDegreeLE_add (hasDegreeLE_const (κ i s) 1)
        (hasDegreeLE_const_mul (μ i s - κ i s) hasDegreeLE_tcount))
      (fun w => by simp only [lawPath]; ring)
  have key : HasDegreeLE (fun w : Cube β => ∑ T ∈ (univ : Finset (Finset ι)),
      ∑ τ ∈ (univ : Finset (ι → α)), a T τ * ∏ i ∈ T, lawPath κ μ (tcount w) i (τ i)) d := by
    apply hasDegreeLE_sum
    intro T _
    apply hasDegreeLE_sum
    intro τ _
    by_cases hT : T.card ≤ d
    · refine hasDegreeLE_const_mul _ (hasDegreeLE_mono (show T.card * 1 ≤ d by simpa using hT) ?_)
      exact hasDegreeLE_prod T (fun i w => lawPath κ μ (tcount w) i (τ i))
        (fun i _ => hfac i (τ i))
    · exact hasDegreeLE_congr (hasDegreeLE_zero _)
        (fun w => by simp [ha0 T (not_le.mp hT) τ])
  refine hasDegreeLE_congr key (fun w => ?_)
  have hP : ∀ i, ∑ s, lawPath κ μ (tcount w) i s = 1 := lawPath_sum κ μ hκ hμ _
  unfold Gpath
  calc (∑ σ : ι → α, f σ * ∏ i, lawPath κ μ (tcount w) i (σ i))
      = ∑ σ : ι → α, ∑ T, ∑ τ, a T τ * (indMono T τ σ * ∏ i, lawPath κ μ (tcount w) i (σ i)) := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        rw [ha σ, Finset.sum_mul]
        refine Finset.sum_congr rfl fun T _ => ?_
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun τ _ => ?_
        ring
    _ = ∑ T, ∑ σ : ι → α, ∑ τ, a T τ * (indMono T τ σ * ∏ i, lawPath κ μ (tcount w) i (σ i)) :=
        Finset.sum_comm
    _ = ∑ T, ∑ τ, ∑ σ : ι → α, a T τ * (indMono T τ σ * ∏ i, lawPath κ μ (tcount w) i (σ i)) :=
        Finset.sum_congr rfl fun T _ => Finset.sum_comm
    _ = ∑ T, ∑ τ, a T τ * ∏ i ∈ T, lawPath κ μ (tcount w) i (τ i) := by
        refine Finset.sum_congr rfl fun T _ => Finset.sum_congr rfl fun τ _ => ?_
        rw [← Finset.mul_sum]
        exact congrArg (fun z => a T τ * z)
          (sum_indMono_mul_prod (fun i s => lawPath κ μ (tcount w) i s) hP T τ)

/-- **Path fooling.** If the path `κ + t (μ - κ)` stays a law for `t ∈ [0, m]`, a degree-`d`
function bounded by `1` has `m · |E_κ f - E_μ f| ≤ 4 d²`. -/
theorem path_fooling (κ μ : ι → α → ℝ) (hκ : ∀ i, ∑ s, κ i s = 1) (hμ : ∀ i, ∑ s, μ i s = 1)
    (h0 : ∀ i s, 0 ≤ κ i s) (m : ℕ) (hm : 0 < m)
    (hm' : ∀ i s, 0 ≤ κ i s + m * (μ i s - κ i s))
    (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1) (hd : HasProdDegreeLE f d) :
    (m : ℝ) * |pexp κ f - pexp μ f| ≤ 4 * (d : ℝ) ^ 2 := by
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hG : ∀ w : Cube (Fin m), |Gpath κ μ f w| ≤ 1 := by
    intro w
    have hW : ∀ σ : ι → α, 0 ≤ ∏ i, lawPath κ μ (tcount w) i (σ i) := fun σ =>
      Finset.prod_nonneg fun i _ => lawPath_nonneg κ μ m hmR h0 hm' _ (tcount_nonneg w)
        (by simpa using tcount_le w) i (σ i)
    have hsum : (∑ σ : ι → α, ∏ i, lawPath κ μ (tcount w) i (σ i)) = 1 :=
      sum_prod_eq_one (fun i s => lawPath κ μ (tcount w) i s) (lawPath_sum κ μ hκ hμ _)
    unfold Gpath
    calc |∑ σ : ι → α, f σ * ∏ i, lawPath κ μ (tcount w) i (σ i)|
        ≤ ∑ σ : ι → α, |f σ * ∏ i, lawPath κ μ (tcount w) i (σ i)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ = ∑ σ : ι → α, |f σ| * ∏ i, lawPath κ μ (tcount w) i (σ i) := by
          refine Finset.sum_congr rfl fun σ _ => ?_
          rw [abs_mul, abs_of_nonneg (hW σ)]
      _ ≤ ∑ σ : ι → α, 1 * ∏ i, lawPath κ μ (tcount w) i (σ i) :=
          Finset.sum_le_sum fun σ _ => mul_le_mul_of_nonneg_right (hf σ) (hW σ)
      _ = 1 := by simp only [one_mul]; exact hsum
  have key := sum_abs_sub_unit_le markovEndpoint (Gpath κ μ f (β := Fin m)) d hG
    (hasDegreeLE_Gpath κ μ hκ hμ d f hd)
  simp only [Gpath_zero, Gpath_unit, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul] at key
  exact key

/-! ## Total variation and the fooling lemma -/

/-- Total-variation distance of two laws on `α`, as an overlap deficit. -/
noncomputable def tvd (q q' : α → ℝ) : ℝ := 1 - ∑ s, min (q s) (q' s)

/-- The common part of a maximal coupling. -/
noncomputable def common (μ μ' : ι → α → ℝ) : ι → α → ℝ :=
  fun i s => min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))

theorem tvd_nonneg (q q' : α → ℝ) (hq : ∑ s, q s = 1) : 0 ≤ tvd q q' := by
  unfold tvd
  have : ∑ s, min (q s) (q' s) ≤ ∑ s, q s := Finset.sum_le_sum fun s _ => min_le_left _ _
  linarith

theorem common_ok (μ μ' : ι → α → ℝ) (hμ0 : ∀ i s, 0 ≤ μ i s) (hμ'0 : ∀ i s, 0 ≤ μ' i s)
    (hμ : ∀ i, ∑ s, μ i s = 1) (m : ℕ) (hm : 0 < m)
    (hγ : ∀ i, (m : ℝ) * tvd (μ i) (μ' i) ≤ 1) (hlt : ∀ i, tvd (μ i) (μ' i) < 1) :
    (∀ i, ∑ s, common μ μ' i s = 1) ∧ (∀ i s, 0 ≤ common μ μ' i s) ∧
      (∀ i s, 0 ≤ common μ μ' i s + m * (μ i s - common μ μ' i s)) ∧
      (∀ i s, 0 ≤ common μ μ' i s + m * (μ' i s - common μ μ' i s)) := by
  have hpos : ∀ i, 0 < 1 - tvd (μ i) (μ' i) := fun i => by linarith [hlt i]
  have hc : ∀ i, 1 - tvd (μ i) (μ' i) = ∑ s, min (μ i s) (μ' i s) := fun i => by
    unfold tvd; ring
  refine ⟨fun i => ?_, fun i s => ?_, fun i s => ?_, fun i s => ?_⟩
  · unfold common
    rw [← Finset.sum_div, ← hc i, div_self (hpos i).ne']
  · exact div_nonneg (le_min (hμ0 i s) (hμ'0 i s)) (hpos i).le
  · -- m μ - (m - 1) κ ≥ 0, since min ≤ μ and m (1 - γ) ≥ m - 1
    unfold common
    have hmin : min (μ i s) (μ' i s) ≤ μ i s := min_le_left _ _
    have h0 : 0 ≤ min (μ i s) (μ' i s) := le_min (hμ0 i s) (hμ'0 i s)
    have hcp := hpos i
    have hmc : (m : ℝ) - 1 ≤ m * (1 - tvd (μ i) (μ' i)) := by have := hγ i; nlinarith
    have hmcp : (0 : ℝ) ≤ m * (1 - tvd (μ i) (μ' i)) := by positivity
    have key : ((m : ℝ) - 1) * min (μ i s) (μ' i s) ≤
        m * (1 - tvd (μ i) (μ' i)) * μ i s :=
      le_trans (mul_le_mul_of_nonneg_right hmc h0) (mul_le_mul_of_nonneg_left hmin hmcp)
    have hk : ((m : ℝ) - 1) * (min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) ≤ m * μ i s := by
      rw [mul_div_assoc', div_le_iff₀ hcp]; nlinarith [key]
    have e : min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i)) +
        m * (μ i s - min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) =
        m * μ i s - ((m : ℝ) - 1) * (min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) := by ring
    rw [e]; linarith
  · unfold common
    have hmin : min (μ i s) (μ' i s) ≤ μ' i s := min_le_right _ _
    have h0 : 0 ≤ min (μ i s) (μ' i s) := le_min (hμ0 i s) (hμ'0 i s)
    have hcp := hpos i
    have hmc : (m : ℝ) - 1 ≤ m * (1 - tvd (μ i) (μ' i)) := by have := hγ i; nlinarith
    have hmcp : (0 : ℝ) ≤ m * (1 - tvd (μ i) (μ' i)) := by positivity
    have key : ((m : ℝ) - 1) * min (μ i s) (μ' i s) ≤
        m * (1 - tvd (μ i) (μ' i)) * μ' i s :=
      le_trans (mul_le_mul_of_nonneg_right hmc h0) (mul_le_mul_of_nonneg_left hmin hmcp)
    have hk : ((m : ℝ) - 1) * (min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) ≤ m * μ' i s := by
      rw [mul_div_assoc', div_le_iff₀ hcp]; nlinarith [key]
    have e : min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i)) +
        m * (μ' i s - min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) =
        m * μ' i s - ((m : ℝ) - 1) * (min (μ i s) (μ' i s) / (1 - tvd (μ i) (μ' i))) := by ring
    rw [e]; linarith

/-- **Fooling lemma.** If every coordinate marginal moves by at most `γ ∈ (0, 1/2]` in total
variation, a degree-`d` function bounded by `1` changes its mean by at most `16 d² γ`. -/
theorem fooling_tv (μ μ' : ι → α → ℝ) (hμ0 : ∀ i s, 0 ≤ μ i s) (hμ'0 : ∀ i s, 0 ≤ μ' i s)
    (hμ : ∀ i, ∑ s, μ i s = 1) (hμ' : ∀ i, ∑ s, μ' i s = 1)
    (γ : ℝ) (hγ0 : 0 < γ) (hγ1 : γ ≤ 1 / 2) (hle : ∀ i, tvd (μ i) (μ' i) ≤ γ)
    (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1) (hd : HasProdDegreeLE f d) :
    |pexp μ f - pexp μ' f| ≤ 16 * (d : ℝ) ^ 2 * γ := by
  set m := ⌊1 / γ⌋₊ with hmdef
  have h1γ : (2 : ℝ) ≤ 1 / γ := by rw [le_div_iff₀ hγ0]; linarith
  have hm1 : 1 ≤ m := Nat.le_floor (by rw [Nat.cast_one]; linarith)
  have hm : 0 < m := hm1
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hmle : (m : ℝ) ≤ 1 / γ := Nat.floor_le (by positivity)
  have hmγ : (m : ℝ) * γ ≤ 1 := by rwa [le_div_iff₀ hγ0] at hmle
  have hmge : 1 / γ < m + 1 := Nat.lt_floor_add_one _
  have hm2 : 1 / (2 * γ) ≤ m := by
    have : 1 / (2 * γ) = (1 / γ) / 2 := by field_simp
    rw [this]; linarith
  have hγi : ∀ i, (m : ℝ) * tvd (μ i) (μ' i) ≤ 1 := fun i =>
    (mul_le_mul_of_nonneg_left (hle i) hmR.le).trans hmγ
  have hlt : ∀ i, tvd (μ i) (μ' i) < 1 := fun i => by linarith [hle i]
  obtain ⟨hκ1, hκ0, hκμ, hκμ'⟩ := common_ok μ μ' hμ0 hμ'0 hμ m hm hγi hlt
  have hA := path_fooling (common μ μ') μ hκ1 hμ hκ0 m hm hκμ d f hf hd
  have hB := path_fooling (common μ μ') μ' hκ1 hμ' hκ0 m hm hκμ' d f hf hd
  have htri : |pexp μ f - pexp μ' f| ≤
      |pexp (common μ μ') f - pexp μ f| + |pexp (common μ μ') f - pexp μ' f| := by
    calc |pexp μ f - pexp μ' f|
        = |(pexp (common μ μ') f - pexp μ' f) - (pexp (common μ μ') f - pexp μ f)| := by ring_nf
      _ ≤ |pexp (common μ μ') f - pexp μ' f| + |pexp (common μ μ') f - pexp μ f| := abs_sub _ _
      _ = _ := add_comm _ _
  have hsum : (m : ℝ) * |pexp μ f - pexp μ' f| ≤ 8 * (d : ℝ) ^ 2 := by
    have := mul_le_mul_of_nonneg_left htri hmR.le
    linarith
  -- |·| ≤ 8 d² / m ≤ 16 d² γ
  have hpos2 : 0 < 2 * γ := by positivity
  have hm2' : 1 ≤ 2 * γ * m := by
    have := mul_le_mul_of_nonneg_left hm2 hpos2.le
    rwa [mul_one_div_cancel hpos2.ne'] at this
  have habs := abs_nonneg (pexp μ f - pexp μ' f)
  nlinarith [mul_le_mul_of_nonneg_left hm2' habs]

/-! ## Means of functions that ignore a coordinate -/

/-- Swap the values `b, b'` at coordinate `i`. -/
def swapAt (i : ι) (b b' : α) (x : ι → α) : ι → α :=
  Function.update x i (Equiv.swap b b' (x i))

theorem swapAt_invol (i : ι) (b b' : α) : Function.Involutive (swapAt i b b') := by
  intro x
  funext k
  by_cases h : k = i
  · subst h; simp [swapAt]
  · simp [swapAt, Function.update_of_ne h]

theorem sum_fiber_eq (H : (ι → α) → ℝ) (i : ι) (hH : Inv H i) (b b' : α) :
    ∑ x, (if x i = b then H x else 0) = ∑ x, (if x i = b' then H x else 0) := by
  rw [← Equiv.sum_comp (swapAt_invol i b b').toPerm (fun x => if x i = b then H x else 0)]
  refine Finset.sum_congr rfl fun x _ => ?_
  simp only [Function.Involutive.coe_toPerm, swapAt, Function.update_self]
  rw [hH x]
  have hiff : Equiv.swap b b' (x i) = b ↔ x i = b' := by
    rw [Equiv.swap_apply_eq_iff, Equiv.swap_apply_left]
  by_cases h : x i = b'
  · rw [if_pos (hiff.mpr h), if_pos h]
  · rw [if_neg (fun h2 => h (hiff.mp h2)), if_neg h]

theorem sum_coord_mul (H : (ι → α) → ℝ) (i : ι) (hH : Inv H i) (c : α → ℝ) (b0 : α) :
    ∑ x, c (x i) * H x = (∑ b, c b) * ∑ x, (if x i = b0 then H x else 0) := by
  have h1 : ∀ x : ι → α, c (x i) * H x = ∑ b, (if x i = b then c b * H x else 0) := by
    intro x
    rw [Finset.sum_ite_eq]
    simp
  rw [Finset.sum_congr rfl fun x _ => h1 x, Finset.sum_comm, Finset.sum_mul]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [← sum_fiber_eq H i hH b b0, Finset.mul_sum]
  refine Finset.sum_congr rfl fun x _ => ?_
  split_ifs with h
  · subst h; ring
  · ring

/-- Changing the law of a coordinate that `g` ignores does not change its mean. -/
theorem pexp_update_inv (p : ι → α → ℝ) (i : ι) (q : α → ℝ) (hp1 : ∑ a, p i a = 1)
    (hq : ∑ a, q a = 1) (g : (ι → α) → ℝ) (hg : Inv g i) :
    pexp (Function.update p i q) g = pexp p g := by
  classical
  set R : (ι → α) → ℝ := fun x => ∏ k ∈ univ.erase i, p k (x k) with hR
  have hRinv : Inv (fun x => R x * g x) i := by
    intro x b
    simp only [hR]
    rw [hg x b]
    congr 1
    refine Finset.prod_congr rfl fun k hk => ?_
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hk)]
  have hp : ∀ x, prodMass p x = p i (x i) * R x := fun x => by
    unfold prodMass; rw [← Finset.mul_prod_erase _ _ (mem_univ i)]
  have hq' : ∀ x, prodMass (Function.update p i q) x = q (x i) * R x := fun x => by
    unfold prodMass
    rw [← Finset.mul_prod_erase _ _ (mem_univ i), Function.update_self]
    congr 1
    refine Finset.prod_congr rfl fun k hk => ?_
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hk)]
  obtain ⟨b0⟩ : Nonempty α := by
    by_contra h
    rw [not_nonempty_iff] at h
    simp at hp1
  have e1 : pexp p g = ∑ x, p i (x i) * (R x * g x) := by
    unfold pexp; exact Finset.sum_congr rfl fun x _ => by rw [hp]; ring
  have e2 : pexp (Function.update p i q) g = ∑ x, q (x i) * (R x * g x) := by
    unfold pexp; exact Finset.sum_congr rfl fun x _ => by rw [hq']; ring
  rw [e1, e2, sum_coord_mul _ i hRinv _ b0, sum_coord_mul _ i hRinv _ b0, hp1, hq]

/-- The point mass at `c`. -/
def delta (c : α) : α → ℝ := fun s => if s = c then 1 else 0

theorem delta_sum (c : α) : ∑ s, delta c s = 1 := by simp [delta]

/-- Fixing a coordinate is the same as giving it a point-mass law. -/
theorem pexp_sect (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (g : (ι → α) → ℝ) (j : ι)
    (c : α) : pexp p (sect g j c) = pexp (Function.update p j (delta c)) g := by
  rw [← pexp_update_inv p j (delta c) (hp1 j) (delta_sum c) _ (inv_sect_self g j c)]
  unfold pexp
  refine Finset.sum_congr rfl fun x _ => ?_
  by_cases hx : x j = c
  · simp only [sect]
    rw [← hx, Function.update_eq_self]
  · have : prodMass (Function.update p j (delta c)) x = 0 := by
      unfold prodMass
      exact Finset.prod_eq_zero (mem_univ j) (by simp [delta, hx])
    rw [this, zero_mul, zero_mul]

/-- Laws with the coordinates of `A` pinned to `ρ`. -/
def pin (A : Finset ι) (ρ : ι → α) (p : ι → α → ℝ) : ι → α → ℝ :=
  fun i => if i ∈ A then delta (ρ i) else p i

/-- `g` is `f` with the coordinates of `A` fixed. -/
def Rep (f : (ι → α) → ℝ) (A : Finset ι) (g : (ι → α) → ℝ) : Prop :=
  ∃ ρ : ι → α, ∀ p : ι → α → ℝ, (∀ i, ∑ a, p i a = 1) → pexp p g = pexp (pin A ρ p) f

theorem rep_empty [Nonempty (ι → α)] (f : (ι → α) → ℝ) : Rep f ∅ f :=
  ⟨Classical.arbitrary _, fun p _ => by congr 1⟩

theorem rep_sect {f g : (ι → α) → ℝ} {A : Finset ι} (h : Rep f A g) (j : ι) (hj : j ∉ A)
    (c : α) : Rep f (insert j A) (sect g j c) := by
  obtain ⟨ρ, hρ⟩ := h
  refine ⟨Function.update ρ j c, fun p hp1 => ?_⟩
  have hp1' : ∀ i, ∑ a, Function.update p j (delta c) i a = 1 := by
    intro i
    by_cases hij : i = j
    · subst hij; simp [delta_sum]
    · rw [Function.update_of_ne hij]; exact hp1 i
  rw [pexp_sect p hp1 g j c, hρ _ hp1']
  congr 1
  funext i
  simp only [pin, Finset.mem_insert]
  by_cases hij : i = j
  · subst hij; simp [hj]
  · by_cases hiA : i ∈ A
    · simp [hiA, hij]
    · simp [hiA, hij]

/-! ## The mixture tree -/

section Tree

variable {Θ : Type} [Fintype Θ]
variable (P : Θ → ι → α → ℝ)

/-- Component weights after observing `x_j = b` (unnormalized posterior). -/
def upd (v : Θ → ℝ) (j : ι) (b : α) : Θ → ℝ := fun θ => v θ * P θ j b

/-- Total weight. -/
def Vs (v : Θ → ℝ) : ℝ := ∑ θ, v θ

/-- Unnormalized expectation under the weighted mixture. -/
noncomputable def Ex (v : Θ → ℝ) (F : (ι → α) → ℝ) : ℝ := ∑ θ, v θ * pexp (P θ) F

noncomputable def mmean (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ := Ex P v g / Vs v

/-- Unnormalized variance under the weighted mixture. -/
noncomputable def mvar (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ :=
  Ex P v (fun x => (g x - mmean P v g) ^ 2)

/-- Posterior-weighted total increment. -/
noncomputable def Phi (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ := ∑ θ, v θ * Ltot (P θ) g

/-- `V · ∑ π_θ²` for the posterior `π = v / V`. -/
noncomputable def Sq (v : Θ → ℝ) : ℝ := (∑ θ, v θ ^ 2) / Vs v

/-- The combined potential. -/
noncomputable def Psi (ga gb : ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ :=
  Phi P v g / ga + (Vs v - Sq v) / gb

/-- Querying `j` lowers the potential by at least the current weight. -/
def Good (ga gb : ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) : Prop :=
  ∑ b, Psi P ga gb (upd P v j b) (sect g j b) + Vs v ≤ Psi P ga gb v g

open Classical in
/-- The simulating tree for the mixture. -/
noncomputable def mbuild (τ ga gb : ℝ) :
    ℕ → Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → DTree ι α
  | 0, _, v, g => .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))
  | n + 1, A, v, g =>
    if h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j then
      .node h.choose
        (fun b => mbuild τ ga gb n (insert h.choose A) (upd P v h.choose b) (sect g h.choose b))
    else .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))

variable (τ ga gb : ℝ)

theorem mbuild_zero (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) :
    mbuild P τ ga gb 0 A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := rfl

theorem mbuild_pos (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j) :
    mbuild P τ ga gb (n + 1) A v g = .node h.choose
      (fun b => mbuild P τ ga gb n (insert h.choose A) (upd P v h.choose b)
        (sect g h.choose b)) := by
  rw [mbuild, dif_pos h]

theorem mbuild_neg (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ¬ ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j) :
    mbuild P τ ga gb (n + 1) A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := by
  rw [mbuild, dif_neg h]

/-- The tree never reads a coordinate of `A`. -/
theorem mbuild_inv (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ),
    ∀ i ∈ A, ∀ x b,
      (mbuild P τ ga gb n A v g).eval (Function.update x i b) = (mbuild P τ ga gb n A v g).eval x ∧
      (mbuild P τ ga gb n A v g).bad (Function.update x i b) = (mbuild P τ ga gb n A v g).bad x ∧
      (mbuild P τ ga gb n A v g).queries (Function.update x i b) =
        (mbuild P τ ga gb n A v g).queries x := by
  induction n with
  | zero => intro A v g i _ x b; simp [mbuild_zero, DTree.eval, DTree.bad, DTree.queries]
  | succ n ih =>
    intro A v g i hi x b
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j
    · rw [mbuild_pos P τ ga gb n A v g h]
      have hj := h.choose_spec
      have hne : i ≠ h.choose := fun hij => hj.1 (hij ▸ hi)
      have hxj : Function.update x i b h.choose = x h.choose := Function.update_of_ne hne.symm _ _
      have := ih (insert h.choose A) (upd P v h.choose (x h.choose))
        (sect g h.choose (x h.choose)) i (Finset.mem_insert_of_mem hi) x b
      simp only [DTree.eval, DTree.bad, DTree.queries, hxj]
      exact ⟨this.1, this.2.1, by rw [this.2.2]⟩
    · rw [mbuild_neg P τ ga gb n A v g h]
      simp [DTree.eval, DTree.bad, DTree.queries]

theorem mqueries_le (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) x,
    (mbuild P τ ga gb n A v g).queries x ≤ n := by
  induction n with
  | zero => intro A v g x; simp [mbuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g x
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j
    · rw [mbuild_pos P τ ga gb n A v g h]
      simp only [DTree.queries]
      exact Nat.succ_le_succ (ih _ _ _ x)
    · rw [mbuild_neg P τ ga gb n A v g h]
      simp [DTree.queries]

variable (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

include hP1 in
theorem Ex_split (v : Θ → ℝ) (j : ι) (H : α → (ι → α) → ℝ)
    (hH : ∀ c x b, H c (Function.update x j b) = H c x) :
    Ex P v (fun x => H (x j) x) = ∑ b, Ex P (upd P v j b) (H b) := by
  unfold Ex upd pexp
  have hs : ∀ θ, ∑ x, prodMass (P θ) x * H (x j) x =
      ∑ c, P θ j c * ∑ x, prodMass (P θ) x * H c x := fun θ =>
    sum_split (P θ) (hP1 θ) j H hH
  simp only [hs, Finset.mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun b _ => Finset.sum_congr rfl fun θ _ => ?_
  exact Finset.sum_congr rfl fun x _ => by ring

omit [DecidableEq ι] [DecidableEq α] in
include hP1 in
theorem Ex_const (v : Θ → ℝ) (c : ℝ) : Ex P v (fun _ => c) = c * Vs v := by
  unfold Ex Vs pexp
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← Finset.sum_mul, sum_prodMass (P θ) (hP1 θ)]
  ring

omit [DecidableEq ι] [DecidableEq α] in
theorem Ex_add (v : Θ → ℝ) (F G : (ι → α) → ℝ) :
    Ex P v (fun x => F x + G x) = Ex P v F + Ex P v G := by
  unfold Ex pexp
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← mul_add, ← Finset.sum_add_distrib]
  congr 1
  exact Finset.sum_congr rfl fun x _ => by ring

omit [DecidableEq ι] in
include hP1 in
theorem Vs_upd_sum (v : Θ → ℝ) (j : ι) : ∑ b, Vs (upd P v j b) = Vs v := by
  unfold Vs upd
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← Finset.mul_sum, hP1 θ j, mul_one]

omit [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] in
theorem Sq_le_Vs (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) : Sq v ≤ Vs v := by
  unfold Sq
  have hV : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
  rcases hV.eq_or_lt with h0 | hpos
  · rw [← h0, div_zero]
  · rw [div_le_iff₀ hpos]
    have : ∀ θ, v θ ^ 2 ≤ v θ * Vs v := fun θ => by
      have hle : v θ ≤ Vs v := Finset.single_le_sum (fun θ _ => hv θ) (mem_univ θ)
      nlinarith [hv θ]
    calc ∑ θ, v θ ^ 2 ≤ ∑ θ, v θ * Vs v := Finset.sum_le_sum fun θ _ => this θ
      _ = Vs v * Vs v := by rw [← Finset.sum_mul]; rfl

include hP0 hP1 in
theorem Psi_nonneg (hga : 0 < ga) (hgb : 0 < gb) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (g : (ι → α) → ℝ) : 0 ≤ Psi P ga gb v g := by
  unfold Psi
  have h1 : 0 ≤ Phi P v g := Finset.sum_nonneg fun θ _ =>
    mul_nonneg (hv θ) (Finset.sum_nonneg fun k _ => pincr_nonneg (P θ) (hP0 θ) g k)
  have h2 : 0 ≤ Vs v - Sq v := sub_nonneg.mpr (Sq_le_Vs v hv)
  positivity

include hP0 hP1 in
/-- **Potential bound** for the mixture tree: `E[queries] ≤ Ψ`. -/
theorem mexpected (hga : 0 < ga) (hgb : 0 < gb) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => ((mbuild P τ ga gb n A v g).queries x : ℝ)) ≤ Psi P ga gb v g := by
  induction n with
  | zero =>
    intro A v g hv
    simp only [mbuild_zero, DTree.queries, Nat.cast_zero]
    rw [Ex_const P hP1, zero_mul]
    exact Psi_nonneg P ga gb hP0 hP1 hga hgb v hv g
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j
    · rw [mbuild_pos P τ ga gb n A v g h]
      set j := h.choose with hjdef
      have hj := h.choose_spec
      rw [← hjdef] at hj
      have hsplit := Ex_split P hP1 v j
        (fun c x => ((mbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℝ))
        (fun c x b => by
          rw [(mbuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b).2.2])
      have hexp : Ex P v (fun x => (((DTree.node j fun c =>
            mbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℕ) : ℝ)) =
          Ex P v (fun x => ((mbuild P τ ga gb n (insert j A) (upd P v j (x j))
            (sect g j (x j))).queries x : ℝ)) + Vs v := by
        simp only [DTree.queries, Nat.cast_add, Nat.cast_one]
        rw [Ex_add, Ex_const P hP1, one_mul]
      rw [hexp, hsplit]
      have hc : ∀ b, Ex P (upd P v j b)
          (fun x => ((mbuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).queries x : ℝ))
          ≤ Psi P ga gb (upd P v j b) (sect g j b) :=
        fun b => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
      have := Finset.sum_le_sum fun b (_ : b ∈ univ) => hc b
      have hg := hj.2.2
      unfold Good at hg
      linarith
    · rw [mbuild_neg P τ ga gb n A v g h]
      simp only [DTree.queries, Nat.cast_zero]
      rw [Ex_const P hP1, zero_mul]
      exact Psi_nonneg P ga gb hP0 hP1 hga hgb v hv g

include hP0 hP1 in
/-- **Leaf error** for the mixture tree. -/
theorem mleaf_error (hτ : 0 ≤ τ) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => if (mbuild P τ ga gb n A v g).bad x then 0
        else (g x - (mbuild P τ ga gb n A v g).eval x) ^ 2) ≤ τ * Vs v := by
  have hleaf : ∀ (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => if (DTree.leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) :
        DTree ι α).bad x then 0 else (g x - (DTree.leaf (mmean P v g)
          (decide (τ * Vs v < mvar P v g)) : DTree ι α).eval x) ^ 2) ≤ τ * Vs v := by
    intro v g hv
    have hV : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
    simp only [DTree.bad, DTree.eval]
    by_cases hlt : τ * Vs v < mvar P v g
    · simp only [hlt, decide_true, ite_true]
      rw [Ex_const P hP1, zero_mul]
      positivity
    · simp only [hlt, decide_false, Bool.false_eq_true, ite_false]
      push_neg at hlt
      exact hlt
  induction n with
  | zero => intro A v g hv; rw [mbuild_zero]; exact hleaf v g hv
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j
    · rw [mbuild_pos P τ ga gb n A v g h]
      set j := h.choose
      have hsplit := Ex_split P hP1 v j
        (fun c x => if (mbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).bad x then 0
          else (sect g j c x - (mbuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).eval x) ^ 2)
        (fun c x b => by
          have hi := mbuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b
          simp only [hi.1, hi.2.1, inv_sect_self g j c x b])
      have hlhs : (fun x => if (DTree.node j fun c => mbuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).bad x then (0 : ℝ)
          else (g x - (DTree.node j fun c => mbuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).eval x) ^ 2) =
          (fun x => (fun c x => if (mbuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).bad x then 0 else (sect g j c x - (mbuild P τ ga gb n (insert j A)
              (upd P v j c) (sect g j c)).eval x) ^ 2) (x j) x) := by
        funext x
        simp only [DTree.bad, DTree.eval]
        congr 2
        rw [sect_self g j x]
      rw [hlhs, hsplit]
      calc ∑ b, Ex P (upd P v j b) (fun x => if (mbuild P τ ga gb n (insert j A)
              (upd P v j b) (sect g j b)).bad x then 0 else (sect g j b x -
                (mbuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).eval x) ^ 2)
          ≤ ∑ b, τ * Vs (upd P v j b) :=
            Finset.sum_le_sum fun b _ => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
        _ = τ * Vs v := by rw [← Finset.mul_sum, Vs_upd_sum P hP1]
    · rw [mbuild_neg P τ ga gb n A v g h]
      exact hleaf v g hv

/-- Unfinished leaves need the full fuel, given that any state in the invariant `S` with large
variance has a good query outside `A`. -/
theorem mbad_queries (S : Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → Prop)
    (hpres : ∀ A v g j b, S A v g → j ∉ A → S (insert j A) (upd P v j b) (sect g j b))
    (hgood : ∀ A v g, S A v g → τ * Vs v < mvar P v g → ∃ j, j ∉ A ∧ Good P ga gb v g j)
    (n : ℕ) : ∀ A v g, S A v g → ∀ x,
      (mbuild P τ ga gb n A v g).bad x = true → (mbuild P τ ga gb n A v g).queries x = n := by
  induction n with
  | zero => intro A v g _ x _; simp [mbuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g hS x hb
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ Good P ga gb v g j
    · rw [mbuild_pos P τ ga gb n A v g h] at hb ⊢
      simp only [DTree.bad] at hb
      simp only [DTree.queries]
      rw [ih _ _ _ (hpres A v g _ _ hS h.choose_spec.1) x hb]
    · exfalso
      rw [mbuild_neg P τ ga gb n A v g h] at hb
      simp only [DTree.bad, decide_eq_true_eq] at hb
      obtain ⟨j, hjA, hj⟩ := hgood A v g hS hb
      exact h ⟨j, hjA, hb, hj⟩

end Tree

end Nightfall.ProductSpace.Mixture
