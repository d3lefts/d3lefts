import QuadraticWynerMeanIncrementProgress
import QuadraticWynerGoodQuery

/-!
Paper VI source-level posterior alternatives. The switching budget uses
the already compiled 128 d² mismatch lemma; constants are deliberately
weaker than the sharp written Markov-switching constants. The rates agree.
No free latent-coordinate queries. Not certified before exact-head replay.
-/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerSeedAverage
open Nightfall.QuadraticWynerSeedResampling
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.QuadraticWynerQ2SourceBridge
open Nightfall.QuadraticWynerMeanIncrementProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

noncomputable def stageEta (d : ℕ) (u : ℝ) : ℝ := u / (512 * (d : ℝ)^2)
noncomputable def stageW0 (K u : ℝ) : ℝ := u / (8*K)
noncomputable def stageGb (K : ℝ) (d : ℕ) (u : ℝ) : ℝ :=
  stageEta d u ^ 2 * stageW0 K u

theorem stageEta_pos (d : ℕ) (u : ℝ) (hd : 1 ≤ d) (hu : 0 < u) :
    0 < stageEta d u := by
  have hdR : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  unfold stageEta
  positivity

theorem stageDelta_budget (K : ℝ) (d : ℕ) (u : ℝ)
    (hK : 0 < K) (hd : 1 ≤ d) :
    2*K*stageW0 K u + 128*(d : ℝ)^2*stageEta d u = u/2 := by
  have hdR : (d : ℝ) ≠ 0 := by exact_mod_cast (show d ≠ 0 by omega)
  unfold stageW0 stageEta
  field_simp [hK.ne', hdR] <;> ring

/-- Either an actual unread information coordinate or a degree-preserving
projected seed with at least half the threshold variance. -/
theorem source_projection_or_information
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE g d)
    (K : ℝ) (hK : 0 < K) (hrows : HasRows g K)
    (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1 / 4)
    (hvar : τ * Vs v < mvar P v g) :
    (∃ (κ : ι → Seed α Θ → ℝ), SeedCoupling P (qmix P v) κ ∧
      τ / 2 < pvar κ (seedAverage (fun θ => v θ / Vs v) g)) ∨
    (∃ j : ι, j ∉ A ∧ stageGb K d τ * Vs v ≤
       ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2) := by
  classical
  set π : Θ → ℝ := fun θ => v θ / Vs v with hπdef
  have hπ0 : ∀ θ, 0 ≤ π θ := fun θ => div_nonneg (hv θ) hV.le
  have hπ1 : ∑ θ, π θ = 1 := by
    simp only [π]
    rw [← Finset.sum_div]
    exact div_self hV.ne'
  set q : ι → α → ℝ := qmix P v with hqdef
  obtain ⟨κ, hκ⟩ := seed_coupling_exists P hP0 hP1 q
    (fun j b => qmix_nonneg P hP0 v hv j b)
    (fun j => qmix_sum P hP1 v hV j)
  let r : ℝ := ∑ θ, π θ * pexp (P θ) g
  have hr : r = ∑ θ, π θ * pexp (P θ) g := rfl
  have hvareq :
      mvar P v g =
        Vs v * (∑ θ, π θ *
          pexp (P θ) (fun x => (g x - r) ^ 2)) := by
    simpa only [π, r] using mvar_eq P v hV g
  have hlarge : τ <
      ∑ θ, π θ * pexp (P θ) (fun x => (g x - r) ^ 2) := by
    by_contra hn
    have hle : (∑ θ, π θ *
      pexp (P θ) (fun x => (g x - r) ^ 2)) ≤ τ := le_of_not_gt hn
    have hm := mul_le_mul_of_nonneg_left hle hV.le
    rw [hvareq] at hvar
    nlinarith
  let η : ℝ := stageEta d τ
  let w₀ : ℝ := stageW0 K τ
  have hη0 : 0 < η := stageEta_pos d τ hd hτ
  have hηhalf : η ≤ 1 / 2 := by
    change τ / (512 * (d : ℝ) ^ 2) ≤ 1 / 2
    have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
    rw [div_le_iff₀ (by positivity)]
    nlinarith [hτmax]
  have hw0 : 0 ≤ w₀ := by
    dsimp [w₀, stageW0]
    positivity
  by_cases hbig : ∃ j : ι, j ∉ A ∧
      w₀ < ∑ θ, π θ * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)
  · obtain ⟨j, hjA, hjbig⟩ := hbig
    refine Or.inr ⟨j, hjA, ?_⟩
    have hpt : ∀ θ, π θ *
        (η ^ 2 * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) ≤
        π θ * tvd (P θ j) (q j) ^ 2 := by
      intro θ
      refine mul_le_mul_of_nonneg_left ?_ (hπ0 θ)
      split_ifs with h
      · nlinarith
      · simp
        exact sq_nonneg _
    have hsum :
        η ^ 2 * (∑ θ, π θ *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) ≤
        ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
      calc
        _ = ∑ θ, π θ * (η ^ 2 *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro θ _
            ring
        _ ≤ _ := Finset.sum_le_sum (fun θ _ => hpt θ)
    have hinformation : stageGb K d τ <
        ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
      change η ^ 2 * w₀ < _
      have hη2 : 0 < η ^ 2 := sq_pos_of_pos hη0
      exact (mul_lt_mul_of_pos_left hjbig hη2).trans_le hsum
    have heq :
        ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 =
          Vs v * (∑ θ, π θ * tvd (P θ j) (q j) ^ 2) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro θ _
      simp only [π, q]
      field_simp
    rw [heq]
    simpa only [mul_comm (stageGb K d τ) (Vs v)] using
      (mul_le_mul_of_nonneg_left hinformation.le hV.le)
  · have hsmall : ∀ j, j ∉ A →
        ∑ θ, π θ * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0) ≤ w₀ := by
      intro j hjA
      by_contra hn
      have hgt : w₀ < ∑ θ, π θ *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0) :=
        lt_of_not_ge hn
      exact hbig ⟨j, hjA, hgt⟩
    have hkey := key_lemma P q κ hκ π hπ0 hπ1
      g hg01 d hdeg K hrows A hinv η hη0 hηhalf w₀ hw0 hsmall
    have hbudget :
        2 * K * w₀ + 128 * (d : ℝ) ^ 2 * η = τ / 2 :=
      stageDelta_budget K d τ hK hd
    rw [hbudget] at hkey
    have hseed : τ / 2 < pvar κ (seedAverage π g) :=
      seed_average_variance_survival P q κ hκ π hπ1 g r τ hr hτ hlarge hkey
    exact Or.inl ⟨κ, hκ, hseed⟩

