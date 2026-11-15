import Mathlib

/-!
# NIGHTFALL Price of Permission: exact joint evidence-capacity lower bound

This is a **finite, frozen-epoch, zero-error** permission-price theorem.
Each fresh mission predicate can be verified either by two complementary
one-slot observations (cost 2*c) or by one perfect direct one-slot test
(cost d ≥ 2*c). Independent full-support modular secrets justify the
information requirement; partial reads do not certify an action.

There are R fresh mission predicates, m interchangeable workers in H
verification slots, N legitimate effects, and g independent effect-time
guards all operating in one final slot. Cached certificates are assumed
authenticated, current, and correctly counted in R = N-(K0-B).
The complete trusted effect mediation of the modeled action set is an
**external engineering assumption**, not inferred from this arithmetic.

No in-window source updates, non-unit latencies, shared cross-action
observations, nondeterministic tests, or unmediated effect paths are covered.
-/

namespace Nightfall.PriceOfPermission.JointLowerBound

/-- The modular Boolean safety gate is safe exactly when its two inputs agree. -/
def modularSafe (x y : Bool) : Prop := x = y

/-- A single left-half observation has both a safe and unsafe completion. -/
theorem left_half_ambiguous (x : Bool) :
    ∃ good bad : Bool, modularSafe x good ∧ ¬ modularSafe x bad := by
  refine ⟨x, !x, rfl, ?_⟩
  cases x <;> decide

/-- A single right-half observation has both a safe and unsafe completion. -/
theorem right_half_ambiguous (y : Bool) :
    ∃ good bad : Bool, modularSafe good y ∧ ¬ modularSafe bad y := by
  refine ⟨y, !y, rfl, ?_⟩
  cases y <;> decide

/-- No deterministic monitor that sees only the left input can give correct
permission on *all* safe and unsafe full-support Boolean worlds. -/
theorem left_only_cannot_decide :
    ¬ ∃ verdict : Bool → Bool,
      ∀ x y, verdict x = true ↔ modularSafe x y := by
  rintro ⟨verdict, h⟩
  have hgood : modularSafe false false := rfl
  have hpass : verdict false = true := (h false false).2 hgood
  have hbad : modularSafe false true := (h false true).1 hpass
  exact (by decide : ¬ modularSafe false true) hbad

/-- The same impossibility holds for right-only monitoring. -/
theorem right_only_cannot_decide :
    ¬ ∃ verdict : Bool → Bool,
      ∀ x y, verdict y = true ↔ modularSafe x y := by
  rintro ⟨verdict, h⟩
  have hgood : modularSafe false false := rfl
  have hpass : verdict false = true := (h false false).2 hgood
  have hbad : modularSafe true false := (h true false).1 hpass
  exact (by decide : ¬ modularSafe true false) hbad

/-- A complete all-safe accepting plan can use two independent half-reads
or a direct test for each required predicate. Pairs use two worker-slots;
direct tests use one. This count-level plan abstraction is exhaustive for
the declared *independent* modular source with only those three sensors,
by the ambiguity lemmas above and the absence of cross-action sensors. -/
structure Plan (R capacity N guards : ℕ) where
  paired : ℕ
  direct : ℕ
  allFreshCovered : paired + direct = R
  withinDeadline : 2 * paired + direct ≤ capacity
  effectTimeGuards : N ≤ guards

/-- At least R worker-slots are unavoidable for R fresh actions. -/
theorem worker_slots_necessary {R capacity N guards : ℕ}
    (p : Plan R capacity N guards) : R ≤ capacity := by
  have hc := p.allFreshCovered
  have hw := p.withinDeadline
  omega

/-- Every permissible plan needs at least (2R-capacity)_+ direct tests.
The truncated natural-number difference is exactly the positive part. -/
theorem deep_tests_necessary {R capacity N guards : ℕ}
    (p : Plan R capacity N guards) :
    2 * R - capacity ≤ p.direct := by
  have hc := p.allFreshCovered
  have hw := p.withinDeadline
  omega

/-- The witness uses exactly the minimum unavoidable number of direct
tests, and otherwise uses complementary cheap pairs. -/
def optimalPlan (R capacity N guards : ℕ)
    (hcap : R ≤ capacity) (hg : N ≤ guards) :
    Plan R capacity N guards := by
  let deep := 2 * R - capacity
  let paired := R - deep
  refine ⟨paired, deep, ?_, ?_, hg⟩
  · dsimp [paired, deep]
    omega
  · dsimp [paired, deep]
    omega

