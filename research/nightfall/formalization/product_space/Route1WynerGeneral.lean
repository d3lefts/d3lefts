import Route1WynerSimulation

/-!
# NIGHTFALL Route 1 — Wyner common information, general latents

Closes the two scope gaps of `route1_wyner_CI`.

* `wynerSet_nonempty`: every probability mass function on `ι → α` has a finite product
  decomposition (point masses), so the nonemptiness hypothesis is automatic.
* `wynerGenSet_eq`: the finite-latent value set equals the **general** one, in which the latent is an
  arbitrary Borel probability measure `ρ` on the compact space `LawSpace` of product laws and
  `I = H(ν) − ∫ H(P_θ) dρ(θ)`. Any latent `W` with the coordinates conditionally independent given
  `W` induces such a `ρ` (push `W` forward along `w ↦ P_{X|W=w}`) with the same `I(X;W)`, since for
  discrete `X`, `I(X;W) = H(X) − ∫ H(P_{X|W=w}) dP_W(w)`. So `wynerGen` is Wyner's definition.
  Proof: the integral of `θ ↦ (P_θ, H(P_θ))` lies in the closed convex hull of its range, which is
  the convex hull (compact, by Carathéodory in finite dimension: `isCompact_convexHull_of_isCompact`),
  hence is a finite convex combination.
* `route1_wyner_general`: the Route 1 simulation with any `s > C_W(ν)`, `ν` any probability mass
  function, no further hypotheses.
-/

namespace Nightfall.Route1Polylog

open Finset Real MeasureTheory
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

/-! ## Compact convex hulls in finite dimension -/

