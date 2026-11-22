import Mathlib

/-!
# A2: genuine adaptive grouped noisy-sign oracle and likelihood factorization

A hidden sign vector ν : I → Bool is queried using the exact group oracle:
query q returns one *fresh independent* noisy bit per i in G q, with
P(U_i=ν_i)=(1+β_i)/2, and returns a deterministic placeholder outside G q.
A legal selection policy depends only on the observed past. The source-level
path likelihood therefore factorizes across independent hidden coordinates,
for **any** finite adaptive history, including arbitrary feedback.

This does NOT prove the asymptotic A2 theorem, Bayesian loss identity,
unbounded optional stopping, KL-conversion or optimal acquisition schedule.
-/ 

namespace Nightfall.GroupAdaptiveLikelihood

open Finset

variable {I Q : Type*} [Fintype I] [Fintype Q]
  [DecidableEq I] [DecidableEq Q]

abbrev Observation (I Q : Type*) := Q × (I → Bool)
abbrev History (I Q : Type*) := List (Observation I Q)

/-- One actual component of the grouped observation model; outside the
paid group there is no disclosure, only a canonical false placeholder. -/
noncomputable def componentMass
    (G : Q → I → Prop) (β : I → ℝ)
    (i : I) (ν : Bool) (q : Q) (bit : Bool) : ℝ := by
  classical
  exact if G q i then
    (if bit = ν then (1 + β i) / 2 else (1 - β i) / 2)
    else if bit = false then 1 else 0

/-- The *actual* joint conditional response probability of a group query,
including independence of fresh component noise. -/
noncomputable def groupMass
    (G : Q → I → Prop) (β : I → ℝ)
    (ν : I → Bool) (q : Q) (u : I → Bool) : ℝ :=
  ∏ i, componentMass G β i (ν i) q (u i)

/-- The exact history-dependent decision of the paid group is modelled by
a deterministic causal selection rule on preceding observations. -/
def Legal (policy : History I Q → Q) : History I Q → Prop
  | [] => True
  | (q, _) :: rest => q = policy rest ∧ Legal policy rest

/-- Under a fixed hidden sign vector, multiply original source conditional
response probabilities along the legal adaptive history, including a zero
mass for illegal proposed query actions. -/
noncomputable def transcriptMass
    (G : Q → I → Prop) (β : I → ℝ)
    (policy : History I Q → Q)
    (ν : I → Bool) : History I Q → ℝ
  | [] => 1
  | (q, u) :: rest =>
    (if q = policy rest then 1 else 0) *
      groupMass G β ν q u *
      transcriptMass G β policy ν rest

/-- Coordinate-local likelihood extracted from the same actual observation
history. Despite group-selection feedback, it depends on ν only via ν_i. -/
noncomputable def coordinateLikelihood
    (G : Q → I → Prop) (β : I → ℝ)
    (i : I) (ν : Bool) : History I Q → ℝ
  | [] => 1
  | (q, u) :: rest =>
    componentMass G β i ν q (u i) *
      coordinateLikelihood G β i ν rest

/-- No external conditional-independence premise:
the history probability **itself** factorizes across the true hidden bits;
causal group-selection factors are independent of ν once history is fixed. -/
theorem transcript_factorization
    (G : Q → I → Prop) (β : I → ℝ)
    (policy : History I Q → Q) (ν : I → Bool)
    (h : History I Q) :
    transcriptMass G β policy ν h =
      (if Legal policy h then (1 : ℝ) else 0) *
        ∏ i, coordinateLikelihood G β i (ν i) h := by
  classical
  induction h with
  | nil =>
      simp [transcriptMass, Legal, coordinateLikelihood]
  | cons step rest ih =>
      rcases step with ⟨q, u⟩
      simp only [transcriptMass, Legal, coordinateLikelihood]
      rw [ih]
      by_cases hq : q = policy rest
      · by_cases hr : Legal policy rest
        · simp [hq, hr, groupMass, Finset.prod_mul_distrib,
            mul_assoc, mul_comm, mul_left_comm]
        · simp [hq, hr]
      · simp [hq]

/-- Source-normalizer factorization for every legal adaptive transcript.
The prior is independent uniform signs, so this identity supplies its
entire unnormalized Bayes posterior without assuming it factorizes. -/
theorem hidden_normalizer_factorization
    (G : Q → I → Prop) (β : I → ℝ)
    (policy : History I Q → Q) (h : History I Q)
    (hlegal : Legal policy h) :
    (∑ ν : I → Bool, transcriptMass G β policy ν h) =
      ∏ i, ∑ bit : Bool, coordinateLikelihood G β i bit h := by
  classical
  calc
    (∑ ν : I → Bool, transcriptMass G β policy ν h) =
        ∑ ν : I → Bool, ∏ i, coordinateLikelihood G β i (ν i) h := by
      apply Finset.sum_congr rfl
      intro ν hν
      rw [transcript_factorization]
      simp [hlegal]
    _ = ∏ i, ∑ bit : Bool, coordinateLikelihood G β i bit h :=
      (Fintype.prod_sum (fun i (bit : Bool) =>
        coordinateLikelihood G β i bit h)).symm

end Nightfall.GroupAdaptiveLikelihood

#print axioms Nightfall.GroupAdaptiveLikelihood.transcript_factorization
#print axioms Nightfall.GroupAdaptiveLikelihood.hidden_normalizer_factorization
