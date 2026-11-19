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

include hP1 in
theorem Ex_const (v : Θ → ℝ) (c : ℝ) : Ex P v (fun _ => c) = c * Vs v := by
  unfold Ex Vs pexp
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← Finset.sum_mul, sum_prodMass (P θ) (hP1 θ)]
  ring

theorem Ex_add (v : Θ → ℝ) (F G : (ι → α) → ℝ) :
    Ex P v (fun x => F x + G x) = Ex P v F + Ex P v G := by
  unfold Ex pexp
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← mul_add, ← Finset.sum_add_distrib]
  congr 1
  exact Finset.sum_congr rfl fun x _ => by ring

include hP1 in
theorem Vs_upd_sum (v : Θ → ℝ) (j : ι) : ∑ b, Vs (upd P v j b) = Vs v := by
  unfold Vs upd
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← Finset.mul_sum, hP1 θ j, mul_one]

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

/-! ## Posterior impurity -/

section Gini

/-- `∑ u²/c - (∑u)²/V ≥ (∑ |u - r c|)² / V` with `r = ∑u / V`, for `0 ≤ u ≤ c`, `∑ c = V > 0`. -/
theorem chi_sq_bound {β : Type} [Fintype β] (u c : β → ℝ) (hu : ∀ b, 0 ≤ u b)
    (huc : ∀ b, u b ≤ c b) (V : ℝ) (hV : 0 < V) (hcV : ∑ b, c b = V) :
    (∑ b, |u b - (∑ b', u b') / V * c b|) ^ 2 / V ≤
      ∑ b, u b ^ 2 / c b - (∑ b, u b) ^ 2 / V := by
  set r := (∑ b', u b') / V with hr
  have hc0 : ∀ b, 0 ≤ c b := fun b => (hu b).trans (huc b)
  have hterm : ∀ b, (u b - r * c b) ^ 2 / c b = u b ^ 2 / c b - 2 * r * u b + r ^ 2 * c b := by
    intro b
    rcases (hc0 b).eq_or_lt with h0 | hpos
    · have hu0 : u b = 0 := le_antisymm (by rw [h0]; exact huc b) (hu b)
      rw [← h0, hu0]; simp
    · field_simp; ring
  have hid : ∑ b, (u b - r * c b) ^ 2 / c b = ∑ b, u b ^ 2 / c b - (∑ b, u b) ^ 2 / V := by
    rw [Finset.sum_congr rfl fun b _ => hterm b, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, hcV, hr]
    field_simp; ring
  rw [← hid, div_le_iff₀ hV]
  -- Cauchy–Schwarz with f = |u - r c| / √c and g = √c
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq univ (fun b => |u b - r * c b| / Real.sqrt (c b))
    (fun b => Real.sqrt (c b))
  have h1 : ∀ b, |u b - r * c b| / Real.sqrt (c b) * Real.sqrt (c b) = |u b - r * c b| := by
    intro b
    rcases (hc0 b).eq_or_lt with h0 | hpos
    · have hu0 : u b = 0 := le_antisymm (by rw [h0]; exact huc b) (hu b)
      rw [← h0, hu0]; simp
    · rw [div_mul_cancel₀ _ (Real.sqrt_pos.mpr hpos).ne']
  have h2 : ∀ b, (|u b - r * c b| / Real.sqrt (c b)) ^ 2 = (u b - r * c b) ^ 2 / c b := by
    intro b
    rw [div_pow, sq_abs, Real.sq_sqrt (hc0 b)]
  have h3 : ∀ b, Real.sqrt (c b) ^ 2 = c b := fun b => Real.sq_sqrt (hc0 b)
  simp only [h1, h2, h3, hcV] at hcs
  exact hcs

variable {Θ : Type} [Fintype Θ] (P : Θ → ι → α → ℝ)

/-- Impurity drop: for every component `θ`,
`∑_b Sq(v_b) - Sq(v) ≥ (v_θ² / V) (∑_b |P θ j b - V_b / V|)²`, and the drop is nonnegative. -/
theorem Sq_gain (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v) (j : ι) (θ0 : Θ) :
    v θ0 ^ 2 / Vs v * (∑ b, |P θ0 j b - Vs (upd P v j b) / Vs v|) ^ 2 ≤
      ∑ b, Sq (upd P v j b) - Sq v := by
  have hsplit : ∑ b, Sq (upd P v j b) - Sq v =
      ∑ θ, (∑ b, (v θ * P θ j b) ^ 2 / Vs (upd P v j b) - (∑ b, v θ * P θ j b) ^ 2 / Vs v) := by
    unfold Sq
    have hsum : ∀ θ, ∑ b, v θ * P θ j b = v θ := fun θ => by rw [← Finset.mul_sum, hP1, mul_one]
    simp only [hsum]
    rw [Finset.sum_sub_distrib, ← Finset.sum_div]
    congr 1
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun b _ => ?_
    unfold upd
    rw [Finset.sum_div]
  have hterm : ∀ θ, (∑ b, |v θ * P θ j b - (∑ b', v θ * P θ j b') / Vs v * Vs (upd P v j b)|) ^ 2
      / Vs v ≤ ∑ b, (v θ * P θ j b) ^ 2 / Vs (upd P v j b) - (∑ b, v θ * P θ j b) ^ 2 / Vs v := by
    intro θ
    refine chi_sq_bound (fun b => v θ * P θ j b) (fun b => Vs (upd P v j b))
      (fun b => mul_nonneg (hv θ) (hP0 θ j b)) (fun b => ?_) (Vs v) hV (Vs_upd_sum P hP1 v j)
    unfold Vs upd
    exact Finset.single_le_sum (f := fun θ' => v θ' * P θ' j b)
      (fun θ' _ => mul_nonneg (hv θ') (hP0 θ' j b)) (mem_univ θ)
  rw [hsplit]
  have hθ0 := hterm θ0
  have hrest : ∀ θ ∈ univ, 0 ≤ ∑ b, (v θ * P θ j b) ^ 2 / Vs (upd P v j b) -
      (∑ b, v θ * P θ j b) ^ 2 / Vs v := fun θ _ => le_trans (by positivity) (hterm θ)
  have hsingle := Finset.single_le_sum hrest (mem_univ θ0)
  refine le_trans (le_of_eq ?_) (hθ0.trans hsingle)
  have hs0 : ∑ b', v θ0 * P θ0 j b' = v θ0 := by rw [← Finset.mul_sum, hP1, mul_one]
  rw [hs0]
  have : ∀ b, |v θ0 * P θ0 j b - v θ0 / Vs v * Vs (upd P v j b)| =
      v θ0 * |P θ0 j b - Vs (upd P v j b) / Vs v| := by
    intro b
    rw [show v θ0 * P θ0 j b - v θ0 / Vs v * Vs (upd P v j b) =
      v θ0 * (P θ0 j b - Vs (upd P v j b) / Vs v) by ring, abs_mul, abs_of_nonneg (hv θ0)]
  simp only [this, ← Finset.mul_sum]
  ring

theorem Sq_mono (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (j : ι) : Sq v ≤ ∑ b, Sq (upd P v j b) := by
  have hV : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
  rcases hV.eq_or_lt with h0 | hpos
  · have : Sq v = 0 := by unfold Sq; rw [← h0, div_zero]
    rw [this]
    exact Finset.sum_nonneg fun b _ => div_nonneg (Finset.sum_nonneg fun θ _ => sq_nonneg _)
      (Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (hP0 θ j b))
  · rcases isEmpty_or_nonempty Θ with hΘ | ⟨⟨θ0⟩⟩
    · unfold Vs at hpos; simp at hpos
    · have := Sq_gain P hP0 hP1 v hv hpos j θ0
      have h0 : 0 ≤ v θ0 ^ 2 / Vs v * (∑ b, |P θ0 j b - Vs (upd P v j b) / Vs v|) ^ 2 := by
        positivity
      linarith

end Gini

/-! ## Analysis: a good query exists while the variance is large -/

section Analysis

theorem pexp_bounds (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (hg : ∀ x, 0 ≤ g x ∧ g x ≤ 1) : 0 ≤ pexp p g ∧ pexp p g ≤ 1 := by
  unfold pexp
  constructor
  · exact Finset.sum_nonneg fun x _ => mul_nonneg (prodMass_nonneg' p hp x) (hg x).1
  · calc ∑ x, prodMass p x * g x ≤ ∑ x, prodMass p x * 1 :=
          Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left (hg x).2 (prodMass_nonneg' p hp x)
      _ = 1 := by simp only [mul_one]; exact sum_prodMass p hp1

theorem pvar_le_quarter (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (hg : ∀ x, 0 ≤ g x ∧ g x ≤ 1) : pvar p g ≤ 1 / 4 := by
  refine (pvar_le_shift p hp1 g (1 / 2)).trans ?_
  calc ∑ x, prodMass p x * (g x - 1 / 2) ^ 2 ≤ ∑ x, prodMass p x * (1 / 4) := by
        refine Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left ?_ (prodMass_nonneg' p hp x)
        nlinarith [(hg x).1, (hg x).2]
    _ = 1 / 4 := by rw [← Finset.sum_mul, sum_prodMass p hp1, one_mul]

theorem pexp_affine (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (g : (ι → α) → ℝ) :
    pexp p (fun x => 2 * g x - 1) = 2 * pexp p g - 1 := by
  unfold pexp
  have : ∀ x, prodMass p x * (2 * g x - 1) = 2 * (prodMass p x * g x) - prodMass p x :=
    fun x => by ring
  rw [Finset.sum_congr rfl fun x _ => this x, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_prodMass p hp1]

theorem l1_eq_two_tvd (q q' : α → ℝ) (hq : ∑ s, q s = 1) (hq' : ∑ s, q' s = 1) :
    ∑ s, |q s - q' s| = 2 * tvd q q' := by
  unfold tvd
  have hmin : ∀ s, min (q s) (q' s) = (q s + q' s - |q s - q' s|) / 2 := by
    intro s
    rcases le_total (q s) (q' s) with h | h
    · rw [min_eq_left h, abs_of_nonpos (by linarith)]; ring
    · rw [min_eq_right h, abs_of_nonneg (by linarith)]; ring
  simp only [hmin, ← Finset.sum_div, Finset.sum_sub_distrib, Finset.sum_add_distrib, hq, hq']
  ring

theorem tvd_self (q : α → ℝ) (hq : ∑ s, q s = 1) : tvd q q = 0 := by
  simp [tvd, hq]

theorem pin_nonneg (A : Finset ι) (ρ : ι → α) (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) :
    ∀ i a, 0 ≤ pin A ρ p i a := by
  intro i a
  by_cases h : i ∈ A
  · simp only [pin, h, if_true, delta]; split_ifs <;> norm_num
  · simp only [pin, h, if_false]; exact hp i a

theorem pin_sum (A : Finset ι) (ρ : ι → α) (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) :
    ∀ i, ∑ a, pin A ρ p i a = 1 := by
  intro i
  unfold pin
  split_ifs
  · exact delta_sum _
  · exact hp1 i

variable {Θ : Type} [Fintype Θ] (P : Θ → ι → α → ℝ)
variable (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

include hP1 in
theorem mvar_decomp (v : Θ → ℝ) (g : (ι → α) → ℝ) :
    mvar P v g = ∑ θ, v θ * pvar (P θ) g + ∑ θ, v θ * (pexp (P θ) g - mmean P v g) ^ 2 := by
  unfold mvar Ex
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [← mul_add]
  congr 1
  exact sum_sq_shift (P θ) (hP1 θ) g (mmean P v g)

theorem pair_identity (v m : Θ → ℝ) (hV : 0 < Vs v) :
    ∑ θ, ∑ θ', v θ * v θ' * (m θ - m θ') ^ 2 =
      2 * Vs v * ∑ θ, v θ * (m θ - (∑ θ', v θ' * m θ') / Vs v) ^ 2 := by
  set a := ∑ θ', v θ' * m θ'
  set b := ∑ θ, v θ * m θ ^ 2
  have hL : ∑ θ, ∑ θ', v θ * v θ' * (m θ - m θ') ^ 2 = 2 * Vs v * b - 2 * a ^ 2 := by
    have e : ∀ θ θ', v θ * v θ' * (m θ - m θ') ^ 2 =
        (v θ * m θ ^ 2) * v θ' - 2 * ((v θ * m θ) * (v θ' * m θ')) + v θ * (v θ' * m θ' ^ 2) :=
      fun θ θ' => by ring
    simp only [e, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      ← Finset.sum_mul]
    unfold Vs
    ring
  have hR : ∑ θ, v θ * (m θ - a / Vs v) ^ 2 = b - a ^ 2 / Vs v := by
    have e : ∀ θ, v θ * (m θ - a / Vs v) ^ 2 =
        v θ * m θ ^ 2 - 2 * (a / Vs v) * (v θ * m θ) + (a / Vs v) ^ 2 * v θ := fun θ => by ring
    simp only [e, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
    have hVs : ∑ θ, v θ = Vs v := rfl
    rw [hVs]
    field_simp
    ring
  rw [hL, hR]
  field_simp

include hP1 in
theorem Phi_sum (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) :
    ∑ b, Phi P (upd P v j b) (sect g j b) = Phi P v g - ∑ θ, v θ * pincr (P θ) g j := by
  unfold Phi upd
  rw [Finset.sum_comm, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  have h := sum_mul_Ltot_sect (P θ) (hP1 θ) g j
  calc ∑ b, v θ * P θ j b * Ltot (P θ) (sect g j b)
      = v θ * ∑ b, P θ j b * Ltot (P θ) (sect g j b) := by
        rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun b _ => by ring
    _ = v θ * Ltot (P θ) g - v θ * pincr (P θ) g j := by rw [h]; ring

/-- The state invariant along the tree. -/
def St (f : (ι → α) → ℝ) (K : ℝ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) : Prop :=
  (∀ θ, 0 ≤ v θ) ∧ (∀ i ∈ A, Inv g i) ∧ HasRows g K ∧ Rep f A g ∧ (∀ x, 0 ≤ g x ∧ g x ≤ 1)

include hP0 in
theorem St_pres (f : (ι → α) → ℝ) (K : ℝ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (j : ι) (b : α) (h : St f K A v g) (hj : j ∉ A) :
    St f K (insert j A) (upd P v j b) (sect g j b) := by
  obtain ⟨hv, hinv, hrows, hrep, hg⟩ := h
  refine ⟨fun θ => mul_nonneg (hv θ) (hP0 θ j b), fun i hi => ?_, hasRows_sect hrows j b,
    rep_sect hrep j hj b, fun x => hg _⟩
  rcases Finset.mem_insert.mp hi with rfl | hiA
  · exact inv_sect_self g i b
  · exact inv_sect (hinv i hiA) j (fun h' => hj (h' ▸ hiA)) b

include hP0 hP1 in
/-- Splitting the potential of the children. -/
theorem Psi_children (ga gb : ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) :
    ∑ b, Psi P ga gb (upd P v j b) (sect g j b) =
      (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga + (Vs v - ∑ b, Sq (upd P v j b)) / gb := by
  unfold Psi
  rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.sum_div, Finset.sum_sub_distrib,
    Phi_sum P hP1 v g j, Vs_upd_sum P hP1 v j]

include hP0 hP1 in
/-- **Increment step.** A heavy component with variance above `τ/4` yields a good query. -/
theorem increment_good (K τ η M gb : ℝ) (hK : 0 < K) (hτ : 0 < τ) (hη : 0 < η) (hM : 0 < M)
    (hgb : 0 < gb) (hητ : 144 * K ^ 4 * η ^ 2 ≤ (τ / 4) ^ 3)
    (A : Finset ι) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ)
    (hinv : ∀ i ∈ A, Inv g i) (hrows : HasRows g K)
    (θs : Θ) (hθvar : τ / 4 < pvar (P θs) g) (hθw : τ * Vs v / M < v θs) :
    ∃ j, j ∉ A ∧ Good P (τ * η / M) gb v g j := by
  obtain ⟨a, hr, hKa⟩ := hrows
  obtain ⟨j, hj⟩ := mean_increment (P θs) (hP0 θs) (hP1 θs) g a hr K hKa
    (lt_trans (by positivity) hθvar)
  have hpj : η ≤ pincr (P θs) g j := by
    by_contra hlt
    push_neg at hlt
    have h0 := pincr_nonneg (P θs) (hP0 θs) g j
    have h1 : pincr (P θs) g j ^ 2 < η ^ 2 := pow_lt_pow_left₀ hlt h0 two_ne_zero
    have h2 : (τ / 4) ^ 3 < pvar (P θs) g ^ 3 :=
      pow_lt_pow_left₀ hθvar (by positivity) (by norm_num)
    have hK4 : 0 < 144 * K ^ 4 := by positivity
    have h3 := mul_lt_mul_of_pos_left h1 hK4
    linarith
  have hjA : j ∉ A := by
    intro hjA
    have := pincr_eq_zero_of_inv (P θs) (hinv j hjA)
    linarith
  refine ⟨j, hjA, ?_⟩
  unfold Good
  rw [Psi_children P hP0 hP1]
  have hga : 0 < τ * η / M := by positivity
  have hDj : v θs * η ≤ ∑ θ, v θ * pincr (P θ) g j := by
    have h1 : v θs * η ≤ v θs * pincr (P θs) g j := mul_le_mul_of_nonneg_left hpj (hv θs)
    have h2 := Finset.single_le_sum (fun θ (_ : θ ∈ univ) =>
      mul_nonneg (hv θ) (pincr_nonneg (P θ) (hP0 θ) g j)) (mem_univ θs)
    linarith
  have hstep : Vs v ≤ (∑ θ, v θ * pincr (P θ) g j) / (τ * η / M) := by
    rw [le_div_iff₀ hga]
    have : Vs v * (τ * η / M) = (τ * Vs v / M) * η := by ring
    rw [this]
    nlinarith [mul_le_mul_of_nonneg_right hθw.le hη.le]
  have hgini : (Vs v - ∑ b, Sq (upd P v j b)) / gb ≤ (Vs v - Sq v) / gb :=
    div_le_div_of_nonneg_right (by linarith [Sq_mono P hP0 hP1 v hv j]) hgb.le
  unfold Psi
  rw [sub_div]
  linarith

include hP0 hP1 in
/-- **Separation step.** A coordinate outside `A` where a heavy component's marginal is far from
the posterior marginal yields a good query. -/
theorem separation_good (ga gb γ c : ℝ) (hga : 0 < ga) (hγ : 0 < γ) (hc : 0 < c)
    (hgb : gb = c ^ 2 * γ ^ 2) (A : Finset ι) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (hV : 0 < Vs v) (g : (ι → α) → ℝ) (j : ι) (hjA : j ∉ A) (θ1 : Θ) (hw : c * Vs v ≤ v θ1)
    (hsep : γ < ∑ b, |P θ1 j b - Vs (upd P v j b) / Vs v|) :
    ∃ j, j ∉ A ∧ Good P ga gb v g j := by
  refine ⟨j, hjA, ?_⟩
  unfold Good
  rw [Psi_children P hP0 hP1]
  have hgain := Sq_gain P hP0 hP1 v hv hV j θ1
  have hgbpos : 0 < gb := by rw [hgb]; positivity
  have hl : gb * Vs v ≤ v θ1 ^ 2 / Vs v * (∑ b, |P θ1 j b - Vs (upd P v j b) / Vs v|) ^ 2 := by
    rw [hgb]
    have h1 : (c * Vs v) ^ 2 ≤ v θ1 ^ 2 := pow_le_pow_left₀ (by positivity) hw 2
    have h2 : γ ^ 2 ≤ (∑ b, |P θ1 j b - Vs (upd P v j b) / Vs v|) ^ 2 :=
      pow_le_pow_left₀ hγ.le hsep.le 2
    have h3 : c ^ 2 * Vs v ≤ v θ1 ^ 2 / Vs v := by
      rw [le_div_iff₀ hV]; nlinarith
    calc c ^ 2 * γ ^ 2 * Vs v = (c ^ 2 * Vs v) * γ ^ 2 := by ring
      _ ≤ v θ1 ^ 2 / Vs v * (∑ b, |P θ1 j b - Vs (upd P v j b) / Vs v|) ^ 2 :=
        mul_le_mul h3 h2 (sq_nonneg _) (by positivity)
  have hD0 : 0 ≤ ∑ θ, v θ * pincr (P θ) g j :=
    Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (pincr_nonneg (P θ) (hP0 θ) g j)
  have hphi : (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga ≤ Phi P v g / ga :=
    div_le_div_of_nonneg_right (by linarith) hga.le
  have hgini : (Vs v - ∑ b, Sq (upd P v j b)) / gb + Vs v ≤ (Vs v - Sq v) / gb := by
    rw [div_add' _ _ _ hgbpos.ne', div_le_div_iff_of_pos_right hgbpos]
    linarith
  unfold Psi
  linarith

/-- Heavy high-variance component when the within-component variance is large. -/
theorem exists_heavy_var (v q : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hq0 : ∀ θ, 0 ≤ q θ)
    (hq : ∀ θ, q θ ≤ 1 / 4) (τ : ℝ) (hτ : 0 < τ) (hM : 0 < Fintype.card Θ)
    (hW : τ * Vs v / 2 < ∑ θ, v θ * q θ) :
    ∃ θ, τ / 4 < q θ ∧ τ * Vs v / (Fintype.card Θ : ℝ) < v θ := by
  set M : ℝ := (Fintype.card Θ : ℝ)
  have hMpos : (0 : ℝ) < M := Nat.cast_pos.mpr hM
  by_contra hcon
  push_neg at hcon
  have hterm : ∀ θ, v θ * q θ ≤ τ * Vs v / (4 * M) + v θ * (τ / 4) := by
    intro θ
    by_cases hc : τ / 4 < q θ
    · have hvle := hcon θ hc
      have : v θ * q θ ≤ τ * Vs v / M * (1 / 4) :=
        mul_le_mul hvle (hq θ) (hq0 θ) (le_trans (hv θ) hvle)
      have h2 : 0 ≤ v θ * (τ / 4) := mul_nonneg (hv θ) (by positivity)
      have h3 : τ * Vs v / M * (1 / 4) = τ * Vs v / (4 * M) := by field_simp
      linarith
    · push_neg at hc
      have : v θ * q θ ≤ v θ * (τ / 4) := mul_le_mul_of_nonneg_left hc (hv θ)
      have hV0 : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
      have h2 : 0 ≤ τ * Vs v / (4 * M) := by positivity
      linarith
  have hsum := Finset.sum_le_sum fun θ (_ : θ ∈ univ) => hterm θ
  rw [Finset.sum_add_distrib, ← Finset.sum_mul] at hsum
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hsum
  have h1 : (Fintype.card Θ : ℝ) * (τ * Vs v / (4 * M)) = τ * Vs v / 4 := by
    simp only [M]; field_simp
  have h2 : ∑ θ, v θ = Vs v := rfl
  rw [h1, h2] at hsum
  linarith

/-- A heavy pair of components with separated means when the between-component variance is
large. -/
theorem exists_pair (v m : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hm : ∀ θ, 0 ≤ m θ ∧ m θ ≤ 1)
    (τ : ℝ) (hτ : 0 < τ) (hM : 0 < Fintype.card Θ)
    (hbig : τ * Vs v ^ 2 < ∑ θ, ∑ θ', v θ * v θ' * (m θ - m θ') ^ 2) :
    ∃ θ1 θ2, τ * Vs v ^ 2 / (2 * (Fintype.card Θ : ℝ) ^ 2) ≤ v θ1 * v θ2 ∧
      τ / 2 < (m θ1 - m θ2) ^ 2 := by
  set M : ℝ := (Fintype.card Θ : ℝ)
  have hMpos : (0 : ℝ) < M := Nat.cast_pos.mpr hM
  by_contra hcon
  push_neg at hcon
  have hterm : ∀ θ θ', v θ * v θ' * (m θ - m θ') ^ 2 ≤
      τ * Vs v ^ 2 / (2 * M ^ 2) + v θ * v θ' * (τ / 2) := by
    intro θ θ'
    have hvv : 0 ≤ v θ * v θ' := mul_nonneg (hv θ) (hv θ')
    have hsq : (m θ - m θ') ^ 2 ≤ 1 := by
      nlinarith [(hm θ).1, (hm θ).2, (hm θ').1, (hm θ').2]
    by_cases hc : τ * Vs v ^ 2 / (2 * M ^ 2) ≤ v θ * v θ'
    · have := mul_le_mul_of_nonneg_left (hcon θ θ' hc) hvv
      have h2 : 0 ≤ τ * Vs v ^ 2 / (2 * M ^ 2) := by positivity
      linarith
    · push_neg at hc
      have := mul_le_mul_of_nonneg_left hsq hvv
      have h2 : 0 ≤ v θ * v θ' * (τ / 2) := by positivity
      linarith
  have hsum := Finset.sum_le_sum fun θ (_ : θ ∈ univ) =>
    Finset.sum_le_sum fun θ' (_ : θ' ∈ univ) => hterm θ θ'
  have hdouble : ∑ θ, ∑ θ', (τ * Vs v ^ 2 / (2 * M ^ 2) + v θ * v θ' * (τ / 2)) =
      τ * Vs v ^ 2 := by
    simp only [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
      ← Finset.sum_mul, ← Finset.mul_sum]
    have h2 : ∑ θ, v θ = Vs v := rfl
    rw [h2]
    field_simp
    ring
  linarith

include hP0 hP1 in
/-- Separated means give a coordinate outside `A` with separated marginals (fooling lemma). -/
theorem exists_sep_coord (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ)
    (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d) (A : Finset ι) (g : (ι → α) → ℝ)
    (hrep : Rep f A g) (θ1 θ2 : Θ) (s : ℝ) (hs : 0 < s) (hs1 : s ≤ 1 / 2)
    (hdiff : s < |pexp (P θ1) g - pexp (P θ2) g|) :
    ∃ i, i ∉ A ∧ s / (8 * (d : ℝ) ^ 2) < tvd (P θ1 i) (P θ2 i) := by
  obtain ⟨ρ, hρ⟩ := hrep
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set γ := s / (8 * (d : ℝ) ^ 2) with hγdef
  have hγ0 : 0 < γ := by positivity
  have hγ1 : γ ≤ 1 / 2 := by
    rw [hγdef, div_le_iff₀ (by positivity)]
    have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hd
    have : (1 : ℝ) ≤ (d : ℝ) ^ 2 := by nlinarith
    linarith
  obtain ⟨i, hi⟩ : ∃ i, γ < tvd (pin A ρ (P θ1) i) (pin A ρ (P θ2) i) := by
    by_contra hcon
    push_neg at hcon
    have hf1 : ∀ x, |2 * f x - 1| ≤ 1 := fun x =>
      abs_le.mpr ⟨by linarith [(hf01 x).1], by linarith [(hf01 x).2]⟩
    have hfo := fooling_tv (pin A ρ (P θ1)) (pin A ρ (P θ2)) (pin_nonneg A ρ _ (hP0 θ1))
      (pin_nonneg A ρ _ (hP0 θ2)) (pin_sum A ρ _ (hP1 θ1)) (pin_sum A ρ _ (hP1 θ2)) γ hγ0 hγ1
      hcon d (fun x => 2 * f x - 1) hf1 (hasProdDegreeLE_two_mul_sub_one f d hdeg)
    rw [pexp_affine _ (pin_sum A ρ _ (hP1 θ1)), pexp_affine _ (pin_sum A ρ _ (hP1 θ2)),
      ← hρ (P θ1) (hP1 θ1), ← hρ (P θ2) (hP1 θ2)] at hfo
    have e : 2 * pexp (P θ1) g - 1 - (2 * pexp (P θ2) g - 1) =
        2 * (pexp (P θ1) g - pexp (P θ2) g) := by ring
    rw [e, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 2)] at hfo
    have : 16 * (d : ℝ) ^ 2 * γ = 2 * s := by rw [hγdef]; field_simp; ring
    linarith
  have hiA : i ∉ A := by
    intro hiA
    simp only [pin, hiA, if_true] at hi
    rw [tvd_self _ (delta_sum _)] at hi
    linarith
  refine ⟨i, hiA, ?_⟩
  simpa [pin, hiA] using hi

end Analysis


end Nightfall.ProductSpace.Mixture
