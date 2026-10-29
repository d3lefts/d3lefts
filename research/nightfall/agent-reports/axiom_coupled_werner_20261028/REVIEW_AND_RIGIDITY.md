# AXIOM / NIGHTFALL — independent Werner block audit and sharp-boundary rigidity

**Date:** October 28, 2026 (New York) / October 29 UTC. **Research lead:** Devin J. Wright; independent proof audit and rigidity deduction: Axiom (GPT-6). **Inputs:** Lemnis draft PR #35 (locally orthogonal two-block and multiblock theorems), Vesper draft PR #38 (one-sided row-orthogonal extension), and Costa Rico (2025), Song–Chen (2026), Bharti–Gajjala–Haug (2026). **Scope:** restricted one-sided locally orthogonal rank-r witness families, exact self-contained proof, standard-library independent finite computations. External referee and priority **OPEN**. No unrestricted four-copy Werner claim.

## 1. Independent referee verdict on PR #35

**PASS (mathematical identity and parameter threshold, under explicitly local orthogonality); INCONCLUSIVE (global priority and comparison to established positivity-map literature).** For `n>=1`, `r>=2`, `0<=t_j<=1`, and rank-one blocks `X_i=|u_i><v_i|` with mutually orthogonal row support at every physical site, even when the `v_i` overlap arbitrarily, the *proper-subset* mixed partial-trace HS products vanish. The all-site partial-trace cross term is `(-1)^n M (|sum_i tau_i|²-sum_i |tau_i|²)` where `tau_i=<v_i,u_i>` and `M=prod_j t_j`. Independently, the swap trick yields `Q(X_i)>=L ||u_i||²||v_i||²`, `L=prod_j(1-t_j)`. Consequently the PR #35 two-sided theorem and the PR #38 one-sided generalization satisfy their claimed even/odd sharp thresholds. The checker verifies the exact `2^n` physical traces, including truly arbitrary overlapping column supports and the four-qutrit `Q=3` witness, without importing either source implementation.

This proof does **not** make arbitrary rank-two matrices positive; one-sided local row orthogonality remains an essential hypothesis. PR #38 precedes this audit for the one-sided extension. No priority duplication is claimed.

## 2. New theorem: exact zero-cone classification at the sharp boundary

Let `H=⊗_{j=1}^n C^(d_j)`, `d_j>=r`, `0<t_j<1`, and set

    Q_t(C) = sum_{J subset [n]} (-1)^|J| prod_{j in J}t_j ||Tr_J C||_F².

Take nonzero `u_i in ⊗_j U_(i,j)`, with `U_(i,j) ⊥ U_(h,j)` whenever `i!=h`, and **arbitrary nonzero complex column vectors** `v_i in H`. Set `X_i=u_i v_i*`, `C=sum_(i=1)^r X_i`, `A_i=||u_i||||v_i||`, `tau_i=Tr X_i`, `L=prod(1-t_j)`, `M=prod t_j`, and define the nonnegative **single-block slack**

    delta_i = Q_t(X_i) - L A_i² >= 0.

Then an exact cross-term identity holds:

    Q_t(C) = sum_i delta_i + L sum_i A_i²
             + (-1)^n M (|sum_i tau_i|² - sum_i |tau_i|²).           (1)

At the *sharp parameter boundaries*, this has the following **exact sum-of-nonnegative-terms decompositions**:

**Even n, L=M:**

    Q_t(C) = sum_i delta_i
             + M sum_i (A_i² - |tau_i|²)
             + M |sum_i tau_i|².                                    (2)

**Odd n, L=(r-1)M:**

    Q_t(C) = sum_i delta_i
             + (r-1)M sum_i (A_i² - |tau_i|²)
             + M sum_(i<h) |tau_i - tau_h|².                         (3)

Every summand is nonnegative by the rank-one swap inequality and Cauchy–Schwarz. Equations (2),(3) supply strict positivity unless every defect vanishes.

### Equality and rigidity (all dimensions, all copy counts, arbitrary complex factors)

Under `0<t_j<1`, `delta_i=0` **if and only if**

    X_i = z_i |a_i><a_i|,

where `a_i=⊗_j a_(i,j)` is a fully separable nonzero vector and `z_i` is a nonzero complex scalar. The row-support hypothesis forces `a_(i,j) ⟂ a_(h,j)` whenever `i≠h`. Rescale each `a_i` to unit norm and absorb its norm in `z_i`.

Therefore every **nonzero zero-energy witness** in the entire one-sided rank-r class is exactly:

- **Even n, at L=M:** `C=sum_i z_i |a_i><a_i|` with unit local product vectors as above and `sum_i z_i=0`.
- **Odd n, at L=(r-1)M:** `C=z sum_i |a_i><a_i|`, with the **same nonzero complex coefficient** `z` for every block.

These conditions are also sufficient. In particular for `r=2`, the entire zero set at `L=M` is `z(P_a-P_b)` for even n and `z(P_a+P_b)` for odd n, with locally orthogonal fully separable `a,b`. Thus **allowing entangled block vectors and overlapping column supports creates no additional zero-energy extremizers**, despite greatly enlarging the positive input class.

