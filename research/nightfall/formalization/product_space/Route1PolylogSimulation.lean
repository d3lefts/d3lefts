import Route1Lift

/-!
# NIGHTFALL Route 1 — polylog-M classical simulation over mixtures of product laws

`polylog_mixture_simulation`: for a mixture `∑_θ w_θ P_θ` of `M` product laws on `ι → α` (any finite
alphabet, any masses, zeros allowed) and `f : (ι → α) → [0,1]` of interaction degree `≤ d`, there is a
decision tree of depth `n` with

    Pr_ν[|f − tree| > ε] ≤ (K/(2γ) + log M · (512 d²)² · 16 K / γ³) / n + τ / ε²,

`K = π² d² / 2`, `γ = √(3 τ⁵ / (12500 (π² (d+1)²)⁶))`. The number of components enters only through
`log M`. Ingredients: the certified product-space AA inequality applied to the latent lift
(`Route1Lift`), the Key Lemma (`Route1KeyLemma`), the entropy information charge (`Route1Entropy`),
and the certified mixture-tree machinery of `MixtureSimulation`, with the collision potential
replaced by the entropy potential.
-/

namespace Nightfall.Route1Polylog

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1LatentDegree

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
variable (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

/-! ## Constants -/

noncomputable def gam (d : ℕ) (τ : ℝ) : ℝ :=
  Real.sqrt (3 * τ ^ 5 / (12500 * (Real.pi ^ 2 * ((d : ℝ) + 1) ^ 2) ^ 6))

noncomputable def etaC (d : ℕ) (τ : ℝ) : ℝ := gam d τ / (512 * (d : ℝ) ^ 2)

noncomputable def w0C (K : ℝ) (d : ℕ) (τ : ℝ) : ℝ := gam d τ / (16 * K)

theorem gam_pos (d : ℕ) (τ : ℝ) (hτ : 0 < τ) : 0 < gam d τ := by
  unfold gam; apply Real.sqrt_pos.mpr; positivity

theorem gam_le_one (d : ℕ) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) : gam d τ ≤ 1 := by
  unfold gam
  rw [Real.sqrt_le_one]
  have hC : 1 ≤ (Real.pi ^ 2 * ((d : ℝ) + 1) ^ 2) ^ 6 := by
    apply one_le_pow₀
    have hpi : 1 ≤ Real.pi ^ 2 := by nlinarith [Real.pi_gt_three]
    have hd : 1 ≤ ((d : ℝ) + 1) ^ 2 := by nlinarith [(Nat.cast_nonneg d : (0 : ℝ) ≤ d)]
    nlinarith
  have hτ5 : τ ^ 5 ≤ 1 := pow_le_one₀ hτ.le hτ1
  rw [div_le_one (by positivity)]
  nlinarith

/-! ## Posterior normalisation -/

