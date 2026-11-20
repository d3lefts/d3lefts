import Route1Entropy
import Route1StarMaximalBridge

/-!
# Route 1: the Key Lemma (M-free fooling of the latent label)

Setting: components `P θ` (product laws on `ι → α`), posterior weights `π`, reference laws
`q j` (any laws; later the posterior mixture marginals), and a *seed coupling* `κ j` on
`U = α × (Θ → α)`: a seed `v` carries a reference letter `v.1` and one letter `v.2 θ` per component,
with component marginals `P θ j` and mismatch `Pr[v.2 θ ≠ v.1] ≤ tvd (P θ j) (q j)`.

For `g` with values in `[0,1]`, degree `≤ d`, rows of cost `≤ K`, and invariant in the coordinates
of `A`: if every `j ∉ A` has `∑_θ π_θ [tvd (P θ j) (q j) > η] ≤ w₀`, then

    ∑_θ π_θ E_u (g(ref u) − g(comp θ u))² ≤ 2 K w₀ + 128 d² η.            (`key_lemma`)

Large coordinates are charged deterministically through the row at the reference point; small ones
by `pair_fooling`. Existence of the seed coupling is `seed_coupling_exists` (finite maximal star
coupling, `Route1StarMaximalBridge.finite_star_maximal_exists`).
-/

namespace Nightfall.Route1Polylog

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ]

/-- Seed: a reference letter and one letter per component. -/
abbrev Seed (α Θ : Type) := α × (Θ → α)

/-- Product mass of a seed configuration. -/
noncomputable def seedMass (κ : ι → Seed α Θ → ℝ) (u : ι → Seed α Θ) : ℝ := ∏ j, κ j (u j)

def refOf (u : ι → Seed α Θ) : ι → α := fun j => (u j).1
def compOf (θ : Θ) (u : ι → Seed α Θ) : ι → α := fun j => (u j).2 θ

/-- Invariance in a set of coordinates. -/
theorem inv_set {g : (ι → α) → ℝ} : ∀ (A : Finset ι), (∀ i ∈ A, Inv g i) →
    ∀ x y : ι → α, (∀ i, i ∉ A → x i = y i) → g x = g y := by
  intro A
  induction A using Finset.induction_on with
  | empty =>
    intro _ x y h
    have : x = y := funext fun i => h i (Finset.notMem_empty i)
    rw [this]
  | insert a A ha ih =>
    intro hinv x y h
    have h1 : g (Function.update x a (y a)) = g x := hinv a (Finset.mem_insert_self a A) x (y a)
    rw [← h1]
    apply ih (fun i hi => hinv i (Finset.mem_insert_of_mem hi))
    intro i hi
    by_cases hia : i = a
    · subst hia; simp
    · rw [Function.update_of_ne hia]
      exact h i (fun hm => (Finset.mem_insert.mp hm).elim hia hi)

/-- Hypotheses on a seed coupling. -/
structure SeedCoupling (P : Θ → ι → α → ℝ) (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) : Prop where
  nonneg : ∀ j v, 0 ≤ κ j v
  total : ∀ j, ∑ v, κ j v = 1
  comp : ∀ j θ b, ∑ v ∈ univ.filter (fun v : Seed α Θ => v.2 θ = b), κ j v = P θ j b
  mis : ∀ j θ, ∑ v ∈ univ.filter (fun v : Seed α Θ => v.2 θ ≠ v.1), κ j v ≤ tvd (P θ j) (q j)

theorem seedMass_sum (κ : ι → Seed α Θ → ℝ) (h1 : ∀ j, ∑ v, κ j v = 1) :
    ∑ u : ι → Seed α Θ, seedMass κ u = 1 := by
  unfold seedMass
  have : ∑ u : ι → Seed α Θ, ∏ j, κ j (u j) = ∏ j, ∑ v, κ j v := by
    rw [Finset.prod_univ_sum, Fintype.piFinset_univ]
  rw [this]
  exact Finset.prod_eq_one fun j _ => h1 j

