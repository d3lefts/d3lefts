import PaperVIStageBudget
import Route1WynerGeneral

/-!
Source-level linearized charge. The constants use the archived
kernel-compatible switching lemma rather than the sharper manuscript
coefficient, but preserve d^6 τ^(-3/2), d^6 C_W τ^(-3), and the staged
quadratic τ^(-1) energy dependence.
-/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

noncomputable def rowK (d : ℕ) : ℝ := Real.pi^2*(d : ℝ)^2/2
noncomputable def meanWeight (d : ℕ) (u : ℝ) : ℝ := 96*(rowK d)^2/Real.sqrt u
noncomputable def infoWeight (d : ℕ) (u : ℝ) : ℝ := (2^24 : ℝ)*rowK d*(d : ℝ)^4/u^2
noncomputable def quadWeight (u : ℝ) : ℝ := 16*quadraticC/u

theorem rowK_pos (d : ℕ) (hd : 1 ≤ d) : 0 < rowK d := by
  have hdR : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  unfold rowK
  positivity

theorem weighted_normalize (v : Θ → ℝ) (hV : 0 < Vs v) (L : Θ → ℝ) :
    (∑ θ, (v θ / Vs v)*L θ)*Vs v = ∑ θ, v θ*L θ := by
  rw [Finset.sum_mul]
  exact Finset.sum_congr rfl fun θ _ => by field_simp [hV.ne']

theorem info_linear_charge (K : ℝ) (d : ℕ) (u R V T : ℝ)
    (hK : 0 < K) (hd : 1 ≤ d) (hu : 0 < u) (hR : u < R) (hV : 0 < V)
    (hinfo : stageGb K d (R/2)*V ≤ T) :
    R*V ≤ ((2^24 : ℝ)*K*(d : ℝ)^4/u^2)*T := by
  have hdR : (0 : ℝ) < d := by exact_mod_cast (show 0 < d by omega)
  let C : ℝ := (2^24 : ℝ)*K*(d : ℝ)^4
  have hC : 0 < C := by dsimp [C]; positivity
  have he : stageGb K d (R/2) = R^3/C := by
    unfold stageGb stageEta stageW0 C
    field_simp [hK.ne', hdR.ne'] <;> ring
  rw [he] at hinfo
  have hpow : u^2 ≤ R^2 := pow_le_pow_left₀ hu.le hR.le 2
  have h1 : u^2*R*V ≤ R^3*V := by
    have h := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hpow (lt_trans hu hR).le) hV.le
    nlinarith only [h]
  have h2 : R^3*V ≤ C*T := by
    rw [div_mul_eq_mul_div, div_le_iff₀ hC] at hinfo
    simpa [mul_comm] using hinfo
  change R*V ≤ C/u^2*T
  rw [div_mul_eq_mul_div, le_div_iff₀ (sq_pos_of_pos hu)]
  nlinarith only [h1,h2]

