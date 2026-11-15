import Mathlib

/-!
# NIGHTFALL: effect-time audit capacity and restricted-action substitution

A two-world cheap-screening blind spot is modeled by the SAME randomized
policy probabilities in both safe and unsafe worlds.

The audit is assumed perfect AND effect-time synchronized. A restricted
capability is assumed independently safe and provides beta units of legitimate
service per use; it is *not* a proof that a particular physical restriction
works. The baseline compares exact rational expected per-request cost and
availability, not queue latency or an arbitrary deployed monitoring system.

The results give a general audit-capacity necessary bound and an exact
rational priced witness for a nontrivial restricted-capability regime.
They are elementary linear-programming mathematics, not a novelty claim.
-/

namespace Nightfall.PriceOfAdmission

/-- Randomized policy probabilities for audited admission, restricted safe
effect, unchecked full admission, and denial. -/
structure Mix where
  audit : ℚ
  restrict : ℚ
  unchecked : ℚ
  deny : ℚ
  audit_nonneg : 0 ≤ audit
  restrict_nonneg : 0 ≤ restrict
  unchecked_nonneg : 0 ≤ unchecked
  deny_nonneg : 0 ≤ deny
  mass : audit + restrict + unchecked + deny = 1

/-- Expected legitimate service at least a; unsafe unchecked admission at
most delta; effect-time independent audit rate at most kappa. The
restricted effect produces legitimate utility beta, assumed between 0 and 1.
The screening transcript is identical in the safe/unsafe worlds. -/
def Feasible (p : Mix) (a delta beta kappa : ℚ) : Prop :=
  a ≤ p.audit + beta * p.restrict + p.unchecked ∧
  p.unchecked ≤ delta ∧
  p.audit ≤ kappa

/-- Exact unavoidable *audit capacity* floor. No stochastic independence
assumption between different requests is used; the model is one request.
A detection-only asynchronous review is not an effect-time audit. -/
theorem capacity_floor (p : Mix)
    {a delta beta kappa : ℚ}
    (hbeta0 : 0 ≤ beta) (hbeta1 : beta ≤ 1)
    (h : Feasible p a delta beta kappa) :
    a ≤ beta + (1 - beta) * (kappa + delta) := by
  rcases h with ⟨hservice, hunsafe, hcapacity⟩
  have hsum : p.audit + p.unchecked ≤ kappa + delta := by
    linarith
  have hmult :
      (1 - beta) * (p.audit + p.unchecked) ≤
        (1 - beta) * (kappa + delta) :=
    mul_le_mul_of_nonneg_left hsum (by linarith)
  have hdeny : 0 ≤ beta * p.deny :=
    mul_nonneg hbeta0 p.deny_nonneg
  have hrest :
      p.restrict = 1 - p.audit - p.unchecked - p.deny := by
    linarith [p.mass]
  rw [hrest] at hservice
  nlinarith [hmult, hdeny]

/-- With half-utility restricted mode, 90% safe-world service and at most
1% unsafe unchecked admission, every feasible policy must effect-time
audit at least 79% of requests. -/
theorem half_utility_audit_floor (p : Mix) {kappa : ℚ}
    (h : Feasible p (9 / 10) (1 / 100) (1 / 2) kappa) :
    (79 / 100 : ℚ) ≤ kappa := by
  have hcap := capacity_floor p (by norm_num : (0 : ℚ) ≤ 1 / 2)
    (by norm_num : (1 / 2 : ℚ) ≤ 1) h
  norm_num at hcap ⊢
  linarith

/-- A priced policy attaining the capacity floor exactly. -/
def witness : Mix where
  audit := 79 / 100
  restrict := 1 / 5
  unchecked := 1 / 100
  deny := 0
  audit_nonneg := by norm_num
  restrict_nonneg := by norm_num
  unchecked_nonneg := by norm_num
  deny_nonneg := by norm_num
  mass := by norm_num

theorem witness_feasible :
    Feasible witness (9 / 10) (1 / 100) (1 / 2) (79 / 100) := by
  norm_num [Feasible, witness]

/-- The cost is a charge of 100 for each independent trusted audit and
10 for each restricted effect. Unchecked grants and denials are charged
zero; the costs are symbolic, NOT vendor prices. -/
def Cost (p : Mix) : ℚ := 100 * p.audit + 10 * p.restrict

/-- No policy meeting the legitimacy and unsafe-admission requirements
can beat the witness's expected charge of 81. -/
theorem cost_floor_81 (p : Mix) {kappa : ℚ}
    (h : Feasible p (9 / 10) (1 / 100) (1 / 2) kappa) :
    81 ≤ Cost p := by
  obtain ⟨hservice, hunsafe, _⟩ := h
  have hfloor : (79 / 100 : ℚ) ≤ p.audit :=
    half_utility_audit_floor p
      ⟨hservice, hunsafe, le_refl p.audit⟩
  unfold Cost
  norm_num at hservice hunsafe hfloor ⊢
  linarith

theorem witness_cost : Cost witness = 81 := by
  norm_num [Cost, witness]

/-- Matching lower bound and explicit construction, for a
nontrivial permission mode that substitutes hard restrictions for audit. -/
theorem sharp_capacity_cost :
    (∀ p : Mix,
      Feasible p (9 / 10) (1 / 100) (1 / 2) (79 / 100) →
        81 ≤ Cost p) ∧
    (∃ p : Mix,
      Feasible p (9 / 10) (1 / 100) (1 / 2) (79 / 100) ∧
        Cost p = 81) := by
  constructor
  · intro p h
    exact cost_floor_81 p h
  · exact ⟨witness, witness_feasible, witness_cost⟩

/-- Reducing the audit capacity below 79% makes the model infeasible
even when restricted effects and unchecked grants are available. -/
theorem capacity_78_impossible (p : Mix) :
    ¬ Feasible p (9 / 10) (1 / 100) (1 / 2) (78 / 100) := by
  intro h
  have hmin := half_utility_audit_floor p h
  norm_num at hmin

/-- If restriction is unavailable, at least 89% trusted effect-time
audits are unavoidable to meet the same availability and safety targets. -/
theorem without_restriction_floor (p : Mix) {kappa : ℚ}
    (h : Feasible p (9 / 10) (1 / 100) (1 / 2) kappa)
    (hnorestrict : p.restrict = 0) :
    (89 / 100 : ℚ) ≤ p.audit := by
  rcases h with ⟨hservice, hunsafe, _⟩
  rw [hnorestrict] at hservice
  norm_num at hservice hunsafe ⊢
  linarith

end Nightfall.PriceOfAdmission
