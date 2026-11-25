import PaperVIMSETerminal

/-!
Paper VI: lift both actual mixture MSE terminals to the existing
general-latent Wyner infimum. No alternative definition of common
information; no externally supplied good-query condition.
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

theorem mean_mse_general
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (u : ℝ) (hu : 0 < u) (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ u +
        (meanWeight d u*rowK d+infoWeight d u*s)/n := by
  rw [← wynerCI_eq_wynerGen] at hs
  obtain ⟨s0, ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩,hlt⟩ :=
    exists_lt_of_csInf_lt (wynerSet_nonempty ν hν0 hν1) hs
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
  obtain ⟨t,ht,herr⟩ := mean_mse_mixture Q hQ0 hQ1 w hw0 hw1 f hf d hd hdeg u hu n hn
  have hEx : Ex Q w (fun x => (f x-t.eval x)^2) = ∑ x, ν x*(f x-t.eval x)^2 := by
    unfold Ex pexp
    simp only [hν,Finset.mul_sum,Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun θ _ => by ring
  rw [hEx] at herr
  refine ⟨t,ht,herr.trans ?_⟩
  have hb : 0 ≤ infoWeight d u := by unfold infoWeight rowK; positivity
  have hnR : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  have hcharge := mul_le_mul_of_nonneg_left hlt.le hb
  have hsum : meanWeight d u*rowK d + infoWeight d u*mutInfo Q w ≤
      meanWeight d u*rowK d + infoWeight d u*s := by linarith only [hcharge]
  have hdiv := div_le_div_of_nonneg_right hsum hnR
  linarith only [hdiv]

/-- Main general-degree MSE terminal, target tolerance τ. The displayed
coefficient is explicit and has exactly the d^6, τ^(-3/2) and
d^6 C_W τ^(-3) orders of Paper VI. -/
theorem paper_vi_general_mse
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (s : ℝ) (hs : wynerGen ν < s)
    (n : ℕ) (hn : 0 < n)
    (hbudget : meanWeight d (τ/2)*rowK d + infoWeight d (τ/2)*s ≤ (n : ℝ)*(τ/2)) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  obtain ⟨t,ht,herr⟩ := mean_mse_general ν hν0 hν1 f hf d hd hdeg
    (τ/2) (by positivity) n hn s hs
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdiv : (meanWeight d (τ/2)*rowK d+infoWeight d (τ/2)*s)/n ≤ τ/2 := by
    rw [div_le_iff₀ hnR]
    simpa [mul_comm] using hbudget
  exact ⟨t,ht,by linarith⟩

theorem quadratic_mse_general_dyadic
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2) (s : ℝ) (hs : wynerGen ν < s)
    (A B : ℝ) (hA0 : 0 ≤ A) (hB0 : 0 ≤ B) (hA : 2048*quadraticC ≤ A)
    (hB : (2^40 : ℝ)*rowK 2*s ≤ B) (N : ℕ) :
    ∃ t : DTree ι α, (∀ x, (t.queries x : ℝ) ≤ 2*N+A*2^N+B*8^N) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ dyadicRisk N := by
  rw [← wynerCI_eq_wynerGen] at hs
  obtain ⟨s0, ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩,hlt⟩ :=
    exists_lt_of_csInf_lt (wynerSet_nonempty ν hν0 hν1) hs
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
  obtain ⟨t,ht,herr⟩ := quadratic_mse_mixture_dyadic Q hQ0 hQ1 w hw0 hw1 f hf hdeg
    s hlt.le A B hA0 hB0 hA hB N
  have hEx : Ex Q w (fun x => (f x-t.eval x)^2) = ∑ x, ν x*(f x-t.eval x)^2 := by
    unfold Ex pexp
    simp only [hν,Finset.mul_sum,Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun θ _ => by ring
  rw [hEx] at herr
  exact ⟨t,ht,herr⟩

theorem two_pow_ge_succ (N : ℕ) : N+1 ≤ 2^N := by
  induction N with
  | zero => norm_num
  | succ n ih =>
    rw [pow_succ]
    omega

theorem dyadic_exists (τ : ℝ) (hτ : 0 < τ) : ∃ N : ℕ, dyadicRisk N ≤ τ := by
  obtain ⟨N,hN⟩ := exists_nat_gt (1/(4*τ))
  refine ⟨N,?_⟩
  have hpow : (N : ℝ) ≤ (2 : ℝ)^N := by
    exact_mod_cast (show N ≤ 2^N from (Nat.le_succ N).trans (two_pow_ge_succ N))
  have h := hN.le.trans hpow
  rw [div_le_iff₀ (by positivity : 0 < 4*τ)] at h
  unfold dyadicRisk
  rw [div_le_iff₀ (by positivity)]
  nlinarith only [h]

theorem positive_wyner_charge
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (s : ℝ) (hs : wynerGen ν < s) : 0 < s := by
  rw [← wynerCI_eq_wynerGen] at hs
  obtain ⟨s0, ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩,hlt⟩ :=
    exists_lt_of_csInf_lt (wynerSet_nonempty ν hν0 hν1) hs
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
  have h := info_nonneg Q hQ0 hQ1 _ (∅ : Finset ι) w rfl hw0
  rw [info_empty] at h
  exact lt_of_le_of_lt h hlt

/-- Main quadratic terminal, with arbitrary positive tolerance below
one quarter. Rounding is done inside the stages, not on the information coefficient.
No per-stage or local drift hypotheses remain. -/
theorem paper_vi_quadratic_mse
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2) (s : ℝ) (hs : wynerGen ν < s)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ < 1/4) :
    ∃ t : DTree ι α,
      (∀ x, (t.queries x : ℝ) ≤
        (2048*quadraticC+2)/(2*τ) +
        ((2^40 : ℝ)*rowK 2*s)/(8*τ^3)) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  classical
  let A : ℝ := 2048*quadraticC
  let B : ℝ := (2^40 : ℝ)*rowK 2*s
  have hC := quadraticC_pos
  have hs0 := positive_wyner_charge ν hν0 hν1 s hs
  have hK := rowK_pos 2 (by decide)
  have hA0 : 0 ≤ A := by dsimp [A]; positivity
  have hB0 : 0 ≤ B := by dsimp [B]; positivity
  have hA : 2048*quadraticC ≤ A := le_rfl
  have hB : (2^40 : ℝ)*rowK 2*s ≤ B := le_rfl
  let hex := dyadic_exists τ hτ
  let N := Nat.find hex
  have hN : dyadicRisk N ≤ τ := Nat.find_spec hex
  have hpos : 0 < N := by
    by_contra! hn
    have he : N = 0 := Nat.eq_zero_of_le_zero hn
    rw [he] at hN
    norm_num [dyadicRisk] at hN
    linarith
  have hprev : τ < dyadicRisk (N-1) := by
    by_contra! hle
    have hmin : N ≤ N-1 := Nat.find_min' hex hle
    omega
  have hrel : dyadicRisk N = dyadicRisk (N-1)/2 := by
    have hN' : N-1+1 = N := by omega
    calc
      dyadicRisk N = dyadicRisk (N-1+1) := congrArg dyadicRisk hN'.symm
      _ = dyadicRisk (N-1)/2 := dyadicRisk_succ _
  have hhalf : τ/2 < dyadicRisk N := by linarith
  have hp : (2 : ℝ)^N ≤ 1/(2*τ) := by
    unfold dyadicRisk at hhalf
    rw [lt_div_iff₀ (by positivity)] at hhalf
    rw [le_div_iff₀ (by positivity)]
    nlinarith only [hhalf]
  have h8 : (8 : ℝ)^N ≤ 1/(8*τ^3) := by
    have hpow : (8 : ℝ)^N = ((2 : ℝ)^N)^3 := by
      rw [← pow_mul, Nat.mul_comm, pow_mul]
      norm_num
    rw [hpow]
    have h := pow_le_pow_left₀ (by positivity : 0 ≤ (2 : ℝ)^N) hp 3
    have he : (1/(2*τ))^3 = 1/(8*τ^3) := by field_simp [hτ.ne'] <;> ring
    rwa [he] at h
  obtain ⟨t,ht,herr⟩ := quadratic_mse_general_dyadic ν hν0 hν1 f hf hdeg s hs A B hA0 hB0 hA hB N
  refine ⟨t,?_,herr.trans hN⟩
  intro x
  have hdepth : (t.queries x : ℝ) ≤ 2*(N : ℝ)+A*(2 : ℝ)^N+B*(8 : ℝ)^N := ht x
  have hNpow : (N : ℝ) ≤ (2 : ℝ)^N := by
    exact_mod_cast (show N ≤ 2^N from (Nat.le_succ N).trans (two_pow_ge_succ N))
  have h1 := mul_le_mul_of_nonneg_left hp hA0
  have h2 := mul_le_mul_of_nonneg_left h8 hB0
  change (t.queries x : ℝ) ≤ (A+2)/(2*τ)+B/(8*τ^3)
  have he : (A+2)/(2*τ) = A*(1/(2*τ))+2*(1/(2*τ)) := by ring
  have he2 : B/(8*τ^3) = B*(1/(8*τ^3)) := by ring
  rw [he,he2]
  linarith

/-- No free information slack in the stated bound: use a tolerance-dependent
strict charge, which has the same order as the private energy term. -/
theorem paper_vi_general_mse_wyner
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (n : ℕ) (hn : 0 < n)
    (hbudget : meanWeight d (τ/2)*rowK d +
      infoWeight d (τ/2)*(wynerGen ν+τ*Real.sqrt τ) ≤ (n : ℝ)*(τ/2)) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  have hstrict : wynerGen ν < wynerGen ν+τ*Real.sqrt τ := by
    have h := mul_pos hτ (Real.sqrt_pos.mpr hτ)
    linarith
  exact paper_vi_general_mse ν hν0 hν1 f hf d hd hdeg τ hτ _ hstrict n hn hbudget

theorem paper_vi_quadratic_mse_wyner
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2) (τ : ℝ) (hτ : 0 < τ) (hτmax : τ < 1/4) :
    ∃ t : DTree ι α,
      (∀ x, (t.queries x : ℝ) ≤
        (2048*quadraticC+2)/(2*τ) +
        ((2^40 : ℝ)*rowK 2*(wynerGen ν+τ^2))/(8*τ^3)) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  have hstrict : wynerGen ν < wynerGen ν+τ^2 := by
    have h := sq_pos_of_pos hτ
    linarith
  exact paper_vi_quadratic_mse ν hν0 hν1 f hf hdeg _ hstrict τ hτ hτmax

#print axioms Nightfall.PaperVI.paper_vi_general_mse_wyner
#print axioms Nightfall.PaperVI.paper_vi_quadratic_mse_wyner

#print axioms Nightfall.PaperVI.mean_mse_general
#print axioms Nightfall.PaperVI.paper_vi_general_mse
#print axioms Nightfall.PaperVI.quadratic_mse_general_dyadic
#print axioms Nightfall.PaperVI.paper_vi_quadratic_mse
end Nightfall.PaperVI