theorem mean_linear_charge (K u R L : ℝ)
    (hK : 0 < K) (hu : 0 < u) (hR : u < R) (hL : 0 ≤ L)
    (hpow : ((R/2)/2)^3 ≤ 144*K^4*L^2) :
    R ≤ (96*K^2/Real.sqrt u)*L := by
  have hs : 0 < Real.sqrt u := Real.sqrt_pos.mpr hu
  have hr : 0 < R := lt_trans hu hR
  have hp : (Real.sqrt u*R)^2 ≤ (96*K^2*L)^2 := by
    rw [mul_pow, Real.sq_sqrt hu.le]
    have h := mul_le_mul_of_nonneg_right hR.le (sq_nonneg R)
    nlinarith only [h,hpow]
  have h : Real.sqrt u*R ≤ 96*K^2*L := by
    by_contra! hn
    have hp' : 0 < (Real.sqrt u*R - 96*K^2*L)*(Real.sqrt u*R + 96*K^2*L) :=
      mul_pos (sub_pos.mpr hn) (add_pos_of_pos_of_nonneg (mul_pos hs hr) (by positivity))
    nlinarith only [hp,hp']
  rw [div_mul_eq_mul_div, le_div_iff₀ hs]
  simpa [mul_comm] using h

theorem quadratic_linear_charge (u R L : ℝ) (hu : 0 < u) (hR : u < R)
    (hpow : (R/2)^2/(4*quadraticC) ≤ L) :
    R ≤ quadWeight u*L := by
  have hC := quadraticC_pos
  have hr : 0 < R := lt_trans hu hR
  rw [div_le_iff₀ (by positivity : 0 < 4*quadraticC)] at hpow
  unfold quadWeight
  rw [div_mul_eq_mul_div, le_div_iff₀ hu]
  have h := mul_le_mul_of_nonneg_right hR.le hr.le
  nlinarith only [h,hpow]

noncomputable def scaledCost (P : Θ → ι → α → ℝ)
    (F : Posterior ι α Θ → ℝ) (a b : ℝ) (s : Posterior ι α Θ) : ℝ :=
  a*F s + b*entropyCost P s

theorem cost_children (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (s : Posterior ι α Θ) (hv : ∀ θ, 0 ≤ s.weight θ) (hV : 0 < mass s)
    (j : ι) (hj : j ∉ s.read)
    (F : Posterior ι α Θ → ℝ) (D a b : ℝ)
    (hF : ∑ c, F (child P s j c) = F s-D) :
    ∑ c, scaledCost P F a b (child P s j c) =
      scaledCost P F a b s - a*D -
        b*(∑ θ, s.weight θ*kl (P θ j) (qmix P s.weight j)) := by
  have hJ : ∑ c, entropyCost P (child P s j c) =
      entropyCost P s - ∑ θ, s.weight θ*kl (P θ j) (qmix P s.weight j) :=
    info_chain P hP0 hP1 s.read j hj s.weight hv hV
  unfold scaledCost
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hF, hJ]
  ring

theorem source_mean_charge (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (f : (ι → α) → ℝ) (d : ℕ) (hd : 1 ≤ d) (u : ℝ) (hu : 0 < u)
    (s : Posterior ι α Θ) (hs : StD f (rowK d) d s.read s.weight s.target)
    (hlarge : u*mass s < risk P s) :
    ∃ j, j ∉ s.read ∧ risk P s + (∑ c,
      scaledCost P (incrementCost P) (meanWeight d u) (infoWeight d u) (child P s j c))
      ≤ scaledCost P (incrementCost P) (meanWeight d u) (infoWeight d u) s := by
  obtain ⟨⟨hv,hinv,_,_,hg⟩,hdeg⟩ := hs
  have hV : 0 < Vs s.weight := Vs_pos_of_var P s.weight hv s.target u hlarge
  let R := risk P s / mass s
  have hR : u < R := (lt_div_iff₀ hV).mpr hlarge
  have hRmax : R ≤ 1/4 := (div_le_iff₀ hV).mpr (mvar_le_quarter_mass P hP0 hP1 s.weight hv s.target hg)
  have hRpos := lt_trans hu hR
  have hK := rowK_pos d hd
  have hRV : R*mass s = risk P s := by dsimp [R]; field_simp [show mass s ≠ 0 from hV.ne']
  have hvar : (R/2)*Vs s.weight < mvar P s.weight s.target := by
    have h := mul_pos hRpos hV
    change (R/2)*mass s < risk P s
    nlinarith only [h,hRV]
  obtain ⟨j,hj,halt⟩ := mean_source_dichotomy P hP0 hP1 s.weight hv hV s.target hg
    d hd hdeg s.read hinv (R/2) (by positivity) (by linarith) hvar
  let D := ∑ θ, s.weight θ*pincr (P θ) s.target j
  let L := ∑ θ, (s.weight θ/Vs s.weight)*pincr (P θ) s.target j
  let T := ∑ θ, s.weight θ*tvd (P θ j) (qmix P s.weight j)^2
  let Q := ∑ θ, s.weight θ*kl (P θ j) (qmix P s.weight j)
  have hD0 : 0 ≤ D := Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (pincr_nonneg (P θ) (hP0 θ) s.target j)
  have hL0 : 0 ≤ L := Finset.sum_nonneg fun θ _ => mul_nonneg (div_nonneg (hv θ) hV.le) (pincr_nonneg (P θ) (hP0 θ) s.target j)
  have hT0 : 0 ≤ T := Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
  have hTQ : T ≤ Q := kl_sum_ge P hP0 hP1 s.weight hv hV j
  have hQ0 := hT0.trans hTQ
  have ha : 0 ≤ meanWeight d u := by unfold meanWeight; positivity
  have hb : 0 ≤ infoWeight d u := by
    unfold infoWeight
    positivity
  have hnorm : L*mass s = D := weighted_normalize s.weight hV _
  have hcost : ∑ c, incrementCost P (child P s j c) = incrementCost P s - D :=
    Phi_sum P hP1 s.weight s.target j
  have hsplit := cost_children P hP0 hP1 s hv hV j hj (incrementCost P)
    D (meanWeight d u) (infoWeight d u) hcost
  refine ⟨j,hj,?_⟩
  rw [hsplit]
  rcases halt with he | hi
  · have he' : ((R/2)/2)^3 ≤ 144*(rowK d)^4*L^2 := he
    have hh := mean_linear_charge (rowK d) u R L hK hu hR hL0 he'
    have hh' := mul_le_mul_of_nonneg_right hh hV.le
    change R*mass s ≤ (meanWeight d u*L)*mass s at hh'
    have hrewrite : (meanWeight d u*L)*mass s = meanWeight d u*D := by rw [mul_assoc,hnorm]
    rw [hRV,hrewrite] at hh'
    have hnon := mul_nonneg hb hQ0
    change risk P s + (scaledCost P (incrementCost P) (meanWeight d u) (infoWeight d u) s -
      meanWeight d u*D - infoWeight d u*Q) ≤ _ 
    linarith
  · have hh : R*mass s ≤ infoWeight d u*T :=
      info_linear_charge (rowK d) d u R (mass s) T hK hd hu hR hV hi
    rw [hRV] at hh
    have hh' := mul_le_mul_of_nonneg_left hTQ hb
    have hnon := mul_nonneg ha hD0
    change risk P s + (scaledCost P (incrementCost P) (meanWeight d u) (infoWeight d u) s -
      meanWeight d u*D - infoWeight d u*Q) ≤ _
    linarith

theorem source_quad_charge (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (f : (ι → α) → ℝ) (u : ℝ) (hu : 0 < u)
    (s : Posterior ι α Θ) (hs : StD f (rowK 2) 2 s.read s.weight s.target)
    (hlarge : u*mass s < risk P s) :
    ∃ j, j ∉ s.read ∧ risk P s + (∑ c,
      scaledCost P (energyCost P) (quadWeight u) (infoWeight 2 u) (child P s j c))
      ≤ scaledCost P (energyCost P) (quadWeight u) (infoWeight 2 u) s := by
  obtain ⟨⟨hv,hinv,_,_,hg⟩,hdeg⟩ := hs
  have hV : 0 < Vs s.weight := Vs_pos_of_var P s.weight hv s.target u hlarge
  let R := risk P s / mass s
  have hR : u < R := (lt_div_iff₀ hV).mpr hlarge
  have hRmax : R ≤ 1/4 := (div_le_iff₀ hV).mpr (mvar_le_quarter_mass P hP0 hP1 s.weight hv s.target hg)
  have hRpos := lt_trans hu hR
  have hK := rowK_pos 2 (by decide)
  have hRV : R*mass s = risk P s := by dsimp [R]; field_simp [show mass s ≠ 0 from hV.ne']
  have hvar : (R/2)*Vs s.weight < mvar P s.weight s.target := by
    have h := mul_pos hRpos hV
    change (R/2)*mass s < risk P s
    nlinarith only [h,hRV]
  obtain ⟨j,hj,halt⟩ := quadratic_source_dichotomy P hP0 hP1 s.weight hv hV s.target hg
    hdeg s.read hinv (R/2) (by positivity) (by linarith) hvar
  let D := ∑ θ, s.weight θ*pinfl (P θ) s.target j
  let L := ∑ θ, (s.weight θ/Vs s.weight)*pinfl (P θ) s.target j
  let T := ∑ θ, s.weight θ*tvd (P θ j) (qmix P s.weight j)^2
  let Q := ∑ θ, s.weight θ*kl (P θ j) (qmix P s.weight j)
  have hD0 : 0 ≤ D := Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (pinfl_nonneg (P θ) (hP0 θ) s.target j)
  have hT0 : 0 ≤ T := Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
  have hTQ : T ≤ Q := kl_sum_ge P hP0 hP1 s.weight hv hV j
  have hQ0 := hT0.trans hTQ
  have ha : 0 ≤ quadWeight u := by unfold quadWeight; have := quadraticC_pos; positivity
  have hb : 0 ≤ infoWeight 2 u := by unfold infoWeight; positivity
  have hnorm : L*mass s = D := weighted_normalize s.weight hV _
  have hcost : ∑ c, energyCost P (child P s j c) = energyCost P s - D :=
    Phi2_sum P hP1 s.weight s.target j
  have hsplit := cost_children P hP0 hP1 s hv hV j hj (energyCost P)
    D (quadWeight u) (infoWeight 2 u) hcost
  refine ⟨j,hj,?_⟩
  rw [hsplit]
  rcases halt with he | hi
  · have hh := quadratic_linear_charge u R L hu hR he
    have hh' := mul_le_mul_of_nonneg_right hh hV.le
    change R*mass s ≤ (quadWeight u*L)*mass s at hh'
    rw [mul_assoc,hnorm,hRV] at hh'
    have hnon := mul_nonneg hb hQ0
    change risk P s + (scaledCost P (energyCost P) (quadWeight u) (infoWeight 2 u) s -
      quadWeight u*D - infoWeight 2 u*Q) ≤ _
    linarith
  · have hi' : stageGb (rowK 2) 2 (R/2)*mass s ≤ T := by
      simpa only [rowK, Nat.cast_ofNat] using hi
    have hh : R*mass s ≤ infoWeight 2 u*T :=
      info_linear_charge (rowK 2) 2 u R (mass s) T hK (by decide) hu hR hV hi'
    rw [hRV] at hh
    have hh' := mul_le_mul_of_nonneg_left hTQ hb
    have hnon := mul_nonneg ha hD0
    change risk P s + (scaledCost P (energyCost P) (quadWeight u) (infoWeight 2 u) s -
      quadWeight u*D - infoWeight 2 u*Q) ≤ _
    linarith

#print axioms Nightfall.PaperVI.mean_linear_charge
#print axioms Nightfall.PaperVI.info_linear_charge
#print axioms Nightfall.PaperVI.quadratic_linear_charge
#print axioms Nightfall.PaperVI.source_mean_charge
#print axioms Nightfall.PaperVI.source_quad_charge
end Nightfall.PaperVI
