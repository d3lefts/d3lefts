import Route1WynerGeneral

/-!
# NIGHTFALL Route 1 — arbitrary latent W to product-law mixing measure

The terminal Route1WynerGeneral theorem uses a Borel mixing probability
measure on the compact space of product laws. Here W can instead be any
measurable latent space, with a probability law μ and a measurable conditional
product kernel Q : W → LawSpace.

The pushforward ρ = μ.map Q has:
1. total mass one;
2. exactly the same input mixture distribution;
3. exactly the same conditional-input entropy, hence the same
   mutual information H(X) − E_W H(P_{X|W}).

The final theorem applies the independently checked finite-support reduction
wynerGenSet_eq to conclude the existence of a finite latent product
representation with exactly the same input law and information cost.

This formalizes the *measurable conditional-product-kernel* change of variables,
rather than relying on a docstring. When an abstract W is given by a joint
law rather than an explicit conditional kernel, its construction via conditional
probabilities / Radon–Nikodym disintegration is a logically separate interface.
-/

namespace Nightfall.Route1Polylog

open MeasureTheory

variable {ι α : Type}
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]

variable {W : Type*} [MeasurableSpace W]

/-- The pushforward of any probability law on an arbitrary measurable latent
space along a measurable conditional-product-law kernel is a probability
measure on the compact product-law space. -/
theorem abstract_latent_pushforward_probability
    (μ : Measure W) [IsProbabilityMeasure μ]
    (Q : W → LawSpace ι α) (hQ : Measurable Q) :
    IsProbabilityMeasure (Measure.map Q μ) :=
  Measure.isProbabilityMeasure_map hQ.aemeasurable

/-- The conditional-product-law pushforward preserves all input atom masses,
including zero atoms, with no finiteness assumption on W. -/
theorem abstract_latent_pushforward_input
    (μ : Measure W)
    (Q : W → LawSpace ι α) (hQ : Measurable Q)
    (x : ι → α) :
    (∫ q : LawSpace ι α, prodMass q.1 x ∂(Measure.map Q μ)) =
      ∫ w : W, prodMass (Q w).1 x ∂μ := by
  exact integral_map_of_stronglyMeasurable hQ
    (continuous_prodMass_law (ι := ι) (α := α) x).stronglyMeasurable

/-- The pushforward preserves conditional entropy, hence mutual information,
without assuming W is finite, countable, or standard Borel. -/
theorem abstract_latent_pushforward_conditional_entropy
    (μ : Measure W)
    (Q : W → LawSpace ι α) (hQ : Measurable Q) :
    (∫ q : LawSpace ι α, Hent (prodMass q.1) ∂(Measure.map Q μ)) =
      ∫ w : W, Hent (prodMass (Q w).1) ∂μ := by
  exact integral_map_of_stronglyMeasurable hQ
    (continuous_Hent_law (ι := ι) (α := α)).stronglyMeasurable

/-- Equality of abstract-W and product-law-mixture information, explicitly
in the finite-observable conditional-entropy definition of mutual information. -/
theorem abstract_latent_pushforward_information
    (ν : (ι → α) → ℝ)
    (μ : Measure W)
    (Q : W → LawSpace ι α) (hQ : Measurable Q) :
    Hent ν -
        (∫ q : LawSpace ι α, Hent (prodMass q.1) ∂(Measure.map Q μ)) =
      Hent ν - ∫ w : W, Hent (prodMass (Q w).1) ∂μ := by
  rw [abstract_latent_pushforward_conditional_entropy μ Q hQ]

/-- Any arbitrary-measurable-latent representation whose coordinates are
conditionally independent has its *exact* source and information value in the
general Borel product-law mixture set. -/
theorem abstract_latent_value_in_wynerGenSet
    (μ : Measure W) [IsProbabilityMeasure μ]
    (Q : W → LawSpace ι α) (hQ : Measurable Q)
    (ν : (ι → α) → ℝ)
    (hν : ∀ x, ν x = ∫ w : W, prodMass (Q w).1 x ∂μ) :
    Hent ν - ∫ w : W, Hent (prodMass (Q w).1) ∂μ ∈
      wynerGenSet ν := by
  refine ⟨Measure.map Q μ,
    abstract_latent_pushforward_probability μ Q hQ, ?_, ?_⟩
  · intro x
    rw [abstract_latent_pushforward_input μ Q hQ x]
    exact hν x
  · rw [abstract_latent_pushforward_conditional_entropy μ Q hQ]

/-- **Abstract W reduces to a finite latent with *exactly equal* information.**

The conclusion provides a finite index k, mixture weights w, and product
components P such that ν = ∑ w·P and the finite mutual information
I(index;X) equals the original H(X)−E_W H(X|W). This reuses the already
kernel-checked compact convex-hull finite-support reduction, and does not
assume that the original W is finite. -/
theorem abstract_latent_exact_finite_reduction
    (μ : Measure W) [IsProbabilityMeasure μ]
    (Q : W → LawSpace ι α) (hQ : Measurable Q)
    (ν : (ι → α) → ℝ)
    (hν : ∀ x, ν x = ∫ w : W, prodMass (Q w).1 x ∂μ) :
    ∃ (k : ℕ) (w : Fin k → ℝ) (P : Fin k → ι → α → ℝ),
      (∀ θ, 0 ≤ w θ) ∧
      (∑ θ, w θ = 1) ∧
      (∀ θ i a, 0 ≤ P θ i a) ∧
      (∀ θ i, ∑ a, P θ i a = 1) ∧
      (∀ x, ν x = ∑ θ, w θ * prodMass (P θ) x) ∧
      Hent ν - ∫ z : W, Hent (prodMass (Q z).1) ∂μ = mutInfo P w := by
  have hmem := abstract_latent_value_in_wynerGenSet μ Q hQ ν hν
  rw [wynerGenSet_eq] at hmem
  exact hmem

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.abstract_latent_pushforward_probability
#print axioms Nightfall.Route1Polylog.abstract_latent_pushforward_input
#print axioms Nightfall.Route1Polylog.abstract_latent_pushforward_conditional_entropy
#print axioms Nightfall.Route1Polylog.abstract_latent_pushforward_information
#print axioms Nightfall.Route1Polylog.abstract_latent_value_in_wynerGenSet
#print axioms Nightfall.Route1Polylog.abstract_latent_exact_finite_reduction
