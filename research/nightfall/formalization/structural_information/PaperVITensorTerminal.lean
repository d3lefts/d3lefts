import SynthesisTensorDistance
import SynthesisWynerEntropy

/-! Paper VI tensor-code specialization on the actual recursive row source.
The uniform observed law is the image of ALL linear functionals, with
no supplied cardinality, minimum distance, or entropy hypothesis. -/
set_option maxHeartbeats 4000000
set_option maxRecDepth 10000
namespace Nightfall.StructuralInformation.PaperVITensorTerminal
open Finset
open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeSharpness
open Nightfall.StructuralInformation.SynthesisTensorDistance
open Nightfall.SynthesisWynerEntropy
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Mixture

abbrev Row (n : ℕ) := {a : E n // a ∈ R n}
abbrev Dual (n : ℕ) := E n →ₗ[K] K

noncomputable def dualEquiv (n : ℕ) :
    (Fin (Module.finrank K (E n)) → K) ≃ Dual n :=
  ((Module.finBasis K (E n)).constr K).toEquiv

noncomputable local instance dualFintype (n : ℕ) : Fintype (Dual n) :=
  Fintype.ofEquiv _ (dualEquiv n)

theorem dual_card (n : ℕ) : Fintype.card (Dual n) = 2^(2^n) := by
  rw [← Fintype.card_congr (dualEquiv n), Fintype.card_fun,
    Fintype.card_fin, ZMod.card, finrank_E]

def bit (x : K) : Bool := decide (x ≠ 0)

theorem bit_injective : Function.Injective bit := by
  intro x y h
  fin_cases x <;> fin_cases y
  all_goals first | rfl | (exfalso; revert h; decide)

def evaluate (n : ℕ) (s : Dual n) : Row n → Bool :=
  fun a => bit (s a.1)

theorem row_card (n : ℕ) : Fintype.card (Row n) = 3^n := by
  rw [Fintype.card_coe, all_levels_cardinality]

theorem weight_is_distance (n : ℕ) (s t : Dual n) :
    (univ.filter fun a : Row n => evaluate n s a ≠ evaluate n t a).card =
      weight (R n) (s-t) := by
  classical
  let f : Row n ↪ E n := ⟨Subtype.val, Subtype.val_injective⟩
  have hmap : (univ.filter fun a : Row n => evaluate n s a ≠ evaluate n t a).map f =
      (R n).filter fun a => (s-t) a ≠ 0 := by
    ext a
    simp only [Finset.mem_map, Finset.mem_filter, Finset.mem_univ, true_and, f,
      Function.Embedding.coeFn_mk, LinearMap.sub_apply, sub_ne_zero]
    constructor
    · rintro ⟨u,hu,rfl⟩
      refine ⟨u.2,?_⟩
      intro h
      apply hu
      simp [evaluate,h]
    · rintro ⟨ha,h⟩
      refine ⟨⟨a,ha⟩,?_,rfl⟩
      intro he
      exact h (bit_injective he)
  unfold weight
  rw [← hmap,Finset.card_map]

theorem evaluate_injective (n : ℕ) : Function.Injective (evaluate n) := by
  intro s t h
  by_contra hn
  have hd := distance_lower n (s-t) (sub_ne_zero.mpr hn)
  rw [← weight_is_distance n s t,h] at hd
  simp at hd

noncomputable def code (n : ℕ) : Finset (Row n → Bool) := by
  classical
  exact univ.map ⟨evaluate n,evaluate_injective n⟩

theorem code_card (n : ℕ) : (code n).card = 2^(2^n) := by
  classical
  rw [code,Finset.card_map,Finset.card_univ,dual_card]

theorem code_nonempty (n : ℕ) : (code n).Nonempty := by
  apply Finset.card_pos.mp
  rw [code_card]
  positivity

theorem code_mem (n : ℕ) (x : Row n → Bool) :
    x ∈ code n ↔ ∃ s : Dual n, evaluate n s = x := by
  classical
  simp [code]

theorem code_distance (n : ℕ) (x y : Row n → Bool)
    (hx : x ∈ code n) (hy : y ∈ code n) (hne : x ≠ y) :
    2^n ≤ (univ.filter fun a => x a ≠ y a).card := by
  obtain ⟨s,rfl⟩ := (code_mem n x).mp hx
  obtain ⟨t,rfl⟩ := (code_mem n y).mp hy
  rw [weight_is_distance]
  exact distance_lower n (s-t) (sub_ne_zero.mpr (fun h => hne (congrArg (evaluate n) h)))

theorem code_exact_parameters (n : ℕ) :
    (Fintype.card (Row n) = 3^n) ∧ (code n).card = 2^(2^n) ∧
    (∀ x ∈ code n, ∀ y ∈ code n, x ≠ y →
      2^n ≤ (univ.filter fun a => x a ≠ y a).card) ∧
    (∃ x ∈ code n, ∃ y ∈ code n, x ≠ y ∧
      (univ.filter fun a => x a ≠ y a).card = 2^n) := by
  refine ⟨row_card n,code_card n,fun x hx y hy h => code_distance n x y hx hy h,?_⟩
  have hw := distance_witness n
  have hn : witness n ≠ 0 := by
    intro h
    rw [h,weight_zero] at hw
    exact (Nat.ne_of_gt (by positivity : 0 < 2^n)) hw.symm
  refine ⟨evaluate n (witness n), (code_mem _ _).mpr ⟨_,rfl⟩,
    evaluate n 0, (code_mem _ _).mpr ⟨_,rfl⟩,?_ ,?_⟩
  · exact fun h => hn (evaluate_injective n h)
  · rw [weight_is_distance,sub_zero,hw]

theorem wyner_nonneg {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1) :
    0 ≤ wynerGen ν := by
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
  have h := info_nonneg Q hQ0 hQ1 _ (∅ : Finset κ) w rfl hw0
  rwa [info_empty] at h

/-- The exact Paper VI uniform tensor entropy lower bound, on original
Boolean coordinates and arbitrary finite latent alphabets. -/
theorem tensor_entropy {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]
    (n b r : ℕ) (encode : (κ → α) → (Row n → Bool))
    (T : κ → Recovery (Row n) α) (L : Row n → Finset κ)
    (hL : ∀ i, (L i).card ≤ b)
    (hlocal : ∀ i z z', (∀ j ∈ L i, z j = z' j) → encode z i = encode z' i)
    (hdepth : ∀ j, (T j).depth ≤ r)
    (μ : (κ → α) → ℝ) (hμ0 : ∀ z, 0 ≤ μ z) (hμ1 : ∑ z, μ z = 1)
    (hsource : ∀ z, 0 < μ z → encode z ∈ code n)
    (hinv : ∀ z, 0 < μ z → ∀ j, (T j).eval (encode z) = z j)
    (huniform : ∀ x ∈ code n, (∑ z ∈ univ.filter (fun z => encode z = x), μ z)
      = 1 / ((code n).card : ℝ)) :
    max 0 ((2 : ℝ)^n-(b : ℝ)*r*(3/2 : ℝ)^n)*Real.log 2 ≤ wynerGen μ := by
  classical
  have h := uniform_code_wyner_obstruction (code n) (code_nonempty n)
    (2^n) b r (by positivity) encode T L hL hlocal hdepth
    (fun x hx y hy hne => code_distance n x y hx hy hne)
    μ hμ0 hμ1 hsource hinv huniform
  rw [code_card,row_card] at h
  push_cast at h
  rw [Real.log_pow] at h
  push_cast at h
  have he : (b : ℝ)*3^n*r/2^n = (b : ℝ)*r*(3/2 : ℝ)^n := by
    rw [div_pow]
    ring
  rw [he] at h
  have h0 := wyner_nonneg μ hμ0 hμ1
  have hlog : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  rw [max_mul_of_nonneg _ _ hlog, zero_mul]
  apply max_le h0
  linarith

theorem score_from_tensor_entropy (n b r : ℕ) (hn : 1 ≤ n) (hb : 1 ≤ b) (hr : 1 ≤ r)
    (C : ℝ) (hC : 0 ≤ C)
    (hinfo : max 0 ((2 : ℝ)^n-(b : ℝ)*r*(3/2 : ℝ)^n)*Real.log 2 ≤ C) :
    (4/3 : ℝ)^n ≤ (b : ℝ)*r*(1+C) := by
  have hbr : 1 ≤ (b : ℝ)*r := by
    have hb' : (1 : ℝ) ≤ b := by exact_mod_cast hb
    have hr' : (1 : ℝ) ≤ r := by exact_mod_cast hr
    nlinarith [mul_nonneg (sub_nonneg.mpr hb') (sub_nonneg.mpr hr')]
  have hlog : (2/3 : ℝ) ≤ Real.log 2 := by
    have h := Real.le_log_one_add_of_nonneg (x := 1) (by norm_num)
    norm_num at h
    exact h
  have hpow : (3/2 : ℝ) ≤ (3/2 : ℝ)^n := by
    obtain ⟨m,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : n ≠ 0)
    rw [pow_succ]
    have h : 1 ≤ (3/2 : ℝ)^m := one_le_pow₀ (by norm_num)
    nlinarith
  have hce : 1 ≤ (3/2 : ℝ)^n * Real.log 2 := by
    have h := mul_le_mul hpow hlog (by norm_num : (0 : ℝ) ≤ 2/3) (by positivity : (0 : ℝ) ≤ (3/2 : ℝ)^n)
    norm_num at h
    exact h
  have he : (3/2 : ℝ)^n * (4/3 : ℝ)^n = (2 : ℝ)^n := by
    rw [← mul_pow]
    norm_num
  have h := mul_le_mul_of_nonneg_right
    (le_max_right 0 ((2 : ℝ)^n-(b : ℝ)*r*(3/2 : ℝ)^n))
    (show 0 ≤ Real.log 2 from Real.log_nonneg (by norm_num))
  have hh : (3/2 : ℝ)^n*Real.log 2*((4/3 : ℝ)^n-(b : ℝ)*r) ≤ C := by
    calc
      _ = ((2 : ℝ)^n-(b : ℝ)*r*(3/2 : ℝ)^n)*Real.log 2 := by
        rw [← he]; ring
      _ ≤ C := h.trans hinfo
  exact score_lower _ _ _ _ _ hbr hC hce hh