/-- The witness is exact, not merely feasible. -/
theorem optimalPlan_direct (R capacity N guards : ℕ)
    (hcap : R ≤ capacity) (hg : N ≤ guards) :
    (optimalPlan R capacity N guards hcap hg).direct =
      2 * R - capacity := rfl

/-- A guard or worker resource shortage makes full timely admission
impossible under the stated two-clock admission contract. -/
theorem impossibility_of_shortage (R capacity N guards : ℕ)
    (h : capacity < R ∨ guards < N) :
    ¬ Nonempty (Plan R capacity N guards) := by
  intro ex
  rcases ex with ⟨p⟩
  rcases h with hw | hg
  · have necessary := worker_slots_necessary p
    omega
  · have necessary := p.effectTimeGuards
    omega

/-- Evidence price at fixed installed capacities, with no discount for
unproductive observations; such observations cannot improve this floor. -/
def evidenceCost {R capacity N guards : ℕ}
    (p : Plan R capacity N guards) (c d : ℕ) : ℕ :=
  2 * c * p.paired + d * p.direct

/-- Exact decomposition of information price and direct-verification premium. -/
theorem evidence_cost_decomposition {R capacity N guards : ℕ}
    (p : Plan R capacity N guards) (c d : ℕ)
    (hprice : 2 * c ≤ d) :
    evidenceCost p c d =
      2 * c * R + (d - 2 * c) * p.direct := by
  have hd : d = 2 * c + (d - 2 * c) := by omega
  calc
    evidenceCost p c d =
      2 * c * (p.paired + p.direct) +
        (d - 2 * c) * p.direct := by
          unfold evidenceCost
          rw [hd]
          ring
    _ = 2 * c * R + (d - 2 * c) * p.direct := by
      rw [p.allFreshCovered]

/-- The minimum joint *evidence* cost at fixed worker-slot capacity. -/
def evidenceFloor (R capacity c d : ℕ) : ℕ :=
  2 * c * R + (d - 2 * c) * (2 * R - capacity)

/-- The minimum complete batch price at fixed installed capacities,
including verifier facility, mandatory effect-guard facility and usage. -/
def permissionFloor (R H m N guards c d verifierFee guardFee effectFee : ℕ) : ℕ :=
  verifierFee * m + guardFee * guards + effectFee * N +
    evidenceFloor R (m * H) c d

/-- The price of a concrete plan under those same resource fees. -/
def permissionCost {R H m N guards : ℕ}
    (p : Plan R (m * H) N guards)
    (c d verifierFee guardFee effectFee : ℕ) : ℕ :=
  verifierFee * m + guardFee * guards + effectFee * N +
    evidenceCost p c d

/-- **Matching information + capacity lower bound.** All valid accepting
plans must pay the joint floor; the proof uses both the count-cover
constraint and the hard slot-capacity constraint. -/
theorem every_plan_pays_joint_floor {R H m N guards c d verifierFee guardFee effectFee : ℕ}
    (p : Plan R (m * H) N guards)
    (hprice : 2 * c ≤ d) :
    permissionFloor R H m N guards c d verifierFee guardFee effectFee ≤
      permissionCost p c d verifierFee guardFee effectFee := by
  have hdeep := deep_tests_necessary p
  have hmul := Nat.mul_le_mul_left (d - 2 * c) hdeep
  change
    verifierFee * m + guardFee * guards + effectFee * N +
        (2 * c * R + (d - 2 * c) * (2 * R - m * H)) ≤
      verifierFee * m + guardFee * guards + effectFee * N +
        evidenceCost p c d
  rw [evidence_cost_decomposition p c d hprice]
  omega

/-- **Matching construction.** The count of expensive tests equals the
lower bound. All independent jobs can be distributed among m·H worker
slots, then guarded in the final effect slot (under the physical contract). -/
theorem joint_floor_is_attainable
    (R H m N guards c d verifierFee guardFee effectFee : ℕ)
    (hcap : R ≤ m * H) (hg : N ≤ guards)
    (hprice : 2 * c ≤ d) :
    ∃ p : Plan R (m * H) N guards,
      permissionCost p c d verifierFee guardFee effectFee =
        permissionFloor R H m N guards c d verifierFee guardFee effectFee := by
  let p := optimalPlan R (m * H) N guards hcap hg
  refine ⟨p, ?_⟩
  change
    verifierFee * m + guardFee * guards + effectFee * N +
        evidenceCost p c d =
      verifierFee * m + guardFee * guards + effectFee * N +
        evidenceFloor R (m * H) c d
  rw [evidence_cost_decomposition p c d hprice]
  change
    verifierFee * m + guardFee * guards + effectFee * N +
      (2 * c * R + (d - 2 * c) * p.direct) =
    verifierFee * m + guardFee * guards + effectFee * N +
      (2 * c * R + (d - 2 * c) * (2 * R - m * H))
  rw [optimalPlan_direct]

