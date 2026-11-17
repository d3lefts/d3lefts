import InfinitePiQ2NativeHeterogeneousTerminal
import InfinitePiQ2FiniteSupportedTerminal

/-!
# Heterogeneous native finite Q2 under supported-only hypotheses

This composes the ALREADY kernel-certified common-alphabet C105.416
source-supported finite theorem with the ALREADY kernel-certified
heterogeneous-to-tagged original weighted source transport.

The previous native heterogeneous terminal required a global pointwise
bound and quadratic identity even at zero-mass label words. This
operator reuses the exact positive-support retraction and proves that
no off-support table extension needs to be supplied by the caller.
-/

namespace Nightfall.InfinitePiQ2NativeSupportedTerminal

open Finset
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteSupportRepair
open Nightfall.InfinitePiQ2FiniteSupportedTerminal
open Nightfall.InfinitePiQ2HeterogeneousAlphabet
open Nightfall.InfinitePiQ2TaggedSourceTransport
open Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceVarianceEnergy

variable {ι : Type} [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (A : ι → Type) [∀ i, Fintype (A i)] [∀ i, Nonempty (A i)]

/-- The actual native product support, not a replacement law. -/
def NativeSupported (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i) : Prop :=
  ∀ i, 0 < p i (x i)

/-- Degree at most two on ALL positive native label atoms, and only there.
Replacement letters and the background word must carry positive mass. -/
def NativeSupportedDegreeTwo
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ) : Prop :=
  ∀ (i j k : ι) (_ : i ≠ j) (_ : i ≠ k) (_ : j ≠ k)
    (a a' : A i) (b b' : A j) (c c' : A k)
    (x : (m : ι) → A m),
    NativeSupported A p x →
    0 < p i a → 0 < p i a' →
    0 < p j b → 0 < p j b' →
    0 < p k c → 0 < p k c' →
    delta i a a' (delta j b b' (delta k c c' f)) x = 0

/-- A tagged letter with positive true-source mass decodes to
a native letter of positive probability. Wrong-index tags have
exactly mass zero, never a positive atom. -/
theorem native_positive_of_tagged
    (p : (i : ι) → A i → ℝ)
    (i : ι) (s : CommonLetter A)
    (hs : 0 < taggedMass A p i s) :
    0 < p i (decodeLetter A i s) := by
  classical
  by_cases h : s.1 = i
  · simpa only [taggedMass, dif_pos h, decodeLetter] using hs
  · have hzero : taggedMass A p i s = 0 :=
      taggedMass_wrong_tag A p i s h
    rw [hzero] at hs
    exact False.elim (not_lt_of_ge (le_refl (0 : ℝ)) hs)

/-- Exact positive support of tagged source words maps to positive
support of the original heterogeneous word. -/
theorem native_supported_of_tagged
    (p : (i : ι) → A i → ℝ)
    (w : ι → CommonLetter A)
    (hw : SourceSupported (taggedMass A p) w) :
    NativeSupported A p (decodeWord A w) := by
  intro i
  exact native_positive_of_tagged A p i (w i) (hw i)

/-- The native positive-support mixed-difference condition transports
to the common tagged alphabet on its own positive source support. -/
theorem native_supported_degree_two_under_tagging
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ)
    (hf : NativeSupportedDegreeTwo A p f) :
    SupportedDegreeTwo (taggedMass A p)
      (fun w : ι → CommonLetter A => f (decodeWord A w)) := by
  classical
  intro i j k hij hik hjk a a' b b' c c' w hw ha ha' hb hb' hc hc'
  rw [show delta i a a' (delta j b b' (delta k c c'
      (fun z : ι → CommonLetter A => f (decodeWord A z)))) w =
      delta i (decodeLetter A i a) (decodeLetter A i a')
        (delta j (decodeLetter A j b) (decodeLetter A j b')
          (delta k (decodeLetter A k c) (decodeLetter A k c') f))
        (decodeWord A w) from
          delta_three_comp (decodeLetter A) i j k a a' b b' c c' f w]
  exact hf i j k hij hik hjk
    (decodeLetter A i a) (decodeLetter A i a')
    (decodeLetter A j b) (decodeLetter A j b')
    (decodeLetter A k c) (decodeLetter A k c')
    (decodeWord A w)
    (native_supported_of_tagged A p w hw)
    (native_positive_of_tagged A p i a ha)
    (native_positive_of_tagged A p i a' ha')
    (native_positive_of_tagged A p j b hb)
    (native_positive_of_tagged A p j b' hb')
    (native_positive_of_tagged A p k c hc)
    (native_positive_of_tagged A p k c' hc')

/-- No global bound on wrong-tag or null native table words is needed. -/
theorem native_supported_bound_under_tagging
    (p : (i : ι) → A i → ℝ)
    (f : ((i : ι) → A i) → ℝ)
    (B : ℝ)
    (hf : ∀ x, NativeSupported A p x → |f x| ≤ B) :
    ∀ w, SourceSupported (taggedMass A p) w →
      |f (decodeWord A w)| ≤ B := by
  intro w hw
  exact hf (decodeWord A w) (native_supported_of_tagged A p w hw)

/-- Unconditional original-source native heterogeneous C105.416 finite
product Q2 theorem with ONLY positive-support degree and magnitude
assumptions, including arbitrary zero-mass label atoms.

This composes existing pinned finite product certificates. -/
theorem native_heterogeneous_q2_105416_supported_unconditional
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : A i, p i a = 1)
    (f : ((i : ι) → A i) → ℝ)
    (hf : NativeSupportedDegreeTwo A p f)
    (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ x, NativeSupported A p x → |f x| ≤ B)
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
  have hdeg : SupportedDegreeTwo pt g :=
    native_supported_degree_two_under_tagging A p f hf
  have hgb : ∀ w, SourceSupported pt w → |g w| ≤ B :=
    native_supported_bound_under_tagging A p f B hbound
  have hcap : ∀ i, sourceInfluence pt g i ≤ M := by
    intro i
    rw [show sourceInfluence pt g i = nativeInfluence A p f i
      from tagged_influence_exact A p f i]
    exact hI i
  have hfinite := original_source_q2_105416_support_unconditional
    pt hpt hpt1 g hdeg B hB hgb M hM hcap
  simpa only [show sourceVariance pt g = nativeVariance A p f
    from tagged_variance_exact A p f] using hfinite

#print axioms Nightfall.InfinitePiQ2NativeSupportedTerminal.native_positive_of_tagged
#print axioms Nightfall.InfinitePiQ2NativeSupportedTerminal.native_supported_degree_two_under_tagging
#print axioms Nightfall.InfinitePiQ2NativeSupportedTerminal.native_supported_bound_under_tagging
#print axioms Nightfall.InfinitePiQ2NativeSupportedTerminal.native_heterogeneous_q2_105416_supported_unconditional

end Nightfall.InfinitePiQ2NativeSupportedTerminal