/-- Powered mean-increment dichotomy at every supported original posterior.
The first alternative is exactly the finite-source version of the
v^{3/2} increment mechanism (written without real fractional powers). -/
theorem mean_source_dichotomy
    (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE g d)
    (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1/4)
    (hvar : τ * Vs v < mvar P v g) :
    ∃ j : ι, j ∉ A ∧
      ((τ/2)^3 ≤ 144*(Real.pi^2*(d : ℝ)^2/2)^4 *
        (∑ θ, (v θ / Vs v) * pincr (P θ) g j)^2 ∨
       stageGb (Real.pi^2*(d : ℝ)^2/2) d τ * Vs v ≤
         ∑ θ, v θ * tvd (P θ j) (qmix P v j)^2) := by
  have hdR : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  let K : ℝ := Real.pi^2*(d : ℝ)^2/2
  have hK : 0 < K := by dsimp [K]; positivity
  have hrows : HasRows g K := hasRows_of_degree g d hg01 hdeg
  rcases source_projection_or_information P hP0 hP1 v hv hV g hg01 d hd hdeg
    K hK hrows A hinv τ hτ hτmax hvar with h | h
  · obtain ⟨κ, hκ, hs⟩ := h
    have hp0 : ∀ θ, 0 ≤ v θ / Vs v := fun θ => div_nonneg (hv θ) hV.le
    have hp1 : ∑ θ, v θ / Vs v = 1 := by
      rw [← Finset.sum_div]
      exact div_self hV.ne'
    obtain ⟨j, hj, hinc⟩ := mean_increment_original_source_energy
      P (qmix P v) κ hκ (fun θ => v θ / Vs v) hp0 hp1 g hg01 d hd hdeg A hinv τ hτ hs
    exact ⟨j, hj, Or.inl hinc⟩
  · obtain ⟨j, hj, hinfo⟩ := h
    exact ⟨j, hj, Or.inr hinfo⟩

