import ProductInfluence
import EfronSteinDegree

/-!
# NIGHTFALL: the influence theorem with coordinate-dependent alphabets and zero-mass atoms

Coordinate `i` takes values in its own finite type `β i` with law `q i` (`q i b ≥ 0`,
`∑_b q i b = 1`; zero-mass atoms allowed). The function `F : (∀ i, β i) → ℝ` only needs
`|F| ≤ 1` on the support `{y : ∀ i, q i (y i) > 0}`: removing zero-mass atoms is exactly passing
to the coordinatewise supports, which are again coordinate-dependent alphabets.

Reduction to `Influence.product_influence`: embed all alphabets into the common alphabet
`Σ k, β k`, carry `q i` to `liftMass q i` (zero off the fibre over `i`), and pull `F` back along
the coordinatewise projection `proj q s0 i : (Σ k, β k) → β i`, which sends the positive-mass part
of the fibre over `i` identically to itself and everything else to a fixed support point `s0 i`.
The pull-back is bounded everywhere, has the same indicator-monomial degree (via
`EfronStein.junta_expand`), and has the same variance and Efron–Stein influences (`push_sum`,
`push_coord`).

Main theorem `heterogeneous_influence`: if `F` has degree at most `d` (indicator monomials over the
dependent alphabets), `|F| ≤ 1` on the support and `Var F > 0`, then some coordinate has
`3 Var(F)⁵ ≤ 12500 (π² d²)⁶ Inf_j(F)²`.
-/

namespace Nightfall.ProductSpace.Heterogeneous

open Finset
open Nightfall.ProductSpace.Transfer Nightfall.ProductSpace.Influence

variable {ι : Type} [Fintype ι] [DecidableEq ι] {β : ι → Type} [∀ i, Fintype (β i)]
  [∀ i, DecidableEq (β i)]

/-! ## Dependent product notions -/

noncomputable def dMass (q : ∀ i, β i → ℝ) (y : ∀ i, β i) : ℝ := ∏ i, q i (y i)

noncomputable def dexp (q : ∀ i, β i → ℝ) (F : (∀ i, β i) → ℝ) : ℝ := ∑ y, dMass q y * F y

noncomputable def dvar (q : ∀ i, β i → ℝ) (F : (∀ i, β i) → ℝ) : ℝ :=
  ∑ y, dMass q y * (F y - dexp q F) ^ 2

/-- Efron–Stein influence with coordinate-dependent alphabets. -/
noncomputable def dinfl (q : ∀ i, β i → ℝ) (F : (∀ i, β i) → ℝ) (j : ι) : ℝ :=
  ∑ y, ∑ b : β j, dMass q y * q j b * ((F y - F (Function.update y j b)) ^ 2 / 2)

noncomputable def dIndMono (T : Finset ι) (τ y : ∀ i, β i) : ℝ :=
  ∏ i ∈ T, if y i = τ i then (1 : ℝ) else 0

/-- Indicator-monomial degree at most `d` over coordinate-dependent alphabets. -/
def DepDegreeLE (F : (∀ i, β i) → ℝ) (d : ℕ) : Prop :=
  ∃ c : Finset ι → (∀ i, β i) → ℝ, (∀ T, d < T.card → ∀ τ, c T τ = 0) ∧
    ∀ y, F y = ∑ T, ∑ τ, c T τ * dIndMono T τ y

/-! ## The common alphabet `Σ k, β k` -/

/-- The law of coordinate `i` carried to `Σ k, β k`. -/
noncomputable def liftMass (q : ∀ i, β i → ℝ) (i : ι) (s : Σ k, β k) : ℝ :=
  if h : s.1 = i then q i (h ▸ s.2) else 0

/-- Projection to the `i`-th alphabet, onto the support. -/
noncomputable def proj (q : ∀ i, β i → ℝ) (s0 : ∀ i, β i) (i : ι) (s : Σ k, β k) : β i :=
  if h : s.1 = i then (if 0 < q i (h ▸ s.2) then h ▸ s.2 else s0 i) else s0 i

theorem liftMass_mk (q : ∀ i, β i → ℝ) (i : ι) (b : β i) :
    liftMass q i ⟨i, b⟩ = q i b := dif_pos rfl

theorem liftMass_ne (q : ∀ i, β i → ℝ) (i : ι) {k : ι} (b : β k) (hk : k ≠ i) :
    liftMass q i ⟨k, b⟩ = 0 := dif_neg hk

