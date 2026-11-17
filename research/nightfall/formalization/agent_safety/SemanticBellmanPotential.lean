import SemanticFencing

/-!
# Bellman lower-bound potentials as independent policy certificates

The source-driven policy solver is untrusted. A potential `L` gives a
lower bound for *every* valid action at every belief set. Induction on
an actual valid evidence plan then proves `L B ≤ cost(plan)`.
A valid proposed plan attaining `L B` is globally optimal.

This imports NIGHTFALL's existing original-world `PlanValid`,
`EvidencePlan`, `FenceSound`, and `worstCost`. Source completeness,
authenticated version counters and atomic effect-time enforcement remain
assumptions of the model, never consequences of this theorem.
-/

namespace Nightfall.SemanticFencing

universe u v

variable {Source : Type u} {World : Type v}

/-- A local Bellman lower certificate must lie below **every** available
terminal decision and every legitimate splitting observation, on *each*
relevant belief set. This is a subsolution condition, not merely the value
reported by an optimizer or one chosen action. -/
def BellmanLowerCertificate
    (M : System Source World) (obs : Source → World → Bool)
    (readPrice checkPrice : Source → ℕ)
    (L : Set World → ℕ) : Prop :=
  (∀ B : Set World,
    (∀ x, x ∈ B → ¬ M.safe x) →
    L B ≤ 0) ∧
  (∀ (B : Set World) (guard : Finset Source),
    (∀ x, x ∈ B → M.safe x) →
    FenceSound M B guard →
    L B ≤ fenceCost checkPrice guard) ∧
  (∀ (B : Set World) (i : Source),
    (∃ x, x ∈ readFiber B obs i false) →
    (∃ x, x ∈ readFiber B obs i true) →
    L B ≤ readPrice i +
      max (L (readFiber B obs i false))
          (L (readFiber B obs i true)))

/-- Every valid finite evidence plan costs at least the Bellman potential.
No optimizer, numerical approximation or original source distribution
is referenced. A read must split into two nonempty proper fibers. -/
theorem bellman_lower_certificate_sound
    (M : System Source World) (obs : Source → World → Bool)
    (readPrice checkPrice : Source → ℕ)
    (L : Set World → ℕ)
    (hL : BellmanLowerCertificate M obs readPrice checkPrice L) :
    ∀ (B : Set World) (p : EvidencePlan Source),
      PlanValid M obs B p →
      L B ≤ worstCost readPrice checkPrice p := by
  rcases hL with ⟨hdeny, hgrant, hread⟩
  intro B p
  induction p generalizing B with
  | deny =>
      intro hp
      simpa [worstCost] using hdeny B hp
  | grant guard =>
      intro hp
      exact hgrant B guard hp.1 hp.2
  | read i no yes ihNo ihYes =>
      intro hp
      obtain ⟨hzero, hone, hpzero, hpone⟩ := hp
      have hz := ihNo (readFiber B obs i false) hpzero
      have ho := ihYes (readFiber B obs i true) hpone
      calc
        L B ≤ readPrice i +
            max (L (readFiber B obs i false))
                (L (readFiber B obs i true)) := hread B i hzero hone
        _ ≤ readPrice i +
            max (worstCost readPrice checkPrice no)
                (worstCost readPrice checkPrice yes) := by
              exact Nat.add_le_add_left (max_le_max hz ho) (readPrice i)
        _ = worstCost readPrice checkPrice (.read i no yes) := rfl

/-- A feasible policy tree **matching** the independently checked Bellman
lower potential is globally minimum-cost among all valid evidence plans.
This provides a reusable proof-carrying policy optimality interface. -/
theorem bellman_matching_policy_optimal
    (M : System Source World) (obs : Source → World → Bool)
    (readPrice checkPrice : Source → ℕ)
    (L : Set World → ℕ)
    (hL : BellmanLowerCertificate M obs readPrice checkPrice L)
    (B : Set World) (p : EvidencePlan Source)
    (hvalid : PlanValid M obs B p)
    (hmatch : worstCost readPrice checkPrice p = L B) :
    ∀ q : EvidencePlan Source,
      PlanValid M obs B q →
      worstCost readPrice checkPrice p ≤ worstCost readPrice checkPrice q := by
  intro q hq
  rw [hmatch]
  exact bellman_lower_certificate_sound M obs readPrice checkPrice L hL B q hq

end Nightfall.SemanticFencing