### Proof that rank-one slack vanishes only on pure product projectors

For `X=uv*` define `w=u⊗v` on two replicas of `H`. Let `F_j` swap the two copies only at site `j`. The swap identity gives

    Q_t(X)=<w, T w>,  T=⊗_j (I-t_j F_j).

All `F_j` commute, with eigenvalues ±1. The minimum eigenvalue of `T` is `L`, with ground eigenspace `Ran(P_+)`, `P_+=prod_j(I+F_j)/2`, since **every** `t_j` is strictly between zero and one. Hence `delta=0` iff `F_j(u⊗v)=u⊗v` for every j. Multiplying the local swaps gives the full swap `v⊗u=u⊗v`, forcing `v` proportional to `u`. Next each `F_j(u⊗u)=u⊗u` implies the reduced density of `u` at site j has purity one, so `u` is a simple tensor across j and its complement. Iterating over j yields `u=a_1⊗...⊗a_n`. Conversely every scalar product projector is in the common ground eigenspace. This proves the rigidity step and, with (2),(3), the full equality classifications.

## 3. New quantitative stability theorem

For `0<t_j<1`, let

    Delta = min_j [2 t_j prod_(h != j)(1-t_h)] > 0.

This is the *exact first spectral excitation gap* of `T` above its minimum `L`; the next eigenvalue flips the swap parity at one site. Since `T-LI >= Delta(I-P_+)`, every rank-one block obeys the explicit stability inequality

    delta_i >= Delta (A_i² - ||P_+(u_i⊗v_i)||²).                 (4)

The projector norm has an independent **physical partial-trace** expression:

    ||P_+(u⊗v)||² = 2^(-n) sum_(J subset [n]) ||Tr_J (uv*)||_F². (5)

Together (2)--(5) give a computable quantitative certificate: at either sharp threshold, any witness with `Q(C)<=epsilon` has ground-excitation weight at most `epsilon/Delta` for the sum of the individual blocks, along with an explicit phase-cancellation (even) or trace-equality (odd) defect at most `epsilon/M`. This is a rigorously scaled *spectral stability* statement; it does **not** claim an unproved norm-distance bound to the nonlinear product-state manifold.

For four qutrits at homogeneous `t_j=1/2`, `L=M=1/16` and `Delta=1/8`. Formula (2) becomes the exact strict-defect decomposition with coefficient `1/16` on the trace terms and a lower bound `1/8` on each block's non-ground spectral mass.

## 4. Source-aligned exact verification

A separately written Python file `verify_rigidity.py` computes physical `2^n` partial traces of sparse complex integer-coefficient matrices using exact rational parameters. It checks:

- 54 independently generated complex row-orthogonal but column-overlapping cases, with exact cross-term equality and nonnegative single-block slacks (n=2,3,4; r=2,3; d=4).
- Each tested boundary identity (2) or (3), and the spectral-gap inequality (4) with the alternate physical formula (5).
- Three even-n balanced extremizers with exact `Q=0` and nearby perturbed controls with `Q>0`.
- Two odd-n equal-weight extremizers at heterogeneous rational sharp thresholds and perturbed controls with `Q>0`.
- The four-qutrit full-local-support Lemnis witness from PR #35, exact `Q=3` by 16 independent physical partial traces.

Every reported sample uses integer-valued complex components and rational `t`, so all accepted quadratic-form comparisons are exact. The code never imports the earlier Lemnis/Vesper checker, Fourier program, or tensor swap basis to calculate `Q`. The universal statements follow from the proof above, not statistical extrapolation.

## 5. Priority and scope

- The source of the partial-trace formulation is Pablo Costa Rico, *New partial trace inequalities and distillability of Werner states*, *Letters in Mathematical Physics* **115**, 47 (2025), DOI `10.1007/s11005-025-01935-y`.
- Nearby exact rank-two partial-trace inequalities: Song and Chen, arXiv:2607.23416 (July 2026), and Bharti, Gajjala and Haug, arXiv:2607.24479 (July 2026).
- Lemnis independently established the two-sided sharp two-block family and multi-block parity threshold in draft PR #35. Vesper independently established the **one-sided** multi-block extension in draft PR #38. Their antecedent claims remain credited.

**Claim added here:** the sharp-boundary **complete complex zero-set classification** and explicit **swap-spectral stability inequality** for that exact restricted class, together with a new independent physical-trace audit. The algebra is elementary and may follow established rigidity of tensor swap symmetry; **global originality is INCONCLUSIVE** until specialist same-scope review. No unrestricted rank-two t=1/2 Werner conclusion, no general NPT distillability result, and no automatic Original Findings promotion.

**Review request:** independently inspect the implication `F_j(u⊗u)=u⊗u` → local reduced-state purity one → full product state; verify that the all-block equality constraints are necessary when t_j>0, including complex phases and any zero-block boundary cases. A formalizer could target identities (2),(3) and the spectral-gap operator bound (4) as three small standalone lemmas.