import Lemmas.SparseContraction

open InclusionBench InclusionBench.Support InclusionBench.Support.Classes
open Nightfall.InclusionBridge

namespace Nightfall.InclusionBridge

/-- The remaining universal source-representation obligation is explicit.
This is NOT the unconditional BQP-to-P benchmark target. -/
theorem conditional_BQP_in_P
    (representation : ∀ language : Language, BQP language →
      ∃ (c : SparseContraction) (threshold : Word → Int),
        FP threshold ∧ ∃ post : Int → Int, PolynomialIntegerMap post ∧
          (∀ input, post (c.score input - threshold input) = 1 ↔ language input)) :
    Includes BQP P := by
  intro language member
  obtain ⟨c, threshold, hthreshold, post, hpost, correct⟩ :=
    representation language member
  exact terminal_in_P c threshold hthreshold post hpost language correct

end Nightfall.InclusionBridge

-- Infrastructure-only control; earns zero benchmark points.
-- The conditional theorem above is deliberately NOT mapped to a claim.
theorem Submission.result_1 : Includes P P := includes_refl P