theorem seedMass_nonneg (κ : ι → Seed α Θ → ℝ) (h0 : ∀ j v, 0 ≤ κ j v) (u : ι → Seed α Θ) :
    0 ≤ seedMass κ u :=
  Finset.prod_nonneg fun j _ => h0 j (u j)

/-- Seed expectations of functions of one component are expectations under that component. -/
theorem seed_comp_pexp (P : Θ → ι → α → ℝ) (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ)
    (hκ : SeedCoupling P q κ) (θ : Θ) (F : (ι → α) → ℝ) :
    ∑ u, seedMass κ u * F (compOf θ u) = pexp (P θ) F := by
  unfold seedMass compOf pexp prodMass
  rw [sum_push κ (fun _ v => v.2 θ) F]
  refine Finset.sum_congr rfl fun x _ => ?_
  congr 1
  exact Finset.prod_congr rfl fun j _ => hκ.comp j θ (x j)

section Key

variable (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

/-- Pair map for the small part. -/
def pairMap (L A : Finset ι) (θ : Θ) (j : ι) (v : Seed α Θ) : α × α :=
  if j ∈ L then (v.2 θ, v.2 θ) else if j ∈ A then (v.1, v.1) else (v.1, v.2 θ)

/-- Small part: switching the small coordinates costs at most `64 d² η`. -/
theorem small_part (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1) (d : ℕ) (hdeg : HasProdDegreeLE g d)
    (A L : Finset ι) (θ : Θ) (η : ℝ) (hη0 : 0 < η) (hη1 : η ≤ 1 / 2)
    (hsmall : ∀ j, j ∉ L → j ∉ A → tvd (P θ j) (q j) ≤ η) :
    ∑ u, seedMass κ u * pairSq g (fun j => pairMap L A θ j (u j)) ≤ 64 * (d : ℝ) ^ 2 * η := by
  classical
  let ρ : ι → α × α → ℝ := fun j c =>
    ∑ v ∈ univ.filter (fun v : Seed α Θ => pairMap L A θ j v = c), κ j v
  have hpush : ∑ u, seedMass κ u * pairSq g (fun j => pairMap L A θ j (u j)) = pexp ρ (pairSq g) := by
    unfold seedMass pexp prodMass
    rw [sum_push κ (fun j v => pairMap L A θ j v) (pairSq g)]
  have hρ0 : ∀ j c, 0 ≤ ρ j c := fun j c => Finset.sum_nonneg fun v _ => hκ.nonneg j v
  have hρ1 : ∀ j, ∑ c, ρ j c = 1 := fun j => by
    simp only [ρ]
    rw [Finset.sum_fiberwise univ (fun v => pairMap L A θ j v) (κ j)]
    exact hκ.total j
  have hmis : ∀ j, pairMismatch (ρ j) ≤ η := by
    intro j
    unfold pairMismatch
    have hfib : ∑ c : α × α, (if c.1 = c.2 then 0 else ρ j c) =
        ∑ v, (if (pairMap L A θ j v).1 = (pairMap L A θ j v).2 then 0 else κ j v) := by
      simp only [ρ]
      rw [← Finset.sum_fiberwise univ (fun v => pairMap L A θ j v)
        (fun v => if (pairMap L A θ j v).1 = (pairMap L A θ j v).2 then 0 else κ j v)]
      refine Finset.sum_congr rfl fun c _ => ?_
      split_ifs with hc
      · refine (Finset.sum_eq_zero fun v hv => ?_).symm
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
        rw [hv]; simp [hc]
      · refine Finset.sum_congr rfl fun v hv => ?_
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
        rw [hv]; simp [hc]
    rw [hfib]
    by_cases hjL : j ∈ L
    · simp [pairMap, hjL]; exact hη0.le
    · by_cases hjA : j ∈ A
      · simp [pairMap, hjL, hjA]; exact hη0.le
      · have hm := hκ.mis j θ
        rw [Finset.sum_filter] at hm
        have : ∑ v, (if (pairMap L A θ j v).1 = (pairMap L A θ j v).2 then 0 else κ j v) =
            ∑ v, (if v.2 θ ≠ v.1 then κ j v else 0) := by
          refine Finset.sum_congr rfl fun v _ => ?_
          simp only [pairMap, hjL, hjA, if_false]
          by_cases h : v.1 = v.2 θ
          · simp [h]
          · simp [h, Ne.symm h]
        rw [this]
        exact hm.trans (hsmall j hjL hjA)
  rw [hpush]
  exact pair_fooling ρ hρ0 hρ1 g hg01 d hdeg η hη0 hη1 hmis

/-- **Key Lemma** (squared form). -/
theorem key_lemma (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ) (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1) (d : ℕ) (hdeg : HasProdDegreeLE g d)
    (K : ℝ) (hrows : HasRows g K) (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (η : ℝ) (hη0 : 0 < η) (hη1 : η ≤ 1 / 2) (w₀ : ℝ) (hw0 : 0 ≤ w₀)
    (hw : ∀ j, j ∉ A → ∑ θ, π θ * (if η < tvd (P θ j) (q j) then 1 else 0) ≤ w₀) :
    ∑ θ, π θ * ∑ u, seedMass κ u * (g (refOf u) - g (compOf θ u)) ^ 2 ≤
      2 * K * w₀ + 128 * (d : ℝ) ^ 2 * η := by
  classical
  obtain ⟨a, ⟨ha0, hacov⟩, hK⟩ := id hrows
  let L : Θ → Finset ι := fun θ => univ.filter (fun j => j ∉ A ∧ η < tvd (P θ j) (q j))
  let z : Θ → (ι → Seed α Θ) → ι → α := fun θ u j => (pairMap (L θ) A θ j (u j)).1
  let y' : Θ → (ι → Seed α Θ) → ι → α := fun θ u j => (pairMap (L θ) A θ j (u j)).2
  have hy' : ∀ θ u, g (compOf θ u) = g (y' θ u) := by
    intro θ u
    apply inv_set A hinv
    intro i hi
    simp only [compOf, y', pairMap]
    split_ifs with h1 h2 <;> first | rfl | exact absurd h2 hi
  have hz : ∀ θ u j, j ∉ L θ → z θ u j = refOf u j := by
    intro θ u j hj
    simp only [z, pairMap, hj, if_false, refOf]
    split_ifs <;> rfl
  have hsplit : ∀ θ u, (g (refOf u) - g (compOf θ u)) ^ 2 ≤
      2 * (g (refOf u) - g (z θ u)) ^ 2 + 2 * pairSq g (fun j => pairMap (L θ) A θ j (u j)) := by
    intro θ u
    rw [hy']
    unfold pairSq
    nlinarith [sq_nonneg (g (refOf u) - 2 * g (z θ u) + g (y' θ u))]
  -- large part, pointwise in `u`
  have hlarge : ∀ u, ∑ θ, π θ * (g (refOf u) - g (z θ u)) ^ 2 ≤ K * w₀ := by
    intro u
    have hterm : ∀ θ, (g (refOf u) - g (z θ u)) ^ 2 ≤ ∑ i ∈ L θ, a (refOf u) i := by
      intro θ
      have hb : |g (refOf u) - g (z θ u)| ≤ 1 := by
        have := hg01 (refOf u); have := hg01 (z θ u); rw [abs_le]; constructor <;> linarith
      have hsq : (g (refOf u) - g (z θ u)) ^ 2 ≤ |g (refOf u) - g (z θ u)| := by
        rw [← sq_abs]; nlinarith [abs_nonneg (g (refOf u) - g (z θ u))]
      refine hsq.trans ((hacov _ _).trans (Finset.sum_le_sum_of_subset_of_nonneg ?_
        fun i _ _ => ha0 _ i))
      intro i hi
      simp only [Nightfall.ProductSpace.Transfer.disagree, Finset.mem_filter, Finset.mem_univ,
        true_and] at hi
      by_contra hni
      exact hi (hz θ u i hni).symm
    have hfreq : ∀ i, ∑ θ, π θ * (if i ∈ L θ then (1 : ℝ) else 0) ≤ w₀ := by
      intro i
      by_cases hiA : i ∈ A
      · have : ∀ θ, (if i ∈ L θ then (1 : ℝ) else 0) = 0 := fun θ => by simp [L, hiA]
        simp only [this, mul_zero, Finset.sum_const_zero]; exact hw0
      · refine le_trans (le_of_eq (Finset.sum_congr rfl fun θ _ => ?_)) (hw i hiA)
        simp [L, hiA]
    calc ∑ θ, π θ * (g (refOf u) - g (z θ u)) ^ 2
        ≤ ∑ θ, π θ * ∑ i ∈ L θ, a (refOf u) i :=
          Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (hterm θ) (hπ0 θ)
      _ = ∑ i, a (refOf u) i * ∑ θ, π θ * (if i ∈ L θ then 1 else 0) := by
          have : ∀ θ, π θ * ∑ i ∈ L θ, a (refOf u) i =
              ∑ i, π θ * (if i ∈ L θ then 1 else 0) * a (refOf u) i := by
            intro θ
            rw [Finset.mul_sum, ← Finset.sum_filter_add_sum_filter_not univ (fun i => i ∈ L θ)]
            rw [Finset.filter_mem_eq_inter, Finset.univ_inter]
            have h0 : ∑ i ∈ univ.filter (fun i => i ∉ L θ),
                π θ * (if i ∈ L θ then (1 : ℝ) else 0) * a (refOf u) i = 0 :=
              Finset.sum_eq_zero fun i hi => by
                simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi; simp [hi]
            rw [h0, add_zero]
            exact Finset.sum_congr rfl fun i hi => by simp [hi]
          rw [Finset.sum_congr rfl fun θ _ => this θ, Finset.sum_comm]
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun θ _ => by ring
      _ ≤ ∑ i, a (refOf u) i * w₀ :=
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hfreq i) (ha0 _ i)
      _ = (∑ i, a (refOf u) i) * w₀ := by rw [Finset.sum_mul]
      _ ≤ K * w₀ := mul_le_mul_of_nonneg_right (hK _) hw0
  have hsm : ∀ θ, ∑ u, seedMass κ u * pairSq g (fun j => pairMap (L θ) A θ j (u j)) ≤
      64 * (d : ℝ) ^ 2 * η := by
    intro θ
    refine small_part P q κ hκ g hg01 d hdeg A (L θ) θ η hη0 hη1 fun j hjL hjA => ?_
    by_contra hlt
    push_neg at hlt
    exact hjL (by simp [L, hjA, hlt])
  have hm0 := seedMass_nonneg κ hκ.nonneg
  calc ∑ θ, π θ * ∑ u, seedMass κ u * (g (refOf u) - g (compOf θ u)) ^ 2
      ≤ ∑ θ, π θ * ∑ u, seedMass κ u * (2 * (g (refOf u) - g (z θ u)) ^ 2 +
          2 * pairSq g (fun j => pairMap (L θ) A θ j (u j))) :=
        Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun u _ =>
          mul_le_mul_of_nonneg_left (hsplit θ u) (hm0 u)) (hπ0 θ)
    _ = 2 * ∑ u, seedMass κ u * ∑ θ, π θ * (g (refOf u) - g (z θ u)) ^ 2 +
          2 * ∑ θ, π θ * ∑ u, seedMass κ u * pairSq g (fun j => pairMap (L θ) A θ j (u j)) := by
        simp only [mul_add, Finset.sum_add_distrib, Finset.mul_sum]
        congr 1
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun θ _ => by ring
        exact Finset.sum_congr rfl fun θ _ => Finset.sum_congr rfl fun u _ => by ring
    _ ≤ 2 * ∑ u, seedMass κ u * (K * w₀) + 2 * ∑ θ, π θ * (64 * (d : ℝ) ^ 2 * η) := by
        gcongr with u _ θ _
        · exact hm0 u
        · exact hlarge u
        · exact hπ0 θ
        · exact hsm θ
    _ = 2 * K * w₀ + 128 * (d : ℝ) ^ 2 * η := by
        rw [← Finset.sum_mul, ← Finset.sum_mul, seedMass_sum κ hκ.total, hπ1]; ring

end Key

end Nightfall.Route1Polylog
