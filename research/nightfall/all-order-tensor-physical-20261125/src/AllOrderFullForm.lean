import AllOrderPatternAssembly

namespace Nightfall.AllOrder.Geometry
open Finset
open Nightfall.AllOrder
open Nightfall.StructuralInformation.T2UniformParseval
variable {J K : Type*} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

/-- Explicit norm and cardinality constants, depending only on the actual
    tensor depth, local alphabet cardinality, slot count, and input norm. -/
noncomputable def patternNorm (L s d : ℕ) (V : ℝ) : ℝ :=
  ((rowBallBound L s (circuitRadius s d) : ℝ)+2)^(d+d^2+2^d)*V

noncomputable def patternCount (d : ℕ) : ℕ := 2^(d+d^2+2^d)

noncomputable def totalNorm (L s n : ℕ) (V : ℝ) : ℝ :=
  Real.sqrt ((3:ℝ)^n)*patternNorm L s (n+1) V

noncomputable def riskFactor (L s d : ℕ) : ℝ :=
  (patternCount d : ℝ)^2*(fiberBound L s d : ℝ)*(d:ℝ)

noncomputable def simulationBudget (L s n : ℕ) (V eps delta : ℝ) : ℕ :=
  patternCount (n+1)*(n+1)*⌈totalNorm L s n V*(riskFactor L s (n+1)*totalNorm L s n V+1)/(eps^2*delta)⌉₊

/-- Fully assembled original-label simulation for one bounded multilinear
    form on the actual binary tensor-character law. Pattern coefficients,
    support, norm and active-fiber bound are constructed, not assumed. -/
theorem bounded_tensor_form_simulation {n : ℕ}
    (c : (Fin (n+1) → Label J K) → ℝ) (V eps delta : ℝ)
    (hV : 0 ≤ V) (hc : CubeBound c V) (heps : 0 < eps) (hdelta : 0 < delta)
    (hf : ∀ s : AddChar (Tensor J K) ℂ,
       0 ≤ phaseEval optionLabel univ c s ∧ phaseEval optionLabel univ c s ≤ 1) :
    ∃ Q : Finset (Label J K), Q.card ≤ simulationBudget (Fintype.card J) (Fintype.card (NonzeroFactor K)) n V eps delta ∧
      ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar (Tensor J K) ℂ =>
        eps < |phaseEval optionLabel univ c s - g (fun a => s (optionLabel a.1))|)).card : ℝ) ≤
        (Fintype.card (AddChar (Tensor J K) ℂ) : ℝ)*delta := by
  classical
  let L := Fintype.card J
  let s := Fintype.card (NonzeroFactor K)
  let d := n+1
  let r := circuitRadius s d
  let C := patternNorm L s d V
  let M := totalNorm L s n V
  let H := riskFactor L s d
  let t := eps^2*delta/(H*M+1)
  let m := ⌈M*(H*M+1)/(eps^2*delta)⌉₊
  have hCnon : 0 ≤ C := by unfold C patternNorm; positivity
  have hMnon : 0 ≤ M := by change 0 ≤ Real.sqrt ((3:ℝ)^n)*C; positivity
  have hHnon : 0 ≤ H := by unfold H riskFactor; positivity
  have hden : 0 < H*M+1 := by positivity
  have hnum : 0 < eps^2*delta := by positivity
  have ht : 0 < t := div_pos hnum hden
  have hMt : Real.sqrt ((3:ℝ)^n)*C ≤ (m:ℝ)*t := by
    change M ≤ (m:ℝ)*t
    unfold t
    rw [← mul_div_assoc]
    apply (le_div_iff₀ hden).mpr
    have hm : M*(H*M+1)/(eps^2*delta) ≤ (m:ℝ) := Nat.le_ceil _
    exact (div_le_iff₀ hnum).mp hm
  have hP : Fintype.card (Pattern (Fin (n+1))) = patternCount d := by rw [pattern_card]; simp [patternCount,d]
  have hChaos : ∀ p : Pattern (Fin (n+1)), ∀ x, |chaos (contractedCoeff c r p) x| ≤ C := by
    intro p x
    have h := contracted_cube_bound c r p V hV hc (fun i a => rad (x i a)) (by intro i a; cases x i a <;> norm_num [rad])
    simpa [chaos,cubeForm,C,patternNorm,L,s,d,r,test_card,pow_two,Nat.add_assoc] using h
  have hBudget : (Fintype.card (Pattern (Fin (n+1))) : ℝ)^2 * (fiberBound L s d : ℝ)*
        (d:ℝ)*(t*(Real.sqrt ((3:ℝ)^n)*C)) ≤ eps^2*delta := by
    rw [hP]
    change H*(t*M) ≤ eps^2*delta
    unfold t
    calc
      H * (eps^2*delta/(H*M+1)*M) = eps^2*delta*(H*M)/(H*M+1) := by ring
      _ ≤ eps^2*delta := (div_le_iff₀ hden).mpr (by nlinarith [hnum.le])
  obtain ⟨Q,hQ,g,hg,herr⟩ := tensor_pattern_simulation (contractedCoeff c r) (contractedSupport r)
    t C eps delta m ht heps hMt hChaos (fun p b hb => contracted_support_good r p b hb)
    (fun z => by rw [contracted_phase_identity]; exact hf z) hBudget
  refine ⟨Q,?_,g,hg,?_⟩
  · rw [hP] at hQ
    exact hQ
  · simpa only [contracted_phase_identity] using herr

#print axioms bounded_tensor_form_simulation
end Nightfall.AllOrder.Geometry