theorem isCompact_convexHull_of_isCompact {E : Type} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] {K : Set E} (hK : IsCompact K) : IsCompact (convexHull ℝ K) := by
  classical
  rcases K.eq_empty_or_nonempty with h0 | ⟨k0, hk0⟩
  · rw [h0, convexHull_empty]; exact isCompact_empty
  set N := Module.finrank ℝ E + 1
  set S : Set ((Fin N → ℝ) × (Fin N → E)) := stdSimplex ℝ (Fin N) ×ˢ Set.univ.pi fun _ => K
  have hS : IsCompact S := (isCompact_stdSimplex ℝ (Fin N)).prod (isCompact_univ_pi fun _ => hK)
  have hΦ : Continuous fun p : (Fin N → ℝ) × (Fin N → E) => ∑ i, p.1 i • p.2 i := by fun_prop
  suffices h : convexHull ℝ K = (fun p : (Fin N → ℝ) × (Fin N → E) => ∑ i, p.1 i • p.2 i) '' S by
    rw [h]; exact hS.image hΦ
  apply Set.Subset.antisymm
  · intro x hx
    obtain ⟨ι', _, z, w, hz, hai, hw, hw1, hx⟩ := eq_pos_convex_span_of_mem_convexHull hx
    have hcard : Fintype.card ι' ≤ N :=
      hai.card_le_finrank_succ.trans (Nat.succ_le_succ (Submodule.finrank_le _))
    let e : ι' → Fin N := fun i => Fin.castLE hcard (Fintype.equivFin ι' i)
    have he : Function.Injective e := fun a b h =>
      (Fintype.equivFin ι').injective (Fin.castLE_injective hcard h)
    set W : Fin N → ℝ := Function.extend e w 0 with hW
    set Z : Fin N → E := Function.extend e z fun _ => k0 with hZ
    have hWe : ∀ i, W (e i) = w i := fun i => he.extend_apply _ _ _
    have hZe : ∀ i, Z (e i) = z i := fun i => he.extend_apply _ _ _
    have hWo : ∀ j, j ∉ Set.range e → W j = 0 := fun j hj => by
      rw [hW, Function.extend_apply' _ _ _ (by simpa using hj)]; simp
    have hZo : ∀ j, j ∉ Set.range e → Z j = k0 := fun j hj => by
      rw [hZ, Function.extend_apply' _ _ _ (by simpa using hj)]
    refine ⟨(W, Z), ⟨⟨fun j => ?_, ?_⟩, fun j _ => ?_⟩, ?_⟩
    · show 0 ≤ W j
      by_cases hj : j ∈ Set.range e
      · obtain ⟨i, rfl⟩ := hj; rw [hWe]; exact (hw i).le
      · rw [hWo j hj]
    · show ∑ j, W j = 1
      rw [← (Fintype.sum_of_injective e he w W hWo (fun i => (hWe i).symm))]; exact hw1
    · show Z j ∈ K
      by_cases hj : j ∈ Set.range e
      · obtain ⟨i, rfl⟩ := hj; rw [hZe]; exact hz ⟨i, rfl⟩
      · rw [hZo j hj]; exact hk0
    · show ∑ j, W j • Z j = x
      rw [← (Fintype.sum_of_injective e he (fun i => w i • z i) (fun j => W j • Z j)
        (fun j hj => by rw [hWo j hj, zero_smul]) (fun i => by rw [hWe, hZe]))]
      exact hx
  · rintro _ ⟨⟨w, z⟩, ⟨⟨hw0, hw1⟩, hz⟩, rfl⟩
    exact (convex_convexHull ℝ K).sum_mem (fun i _ => hw0 i) hw1
      (fun i _ => subset_convexHull ℝ K (hz i (Set.mem_univ i)))

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]

/-! ## Entropy bookkeeping -/

/-- Shannon entropy (nats) of a mass function on `ι → α`. -/
noncomputable def Hent (m : (ι → α) → ℝ) : ℝ := ∑ x, negMulLog (m x)

theorem prodMass_total (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) :
    ∑ x : ι → α, prodMass p x = 1 := by
  unfold prodMass
  rw [← Fintype.piFinset_univ, ← Finset.prod_univ_sum]
  simp [hp1]

/-- `I(Θ;X) = H(Θ) − H(Θ|X) = H(X) − H(X|Θ)`. -/
theorem mutInfo_eq {Θ : Type} [Fintype Θ] (P : Θ → ι → α → ℝ) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw1 : ∑ θ, w θ = 1) :
    mutInfo P w = Hent (fun x => ∑ θ, w θ * prodMass (P θ) x) -
      ∑ θ, w θ * Hent (prodMass (P θ)) := by
  unfold mutInfo Ent Vs Hent
  rw [hw1, negMulLog_one, sub_zero]
  simp only [negMulLog_mul, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  rw [Finset.sum_comm (f := fun x θ => prodMass (P θ) x * negMulLog (w θ)),
    Finset.sum_comm (f := fun x θ => w θ * negMulLog (prodMass (P θ) x))]
  simp only [← Finset.sum_mul, ← Finset.mul_sum, prodMass_total _ (hP1 _), one_mul]
  ring

/-! ## The space of product laws -/

/-- Product laws on `ι → α`. -/
abbrev LawSpace (ι α : Type) [Fintype α] : Type :=
  {p : ι → α → ℝ // (∀ i a, 0 ≤ p i a) ∧ ∀ i, ∑ a, p i a = 1}

theorem isCompact_lawSet :
    IsCompact {p : ι → α → ℝ | (∀ i a, 0 ≤ p i a) ∧ ∀ i, ∑ a, p i a = 1} := by
  apply Metric.isCompact_of_isClosed_isBounded
  · simp only [Set.ofPred_and, Set.ofPred_forall]
    refine IsClosed.inter (isClosed_iInter fun i => isClosed_iInter fun a =>
      isClosed_le continuous_const (by fun_prop)) (isClosed_iInter fun i =>
      isClosed_eq (by fun_prop) continuous_const)
  · refine (Metric.isBounded_closedBall (x := 0) (r := 1)).subset fun p hp => ?_
    rw [Metric.mem_closedBall, dist_zero_right]
    refine (pi_norm_le_iff_of_nonneg zero_le_one).mpr fun i => ?_
    refine (pi_norm_le_iff_of_nonneg zero_le_one).mpr fun a => ?_
    rw [Real.norm_eq_abs, abs_of_nonneg (hp.1 i a)]
    calc p i a ≤ ∑ b, p i b := Finset.single_le_sum (fun b _ => hp.1 i b) (mem_univ a)
      _ = 1 := hp.2 i

instance : CompactSpace (LawSpace ι α) := isCompact_iff_compactSpace.mp isCompact_lawSet

theorem continuous_prodMass_law (x : ι → α) :
    Continuous fun θ : LawSpace ι α => prodMass θ.1 x := by
  unfold prodMass
  exact continuous_finsetProd _ fun i _ =>
    (continuous_apply (x i)).comp ((continuous_apply i).comp continuous_subtype_val)

theorem continuous_Hent_law : Continuous fun θ : LawSpace ι α => Hent (prodMass θ.1) := by
  unfold Hent
  have := fun x => Real.continuous_negMulLog.comp (continuous_prodMass_law (ι := ι) (α := α) x)
  fun_prop

/-! ## Wyner's definition with a general latent -/

/-- Values of `H(ν) − ∫ H(P_θ) dρ` over Borel probability measures `ρ` on product laws with
`ν = ∫ P_θ dρ`. -/
def wynerGenSet (ν : (ι → α) → ℝ) : Set ℝ :=
  {s | ∃ ρ : Measure (LawSpace ι α), IsProbabilityMeasure ρ ∧
    (∀ x, ν x = ∫ θ, prodMass θ.1 x ∂ρ) ∧ s = Hent ν - ∫ θ, Hent (prodMass θ.1) ∂ρ}

/-- **Wyner common information** of `ν` (general latent). -/
noncomputable def wynerGen (ν : (ι → α) → ℝ) : ℝ := sInf (wynerGenSet ν)

theorem wynerSet_sub_gen (ν : (ι → α) → ℝ) : wynerSet ν ⊆ wynerGenSet ν := by
  rintro s ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩
  let pt : Fin k → LawSpace ι α := fun θ => ⟨Q θ, hQ0 θ, hQ1 θ⟩
  let ρ : Measure (LawSpace ι α) :=
    Measure.sum fun θ => ENNReal.ofReal (w θ) • Measure.dirac (pt θ)
  have hint : ∀ F : LawSpace ι α → ℝ, ∫ θ, F θ ∂ρ = ∑ θ, w θ * F (pt θ) := by
    intro F
    rw [integral_sum_dirac (fun θ => ENNReal.ofReal_ne_top), tsum_fintype]
    exact Finset.sum_congr rfl fun θ _ => by rw [ENNReal.toReal_ofReal (hw0 θ), smul_eq_mul]
  refine ⟨ρ, ⟨?_⟩, fun x => ?_, ?_⟩
  · rw [Measure.sum_apply _ MeasurableSet.univ, tsum_fintype]
    simp only [Measure.smul_apply, measure_univ, smul_eq_mul, mul_one]
    rw [← ENNReal.ofReal_sum_of_nonneg fun θ _ => hw0 θ, hw1, ENNReal.ofReal_one]
  · rw [hint, hν]
  · rw [hint, mutInfo_eq Q hQ1 w hw1]
    congr 2; funext x; exact (hν x).symm

theorem wynerGen_sub_set (ν : (ι → α) → ℝ) : wynerGenSet ν ⊆ wynerSet ν := by
  classical
  rintro s ⟨ρ, hρ, hν, rfl⟩
  set E := ((ι → α) → ℝ) × ℝ
  let F : LawSpace ι α → E := fun θ => (fun x => prodMass θ.1 x, Hent (prodMass θ.1))
  have hF : Continuous F :=
    Continuous.prodMk (continuous_pi fun x => continuous_prodMass_law x) continuous_Hent_law
  have hFi : Integrable F ρ := (BoundedContinuousFunction.mkOfCompact ⟨F, hF⟩).integrable ρ
  have hhull : IsCompact (convexHull ℝ (Set.range F)) :=
    isCompact_convexHull_of_isCompact (isCompact_range hF)
  have hmem : ∫ θ, F θ ∂ρ ∈ convexHull ℝ (Set.range F) :=
    (convex_convexHull ℝ _).integral_mem hhull.isClosed
      (Filter.Eventually.of_forall fun θ => subset_convexHull ℝ _ ⟨θ, rfl⟩) hFi
  obtain ⟨ι', _, c, z, hc0, hc1, hz, hsum⟩ := mem_convexHull_iff_exists_fintype.mp hmem
  choose th hth using hz
  -- evaluation functionals
  have hev : ∀ L : E →L[ℝ] ℝ, ∫ θ, L (F θ) ∂ρ = ∑ i, c i * L (F (th i)) := by
    intro L
    rw [ContinuousLinearMap.integral_comp_comm L hFi, ← hsum, map_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [map_smul, smul_eq_mul, hth]
  have hevx : ∀ x, ∫ θ, prodMass θ.1 x ∂ρ = ∑ i, c i * prodMass (th i).1 x := fun x =>
    hev ((ContinuousLinearMap.proj x).comp (ContinuousLinearMap.fst ℝ _ ℝ))
  let k := Fintype.card ι'
  let e := Fintype.equivFin ι'
  refine ⟨k, fun θ => c (e.symm θ), fun θ => (th (e.symm θ)).1, fun θ => hc0 _, ?_,
    fun θ => (th (e.symm θ)).2.1, fun θ => (th (e.symm θ)).2.2, fun x => ?_, ?_⟩
  · rw [Equiv.sum_comp e.symm c]; exact hc1
  · have := hevx x
    rw [hν x, this, ← Equiv.sum_comp e.symm (fun i => c i * prodMass (th i).1 x)]
  · have hx : ∀ x, ν x = ∑ θ, c (e.symm θ) * prodMass (th (e.symm θ)).1 x := by
      intro x
      rw [hν x, hevx x, ← Equiv.sum_comp e.symm (fun i => c i * prodMass (th i).1 x)]
    have hH : ∫ θ, Hent (prodMass θ.1) ∂ρ = ∑ i, c i * Hent (prodMass (th i).1) :=
      hev (ContinuousLinearMap.snd ℝ _ ℝ)
    rw [mutInfo_eq _ (fun θ => (th (e.symm θ)).2.2) _ (by rw [Equiv.sum_comp e.symm c]; exact hc1),
      hH, ← Equiv.sum_comp e.symm (fun i => c i * Hent (prodMass (th i).1))]
    congr 2; funext x; exact hx x

/-- **The finite-latent and general Wyner values coincide.** -/
theorem wynerGenSet_eq (ν : (ι → α) → ℝ) : wynerGenSet ν = wynerSet ν :=
  Set.Subset.antisymm (wynerGen_sub_set ν) (wynerSet_sub_gen ν)

theorem wynerCI_eq_wynerGen (ν : (ι → α) → ℝ) : wynerCI ν = wynerGen ν := by
  unfold wynerCI wynerGen; rw [wynerGenSet_eq]

/-- **Every probability mass function has a finite product decomposition** (point masses). -/
theorem wynerSet_nonempty (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1) :
    (wynerSet ν).Nonempty := by
  classical
  let e := Fintype.equivFin (ι → α)
  let Q : Fin (Fintype.card (ι → α)) → ι → α → ℝ :=
    fun θ i a => if a = e.symm θ i then 1 else 0
  have hm : ∀ θ x, prodMass (Q θ) x = if x = e.symm θ then 1 else 0 := by
    intro θ x
    unfold prodMass
    split_ifs with hx
    · subst hx; simp [Q]
    · obtain ⟨i, hi⟩ : ∃ i, x i ≠ e.symm θ i := by
        by_contra h; push Not at h; exact hx (funext h)
      exact Finset.prod_eq_zero (mem_univ i) (by simp [Q, hi])
  refine ⟨_, Fintype.card (ι → α), fun θ => ν (e.symm θ), Q, fun θ => hν0 _, ?_,
    fun θ i a => by simp only [Q]; split_ifs <;> norm_num,
    fun θ i => by simp [Q], fun x => ?_, rfl⟩
  · rw [Equiv.sum_comp e.symm ν]; exact hν1
  · simp only [hm, mul_ite, mul_one, mul_zero, Equiv.eq_symm_apply]
    rw [Finset.sum_ite_eq]; simp

/-! ## The unconditional theorem -/

/-- **Route 1, Wyner form, general latents.** For any probability mass function `ν` on `ι → α`,
any `f : (ι → α) → [0,1]` of interaction degree `≤ d`, and any `s > C_W(ν)` (Wyner common
information, arbitrary latents), there is a depth-`n` tree with
`Pr_ν[|f − tree| > ε] ≤ (K/(2γ) + s/(η²w₀))/n + τ/ε²`. -/
theorem route1_wyner_general (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hd : 1 ≤ d)
    (hdeg : HasProdDegreeLE f d) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          s / (etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  rw [← wynerCI_eq_wynerGen] at hs
  exact route1_wyner_CI ν (wynerSet_nonempty ν hν0 hν1) f hf01 d hd hdeg τ hτ hτ1 ε hε n hn s hs

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.isCompact_convexHull_of_isCompact
#print axioms Nightfall.Route1Polylog.wynerGenSet_eq
#print axioms Nightfall.Route1Polylog.wynerSet_nonempty
#print axioms Nightfall.Route1Polylog.route1_wyner_general
