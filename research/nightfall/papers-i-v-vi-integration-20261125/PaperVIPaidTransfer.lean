import PaperVIGeneralLatentTerminal
import QueryLocalWynerComplete

/-! Paper VI Corollary 5.4: original-query compiler, actual latent
staged tree and bounded squared-risk transfer. The TV hypothesis is
the usual expectation form for all [0,1]-valued finite tests. -/
namespace Nightfall.PaperVIPaidTransfer
open Finset
open Nightfall.Route1Polylog
open Nightfall.PaperVI
open Nightfall.QueryLocalWyner
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {I J A : Type} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

noncomputable def clip (v : ℝ) : ℝ := max 0 (min 1 v)

noncomputable def clipTree : DTree I A → DTree I A
  | .leaf v b => .leaf (clip v) b
  | .node j t => .node j (fun a => clipTree (t a))

theorem clipTree_eval (t : DTree I A) (x : I → A) :
    (clipTree t).eval x = clip (t.eval x) := by
  induction t with
  | leaf v b => rfl
  | node j t ih => exact ih (x j)

theorem clipTree_depth (t : DTree I A) (x : I → A) :
    (clipTree t).queries x = t.queries x := by
  induction t with
  | leaf v b => rfl
  | node j t ih => simp only [clipTree,DTree.queries,ih]

theorem clip_range (v : ℝ) : 0 ≤ clip v ∧ clip v ≤ 1 := by
  unfold clip
  constructor
  · exact le_max_left _ _
  · exact max_le zero_le_one (min_le_left _ _)

theorem clip_sq_le (a v : ℝ) (ha : 0 ≤ a ∧ a ≤ 1) :
    (a-clip v)^2 ≤ (a-v)^2 := by
  unfold clip
  rcases le_total v 0 with h|h
  · rw [min_eq_right (h.trans zero_le_one),max_eq_left h]
    nlinarith [mul_nonneg ha.1 (neg_nonneg.mpr h),sq_nonneg v]
  · rcases le_total v 1 with h1|h1
    · rw [min_eq_right h1,max_eq_right h]
    · rw [min_eq_left h1,max_eq_right zero_le_one]
      nlinarith [mul_nonneg (sub_nonneg.mpr ha.2) (sub_nonneg.mpr h1),
        sq_nonneg (v-1)]

theorem paid_tree_mse
    (μ : (J → A) → ℝ) (hμ : ∀ z, 0 ≤ μ z)
    (ν : (I → A) → ℝ) (Φ : (J → A) → (I → A))
    (recover : J → RecoveryTree I A) (r q : ℕ)
    (hr : ∀ j x, (recover j).queries x ≤ r)
    (hrec : ∀ z, μ z ≠ 0 → ∀ j, (recover j).eval (Φ z) = z j)
    (ζ τ : ℝ)
    (hTV : ∀ g : (I → A) → ℝ, (∀ x, 0 ≤ g x ∧ g x ≤ 1) →
      (∑ x, ν x*g x) ≤ (∑ z, μ z*g (Φ z))+ζ)
    (f : (I → A) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (t : DTree J A) (ht : ∀ z, t.queries z ≤ q)
    (herr : ∑ z, μ z*(f (Φ z)-t.eval z)^2 ≤ τ) :
    ∃ obs : DTree I A, (∀ x, obs.queries x ≤ r*q) ∧
      (∑ x, ν x*(f x-obs.eval x)^2) ≤ τ+ζ := by
  let obs := clipTree (compile recover t)
  refine ⟨obs,?_,?_⟩
  · intro x
    rw [show obs.queries x = (compile recover t).queries x from clipTree_depth _ _]
    exact compile_global_depth recover r q hr t ht x
  · have hbounded : ∀ x, 0 ≤ (f x-obs.eval x)^2 ∧ (f x-obs.eval x)^2 ≤ 1 := by
      intro x
      have he : obs.eval x = clip ((compile recover t).eval x) := clipTree_eval _ _
      rw [he]
      have hh := clip_range ((compile recover t).eval x)
      have hdiff : |f x-clip ((compile recover t).eval x)| ≤ 1 :=
        abs_le.mpr ⟨by linarith [(hf x).1,hh.2],by linarith [(hf x).2,hh.1]⟩
      refine ⟨sq_nonneg _,?_⟩
      exact (sq_le_one_iff_abs_le_one _).mpr hdiff
    have h := hTV (fun x => (f x-obs.eval x)^2) hbounded
    have hb : (∑ z, μ z*(f (Φ z)-obs.eval (Φ z))^2) ≤
        ∑ z, μ z*(f (Φ z)-t.eval z)^2 := by
      apply Finset.sum_le_sum
      intro z _
      by_cases hz : μ z = 0
      · simp [hz]
      · have he : obs.eval (Φ z) = clip (t.eval z) := by
          rw [show obs.eval (Φ z) = clip ((compile recover t).eval (Φ z)) from clipTree_eval _ _,
            compile_correct_on_source recover Φ t z (hrec z hz)]
        rw [he]
        exact mul_le_mul_of_nonneg_left (clip_sq_le _ _ (hf (Φ z))) (hμ z)
    linarith [hb.trans herr]

theorem paid_general_wyner_mse
    (μ : (J → A) → ℝ) (hμ0 : ∀ z, 0 ≤ μ z) (hμ1 : ∑ z, μ z = 1)
    (ν : (I → A) → ℝ) (Φ : (J → A) → (I → A))
    (S : I → Finset J) (b d : ℕ) (hb : ∀ i, (S i).card ≤ b)
    (hlocal : LocallyEncoded Φ S)
    (recover : J → RecoveryTree I A) (r q : ℕ) (hq : 0 < q)
    (hr : ∀ j x, (recover j).queries x ≤ r)
    (hrec : ∀ z, μ z ≠ 0 → ∀ j, (recover j).eval (Φ z) = z j)
    (ζ τ : ℝ) (hτ : 0 < τ)
    (hTV : ∀ g : (I → A) → ℝ, (∀ x, 0 ≤ g x ∧ g x ≤ 1) →
      (∑ x, ν x*g x) ≤ (∑ z, μ z*g (Φ z))+ζ)
    (f : (I → A) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f d)
    (hbudget : meanWeight (max 1 (b*d)) (τ/2)*rowK (max 1 (b*d)) +
      infoWeight (max 1 (b*d)) (τ/2)*(wynerGen μ+τ*Real.sqrt τ) ≤ (q : ℝ)*(τ/2)) :
    ∃ obs : DTree I A, (∀ x, obs.queries x ≤ r*q) ∧
      (∑ x, ν x*(f x-obs.eval x)^2) ≤ τ+ζ := by
  have hD : 1 ≤ max 1 (b*d) := le_max_left _ _
  have hp := degree_local_pullback Φ S b d hb hlocal f hdeg
  have hp' := degree_le_mono (fun z => f (Φ z)) (b*d) (max 1 (b*d)) (le_max_right _ _) hp
  obtain ⟨t,ht,herr⟩ := paper_vi_general_mse_wyner μ hμ0 hμ1
    (fun z => f (Φ z)) (fun z => hf (Φ z)) _ hD hp' τ hτ q hq hbudget
  exact paid_tree_mse μ hμ0 ν Φ recover r q hr hrec ζ τ hTV f hf t ht herr

#print axioms clipTree_eval
#print axioms clipTree_depth
#print axioms clip_sq_le
#print axioms paid_tree_mse
#print axioms paid_general_wyner_mse
end Nightfall.PaperVIPaidTransfer
