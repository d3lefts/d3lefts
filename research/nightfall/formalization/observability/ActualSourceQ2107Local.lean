import ActualSourceQ2128Terminal
import ShiftedOwnerQuarterMoments

/-!
# Unrestricted source Q2: exact c/4 shifted Hilbert local site
The polynomial certificate is imported from ShiftedOwnerBernstein,
the genuine all-increment law and original-source owner from
ActualSourceQ2128Terminal.  Zero-mass atoms and nonzero singleton
components are admitted.  No c/5 claim.
-/
namespace Nightfall.Observability.ActualSourceQ2107Local
open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceIntegratedFive
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualSourceOwnedMomentEnergy
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceQ2EnergyDualSource
open Nightfall.Observability.ActualSourceQ2SharpAdditiveFinal
open Nightfall.Observability.ShiftedOwnerSourceJensen
open Nightfall.Observability.ShiftedOwnerScalarMoments
open Nightfall.Observability.ShiftedOwnerScalar
open Nightfall.Observability.ShiftedHilbertManyIncrement
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint


open Nightfall.Observability.ActualSourceQ2128Terminal
open Nightfall.Observability.ShiftedOwnerQuarterMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Shifted local site: original canonical singleton, true owned
independent source-neighbor samples, true source first norm and
the original resampling influence. -/
theorem actual_source_shifted_site_107
    (p : ι → α → ℝ)
    (hp : ∀ k b, 0 ≤ p k b)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (c : ι → ℝ) (hc : ∀ i, 0 ≤ c i)
    (hcover : ∀ e : Edge ι, ∀ a b : α,
       |sourceDoubleCenteredPair p f (edgeFirst e) (edgeSecond e) a b| ≤
         c (owner edgeFirst edgeSecond c e))
    (i : ι) :
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    let a := originalSingletonNorm p f i
    let s := moment2 (fun k => p (j k)) Y J.card
    let e := a^2+s
    e ≤ sourceInfluence p f i ∧
    e ≤ Real.sqrt (sourceInfluence p f i) *
      (Real.sqrt 3 * shiftedOwnedFirstNorm p f c i + c i/4) := by
  classical
  dsimp
  let J : Finset ι := ownedNeighbors c i
  let j : ℕ → ι := neighborIndex i J
  let Y := finitePairIncrement p f i j J.card
  let a : ℝ := originalSingletonNorm p f i
  let H : α → ℝ := fun b =>
    Real.sqrt (p i b) * sourceCenteredSingleton p f i b
  let s : ℝ := moment2 (fun k => p (j k)) Y J.card
  let e : ℝ := a^2+s
  let u : ℝ := shiftedOwnedFirstNorm p f c i
  let q : ℝ := shiftedMoment4 (fun k => p (j k)) Y H J.card
  have ha : 0 ≤ a := Real.sqrt_nonneg _
  have hs : 0 ≤ s := by
    dsimp [s, moment2]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg (fun k => p (j k))
      (fun k b => hp (j k) b) J.card w) (vecNormSq_nonneg _)
  have he : 0 ≤ e := by dsimp [e]; positivity
  have hu : 0 ≤ u := by
    dsimp [u, shiftedOwnedFirstNorm]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg (fun k => p (j k))
      (fun k b => hp (j k) b) J.card w) (Real.sqrt_nonneg _)
  have hH : vecNormSq H = a^2 := by
    have htab : a = Real.sqrt (∑ b : α, p i b *
      (sourceCenteredSingleton p f i b)^2) := by
        exact original_singleton_norm_source_table p hp1 f i
    have hnonneg : 0 ≤
        (∑ b : α, p i b * (sourceCenteredSingleton p f i b)^2) :=
      Finset.sum_nonneg (fun b _ => mul_nonneg (hp i b) (sq_nonneg _))
    calc
      vecNormSq H =
          ∑ b : α, p i b * (sourceCenteredSingleton p f i b)^2 := by
            unfold vecNormSq
            apply Finset.sum_congr rfl
            intro b _
            dsimp [H]
            rw [mul_pow, Real.sq_sqrt (hp i b)]
            ring
      _ = a^2 := by rw [htab, Real.sq_sqrt hnonneg]
  have hne : ∀ k, k < J.card → i ≠ j k := by
    intro k hk
    have hm : j k ∈ ownedNeighbors c i := by
      simpa only [j, J] using (neighborIndex_mem i J k hk)
    intro heq
    rw [← heq] at hm
    exact (original_owner_not_in_neighbors c i) hm
  have hkernel : ∀ k, k < J.card → ∀ b d : α,
      |sourceDoubleCenteredPair p f i (j k) b d| ≤ c i := by
    intro k hk b d
    exact actual_owned_neighbor_kernel_amplitude
      p hp1 f c hcover i k hk b d
  have hY : ∀ k b, (∑ d : α, p (j k) d * Y k d b) = 0 := by
    intro k b
    exact finitePairIncrement_centered p hp1 f i j J.card hne k b
  have hbound : ∀ k b, vecNormSq (Y k b) ≤ (c i)^2 := by
    intro k b
    exact finitePairIncrement_norm_bounded
      p hp hp1 f i j J.card (c i) hkernel k b
  have hsecond := shifted_second_moment
    (fun k => p (j k)) Y H
    (fun k => hp1 (j k)) hY J.card
  have hbudget := moment2_eq_budget (fun k => p (j k)) Y
    (fun k => hp1 (j k)) hY J.card
  have hfourth := arbitrary_law_many_shifted_hilbert_fourth
    (fun k => p (j k)) Y H a (c i)
    (fun k b => hp (j k) b) (fun k => hp1 (j k))
    hY ha (hc i) hH hbound J.card
  have hqstrong : q ≤
      3*e^2-2*a^4+4*a*(c i)*s+(c i)^2*s := by
    dsimp [q,e,s]
    rw [← hbudget] at hfourth
    convert hfourth using 1 <;> ring
  have hint := shifted_product_l1_l2_l4 (fun k => p (j k))
    Y H (fun k b => hp (j k) b) J.card
  have hnorm : (∑ w : Samples α J.card,
      mass (fun k => p (j k)) J.card w *
        vecNormSq (fun b => H b + sumVector Y J.card w b)) = e := by
    calc
      _ = vecNormSq H + moment2 (fun k => p (j k)) Y J.card :=
        hsecond
      _ = e := by dsimp [e,s]; rw [hH]
  have hholder : e^3 ≤ u^2*q := by
    rw [hnorm] at hint
    simpa only [u, shiftedOwnedFirstNorm, q, H, Y, j, J] using hint
  have hrootEnergy : (Real.sqrt e)^2 = a^2+s := by
    rw [Real.sq_sqrt he]
    rfl
  have hrootHolder : (Real.sqrt e)^6 ≤ u^2*q := by
    calc
      (Real.sqrt e)^6 = e^3 := by
        calc
          (Real.sqrt e)^6 = ((Real.sqrt e)^2)^3 := by ring
          _ = e^3 := by rw [Real.sq_sqrt he]
      _ ≤ u^2*q := hholder
  have hrootFourth :
      q ≤ 3*(Real.sqrt e)^4-2*a^4+4*a*(c i)*s+(c i)^2*s := by
    have hsqr : (Real.sqrt e)^4=e^2 := by
      calc
        (Real.sqrt e)^4 = ((Real.sqrt e)^2)^2 := by ring
        _ = e^2 := by rw [Real.sq_sqrt he]
    rw [hsqr]
    exact hqstrong
  have hshift : Real.sqrt e ≤ Real.sqrt 3*u+(c i)/4 :=
    shifted_c4_from_moments (Real.sqrt e) a s (c i) u q
      (Real.sqrt_nonneg _) ha hs (hc i) hu hrootEnergy
      hrootHolder hrootFourth
  have hcap : e ≤ sourceInfluence p f i := by
    simpa only [e,a,s,j,Y,J] using
      (original_singleton_plus_owned_energy_le_influence
        p hp hp1 f hdegree c i)
  have hsite : e ≤ Real.sqrt (sourceInfluence p f i) *
      (Real.sqrt 3*u+(c i)/4) := by
    calc
      e = Real.sqrt e * Real.sqrt e := by
        rw [← pow_two, Real.sq_sqrt he]
      _ ≤ Real.sqrt (sourceInfluence p f i) * Real.sqrt e :=
        mul_le_mul_of_nonneg_right
          (Real.sqrt_le_sqrt hcap) (Real.sqrt_nonneg _)
      _ ≤ Real.sqrt (sourceInfluence p f i) *
          (Real.sqrt 3*u+(c i)/4) :=
        mul_le_mul_of_nonneg_left hshift (Real.sqrt_nonneg _)

  exact ⟨hcap, by simpa only [e,u,a,s,j,Y,J] using hsite⟩


end Nightfall.Observability.ActualSourceQ2107Local
