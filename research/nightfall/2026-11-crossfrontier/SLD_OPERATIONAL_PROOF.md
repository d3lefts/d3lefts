# Quantum SLD visibility: exact physical and operational proof (research manuscript)

Date 2026-11-16; candidate for a transitive pinned Lean certificate; **analytic proof completed in this note, but NOT a Lean-certified quantum theorem or externally refereed result**. Imports standard finite-dimensional quantum decision theory; research predecessor: PR #397 and check_sld_separation.py.

## 1. Physical qubit ensemble and task

For p∈(0,1), q=1−p, ω=exp(2πi/3), X_j independent uniform on {0,1,2}, set
|ψ_x⟩=√p |0⟩+√q ω^x |1⟩ and ρ_x=|ψ_x⟩⟨ψ_x|. Each ρ_x is a valid rank-one density operator: Hermitian PSD, trace 1. The global encoded state for x=(x_1,...,x_d) is ρ_x^{(d)}=⊗_j ρ_{x_j}. The real task is f(x)=Re ω^{∑x_j}. For every d≥1, E f=0 and E f²=1/2.

Let B=Eρ_X^{(d)}, A=E[f(X)ρ_X^{(d)}]. Averaging a local ternary character gives B=diag(p,q)^{⊗d}. Character orthogonality (sum of ω^x over x=0,1,2 is zero) kills all terms except the two all-offdiagonal extreme corners:
A=c (|0^d⟩⟨1^d|+|1^d⟩⟨0^d|), c=(pq)^{d/2}/2.
For every proper subset of measured registers, partial trace of A vanishes, since each omitted register contains a traceless offdiagonal |0⟩⟨1| or its adjoint. Thus no measurement on fewer than d complete registers gives positive Bayes improvement for f.

## 2. Exact optimum over *all allowed POVMs*

Consider any finite POVM {E_z}, E_z≥0, ∑E_z=I on the entire d-qubit register. Define w_z=Tr(E_z B) and a_z=Tr(E_z A), taking a_z²/w_z=0 whenever w_z=0. The optimal squared-loss estimator for outcome z is the posterior mean m_z=a_z/w_z, and its Bayes improvement relative to predicting E f=0 is Δ({E_z})=∑_z a_z²/w_z.

Because B is strictly positive for 0<p,q<1, there is a unique Hermitian symmetric logarithmic derivative (SLD) L solving (BL+LB)/2=A. Define the B-symmetrized positive inner product ⟨H,J⟩_B=Tr[B(HJ+JH)/2] on Hermitian observables. For each POVM effect E_z, the elementary Cauchy–Schwarz/Kadison argument gives a_z²≤w_z Tr(B L E_z L) (equivalently, a_z²≤w_z Tr(E_z LBL) via Hermitian cyclic rearrangement, with a symmetric trace alternative). Summing and using ∑ E_z=I gives Δ({E_z})≤Tr(BL²)=Tr(AL).

**Operational equality:** Measure the spectral projectors of L. For an eigenprojector P_λ, Tr(P_λ A)=Tr(P_λ (BL+LB)/2)=λ Tr(P_λ B); hence its posterior mean is λ, and summing λ²Tr(P_λ B)=Tr(BL²). This is an actual projective measurement (hence valid POVM) attaining the upper bound, not an abstract information functional.

The upper bound also follows cleanly by setting X_z=E_z^{1/2}B^{1/2} and Y_z=E_z^{1/2}LB^{1/2}: Re Tr(X_z*Y_z)=a_z and |Tr(X_z*Y_z)|²≤Tr(X_z*X_z)Tr(Y_z*Y_z)=w_z Tr(B L E_z L). This resolves trace-order sensitivity explicitly.

## 3. Solve the SLD and compute exact visibility