/-- Full representation-score headline, with no supplied entropy or
distance premise. The only inputs are the actual query-local model. -/
theorem tensor_representation_score {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]
    (n b r : ℕ) (hn : 1 ≤ n) (hb : 1 ≤ b) (hr : 1 ≤ r)
    (encode : (κ → α) → (Row n → Bool)) (T : κ → Recovery (Row n) α)
    (L : Row n → Finset κ) (hL : ∀ i, (L i).card ≤ b)
    (hlocal : ∀ i z z', (∀ j ∈ L i, z j = z' j) → encode z i = encode z' i)
    (hdepth : ∀ j, (T j).depth ≤ r)
    (μ : (κ → α) → ℝ) (hμ0 : ∀ z, 0 ≤ μ z) (hμ1 : ∑ z, μ z = 1)
    (hsource : ∀ z, 0 < μ z → encode z ∈ code n)
    (hinv : ∀ z, 0 < μ z → ∀ j, (T j).eval (encode z) = z j)
    (huniform : ∀ x ∈ code n, (∑ z ∈ univ.filter (fun z => encode z = x), μ z)
      = 1 / ((code n).card : ℝ)) :
    (4/3 : ℝ)^n ≤ (b : ℝ)*r*(1+wynerGen μ) :=
  score_from_tensor_entropy n b r hn hb hr _ (wyner_nonneg μ hμ0 hμ1)
    (tensor_entropy n b r encode T L hL hlocal hdepth μ hμ0 hμ1 hsource hinv huniform)

#print axioms code_exact_parameters
#print axioms tensor_entropy
#print axioms tensor_representation_score
end Nightfall.StructuralInformation.PaperVITensorTerminal
