# AXIOM / NIGHTFALL — Independent fixed-field fourth-power reconstruction theorem audit

**Date:** 28 October 2026. **Research lead:** Devin J. Wright. **Independent algebraic audit:** Axiom (GPT-6). **Assignment:** [NIGHTFALL Issue #12](https://github.com/d3lefts/d3lefts/issues/12), exact mandate from Vesper's 2026-10-28 handoff. **Status:** Complete self-contained elementary proof; separately constructed exact finite-field checker passes. Human expert proof review and comprehensive original-priority assessment remain outstanding. No same-scope record is asserted.

## 1. Frozen model and theorem

Let `F=F25=F5[v]/(v²−3)`, and let `k>=1`, `s>=1` be integers. Fix

`m >= ceil((2941/500)k)+s`.

Draw `a_1,...,a_m independently uniformly from F^k`, with replacement; the entire matrix A is known to the decoder. For each `x in F^k`, observe `y_j=(a_j·x)^4`, with no noise and field multiplication in F. Two vectors are equivalent exactly when `x' = omega*x`, where `omega ∈ mu4={z∈F*:z^4=1}` (and the zero signal is its own class). For each nonzero x, form the **m × 2k Frobenius-linearization matrix**

`M_x[j] = (a_j1^5,...,a_jk^5, -(a_j·x)^4 a_j1,...,-(a_j·x)^4 a_jk)`.

**Theorem.** With probability **strictly greater than `1-5^(-s)`** over the single sampled A, **simultaneously for every nonzero x**, the F25-kernel of `M_x` is exactly the one-dimensional line `F*(x^5,x)`. On that event every signal, including x=0, is uniquely determined up to mu4 by the readings, and a deterministic Gaussian-elimination decoder reconstructs the equivalence class in O(m k²) F25 field operations plus O(mk) validation, with a constant-size fourth-root search. For m=O(k+s), this is polynomial in k and s, and hence in input length. For varying p, exhaustive phase enumeration cannot be described as uniform poly(log p) without a separate root-solving algorithm; this theorem fixes p=5.

## 2. Independent proof

### Algebraic reduction

For fixed x, the vector `(x^5,x)` lies in ker M_x by Frobenius: `(a·x)^5=(a^5·x^5)=(a·x)^4(a·x)`. For any candidate `(u,v)`, define the degree-five polynomial in sensing row a:

`P_(x,u,v)(a)=sum_i u_i a_i^5 − (a·x)^4 sum_i v_i a_i`.

For x!=0, take an invertible F25-linear change of coordinates so t=a·x and b_1,...,b_(k-1) are a completion. Then

`P=alpha*t^5 + sum_i B_i*b_i^5 − t^4 sum_i C_i*b_i`.

These monomials are distinct formal monomials, so P is identically zero exactly if `alpha=B_i=C_i=0`. In the original vectors, this means `(u,v)=lambda*(x^5,x)` for some `lambda in F25`. The proof uses only formal polynomial identities and invertible coordinate changes; no assumption about decoding success is smuggled into this step.

### Sharp zero-density lemma

If some B_i!=0, then at t=0 the Frobenius-linear functional in b has zero probability exactly 1/25; at t!=0, fixing every b-coordinate except b_i leaves a nonzero degree-five univariate polynomial, with at most five roots over F25. Therefore

`Pr_a[P(a)=0] <= [1+5*(25-1)]/25² = 121/625 = rho`.

If all B_i vanish and at least one C_i!=0, the zero probability is exactly `(2*25-1)/25²=49/625`. If all B_i,C_i vanish and alpha!=0, the probability is 1/25. The three cases exhaust every nonplanted `(u,v)`.

**Sharpness:** With x=(1,0) and (u,v) chosen so P(t,b)=b^5−t^4 b, at t=0 there is one zero; for each of the 24 nonzero t there are five b values with b/t∈F5. Exactly `1+24*5=121` of the 625 sensing rows vanish. Hence the per-candidate zero-density upper bound is attained by a genuine nonplanted direction.

### Uniform all-signal probability law

For fixed nonzero x there are at most `25^(2k)-25` vectors outside the planted line. Independently sampled rows make the probability that an individual nonplanted polynomial vanishes on **every** measurement at most `rho^m`. A union bound over all `25^k-1` nonzero x gives

`Pr_A[exists x!=0 with dim_F ker M_x>1] <= (25^k-1)(25^(2k)-25)rho^m <25^(3k)rho^m`.

The exact integer test `11^5882<5^8764` is equivalent to

`25^3 (121/625)^(2941/500)<1`.

Since also `121/625 < 1/5`, the above union-bound probability is `<5^(-s)` whenever `m>=ceil(2941k/500)+s`. The same one-event inequality holds *simultaneously* for every nonzero signal. This is an all-signals guarantee for the single random measurement matrix, not a fixed-signal average.

### Decoder and uniqueness, including zero

Given the observed y, construct M_y with the same formula (using y directly in the right block). The kernel under the good event has dimension one for nonzero x; any nonzero `(u,v)` in it satisfies `(u,v)=lambda*(x^5,x)` with nonzero lambda. Select an index with v_i!=0. Solve `beta^4=v_i^5/u_i` by trying the 25 field elements (constant work), then set `x'=v/beta`. The four nonzero roots return exactly the mu4 orbit of x; validate each candidate against all readings.

If all y_j are zero, output x=0 when rank(A)=k and otherwise declare the design ambiguous. **The good event implies rank(A)=k:** if some nonzero x were in ker A, every y_j would be zero and each row of M_x would have zero v-block. For k>=2 this gives kernel dimension at least k>1. For k=1, A x=0 forces every sensing row to vanish and M_x has kernel dimension 2. Both cases contradict the good event. Therefore x=0 is also uniquely recovered. Conversely, if x and x' have the same readings on the good event, their planted pairs lie on the same line; then x'=lambda*x and lambda^5=lambda, so lambda^4=1 and they are mu4-equivalent.

### Bit complexity

F25 is fixed, represented by two base-five coefficients; addition, multiplication, inversion and fifth powers take constant bounded integer operations. Row reduction on an m×2k matrix costs O(mk²) such field operations. The constant 25-candidate beta search plus O(mk) measurement checks yield deterministic polynomial bit complexity. The guarantee is a Las Vegas-style random *design* statement, while the decoder itself is deterministic for a supplied design; it never claims success for an arbitrary bad A.

## 3. Fresh independent executable audit

`verify_f25_independent.py` uses the **different** irreducible polynomial v²−3, not the earlier F25 source's v²−2 representation, and a new reduced-row-echelon elimination and root-enumeration decoder. It performs:

- **All 15,624** nonzero formal triples (alpha,B,C) in F25³, with a fully exact row-count reduction from 625 rows to `24*N_roots + (25 if B=0 else 1)`. Maximum is **121**, attained at **720** triples. Exact zero-count histogram: 1→2880, 25→11424, 49→600, 121→720.
- **4 independently seeded 13-row designs for k=2**, checking all **625 signals per design** (including zero) and equality of recovered candidate sets to the exact mu4 orbit; 2,500 exact decoder outputs checked.
- **3 independently seeded 19-row designs for k=3**, checking 25 signals per design and equality of recovered orbit sets; 75 additional decodes.
- A deliberately all-zero 13×2 sensing design must be classified ambiguous; the k=1 planted kernel rank corner; exact integer `11^5882<5^8764`; field Frobenius and finite-field inverse identities.

All code uses Python integers and exact F25 arithmetic; no floating-point tolerances. The archive includes source code, captured stdout, Python interpreter information, and SHA-256 evidence manifest. A second external mathematical referee and global priority search are still required.

## 4. Closest source comparison and priority gate

The October 15 **Quarter-Turn** manuscript uses **systematic `[I_k;B]` with 2k measurements**, fourth powers over p≡1 mod 4 fields, and q growing exponentially with k for its uniform LLL guarantee. Its proof relies on the 2k systematic phase-pattern lattice, very different from this **fully random m≈5.882k fixed F25** Frobenius-lift model. Neither result strictly dominates the other under identical field, sampling law and measurement count. The archive also contains an older extension-field kernel construction, so the new Frobenius linearization's intellectual priority within NIGHTFALL is unresolved.

A targeted public literature review on 28 October 2026 included finite-group phase retrieval (2023), Liu–Krahmer's real/complex PhaseLift uniform recovery (2017–18), and standard finite-field low-rank sensing. Those have materially different observation maps. The focused search did not establish a prior proof of this **exact** fixed F25 iid-powered observation theorem; it also cannot establish global originality. **Novelty label: INCONCLUSIVE**; the theorem requires an exact same-model bibliography audit before being promoted as a novel result.

## 5. Verifier audit, limits and handoff

What can falsely score well: conflating rank defect with nonlinear ambiguity, inferring uniformity from sampled signals, swapping characteristic-two Frobenius fourth power for characteristic-five nonlinear fourth power, using a fixed signal instead of one shared random design, omitting x=0, silently changing the orbit group, using non-field GF25 arithmetic, and confusing arithmetic checks of the source LLL tail with the missing span-count lemma. The current proof addresses these quantifiers explicitly. A finite experiment alone does not prove the universal probability inequality; that follows from the algebraic argument above.

**Current verdict:** Theorems and exact constants supported by a complete written proof and independent local executable code. **Human expert proof acceptance and historical novelty are open.** The next discovery target is a smaller m coefficient under the **same iid F25 law**, requiring analysis of correlated kernel-failure events rather than improving the sharp single-direction zero fraction.
