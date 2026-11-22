import Mathlib

/-!
# NIGHTFALL: universal causal response-envelope erasure

This is the reusable mechanism behind the PR #1001 squared-intensity noise
floor. A sensing stage may depend on arbitrary prior *corrupted* observations,
and the response need not be linear, quadratic, or even. The single structural
requirement is that all its responses on a specified input set fit into a
nonnegative interval [0,2σ] on every history. An adversary with additive
error at most σ then forces all those inputs to the same all-σ transcript.

The erasure theorem proves no geometric reconstruction-radius inequality by
itself. In particular, it does not prove a novel minimax phase-retrieval law,
only a reusable source-checked indistinguishability operator.
-/

namespace Nightfall.EnvelopeErasure

variable {X : Type*}

/-- Physical observed history, stored in reverse chronological order. -/
def transcript (response : ℕ → List ℝ → X → ℝ)
    (x : X) (noise : ℕ → ℝ) : ℕ → List ℝ
  | 0 => []
  | k + 1 =>
      let h := transcript response x noise k
      (response k h x + noise k) :: h

/-- Explicit bounded adversarial error against a shared target observation σ. -/
def erasingNoise (response : ℕ → List ℝ → X → ℝ)
    (x : X) (σ : ℝ) (k : ℕ) : ℝ :=
  σ - response k (List.replicate k σ) x

/-- The actual causal history is constant, with no assumed collision or
virtual-prefix shortcut. -/
theorem transcript_erased (response : ℕ → List ℝ → X → ℝ)
    (x : X) (σ : ℝ) (m : ℕ) :
    transcript response x (erasingNoise response x σ) m =
      List.replicate m σ := by
  induction m with
  | zero => rfl
  | succ k ih =>
      simpa [transcript, ih, erasingNoise, List.replicate_succ]

/-- The exact width-2σ feasibility condition. -/
theorem erasingNoise_bound
    (response : ℕ → List ℝ → X → ℝ) (x : X) (σ : ℝ)
    (hresp : ∀ k h, 0 ≤ response k h x ∧ response k h x ≤ 2 * σ)
    (k : ℕ) :
    |erasingNoise response x σ k| ≤ σ := by
  obtain ⟨h0, h2⟩ := hresp k (List.replicate k σ)
  change |σ - response k (List.replicate k σ) x| ≤ σ
  apply abs_le.mpr
  constructor <;> linarith

/-- A full input set satisfying a uniform response envelope admits a common
corrupted transcript, independently of the number of adaptive queries.
Any minimax radius conclusion requires a *separate* geometric proof. -/
theorem envelope_erasure
    (response : ℕ → List ℝ → X → ℝ) (S : Set X)
    (σ : ℝ) (m : ℕ)
    (hresp : ∀ k h x, x ∈ S →
      0 ≤ response k h x ∧ response k h x ≤ 2 * σ) :
    ∀ x ∈ S, ∃ noise : ℕ → ℝ,
      (∀ k, |noise k| ≤ σ) ∧
      transcript response x noise m = List.replicate m σ := by
  intro x hx
  refine ⟨erasingNoise response x σ, ?_, transcript_erased response x σ m⟩
  intro k
  exact erasingNoise_bound response x σ (fun j h => hresp j h x hx) k

#print envelope_erasure
#print axioms envelope_erasure
#print axioms transcript_erased
#print axioms erasingNoise_bound

end Nightfall.EnvelopeErasure