/-- Squared influence alternative, retaining the actual original source
influence, rather than relaxing it to the absolute increment. -/
theorem quadratic_source_energy
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ) (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (hdeg : HasProdDegreeLE g 2) (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hvar : τ / 2 < pvar κ (seedAverage π g)) :
    ∃ j : ι, j ∉ A ∧ τ^2 / (4*quadraticC) ≤ ∑ θ, π θ * pinfl (P θ) g j := by
  classical
  have hC := quadraticC_pos
  let H : (ι → Seed α Θ) → ℝ := seedAverage π g
  let M : ℝ := τ^2/(4*quadraticC)
  have hM : 0 < M := by dsimp [M]; positivity
  have hdegree : HasProdDegreeLE H 2 := seed_average_degree π g 2 hdeg
  have hbound : ∀ u, 0 ≤ H u ∧ H u ≤ 1 := seed_average_bounded π hπ0 hπ1 g hg01
  have hex : ∃ j : ι, M < pinfl κ H j := by
    by_contra hn
    push_neg at hn
    have hQ := quadratic_product_influence_on_route1_source κ hκ.nonneg hκ.total H hbound hdegree M hM.le hn
    have hQ' : (pvar κ H)^2 ≤ quadraticC * M := by simpa only [quadraticC] using hQ
    have he : quadraticC * M = τ^2/4 := by dsimp [M]; field_simp
    rw [he] at hQ'
    have hpos : 0 < (pvar κ H - τ/2)*(pvar κ H + τ/2) := mul_pos (by linarith) (by linarith)
    nlinarith
  obtain ⟨j, hj⟩ := hex
  have hj' := seed_average_pinfl_le_original P q κ hκ π hπ0 hπ1 g j
  have hout : j ∉ A := by
    intro hm
    have hz : ∀ θ, pinfl (P θ) g j = 0 := fun θ => pinfl_inv (P θ) g j (hinv j hm)
    simp only [hz, mul_zero, Finset.sum_const_zero] at hj'
    linarith
  exact ⟨j, hout, hj.le.trans hj'⟩

/-- Quadratic squared-energy or information dichotomy, on the same source
as the general-degree alternative. -/
theorem quadratic_source_dichotomy
    (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (hdeg : HasProdDegreeLE g 2) (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1/4)
    (hvar : τ * Vs v < mvar P v g) :
    ∃ j : ι, j ∉ A ∧
      (τ^2/(4*quadraticC) ≤ ∑ θ, (v θ / Vs v) * pinfl (P θ) g j ∨
       stageGb (Real.pi^2*(2 : ℝ)^2/2) 2 τ * Vs v ≤
         ∑ θ, v θ * tvd (P θ j) (qmix P v j)^2) := by
  let K : ℝ := Real.pi^2*(2 : ℝ)^2/2
  have hK : 0 < K := by dsimp [K]; positivity
  have hrows : HasRows g K := by
    simpa only [Nat.cast_ofNat] using hasRows_of_degree g 2 hg01 hdeg
  rcases source_projection_or_information P hP0 hP1 v hv hV g hg01 2 (by decide) hdeg
    K hK hrows A hinv τ hτ hτmax hvar with h | h
  · obtain ⟨κ, hκ, hs⟩ := h
    have hp0 : ∀ θ, 0 ≤ v θ / Vs v := fun θ => div_nonneg (hv θ) hV.le
    have hp1 : ∑ θ, v θ / Vs v = 1 := by
      rw [← Finset.sum_div]
      exact div_self hV.ne'
    obtain ⟨j, hj, he⟩ := quadratic_source_energy P (qmix P v) κ hκ
      (fun θ => v θ / Vs v) hp0 hp1 g hg01 hdeg A hinv τ hτ hs
    exact ⟨j, hj, Or.inl he⟩
  · obtain ⟨j, hj, hi⟩ := h
    exact ⟨j, hj, Or.inr hi⟩

#print axioms Nightfall.PaperVI.source_projection_or_information
#print axioms Nightfall.PaperVI.mean_source_dichotomy
#print axioms Nightfall.PaperVI.quadratic_source_energy
#print axioms Nightfall.PaperVI.quadratic_source_dichotomy
end Nightfall.PaperVI
