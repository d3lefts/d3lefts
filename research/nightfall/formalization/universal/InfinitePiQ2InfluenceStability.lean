import InfinitePiQ2Density

/-!
# Source-coordinate influence stability on arbitrary infinite products

This module defines the genuine L² conditional expectation onto all
coordinates except one under the original infinite product measure.
It proves a uniform, dimension-independent perturbation bound for its
coordinate residual. The proof uses only the original product measure,
the actual conditional-expectation Hilbert projection, linearity, and
contraction. There is no source substitution or supplied influence cap.

The result is a necessary transfer tool for finite-table Q2
discretization, not itself the infinite-product Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2InfluenceStability

open MeasureTheory

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

def sourceOtherIndices (i : ι) : Set ι := {j | j ≠ i}

/-- True information carried by all source coordinates other than i. -/
def sourceOtherSigma (i : ι) :
    MeasurableSpace ((j : ι) → X j) :=
  MeasurableSpace.comap
    (fun x : (j : ι) → X j => (sourceOtherIndices i).restrict x)
    (inferInstance : MeasurableSpace ((j : sourceOtherIndices i) → X j))

theorem sourceOtherSigma_le (i : ι) :
    sourceOtherSigma (X := X) i ≤
      (inferInstance : MeasurableSpace ((j : ι) → X j)) := by
  exact (Set.measurable_restrict (sourceOtherIndices i)).comap_le

/-- The original-product heat-bath projection, not an external
influence oracle or a surrogate probability law. -/
noncomputable def sourceOtherProjection (i : ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  (condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) i) f :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))

theorem sourceOtherProjection_contract
    (i : ι) (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    ‖sourceOtherProjection μ i f‖ ≤ ‖f‖ := by
  exact norm_condExpL2_coe_le (sourceOtherSigma_le (X := X) i) f

theorem sourceOtherProjection_sub
    (i : ι) (f g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjection μ i (f - g) =
      sourceOtherProjection μ i f - sourceOtherProjection μ i g := by
  unfold sourceOtherProjection
  simp only [map_sub, Submodule.coe_sub]

/-- The residual defining the original coordinate Efron-Stein influence. -/
noncomputable def sourceCoordinateResidual (i : ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  f - sourceOtherProjection μ i f

/-- Subtracting a source-coordinate projection is linear. -/
theorem sourceCoordinateResidual_sub
    (i : ι) (f g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceCoordinateResidual μ i (f - g) =
      sourceCoordinateResidual μ i f -
        sourceCoordinateResidual μ i g := by
  dsimp [sourceCoordinateResidual]
  rw [sourceOtherProjection_sub]
  abel

/-- Uniform original-source influence stability. The residual map has
operator norm at most 2, even without invoking the sharper orthogonal
complement contraction. This bound works for every index, including
uncountable families and null/nonatomic coordinate measures. -/
theorem sourceCoordinateResidual_lipschitz
    (i : ι)
    (f g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    ‖sourceCoordinateResidual μ i g‖ ≤
      ‖sourceCoordinateResidual μ i f‖ + 2 * ‖g - f‖ := by
  have hline :
      sourceCoordinateResidual μ i g =
        sourceCoordinateResidual μ i f +
          sourceCoordinateResidual μ i (g - f) := by
    rw [sourceCoordinateResidual_sub]
    abel
  have hsub :
      ‖sourceCoordinateResidual μ i (g - f)‖ ≤
        ‖g - f‖ + ‖sourceOtherProjection μ i (g - f)‖ := by
    unfold sourceCoordinateResidual
    exact norm_sub_le _ _
  have hP :
      ‖sourceOtherProjection μ i (g - f)‖ ≤ ‖g - f‖ :=
    sourceOtherProjection_contract μ i (g - f)
  calc
    ‖sourceCoordinateResidual μ i g‖ =
        ‖sourceCoordinateResidual μ i f +
          sourceCoordinateResidual μ i (g - f)‖ := by rw [hline]
    _ ≤ ‖sourceCoordinateResidual μ i f‖ +
        ‖sourceCoordinateResidual μ i (g - f)‖ :=
          norm_add_le _ _
    _ ≤ ‖sourceCoordinateResidual μ i f‖ + 2 * ‖g - f‖ := by
          linarith

noncomputable def sourceCoordinateInfluence (i : ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) : ℝ :=
  ‖sourceCoordinateResidual μ i f‖ ^ 2

/-- Source-influence control under an arbitrary finite-model L²
perturbation. The same error works simultaneously for all coordinates;
no factor depending on the number of active variables appears. -/
theorem sourceCoordinateInfluence_stable
    (f g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    ∀ i : ι,
      sourceCoordinateInfluence μ i g ≤
        (‖sourceCoordinateResidual μ i f‖ + 2 * ‖g - f‖) ^ 2 := by
  intro i
  unfold sourceCoordinateInfluence
  exact pow_le_pow_left₀
    (norm_nonneg _) (sourceCoordinateResidual_lipschitz μ i f g) 2

end Nightfall.InfinitePiQ2InfluenceStability