theorem proj_mk (q : ∀ i, β i → ℝ) (s0 : ∀ i, β i) (i : ι) (b : β i) :
    proj q s0 i ⟨i, b⟩ = if 0 < q i b then b else s0 i := dif_pos rfl

theorem liftMass_nonneg (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) :
    ∀ i (s : Σ k, β k), 0 ≤ liftMass q i s := by
  intro i s
  unfold liftMass
  split_ifs
  · exact hq _ _
  · exact le_refl 0

theorem liftMass_sum (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1) (i : ι) :
    ∑ s : (Σ k, β k), liftMass q i s = 1 := by
  rw [Fintype.sum_sigma, Finset.sum_eq_single i]
  · simp only [liftMass_mk]
    exact hq1 i
  · intro k _ hk
    apply Finset.sum_eq_zero
    intro b _
    exact liftMass_ne q i b hk
  · intro h
    exact (h (mem_univ i)).elim

theorem proj_pos (q : ∀ i, β i → ℝ) (s0 : ∀ i, β i) (hs0 : ∀ i, 0 < q i (s0 i)) (i : ι)
    (s : Σ k, β k) : 0 < q i (proj q s0 i s) := by
  unfold proj
  split_ifs with h1 h2
  · exact h2
  · exact hs0 i
  · exact hs0 i

theorem exists_pos (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1) :
    ∀ i, ∃ b : β i, 0 < q i b := by
  intro i
  by_contra h
  push_neg at h
  have hs : ∑ b, q i b ≤ 0 := Finset.sum_nonpos (fun b _ => h b)
  rw [hq1 i] at hs
  norm_num at hs

/-- The fibre of `b` under `proj q s0 i` carries mass `q i b`. -/
theorem fiber_sum (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) (s0 : ∀ i, β i) (i : ι)
    (b : β i) :
    ∑ s : (Σ k, β k), (if proj q s0 i s = b then liftMass q i s else 0) = q i b := by
  rw [Fintype.sum_sigma, Finset.sum_eq_single i]
  · have hc : ∀ c : β i, (if proj q s0 i ⟨i, c⟩ = b then liftMass q i ⟨i, c⟩ else 0) =
        if c = b then q i c else 0 := by
      intro c
      rw [proj_mk, liftMass_mk]
      by_cases hpos : 0 < q i c
      · rw [if_pos hpos]
      · have h0 : q i c = 0 := le_antisymm (not_lt.mp hpos) (hq i c)
        rw [h0]
        simp
    rw [Finset.sum_congr rfl (fun c _ => hc c)]
    simp
  · intro k _ hk
    apply Finset.sum_eq_zero
    intro c _
    rw [liftMass_ne q i c hk]
    simp
  · intro h
    exact (h (mem_univ i)).elim

