import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Finite native-source L²-zero to supported pointwise-zero transfer

The infinite-product Q2 finite-label transfer obtains triple heat-bath
residual zero as an L² equality. The finite native Q2 theorem, however,
requires identities on source-support words. On finite product tables
the exact weighted sum of squares detects every positive-mass atom.

This is the final purely finite, measure-to-pointwise step. It does
not assert an infinite-product table construction or degree condition.
No atom floor and no uniform marginals are assumed.
-/

namespace Nightfall.InfinitePiQ2PositiveAtomL2Zero

open Finset
open Nightfall.InfinitePiQ2DegreeRetraction

/-- A finite nonnegative weighted sum of squares can vanish only if
the summand vanishes at every strictly positive-weight atom. -/
theorem weighted_square_zero_at_positive
    {Ω : Type*} [Fintype Ω]
    (w : Ω → ℝ) (hw : ∀ x, 0 ≤ w x)
    (g : Ω → ℝ)
    (hzero : (∑ x : Ω, w x * (g x)^2) = 0)
    (x : Ω) (hx : 0 < w x) :
    g x = 0 := by
  classical
  have hnonneg (y : Ω) : 0 ≤ w y * (g y)^2 :=
    mul_nonneg (hw y) (sq_nonneg _)
  have hterm :
      w x * (g x)^2 ≤ ∑ y : Ω, w y * (g y)^2 := by
    exact Finset.single_le_sum
      (fun y hy => hnonneg y) (Finset.mem_univ x)
  have heq : w x * (g x)^2 = 0 := by
    nlinarith [hnonneg x]
  have hsq : (g x)^2 = 0 :=
    (mul_eq_zero.mp heq).resolve_left (ne_of_gt hx)
  nlinarith

universe u v
variable {ι : Type u} [Fintype ι] [DecidableEq ι]
variable {A : ι → Type v} [∀ i, Fintype (A i)]

/-- Native heterogeneous source product weights; no common alphabet
encoding is used at this stage. -/
noncomputable def nativeMass
    (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i) : ℝ :=
  ∏ i : ι, p i (x i)

/-- Every original positive-support word has strictly positive mass,
with no lower bound uniform over the finite source. -/
theorem nativeMass_pos_of_supported
    (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i)
    (hx : ∀ i, 0 < p i (x i)) :
    0 < nativeMass p x := by
  unfold nativeMass
  exact Finset.prod_pos (fun i _ => hx i)

/-- Genuine original finite native product mass is nonnegative under
arbitrary heterogeneous nonnegative source marginal masses. -/
theorem nativeMass_nonneg
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (x : (i : ι) → A i) :
    0 ≤ nativeMass p x := by
  unfold nativeMass
  exact Finset.prod_nonneg (fun i _ => hp i (x i))

/-- Exact finite native original-product L² zero implies pointwise
zero on every positive-probability source word, including when zero
mass words carry arbitrary values. -/
theorem native_L2_zero_implies_supported_pointwise_zero
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (g : ((i : ι) → A i) → ℝ)
    (hzero : (∑ x : (i : ι) → A i,
      nativeMass p x * (g x)^2) = 0)
    (x : (i : ι) → A i)
    (hx : ∀ i, 0 < p i (x i)) :
    g x = 0 :=
  weighted_square_zero_at_positive (nativeMass p)
    (nativeMass_nonneg p hp) g hzero x
    (nativeMass_pos_of_supported p x hx)

/-- Replacing one coordinate by a positive-mass native letter keeps
every original coordinate of the word on the true positive support. -/
theorem sourceSupported_update
    (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i)
    (hx : ∀ i, 0 < p i (x i))
    (i : ι) (a : A i) (ha : 0 < p i a) :
    ∀ j, 0 < p j ((Function.update x i a) j) := by
  intro j
  by_cases hji : j = i
  · subst j
    simpa using ha
  · simpa only [Function.update_of_ne hji] using hx j

/-- A function vanishing at every genuine positive native source atom
has a vanishing one-coordinate mixed difference at every supported
base word, provided its replacement letters are themselves supported. -/
theorem delta_zero_on_source_support
    (p : (i : ι) → A i → ℝ)
    (g : ((i : ι) → A i) → ℝ)
    (hzero : ∀ x, (∀ j, 0 < p j (x j)) → g x = 0)
    (i : ι) (a b : A i)
    (ha : 0 < p i a) (hb : 0 < p i b) :
    ∀ x, (∀ j, 0 < p j (x j)) → delta i a b g x = 0 := by
  intro x hx
  change g (Function.update x i a) - g (Function.update x i b) = 0
  rw [hzero (Function.update x i a)
    (sourceSupported_update p x hx i a ha)]
  rw [hzero (Function.update x i b)
    (sourceSupported_update p x hx i b hb)]
  ring

/-- Direct source-native finite L² to mixed-third-difference conversion.
A zero *weighted* squared residual suffices: it need not vanish at
null table words. The eight corners involved in any supported mixed
third difference remain positive source atoms. -/
theorem native_L2_zero_implies_supported_mixed_third_zero
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (g : ((i : ι) → A i) → ℝ)
    (hzero : (∑ x : (i : ι) → A i,
      nativeMass p x * (g x)^2) = 0)
    (i j k : ι)
    (a a' : A i) (b b' : A j) (c c' : A k)
    (x : (i : ι) → A i)
    (hx : ∀ l, 0 < p l (x l))
    (ha : 0 < p i a) (ha' : 0 < p i a')
    (hb : 0 < p j b) (hb' : 0 < p j b')
    (hc : 0 < p k c) (hc' : 0 < p k c') :
    delta i a a' (delta j b b' (delta k c c' g)) x = 0 := by
  have hSupported :
      ∀ w, (∀ l, 0 < p l (w l)) → g w = 0 := by
    intro w hw
    exact native_L2_zero_implies_supported_pointwise_zero p hp g
      hzero w hw
  have hk :
      ∀ w, (∀ l, 0 < p l (w l)) →
        delta k c c' g w = 0 :=
    delta_zero_on_source_support p g hSupported k c c' hc hc'
  have hj :
      ∀ w, (∀ l, 0 < p l (w l)) →
        delta j b b' (delta k c c' g) w = 0 :=
    delta_zero_on_source_support p
      (delta k c c' g) hk j b b' hb hb'
  have hi :
      ∀ w, (∀ l, 0 < p l (w l)) →
        delta i a a' (delta j b b' (delta k c c' g)) w = 0 :=
    delta_zero_on_source_support p
      (delta j b b' (delta k c c' g)) hj i a a' ha ha'
  exact hi x hx

end Nightfall.InfinitePiQ2PositiveAtomL2Zero