/-- Exact matching lower and upper permission price for all finite input
sizes, with explicit feasibility conditions and real resource charges.
This does NOT hide a caller-supplied 'joint optimum' assumption. -/
theorem exact_joint_permission_price
    (R H m N guards c d verifierFee guardFee effectFee : ℕ)
    (hcap : R ≤ m * H) (hg : N ≤ guards)
    (hprice : 2 * c ≤ d) :
    (∀ p : Plan R (m * H) N guards,
      permissionFloor R H m N guards c d verifierFee guardFee effectFee ≤
        permissionCost p c d verifierFee guardFee effectFee) ∧
    (∃ p : Plan R (m * H) N guards,
      permissionCost p c d verifierFee guardFee effectFee =
        permissionFloor R H m N guards c d verifierFee guardFee effectFee) := by
  constructor
  · intro p
    exact every_plan_pays_joint_floor p hprice
  · exact joint_floor_is_attainable
      R H m N guards c d verifierFee guardFee effectFee hcap hg hprice

/-- Cached certificates survive exactly B authorized pre-window
invalidations; the source epoch is assumed frozen afterward. -/
def freshActions (N initialCache invalidated : ℕ) : ℕ :=
  N - (initialCache - invalidated)

/-- End-to-end **finite zero-error source-cache / worker-slot / guard**
price theorem, with no caller-supplied cost or optimum premises. -/
theorem exact_cached_permission_price
    (N initialCache invalidated H m guards c d verifierFee guardFee effectFee : ℕ)
    (hcache : initialCache ≤ N)
    (hinvalid : invalidated ≤ initialCache)
    (hcapacity : freshActions N initialCache invalidated ≤ m * H)
    (hguard : N ≤ guards)
    (hprice : 2 * c ≤ d) :
    (∀ p : Plan (freshActions N initialCache invalidated) (m * H) N guards,
      permissionFloor (freshActions N initialCache invalidated)
        H m N guards c d verifierFee guardFee effectFee ≤
        permissionCost p c d verifierFee guardFee effectFee) ∧
    (∃ p : Plan (freshActions N initialCache invalidated) (m * H) N guards,
      permissionCost p c d verifierFee guardFee effectFee =
        permissionFloor (freshActions N initialCache invalidated)
          H m N guards c d verifierFee guardFee effectFee) := by
  exact exact_joint_permission_price
    (freshActions N initialCache invalidated)
    H m N guards c d verifierFee guardFee effectFee
    hcapacity hguard hprice

/-- Canonical exact three-action witness: one lost valid certificate
raises the minimum evidence cost from 4 to 12, exceeding direct fee 5. -/
theorem invalidation_amplification_witness :
    evidenceFloor 2 4 1 5 = 4 ∧
    evidenceFloor 3 4 1 5 = 12 ∧
    evidenceFloor 3 4 1 5 - evidenceFloor 2 4 1 5 = 8 ∧
    5 < (evidenceFloor 3 4 1 5 - evidenceFloor 2 4 1 5) := by
  decide

/-- At fixed m=2, g=3, facility fees 4 and 1, guard use fee 1:
full three-action permission price is 18 before, 26 after invalidation. -/
theorem fixed_facility_price_witness :
    permissionFloor 2 2 2 3 3 1 5 4 1 1 = 18 ∧
    permissionFloor 3 2 2 3 3 1 5 4 1 1 = 26 := by
  decide

/-- Purchasing a third worker after invalidation lowers full batch
price from 26 to 24 without violating the zero-error deadline. -/
theorem purchase_a_third_worker_witness :
    permissionFloor 3 2 3 3 3 1 5 4 1 1 = 24 ∧
    permissionFloor 3 2 3 3 3 1 5 4 1 1 <
      permissionFloor 3 2 2 3 3 1 5 4 1 1 := by
  decide

end Nightfall.PriceOfPermission.JointLowerBound
