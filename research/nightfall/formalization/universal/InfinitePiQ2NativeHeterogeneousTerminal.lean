import InfinitePiQ2TaggedSourceTransport
import InfinitePiQ2FiniteDegreeBridge
import ActualSourceQ223802Terminal

/-!
# Unconditional native heterogeneous finite-product Q2, original source

A genuine finite alphabet can vary by coordinate. The single-alphabet
original-source C105.416 theorem is transported exactly by tagging wrong
coordinate letters with source probability 0. This uses *native* original
weighted mean, variance, and heat-bath influence; it does not supply
an influence oracle or a finite-table inequality as a hypothesis.

This is still finite-coordinate: no infinite-product terminal is inferred.
-/

namespace Nightfall.InfinitePiQ2NativeHeterogeneousTerminal

open Finset
open Nightfall.InfinitePiQ2HeterogeneousAlphabet
open Nightfall.InfinitePiQ2TaggedSourceTransport
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteDegreeBridge
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ223802Terminal
open Nightfall.Observability.ActualSourceANOVA

variable {ι : Type} [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (A : ι → Type) [∀ i, Fintype (A i)] [∀ i, Nonempty (A i)]

noncomputable def nativeMass (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i) : ℝ := ∏ i : ι, p i (x i)

noncomputable def nativeMean (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) : ℝ :=
  ∑ x, nativeMass A p x * f x

noncomputable def nativeVariance (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) : ℝ :=
  ∑ x, nativeMass A p x * (f x - nativeMean A p f)^2

noncomputable def nativeInfluence (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) (i : ι) : ℝ :=
  ∑ x, nativeMass A p x *
    (f x - ∑ a : A i, p i a * f (Function.update x i a))^2

theorem tagged_mean_exact
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) :
    sourceMean (taggedMass A p)
      (fun w => f (decodeWord A w)) = nativeMean A p f := by
  simpa only [sourceMean, nativeMean, nativeMass] using
    (originalSource_sum_tagged_exact A p f)

theorem tagged_variance_exact
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) :
    sourceVariance (taggedMass A p)
      (fun w => f (decodeWord A w)) = nativeVariance A p f := by
  unfold sourceVariance nativeVariance
  rw [tagged_mean_exact A p f]
  simpa only [nativeMass] using
    (originalSource_sum_tagged_exact A p
      (fun x => (f x - nativeMean A p f)^2))

theorem decode_update_embed
    (w : ι → CommonLetter A) (i : ι) (a : A i) :
    decodeWord A (Function.update w i (embedLetter A i a)) =
      Function.update (decodeWord A w) i a := by
  unfold decodeWord
  rw [mapInputs_update, decode_embed]

theorem tagged_one_coordinate_heatbath
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ)
    (i : ι) (w : ι → CommonLetter A) :
    (∑ s : CommonLetter A, taggedMass A p i s *
      f (decodeWord A (Function.update w i s))) =
    (∑ a : A i, p i a *
      f (Function.update (decodeWord A w) i a)) := by
  classical
  simp only [Fintype.sum_sigma]
  simp [taggedMass, decode_update_embed]

theorem tagged_influence_exact
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ)
    (i : ι) :
    sourceInfluence (taggedMass A p)
      (fun w => f (decodeWord A w)) i = nativeInfluence A p f i := by
  calc
    sourceInfluence (taggedMass A p)
      (fun w => f (decodeWord A w)) i =
      ∑ w : ι → CommonLetter A, originalMass (taggedMass A p) w *
        (f (decodeWord A w) -
          ∑ a : A i, p i a *
            f (Function.update (decodeWord A w) i a))^2 := by
      unfold sourceInfluence
      apply Finset.sum_congr rfl
      intro w _
      rw [tagged_one_coordinate_heatbath A p f i w]
    _ = nativeInfluence A p f i := by
      simpa only [nativeInfluence, nativeMass] using
        (originalSource_sum_tagged_exact A p
          (fun x => (f x - ∑ a : A i, p i a *
            f (Function.update x i a))^2))

/-- All native heterogeneous alphabets; every original source marginal can
be nonuniform and have zero-mass letters. C105.416 with no change. -/
theorem native_heterogeneous_q2_105416_unconditional
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : A i, p i a = 1)
    (f : ((i : ι) → A i) → ℝ)
    (hf : PointwiseDegreeTwo f)
    (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ x, |f x| ≤ B)
    (M : ℝ) (hM : 0 ≤ M)
    (hI : ∀ i, nativeInfluence A p f i ≤ M) :
    (nativeVariance A p f)^2 ≤
      ((2*(1+Real.sqrt 2))*Real.sqrt 3+11901/6250)^2*B^2*M := by
  classical
  letI : Nonempty (CommonLetter A) := by
    obtain ⟨i⟩ := (inferInstance : Nonempty ι)
    exact ⟨⟨i, Classical.choice (inferInstance : Nonempty (A i))⟩⟩
  let pt : ι → CommonLetter A → ℝ := taggedMass A p
  let g : (ι → CommonLetter A) → ℝ := fun w => f (decodeWord A w)
  have hpt : ∀ i s, 0 ≤ pt i s := taggedMass_nonneg A p hp
  have hpt1 : ∀ i, ∑ s : CommonLetter A, pt i s = 1 :=
    taggedMass_normalized A p hp1
  have hdegree : ESDegreeLE pt g 2 :=
    pointwiseDegreeTwo_implies_ESDegreeLE pt g
      (degree_two_under_common_alphabet A f hf)
  have hgb : ∀ w, |g w| ≤ B := bound_under_common_alphabet A f B hbound
  have hcap : ∀ i, sourceInfluence pt g i ≤ M := by
    intro i
    rw [show sourceInfluence pt g i = nativeInfluence A p f i
      from tagged_influence_exact A p f i]
    exact hI i
  have hfinite := actual_source_q2_23802_unconditional
    pt hpt hpt1 g hdegree B hB hgb M hM hcap
  simpa only [show sourceVariance pt g = nativeVariance A p f
    from tagged_variance_exact A p f] using hfinite

#print axioms Nightfall.InfinitePiQ2NativeHeterogeneousTerminal.tagged_mean_exact
#print axioms Nightfall.InfinitePiQ2NativeHeterogeneousTerminal.tagged_variance_exact
#print axioms Nightfall.InfinitePiQ2NativeHeterogeneousTerminal.tagged_influence_exact
#print axioms Nightfall.InfinitePiQ2NativeHeterogeneousTerminal.native_heterogeneous_q2_105416_unconditional

end Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