omit [DecidableEq Θ] [Nonempty Θ] [Nonempty α] in
theorem mvar_eq (v : Θ → ℝ) (hV : 0 < Vs v) (g : (ι → α) → ℝ) :
    mvar P v g = Vs v * ∑ θ, (v θ / Vs v) *
      pexp (P θ) (fun x => (g x - ∑ θ', (v θ' / Vs v) * pexp (P θ') g) ^ 2) := by
  have hm : mmean P v g = ∑ θ', (v θ' / Vs v) * pexp (P θ') g := by
    unfold mmean Ex; rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun θ _ => by ring
  unfold mvar Ex
  rw [hm, Finset.mul_sum]
  exact Finset.sum_congr rfl fun θ _ => by field_simp

omit [DecidableEq Θ] [Nonempty Θ] [DecidableEq α] [Nonempty α] in
theorem pinfl_le_half_pincr (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (g : (ι → α) → ℝ)
    (hg : ∀ x, 0 ≤ g x ∧ g x ≤ 1) (j : ι) : 2 * pinfl p g j ≤ pincr p g j := by
  unfold pinfl pincr
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun x _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun b _ => ?_
  have hm : 0 ≤ prodMass p x * p j b := mul_nonneg (Finset.prod_nonneg fun i _ => hp i _) (hp j b)
  have h1 := hg x; have h2 := hg (Function.update x j b)
  have hsq : (g x - g (Function.update x j b)) ^ 2 ≤ |g x - g (Function.update x j b)| := by
    have hb : |g x - g (Function.update x j b)| ≤ 1 := by
      rw [abs_le]; constructor <;> linarith
    rw [← sq_abs]; nlinarith [abs_nonneg (g x - g (Function.update x j b))]
  nlinarith

omit [DecidableEq Θ] [Nonempty Θ] [Nonempty α] in
theorem pinfl_inv (p : ι → α → ℝ) (g : (ι → α) → ℝ) (j : ι) (hj : Inv g j) :
    pinfl p g j = 0 := by
  unfold pinfl
  refine Finset.sum_eq_zero fun x _ => Finset.sum_eq_zero fun b _ => ?_
  rw [hj x b]; ring

/-! ## The crux -/

include hP0 hP1 in
/-- **Crux (M-free).** At a node with large variance, some unqueried coordinate either carries a
posterior-averaged increment of at least `2γ` or an information charge of at least `η² w₀`. -/
theorem crux (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v) (g : (ι → α) → ℝ)
    (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1) (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE g d)
    (K : ℝ) (hK : 0 < K) (hrows : HasRows g K) (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (hvar : τ * Vs v < mvar P v g) :
    ∃ j, j ∉ A ∧ (2 * gam d τ * Vs v ≤ ∑ θ, v θ * pincr (P θ) g j ∨
      etaC d τ ^ 2 * w0C K d τ * Vs v ≤ ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2) := by
  classical
  set π : Θ → ℝ := fun θ => v θ / Vs v with hπdef
  have hπ0 : ∀ θ, 0 ≤ π θ := fun θ => div_nonneg (hv θ) hV.le
  have hπ1 : ∑ θ, π θ = 1 := by simp only [π]; rw [← Finset.sum_div]; exact div_self hV.ne'
  set q := qmix P v with hqdef
  obtain ⟨κ, hκ⟩ := seed_coupling_exists P hP0 hP1 q (fun j b => qmix_nonneg P hP0 v hv j b)
    (fun j => qmix_sum P hP1 v hV j)
  set G : (Option ι → Θ ⊕ Seed α Θ) → ℝ := latentLift g (dec (ι := ι) (α := α) (Θ := Θ)) with hGdef
  have hGb : ∀ z, |G z| ≤ 1 := fun z => by
    have := hg01 (fun i => dec (pickTheta z) i (pickSeed z i))
    simp only [hGdef, latentLift]
    rw [abs_le]; constructor <;> linarith [this.1, this.2]
  have hGdeg : HasProdDegreeLE G (d + 1) :=
    by simpa [hGdef] using Nightfall.Route1SourceBridge.source_latent_degree_succ g (dec (ι := ι) (α := α) (Θ := Θ)) d hdeg
  have hpv : pvar (liftLaw π κ) G = mvar P v g / Vs v := by
    rw [pvar_lift P q κ hκ π g, mvar_eq P v hV g, mul_div_cancel_left₀ _ hV.ne']
  have hVpos : τ < pvar (liftLaw π κ) G := by
    rw [hpv, lt_div_iff₀ hV]; linarith
  obtain ⟨c, hc⟩ := product_influence (liftLaw π κ) (liftLaw_nonneg π hπ0 κ hκ.nonneg)
    (liftLaw_sum π hπ1 κ hκ.total) (d + 1) G hGb (by exact_mod_cast hGdeg) (hτ.trans hVpos)
  -- the influence at `c` is at least `γ`
  set C : ℝ := 12500 * (Real.pi ^ 2 * ((d : ℝ) + 1) ^ 2) ^ 6 with hCdef
  have hCpos : 0 < C := by positivity
  have hc' : 3 * pvar (liftLaw π κ) G ^ 5 ≤ C * pinfl (liftLaw π κ) G c ^ 2 := by
    have := hc; push_cast at this; simpa [hCdef] using this
  have hI0 : 0 ≤ pinfl (liftLaw π κ) G c := by
    unfold pinfl
    exact Finset.sum_nonneg fun z _ => Finset.sum_nonneg fun t _ => mul_nonneg (mul_nonneg
      (Finset.prod_nonneg fun o _ => liftLaw_nonneg π hπ0 κ hκ.nonneg o _)
      (liftLaw_nonneg π hπ0 κ hκ.nonneg c t)) (by positivity)
  have hγ : gam d τ ≤ pinfl (liftLaw π κ) G c := by
    unfold gam
    rw [← hCdef, show 3 * τ ^ 5 / C = (3 * τ ^ 5 / C) by rfl]
    calc Real.sqrt (3 * τ ^ 5 / C) ≤ Real.sqrt (pinfl (liftLaw π κ) G c ^ 2) := by
          apply Real.sqrt_le_sqrt
          rw [div_le_iff₀ hCpos]
          have h5 : τ ^ 5 ≤ pvar (liftLaw π κ) G ^ 5 := pow_le_pow_left₀ hτ.le hVpos.le 5
          nlinarith
      _ = pinfl (liftLaw π κ) G c := Real.sqrt_sq hI0
  have hγpos := gam_pos d τ hτ
  cases c with
  | some j =>
    -- seed coordinate: posterior-averaged component influence
    rw [hGdef, pinfl_lift_seed P q κ hκ π g j] at hγ
    have hjA : j ∉ A := by
      intro hj
      have : ∑ θ, π θ * pinfl (P θ) g j = 0 := Finset.sum_eq_zero fun θ _ => by
        rw [pinfl_inv (P θ) g j (hinv j hj), mul_zero]
      linarith
    refine ⟨j, hjA, Or.inl ?_⟩
    calc 2 * gam d τ * Vs v ≤ 2 * (∑ θ, π θ * pinfl (P θ) g j) * Vs v := by gcongr
      _ = ∑ θ, v θ * (2 * pinfl (P θ) g j) := by
          rw [mul_assoc, Finset.sum_mul, Finset.mul_sum]
          exact Finset.sum_congr rfl fun θ _ => by simp only [π]; field_simp
      _ ≤ ∑ θ, v θ * pincr (P θ) g j := Finset.sum_le_sum fun θ _ =>
          mul_le_mul_of_nonneg_left (pinfl_le_half_pincr (P θ) (hP0 θ) g hg01 j) (hv θ)
  | none =>
    -- label coordinate: the Key Lemma forces an informative coordinate
    rw [hGdef] at hγ
    have hlab := pinfl_lift_label P q κ hκ π hπ0 hπ1 g
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hη0 : 0 < etaC d τ := by unfold etaC; positivity
    have hη1 : etaC d τ ≤ 1 / 2 := by
      unfold etaC
      rw [div_le_iff₀ (by positivity)]
      have := gam_le_one d τ hτ hτ1
      have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hd
      have : (1 : ℝ) ≤ (d : ℝ) ^ 2 := by nlinarith
      nlinarith
    have hw0 : 0 ≤ w0C K d τ := by unfold w0C; positivity
    by_contra hno
    push Not at hno
    have hall : ∀ j, j ∉ A →
        ∑ θ, π θ * (if etaC d τ < tvd (P θ j) (q j) then 1 else 0) ≤ w0C K d τ := by
      intro j hj
      by_contra hgt
      push Not at hgt
      obtain ⟨h1, h2⟩ := hno j hj
      apply (not_le.mpr h2)
      -- `∑ v tvd² ≥ Vs · η² · ∑ π [η < tvd] ≥ Vs η² w₀`
      have hpt : ∀ θ, π θ * (etaC d τ ^ 2 * (if etaC d τ < tvd (P θ j) (q j) then 1 else 0)) ≤
          π θ * tvd (P θ j) (q j) ^ 2 := by
        intro θ
        refine mul_le_mul_of_nonneg_left ?_ (hπ0 θ)
        split_ifs with h
        · nlinarith
        · simp; exact sq_nonneg _
      have hsum := Finset.sum_le_sum fun θ (_ : θ ∈ univ) => hpt θ
      have hre : ∑ θ, π θ * (etaC d τ ^ 2 * (if etaC d τ < tvd (P θ j) (q j) then 1 else 0)) =
          etaC d τ ^ 2 * ∑ θ, π θ * (if etaC d τ < tvd (P θ j) (q j) then 1 else 0) := by
        rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun θ _ => by ring
      have hvq : ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 =
          Vs v * ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun θ _ => by simp only [π, hqdef]; field_simp
      rw [hvq]
      have : etaC d τ ^ 2 * w0C K d τ ≤ ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
        rw [hre] at hsum
        exact le_trans (mul_le_mul_of_nonneg_left hgt.le (sq_nonneg _)) hsum
      nlinarith
    have hkey := key_lemma P q κ hκ π hπ0 hπ1 g hg01 d hdeg K hrows A hinv (etaC d τ) hη0 hη1
      (w0C K d τ) hw0 hall
    have hval : 2 * K * w0C K d τ + 128 * (d : ℝ) ^ 2 * etaC d τ = 3 * gam d τ / 8 := by
      unfold w0C etaC; field_simp; ring
    rw [hval] at hkey
    linarith


/-! ## The entropy-potential tree -/

/-- Increment potential plus entropy potential. -/
noncomputable def Pot (ga gb : ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ :=
  Phi P v g / ga + Ent v / gb

/-- Querying `j` lowers the potential by at least the current weight. -/
def GoodE (ga gb : ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) : Prop :=
  ∑ b, Pot P ga gb (upd P v j b) (sect g j b) + Vs v ≤ Pot P ga gb v g

section ETree

open Classical in
/-- The simulating tree for the mixture. -/
noncomputable def ebuild (τ ga gb : ℝ) :
    ℕ → Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → DTree ι α
  | 0, _, v, g => .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))
  | n + 1, A, v, g =>
    if h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j then
      .node h.choose
        (fun b => ebuild τ ga gb n (insert h.choose A) (upd P v h.choose b) (sect g h.choose b))
    else .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))

variable (τ ga gb : ℝ)

theorem ebuild_zero (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) :
    ebuild P τ ga gb 0 A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := rfl

theorem ebuild_pos (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j) :
    ebuild P τ ga gb (n + 1) A v g = .node h.choose
      (fun b => ebuild P τ ga gb n (insert h.choose A) (upd P v h.choose b)
        (sect g h.choose b)) := by
  rw [ebuild, dif_pos h]

theorem ebuild_neg (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ¬ ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j) :
    ebuild P τ ga gb (n + 1) A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := by
  rw [ebuild, dif_neg h]

/-- The tree never reads a coordinate of `A`. -/
theorem ebuild_inv (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ),
    ∀ i ∈ A, ∀ x b,
      (ebuild P τ ga gb n A v g).eval (Function.update x i b) = (ebuild P τ ga gb n A v g).eval x ∧
      (ebuild P τ ga gb n A v g).bad (Function.update x i b) = (ebuild P τ ga gb n A v g).bad x ∧
      (ebuild P τ ga gb n A v g).queries (Function.update x i b) =
        (ebuild P τ ga gb n A v g).queries x := by
  induction n with
  | zero => intro A v g i _ x b; simp [ebuild_zero, DTree.eval, DTree.bad, DTree.queries]
  | succ n ih =>
    intro A v g i hi x b
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j
    · rw [ebuild_pos P τ ga gb n A v g h]
      have hj := h.choose_spec
      have hne : i ≠ h.choose := fun hij => hj.1 (hij ▸ hi)
      have hxj : Function.update x i b h.choose = x h.choose := Function.update_of_ne hne.symm _ _
      have := ih (insert h.choose A) (upd P v h.choose (x h.choose))
        (sect g h.choose (x h.choose)) i (Finset.mem_insert_of_mem hi) x b
      simp only [DTree.eval, DTree.bad, DTree.queries, hxj]
      exact ⟨this.1, this.2.1, by rw [this.2.2]⟩
    · rw [ebuild_neg P τ ga gb n A v g h]
      simp [DTree.eval, DTree.bad, DTree.queries]

theorem equeries_le (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) x,
    (ebuild P τ ga gb n A v g).queries x ≤ n := by
  induction n with
  | zero => intro A v g x; simp [ebuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g x
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j
    · rw [ebuild_pos P τ ga gb n A v g h]
      simp only [DTree.queries]
      exact Nat.succ_le_succ (ih _ _ _ x)
    · rw [ebuild_neg P τ ga gb n A v g h]
      simp [DTree.queries]


include hP0 hP1 in
theorem Pot_nonneg (hga : 0 < ga) (hgb : 0 < gb) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (g : (ι → α) → ℝ) : 0 ≤ Pot P ga gb v g := by
  unfold Pot
  have h1 : 0 ≤ Phi P v g := Finset.sum_nonneg fun θ _ =>
    mul_nonneg (hv θ) (Finset.sum_nonneg fun k _ => pincr_nonneg (P θ) (hP0 θ) g k)
  have h2 : 0 ≤ Ent v := ent_nonneg v hv
  positivity

include hP0 hP1 in
/-- **Potential bound** for the mixture tree: `E[queries] ≤ Ψ`. -/
theorem eexpected (hga : 0 < ga) (hgb : 0 < gb) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => ((ebuild P τ ga gb n A v g).queries x : ℝ)) ≤ Pot P ga gb v g := by
  induction n with
  | zero =>
    intro A v g hv
    simp only [ebuild_zero, DTree.queries, Nat.cast_zero]
    rw [Ex_const P hP1, zero_mul]
    exact Pot_nonneg P hP0 hP1 ga gb hga hgb v hv g
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j
    · rw [ebuild_pos P τ ga gb n A v g h]
      set j := h.choose with hjdef
      have hj := h.choose_spec
      rw [← hjdef] at hj
      have hsplit := Ex_split P hP1 v j
        (fun c x => ((ebuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℝ))
        (fun c x b => by
          rw [(ebuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b).2.2])
      have hexp : Ex P v (fun x => (((DTree.node j fun c =>
            ebuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℕ) : ℝ)) =
          Ex P v (fun x => ((ebuild P τ ga gb n (insert j A) (upd P v j (x j))
            (sect g j (x j))).queries x : ℝ)) + Vs v := by
        simp only [DTree.queries, Nat.cast_add, Nat.cast_one]
        rw [Ex_add, Ex_const P hP1, one_mul]
      rw [hexp, hsplit]
      have hc : ∀ b, Ex P (upd P v j b)
          (fun x => ((ebuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).queries x : ℝ))
          ≤ Pot P ga gb (upd P v j b) (sect g j b) :=
        fun b => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
      have := Finset.sum_le_sum fun b (_ : b ∈ univ) => hc b
      have hg := hj.2.2
      unfold GoodE at hg
      linarith
    · rw [ebuild_neg P τ ga gb n A v g h]
      simp only [DTree.queries, Nat.cast_zero]
      rw [Ex_const P hP1, zero_mul]
      exact Pot_nonneg P hP0 hP1 ga gb hga hgb v hv g

include hP0 hP1 in
/-- **Leaf error** for the mixture tree. -/
theorem eleaf_error (hτ : 0 ≤ τ) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => if (ebuild P τ ga gb n A v g).bad x then 0
        else (g x - (ebuild P τ ga gb n A v g).eval x) ^ 2) ≤ τ * Vs v := by
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
      push Not at hlt
      exact hlt
  induction n with
  | zero => intro A v g hv; rw [ebuild_zero]; exact hleaf v g hv
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j
    · rw [ebuild_pos P τ ga gb n A v g h]
      set j := h.choose
      have hsplit := Ex_split P hP1 v j
        (fun c x => if (ebuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).bad x then 0
          else (sect g j c x - (ebuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).eval x) ^ 2)
        (fun c x b => by
          have hi := ebuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b
          simp only [hi.1, hi.2.1, inv_sect_self g j c x b])
      have hlhs : (fun x => if (DTree.node j fun c => ebuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).bad x then (0 : ℝ)
          else (g x - (DTree.node j fun c => ebuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).eval x) ^ 2) =
          (fun x => (fun c x => if (ebuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).bad x then 0 else (sect g j c x - (ebuild P τ ga gb n (insert j A)
              (upd P v j c) (sect g j c)).eval x) ^ 2) (x j) x) := by
        funext x
        simp only [DTree.bad, DTree.eval]
        congr 2
        rw [sect_self g j x]
      rw [hlhs, hsplit]
      calc ∑ b, Ex P (upd P v j b) (fun x => if (ebuild P τ ga gb n (insert j A)
              (upd P v j b) (sect g j b)).bad x then 0 else (sect g j b x -
                (ebuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).eval x) ^ 2)
          ≤ ∑ b, τ * Vs (upd P v j b) :=
            Finset.sum_le_sum fun b _ => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
        _ = τ * Vs v := by rw [← Finset.mul_sum, Vs_upd_sum P hP1]
    · rw [ebuild_neg P τ ga gb n A v g h]
      exact hleaf v g hv

/-- Unfinished leaves need the full fuel, given that any state in the invariant `S` with large
variance has a good query outside `A`. -/
theorem ebad_queries (S : Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → Prop)
    (hpres : ∀ A v g j b, S A v g → j ∉ A → S (insert j A) (upd P v j b) (sect g j b))
    (hgood : ∀ A v g, S A v g → τ * Vs v < mvar P v g → ∃ j, j ∉ A ∧ GoodE P ga gb v g j)
    (n : ℕ) : ∀ A v g, S A v g → ∀ x,
      (ebuild P τ ga gb n A v g).bad x = true → (ebuild P τ ga gb n A v g).queries x = n := by
  induction n with
  | zero => intro A v g _ x _; simp [ebuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g hS x hb
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodE P ga gb v g j
    · rw [ebuild_pos P τ ga gb n A v g h] at hb ⊢
      simp only [DTree.bad] at hb
      simp only [DTree.queries]
      rw [ih _ _ _ (hpres A v g _ _ hS h.choose_spec.1) x hb]
    · exfalso
      rw [ebuild_neg P τ ga gb n A v g h] at hb
      simp only [DTree.bad, decide_eq_true_eq] at hb
      obtain ⟨j, hjA, hj⟩ := hgood A v g hS hb
      exact h ⟨j, hjA, hb, hj⟩


end ETree

/-! ## A good query exists -/

/-- Invariant along the tree: the certified mixture-tree state plus the degree bound. -/
def StD (f : (ι → α) → ℝ) (K : ℝ) (d : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) : Prop :=
  St f K A v g ∧ HasProdDegreeLE g d

include hP0 in
theorem StD_pres (f : (ι → α) → ℝ) (K : ℝ) (d : ℕ) (A : Finset ι) (v : Θ → ℝ)
    (g : (ι → α) → ℝ) (j : ι) (b : α) (h : StD f K d A v g) (hj : j ∉ A) :
    StD f K d (insert j A) (upd P v j b) (sect g j b) :=
  ⟨St_pres P hP0 f K A v g j b h.1 hj, deg_sect h.2 j b⟩

omit [DecidableEq Θ] [Nonempty Θ] [Nonempty α] in
theorem Vs_pos_of_var (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ) (τ : ℝ)
    (h : τ * Vs v < mvar P v g) : 0 < Vs v := by
  have hV0 : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
  rcases hV0.eq_or_lt with h0 | hpos
  · exfalso
    have hz : ∀ θ, v θ = 0 := fun θ =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun θ _ => hv θ)).mp h0.symm θ (mem_univ θ)
    have : mvar P v g = 0 := by
      unfold mvar Ex; exact Finset.sum_eq_zero fun θ _ => by rw [hz θ, zero_mul]
    rw [← h0, mul_zero, this] at h; exact lt_irrefl 0 h
  · exact hpos

include hP0 hP1 in
/-- **Good query (polylog form).** -/
theorem good_exists_polylog (f : (ι → α) → ℝ) (d : ℕ) (hd : 1 ≤ d) (K : ℝ) (hK : 0 < K)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (hS : StD f K d A v g) (hvar : τ * Vs v < mvar P v g) :
    ∃ j, j ∉ A ∧ GoodE P (2 * gam d τ) (etaC d τ ^ 2 * w0C K d τ) v g j := by
  obtain ⟨⟨hv, hinv, hrows, _, hg01⟩, hdeg⟩ := hS
  have hV := Vs_pos_of_var P v hv g τ hvar
  have hγ := gam_pos d τ hτ
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hη : 0 < etaC d τ := by unfold etaC; positivity
  have hw : 0 < w0C K d τ := by unfold w0C; positivity
  set ga := 2 * gam d τ with hga
  set gb := etaC d τ ^ 2 * w0C K d τ with hgb
  have hga0 : 0 < ga := by positivity
  have hgb0 : 0 < gb := by positivity
  obtain ⟨j, hjA, hj⟩ := crux P hP0 hP1 v hv hV g hg01 d hd hdeg K hK hrows A hinv τ hτ hτ1 hvar
  refine ⟨j, hjA, ?_⟩
  unfold GoodE Pot
  rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.sum_div, Phi_sum P hP1 v g j]
  have hdrop := ent_drop_ge P hP0 hP1 v hv hV j
  have hinc0 : 0 ≤ ∑ θ, v θ * pincr (P θ) g j :=
    Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (pincr_nonneg (P θ) (hP0 θ) g j)
  have htv0 : 0 ≤ ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 :=
    Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
  rcases hj with hinc | hinfo
  · have h1 : (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga ≤ Phi P v g / ga - Vs v := by
      rw [sub_div]
      have : Vs v ≤ (∑ θ, v θ * pincr (P θ) g j) / ga := by rw [le_div_iff₀ hga0]; linarith
      linarith
    have h2 : (∑ b, Ent (upd P v j b)) / gb ≤ Ent v / gb :=
      div_le_div_of_nonneg_right (by linarith) hgb0.le
    linarith
  · have h1 : (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga ≤ Phi P v g / ga :=
      div_le_div_of_nonneg_right (by linarith) hga0.le
    have h2 : (∑ b, Ent (upd P v j b)) / gb ≤ Ent v / gb - Vs v := by
      have : (∑ b, Ent (upd P v j b)) ≤ Ent v - gb * Vs v := by rw [hgb]; linarith
      rw [le_sub_iff_add_le, div_add' _ _ _ hgb0.ne', div_le_div_iff_of_pos_right hgb0]
      linarith
    linarith

/-! ## The theorem -/

include hP0 hP1 in
/-- **Route 1: polylog-`M` classical simulation over mixtures of product laws.** Let
`ν = ∑_θ w_θ ⊗_i P θ i` be a mixture of `M = |Θ|` product laws on `ι → α` (any finite alphabet,
any masses, zeros allowed) and let `f` take values in `[0,1]` with interaction degree `≤ d`,
`d ≥ 1`. For `τ ∈ (0,1]`, `ε > 0`, `n ≥ 1` there is a decision tree making at most `n` queries on
every input with

  `Pr_ν[|f − tree| > ε] ≤ (K/(2γ) + log M / (η² w₀)) / n + τ/ε²`,

`K = π²d²/2`, `γ = gam d τ`, `η = γ/(512 d²)`, `w₀ = γ/(16K)`. Since `γ = poly(τ, 1/d)`, the
depth for error probability `δ` (take `τ = ε²δ/2`) is `poly(d, 1/ε, 1/δ) · (1 + log M)`. -/
theorem route1_polylog_simulation (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hd : 1 ≤ d)
    (hdeg : HasProdDegreeLE f d) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Ex P w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          Real.log (Fintype.card Θ) /
            (etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set K : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2 with hKdef
  have hK : 0 < K := by positivity
  have hγ := gam_pos d τ hτ
  set ga := 2 * gam d τ with hgadef
  set gb := etaC d τ ^ 2 * w0C K d τ with hgbdef
  have hga : 0 < ga := by positivity
  have hgb : 0 < gb := by
    have : 0 < etaC d τ := by unfold etaC; positivity
    have : 0 < w0C K d τ := by unfold w0C; positivity
    positivity
  set t := ebuild P τ ga gb n ∅ w f with htdef
  refine ⟨t, equeries_le P τ ga gb n ∅ w f, ?_⟩
  have hS0 : StD f K d ∅ w f :=
    ⟨⟨hw0, fun i hi => absurd hi (Finset.notMem_empty i), hasRows_of_degree f d hf01 hdeg,
      rep_empty f, hf01⟩, hdeg⟩
  have hbq := ebad_queries P τ ga gb (StD f K d)
    (fun A v g j b hS hj => StD_pres P hP0 f K d A v g j b hS hj)
    (fun A v g hS hvar => good_exists_polylog P hP0 hP1 f d hd K hK τ hτ hτ1 A v g hS hvar)
    n ∅ w f hS0
  have hq := eexpected P hP0 hP1 τ ga gb hga hgb n ∅ w f hw0
  have herr := eleaf_error P hP0 hP1 τ ga gb hτ.le n ∅ w f hw0
  have hVw : Vs w = 1 := hw1
  rw [hVw, mul_one] at herr
  have hε2 : 0 < ε ^ 2 := by positivity
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hpt : ∀ x, (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (t.queries x : ℝ) / n + (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    intro x
    by_cases hb : t.bad x = true
    · have hqn : (t.queries x : ℝ) = n := by exact_mod_cast hbq x hb
      rw [hqn, div_self hn'.ne']
      simp only [hb, ite_true, zero_div, add_zero]
      split_ifs <;> norm_num
    · simp only [hb, Bool.false_eq_true, ite_false]
      have hq0 : 0 ≤ (t.queries x : ℝ) / n := by positivity
      split_ifs with hlt
      · have h1 : ε ^ 2 < (f x - t.eval x) ^ 2 := by
          have := pow_lt_pow_left₀ hlt hε.le two_ne_zero; rwa [sq_abs] at this
        have : 1 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by rw [le_div_iff₀ hε2, one_mul]; exact h1.le
        linarith
      · have : 0 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by positivity
        linarith
  have hmono := Ex_mono P w hw0 hP0 _ _ hpt
  have hsplit : Ex P w (fun x => (t.queries x : ℝ) / n +
      (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2) =
      Ex P w (fun x => (t.queries x : ℝ)) / n +
        Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    rw [Ex_add]
    unfold Ex pexp
    congr 1
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
  rw [hsplit] at hmono
  have hPot : Pot P ga gb w f ≤ K / ga + Real.log (Fintype.card Θ) / gb := by
    unfold Pot
    have hPhi : Phi P w f ≤ K := by
      unfold Phi
      obtain ⟨a, hr, hKa⟩ := hasRows_of_degree f d hf01 hdeg
      calc ∑ θ, w θ * Ltot (P θ) f ≤ ∑ θ, w θ * K :=
            Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left
              (sum_pincr_le (P θ) (hP0 θ) (hP1 θ) f a hr K hKa) (hw0 θ)
        _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
    have h1 : Phi P w f / ga ≤ K / ga := div_le_div_of_nonneg_right hPhi hga.le
    have h2 : Ent w / gb ≤ Real.log (Fintype.card Θ) / gb :=
      div_le_div_of_nonneg_right (ent_le_log_card w hw0 hw1) hgb.le
    linarith
  have hfinal : Ex P w (fun x => (t.queries x : ℝ)) / n ≤
      (K / ga + Real.log (Fintype.card Θ) / gb) / n :=
    div_le_div_of_nonneg_right (hq.trans hPot) hn'.le
  have herr' : Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 ≤ τ / ε ^ 2 :=
    div_le_div_of_nonneg_right herr hε2.le
  linarith

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.crux
#print axioms Nightfall.Route1Polylog.route1_polylog_simulation