The only nonzero matrix elements of A lie between |0^d⟩ and |1^d⟩, whose B-eigenvalues are p^d and q^d. Therefore
L=(2c/(p^d+q^d)) (|0^d⟩⟨1^d|+|1^d⟩⟨0^d|).
Then Tr(AL)=4c²/(p^d+q^d)=(pq)^d/(p^d+q^d).
The optimal projective measurement is onto the normalized GHZ-like vectors (|0^d⟩±|1^d⟩)/√2 and the orthogonal complement. The ± outcomes have probabilities (p^d+q^d)/2 and posterior means ±(pq)^{d/2}/(p^d+q^d); all complement outcomes have posterior zero. Both the resulting Bayes gain and the SLD energy are therefore physically attained.

For a single local site, the real cosine/sine tangent Gram matrix is a I₂ with a=2pq. The variance and resampling influence of f are each 1/2. Thus the normalized extra transfer factor is
Δ_d/(a^d I_i)=2^{1−d}/(p^d+q^d).
Taking p→1 at any fixed d establishes sharpness of the 2^{1−d} constant under the stated positive-gap assumptions. At the fixed nonzero p=3/4 (a=3/8), this ratio is 2^{d+1}/(3^d+1)∼2(2/3)^d. Hence no bound replacing the *additional* factor by a degree-polynomial lower penalty can hold universally under these hypotheses. Do not confuse this with the independent a^d penalty.

## 4. Separate Hermitian simple-tensor inequality

Let each b_t be positive definite with spectrum λ_{t,i}>0, and H_t Hermitian. The SLD quadratic form is Q_b(H)=Σ_{ij} 2|H_ij|²/(λ_i+λ_j). For the tensor product, compare each unordered index-pair's 2^d independent orientation flips. Write λ_{t,i}=s_t(1+δ_t), λ_{t,j}=s_t(1−δ_t), |δ_t|<1. The oriented denominator is
D_ε=∏_t s_t [∏_t(1+ε_tδ_t)+∏_t(1−ε_tδ_t)].
Its average over ε∈{±1}^d is 2∏_t s_t. The map z→1/z is convex on positive z, so Jensen gives E_ε[2/D_ε]≥1/∏_t s_t=∏_t 2/(λ_{t,i}+λ_{t,j}). The numerator product |H_{ij}|² is invariant under each orientation because the H_t are Hermitian. Multiply and sum to prove
Q_{⊗b_t}(⊗H_t)≥∏_t Q_{b_t}(H_t).
This states a simple-tensor Hermitian inequality, not an unrestricted entangled quantum influence theorem.

## 5. Checker and formalization contract

Existing independent direct-matrix script: research/nightfall/2026-11-sld-transfer-sharpness/check_sld_separation.py. It reconstructs B,A from all 3^d input states for d≤6, checks local tangent Gram and exact rational predictions, and attacks simple-tensor inequality on 600 Hermitian models. **Not a Lean proof.**

Transitive Lean terminal must construct actual complex density matrices and tensor products, prove PSD/trace, character cancellation, SLD existence/uniqueness, every-POVM upper bound, physical spectral-projector equality, nontrivial local visibility, proper-subset zero gain and the Jensen tensor inequality. A Lean scalar/corner sublemma alone is a stage, not terminal. Independent quantum referee must attack POVM quantifiers, degeneracies p→0, empty/zero-probability outcomes, tensor support and distinction between geometric and SLD Gram metrics.

## 6. Exact correction to potential Cauchy Schwarz trace mistake

The correct Cauchy-Schwarz witness for a_z is X_z=E_z^{1/2} B^{1/2}, Y_z=E_z^{1/2} L B^{1/2}: Re Tr(X_z*Y_z)=Re Tr(B E_z L)=Tr(E_z A). The Y quadratic is Tr(B L E_z L), and it sums to Tr(BL²). Directly replacing this by Tr(E_z B L²) term-by-term without a proof of commutation would be an error. The exact measurement equality supplies a noncommuting audit of the operator bound.
