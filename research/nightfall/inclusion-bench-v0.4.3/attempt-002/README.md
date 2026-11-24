# Attempt 002 — one-frequency counting obstruction and exact sampling escape

Status: paper-level derivation, exact finite test passed, Lean source authored but not compiled; not a new benchmark inclusion or novelty claim. No external submission. Do not conflate this restricted family with all BQP.

## Frozen contract
InclusionBench v0.4.3 at 326065e17df73039332b4fd974b1e335dc4b5e68; NIGHTFALL source at 8cc18c23f85de99acef05f2adff22d0a6a6b1b63. Target: test whether secant support cardinality plus uniform access suffices for polynomial-time coefficient evaluation. Alternative: exact sampling can avoid evaluation altogether. Pass criterion: explicit circuit family, arithmetic identity, complexity reductions, independent arithmetic replay and named Lean obligations. Stop before any open class claim without a closed proof.

## Theorem (paper level; scoped standard counting construction)
For any two uniform polynomial-time Boolean predicates A(x,y), B(x,y) with a common polynomial witness width m(|x|), write N=2^m and g(x)=#A(x)-#B(x). There is a uniform circuit with one external phase query to a single unknown bit z and acceptance
p_x(z)=1/2+(-1)^z g(x)/(2N).
The acceptance Fourier support in z is contained in {0,1}; it is exactly {0,1} if g(x) is nonzero. Nevertheless exact signed coefficient computation is GapP-hard (and #P-hard by B identically false), positive coefficient decision captures PP, and zero coefficient decision captures C_=P. All these statements concern exact values or unbounded-error thresholds, not bounded-error BQP. In contrast the circuit's acceptance bit has an exact uniform classical sampler using one query to z and one evaluation of A or B.

Proof: prepare a uniform superposition over selector b and y, and a control |+>. Conditioned on b,y, apply to the control's |1> component a phase sigma = 2A(x,y)-1 for b=0 and 1-2B(x,y) for b=1. Compute/uncompute the Boolean predicates with reversible classical circuitry; all workspace can be cleaned. A single phase query multiplies that component by (-1)^z. A final H on the control followed by acceptance on outcome 0 contributes (1+(-1)^z sigma)^2/(8N) per orthogonal selector/witness sector. Summation gives the stated formula. The gates H, reversible classical gates and controlled phase are exactly realizable in H/T/X/CNOT (standard exact Toffoli synthesis); the external phase query is an explicit separate oracle operation. If z is supplied as ordinary classical input it is directly implementable. The matching sampler chooses b,y uniformly, reads z once, and accepts iff (A if b=0 else NOT B) XOR z is true. This gives equality of the entire one-bit output law, not just approximation.

Counting reductions: every GapP function is a difference of #P counts. Each count can be encoded as a polynomial-length witness relation with one witness per accepting machine path (uniquely pad after halting and encode transition indices with invalid encodings rejected). Equalize the widths by requiring padding bits zero. Recover g by multiplying the nonconstant Fourier coefficient by 2N; for #SAT take B identically false. Sign and zero characterize the benchmark's operational PP and CeqP through the GapP definitions and these standard count-to-witness encodings. Thus an FP exact coefficient algorithm for all such circuits implies FP=#P (with standard integer-output convention). This is a conditional implication, not a separation.

## Why this matters to NIGHTFALL
Even an explicitly known single frequency with a uniformly computable summand can hide exponentially many contributing paths. Bounding distinct XOR frequencies does not bound multiplicity or the cost of combining coefficients. Importantly, the same family is exactly sampleable without computing the coefficient: counting hardness is not a barrier to weak simulation. The corrected research object is a uniform bounded-variance sampling representation, not an exact sparse Fourier listing.

For the wider bridge, the trusted GapP exponential-sum interface safely accepts a uniformly FP signed term on a polynomial-width binary index, even when the number of terms is exponential. PP and CeqP sign/zero terminals follow without materializing the array. These are existing counting mechanisms, not new general complexity inclusions.

## Certificate / independent arithmetic test
Run python3 check.py. Actual session result: PASS: 65812 ordered truth-table pairs, 2 oracle bits each; exact rational quantum/classical agreement and coefficient signs. Exhaustive for m=0,1,2,3. The two routes use squared amplitudes and Boolean sampling counts independently. This is a finite arithmetic replay, not independent human theorem review. OneFrequency.lean states the integer count identity and benchmark GapP/PP/CeqP terminals; the quantum source and uniform circuit construction remain paper-level and the Lean module is not verified here. No new axioms or sorry intended. Do not map any helper to a closed class claim.

## Prior art and novelty limits (checked 2026-11-23)
- Fenner, Green, Homer and Pruim, Determining acceptance possibility for a quantum computation (1999), and Montanaro, Quantum circuits and low-degree polynomials over F2: standard GapP/amplitude and exact-hardness antecedents.
- https://people.maths.bris.ac.uk/~csxam/papers/lowdegree.pdf
- https://ocw.mit.edu/courses/18-405j-advanced-complexity-theory-spring-2016/4d5054520a7b726a9863987c5d616684_MIT18_405JS16_QuantumCompt.pdf
- https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.TQC.2021.4 establishes the known StoqMA ⊆ SBP direction; do not repurpose as a discovery.
The explicit scoped transfer to NIGHTFALL's secant method is useful as a design constraint; no global novelty is asserted.

## Next experiment
Recover a source-exact two-query terminal and prove a uniformly sampleable factorization with an inverse-polynomial variance bound for a nontrivial circuit family; test coherent intermediate unitaries where the selector ceases to label orthogonal final sectors. Require per-input error (not average over secrets). Compare against standard quasiprobability/weak-simulation methods; only then attempt an unconditional class relation. A known zero-point control is not evidence for a new inclusion.