/-- Pushforward of the lifted product law under the coordinatewise projection. -/
theorem push_sum (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) (s0 : ∀ i, β i)
    (H : (∀ i, β i) → ℝ) :
    ∑ x : ι → (Σ k, β k), prodMass (liftMass q) x * H (fun i => proj q s0 i (x i)) =
      ∑ y, dMass q y * H y := by
  have h1 : ∀ x : ι → (Σ k, β k), prodMass (liftMass q) x * H (fun i => proj q s0 i (x i)) =
      ∑ y, (if (fun i => proj q s0 i (x i)) = y then prodMass (liftMass q) x else 0) * H y := by
    intro x
    rw [Finset.sum_eq_single (fun i => proj q s0 i (x i))]
    · rw [if_pos rfl]
    · intro y _ hy
      rw [if_neg (fun h => hy h.symm), zero_mul]
    · intro h
      exact (h (mem_univ _)).elim
  rw [Finset.sum_congr rfl (fun x _ => h1 x), Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro y _
  rw [← Finset.sum_mul]
  congr 1
  have h2 : ∀ x : ι → (Σ k, β k),
      (if (fun i => proj q s0 i (x i)) = y then prodMass (liftMass q) x else 0) =
        ∏ i, (if proj q s0 i (x i) = y i then liftMass q i (x i) else 0) := by
    intro x
    by_cases hx : (fun i => proj q s0 i (x i)) = y
    · rw [if_pos hx]
      unfold prodMass
      apply Finset.prod_congr rfl
      intro i _
      have hxi : proj q s0 i (x i) = y i := congrFun hx i
      rw [if_pos hxi]
    · rw [if_neg hx]
      obtain ⟨i, hi⟩ : ∃ i, proj q s0 i (x i) ≠ y i := by
        by_contra hcon
        push_neg at hcon
        exact hx (funext hcon)
      exact (Finset.prod_eq_zero (mem_univ i) (if_neg hi)).symm
  rw [Finset.sum_congr rfl (fun x _ => h2 x)]
  have h3 : ∑ x : ι → (Σ k, β k),
      ∏ i, (if proj q s0 i (x i) = y i then liftMass q i (x i) else 0) =
      ∏ i, ∑ s : (Σ k, β k), (if proj q s0 i s = y i then liftMass q i s else 0) :=
    (Fintype.prod_sum (fun i (s : Σ k, β k) =>
      if proj q s0 i s = y i then liftMass q i s else 0)).symm
  rw [h3]
  unfold dMass
  apply Finset.prod_congr rfl
  intro i _
  exact fiber_sum q hq s0 i (y i)

theorem push_coord (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) (s0 : ∀ i, β i) (j : ι)
    (K : β j → ℝ) :
    ∑ s : (Σ k, β k), liftMass q j s * K (proj q s0 j s) = ∑ b, q j b * K b := by
  have h1 : ∀ s : (Σ k, β k), liftMass q j s * K (proj q s0 j s) =
      ∑ b, (if proj q s0 j s = b then liftMass q j s else 0) * K b := by
    intro s
    rw [Finset.sum_eq_single (proj q s0 j s)]
    · rw [if_pos rfl]
    · intro b _ hb
      rw [if_neg (fun h => hb h.symm), zero_mul]
    · intro h
      exact (h (mem_univ _)).elim
  rw [Finset.sum_congr rfl (fun s _ => h1 s), Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro b _
  rw [← Finset.sum_mul, fiber_sum q hq s0 j b]

theorem proj_update (q : ∀ i, β i → ℝ) (s0 : ∀ i, β i) (x : ι → (Σ k, β k)) (j : ι)
    (s : Σ k, β k) :
    (fun i => proj q s0 i (Function.update x j s i)) =
      Function.update (fun i => proj q s0 i (x i)) j (proj q s0 j s) := by
  funext i
  by_cases h : i = j
  · subst h
    simp
  · simp [Function.update_of_ne h]

/-! ## Transfer of variance, influences, boundedness and degree -/

theorem pvar_lift (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) (s0 : ∀ i, β i)
    (F : (∀ i, β i) → ℝ) :
    pvar (liftMass q) (fun x => F (fun i => proj q s0 i (x i))) = dvar q F := by
  have hE : pexp (liftMass q) (fun x => F (fun i => proj q s0 i (x i))) = dexp q F :=
    push_sum q hq s0 F
  unfold pvar
  rw [hE]
  exact push_sum q hq s0 (fun y => (F y - dexp q F) ^ 2)

theorem pinfl_lift (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b) (s0 : ∀ i, β i)
    (F : (∀ i, β i) → ℝ) (j : ι) :
    pinfl (liftMass q) (fun x => F (fun i => proj q s0 i (x i))) j = dinfl q F j := by
  unfold pinfl dinfl
  beta_reduce
  have h1 : ∀ x : ι → (Σ k, β k), ∑ s, prodMass (liftMass q) x * liftMass q j s *
      ((F (fun i => proj q s0 i (x i)) -
        F (fun i => proj q s0 i (Function.update x j s i))) ^ 2 / 2) =
      prodMass (liftMass q) x * ∑ b, q j b * ((F (fun i => proj q s0 i (x i)) -
        F (Function.update (fun i => proj q s0 i (x i)) j b)) ^ 2 / 2) := by
    intro x
    rw [← push_coord q hq s0 j (fun b => (F (fun i => proj q s0 i (x i)) -
        F (Function.update (fun i => proj q s0 i (x i)) j b)) ^ 2 / 2), Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro s _
    rw [proj_update]
    beta_reduce
    ring
  rw [Finset.sum_congr rfl (fun x _ => h1 x)]
  have h2 : ∑ x : ι → (Σ k, β k), prodMass (liftMass q) x * ∑ b, q j b *
      ((F (fun i => proj q s0 i (x i)) -
        F (Function.update (fun i => proj q s0 i (x i)) j b)) ^ 2 / 2) =
      ∑ y, dMass q y * ∑ b, q j b * ((F y - F (Function.update y j b)) ^ 2 / 2) :=
    push_sum q hq s0 (fun y => ∑ b, q j b * ((F y - F (Function.update y j b)) ^ 2 / 2))
  rw [h2]
  apply Finset.sum_congr rfl
  intro y _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  ring

theorem dInd_dependsOn (q : ∀ i, β i → ℝ) (s0 : ∀ i, β i) (T : Finset ι) (τ : ∀ i, β i) :
    EfronStein.DependsOn T
      (fun σ : ι → (Σ k, β k) => dIndMono T τ (fun i => proj q s0 i (σ i))) := by
  intro x x' hxx
  beta_reduce
  unfold dIndMono
  apply Finset.prod_congr rfl
  intro i hi
  rw [hxx i hi]

theorem lift_degree (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1) (s0 : ∀ i, β i)
    (F : (∀ i, β i) → ℝ) (d : ℕ) (hd : DepDegreeLE F d) :
    RowBound.HasProdDegreeLE (fun x : ι → (Σ k, β k) => F (fun i => proj q s0 i (x i))) d := by
  obtain ⟨c, hc0, hFc⟩ := hd
  refine ⟨fun T σ => ∑ τ, c T τ * (dIndMono T τ (fun i => proj q s0 i (σ i)) *
      ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i))), ?_, ?_⟩
  · intro T hT σ
    beta_reduce
    apply Finset.sum_eq_zero
    intro τ _
    rw [hc0 T hT τ, zero_mul]
  · intro x
    beta_reduce
    rw [hFc]
    apply Finset.sum_congr rfl
    intro T _
    have hj : ∀ τ : ∀ i, β i, ∑ σ : ι → (Σ k, β k),
        (dIndMono T τ (fun i => proj q s0 i (σ i)) *
          ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i))) * RowBound.indMono T σ x =
        dIndMono T τ (fun i => proj q s0 i (x i)) :=
      fun τ => EfronStein.junta_expand (liftMass q) (liftMass_sum q hq1) T
        (fun σ => dIndMono T τ (fun i => proj q s0 i (σ i))) (dInd_dependsOn q s0 T τ) x
    calc ∑ τ, c T τ * dIndMono T τ (fun i => proj q s0 i (x i))
        = ∑ τ, c T τ * ∑ σ : ι → (Σ k, β k), (dIndMono T τ (fun i => proj q s0 i (σ i)) *
            ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i))) * RowBound.indMono T σ x := by
          apply Finset.sum_congr rfl
          intro τ _
          rw [hj τ]
      _ = ∑ τ, ∑ σ : ι → (Σ k, β k), c T τ * ((dIndMono T τ (fun i => proj q s0 i (σ i)) *
            ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i))) * RowBound.indMono T σ x) := by
          apply Finset.sum_congr rfl
          intro τ _
          rw [Finset.mul_sum]
      _ = ∑ σ : ι → (Σ k, β k), ∑ τ, c T τ * ((dIndMono T τ (fun i => proj q s0 i (σ i)) *
            ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i))) * RowBound.indMono T σ x) :=
          Finset.sum_comm
      _ = ∑ σ : ι → (Σ k, β k), (∑ τ, c T τ * (dIndMono T τ (fun i => proj q s0 i (σ i)) *
            ∏ i, (if i ∈ T then (1 : ℝ) else liftMass q i (σ i)))) * RowBound.indMono T σ x := by
          apply Finset.sum_congr rfl
          intro σ _
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro τ _
          ring

/-- **Bias-free influence theorem with coordinate-dependent alphabets and zero-mass atoms.** -/
theorem heterogeneous_influence (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b)
    (hq1 : ∀ i, ∑ b, q i b = 1) (d : ℕ) (F : (∀ i, β i) → ℝ)
    (hF : ∀ y : ∀ i, β i, (∀ i, 0 < q i (y i)) → |F y| ≤ 1)
    (hd : DepDegreeLE F d) (hV : 0 < dvar q F) :
    ∃ j, 3 * dvar q F ^ 5 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * dinfl q F j ^ 2 := by
  choose s0 hs0 using exists_pos q hq1
  obtain ⟨j, hj⟩ := Influence.product_influence (liftMass q) (liftMass_nonneg q hq)
    (liftMass_sum q hq1) d (fun x => F (fun i => proj q s0 i (x i)))
    (fun x => hF _ (fun i => proj_pos q s0 hs0 i (x i)))
    (lift_degree q hq1 s0 F d hd) (by rw [pvar_lift q hq s0 F]; exact hV)
  refine ⟨j, ?_⟩
  rw [pvar_lift q hq s0 F, pinfl_lift q hq s0 F j] at hj
  exact hj

end Nightfall.ProductSpace.Heterogeneous
