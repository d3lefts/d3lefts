# LEMNIS / NIGHTFALL — sharp locally orthogonal two-block Werner transfer

**Research checkpoint:** October 28–29, 2026  
**Program leadership:** Devin J. Wright / NIGHTFALL PHASESHIFT  
**Mathematical development and internally independent checks:** Lemnis (GPT-6)  
**Review status:** self-contained elementary theorem with two independently structured physical/operator checks, explicit rank-two witness and exact archive-boundary comparisons; independent human refereeing and worldwide originality review **open**. This result concerns a restricted witness class and does **not** settle unrestricted Werner-state undistillability.

## 1. Theorem — every copy count, every local dimension, heterogeneous parameters

Fix integers `n>=1` and `d>=2`, and real parameters `0<=t_j<=1` for `j=1,...,n`. Define the rank-two Werner partial-trace form on matrices acting on `(C^d)^(tensor n)` by

    Q_t(C) = sum_(J subset [n]) (-1)^|J| (prod_(j in J) t_j) ||Tr_J C||_F^2.

Choose nonzero mutually orthogonal local subspaces `V_j,W_j` of `C^d` (`V_j perpendicular W_j`); put `V=tensor_j V_j`, `W=tensor_j W_j`. Let `u,v in V` and `x,y in W` be arbitrary complex vectors. Set

    C = |u><v| + |x><y|;   rank(C) <= 2.
    A = ||u|| ||v||,       B = ||x|| ||y||,
    L = prod_j (1-t_j),    M = prod_j t_j.

**Theorem (two-block transfer and sharp parameter criterion).**

    Q_t(C) >= L(A^2+B^2) - 2M A B
           = (L-M)(A^2+B^2) + M(A-B)^2.

Consequently **`Q_t(C)>=0` for every admissible complex rank-at-most-two C of this two-block form if and only if `L>=M`**. The threshold is sharp for *every* `n,d`: when `L<M`, choose product basis words `a in V`, `b in W` with `a_j ⟂ b_j`, then

    C_bad = |a><a| + (-1)^(n+1) |b><b|,
    Q_t(C_bad) = 2(L-M) < 0.

For homogeneous `t_j=t`, the exact universal criterion reduces to **`t<=1/2`**. No four-/five-copy SDP or restricted affine-code theorem is imported: this is a standalone algebraic bound.

## 2. Proof

Let `F_j` swap the Alice/Bob qutrit (or qudit) at site `j` and let `Omega_d=sum_a |aa>` be unnormalized. Under partial transpose on all Bob systems,

    K_t = tensor_j (I-t_j |Omega_d><Omega_d|)
        = [tensor_j (I-t_j F_j)]^(T_B).

For a rank-one matrix `Z=|u><v|`, its vectorization is `u tensor conjugate(v)`; partial transpose and the trace pairing yield

    Q_t(Z) = <u tensor v, [tensor_j (I-t_j F_j)] (u tensor v)>.

Each local `I-t_j F_j` has least eigenvalue `1-t_j`, so the tensor product has least eigenvalue `L`:

    Q_t(|u><v|) >= L ||u||^2 ||v||^2 = L A^2.

The same bound gives `Q_t(|x><y|)>=L B^2`.

For the polarized cross term, choose an orthonormal local basis compatible with `V_j ⟂ W_j`. The identity contribution to the local matrix-unit kernel vanishes between the two blocks, while the `|Omega><Omega|` contribution can connect only local diagonal matrix units. Hence the *exact* global cross term is

    <uv*, K_t xy*> = (-1)^n M conjugate(Tr(uv*)) Tr(xy*).

(This formula is written up to the harmless conjugation convention of the Hermitian pairing; its real part is invariant.) In particular,

    |<uv*, K_t xy*>| <= M |<v,u>| |<y,x>| <= M A B.

Adding both self terms and the polarized cross term proves the displayed bound. For sharpness, choose `u=v=|a>`, `x=(-1)^(n+1)|b>`, `y=|b>` with each `a_j` orthogonal to `b_j`. The two self terms are exactly `L` each, the mixed term exactly `-2M`, giving `2(L-M)`.

**Why the rank condition survives:** The proof uses the original two rank-one factors and never treats a grade-compressed residual as rank at most two. The factors' row and column spaces are locally orthogonal and therefore linearly independent whenever both are nonzero.

**Why it is structurally stronger than continuity:** The theorem covers arbitrary complex choices of `u,v,x,y` within both tensor blocks, with no proximity constraint to any previously certified witness and a sharp parameter criterion. For `d=4`, both local blocks can have dimension two; for `d=3`, a two-symbol block and a complementary singleton already generate full three-level local support on both sides.

## 3. Four-qutrit strict adversarial witness (outside the existing certificates)

Use qutrit computational words

    a=0000,  b=1111,  c=2220,  d=2222,
    u=|a>+|c>+|d>,
    C=|u><u| - |b><b|.

Take `V_j=span{|0>,|2>}` and `W_j=span{|1>}` at every site. Then `rank(C)=2`, and the row and column reduced local supports both occupy all **three** levels at every site. There are ten nonzero matrix units. For `t_1=...=t_4=1/2`, the theorem certifies

    Q_4(C) >= (||u||²-1)² /16 = 1/4.

Independent physical 16-partial-trace evaluation gives the stronger exact value

    Q_4(C) = 3 > 1/4.

A full nontrivial one-parameter family is

    u_s=|0000>+|2220>+s|2222>,  C_s=|u_s><u_s|-|1111><1111|.

For every complex `s`, `rank(C_s)<=2`, with the uniform theorem margin `Q_4(C_s)>=(1+|s|²)²/16`. For real `s`, a direct exact partial-trace identity gives

    Q_4(C_s) = 13/16 + (17/8) s² + s⁴/16.

All nonzero `s` supply full-three-level local support on Alice and Bob; this is not a tensor-factorized witness across the four copy sites.

### 3a. Exact comparison with previous NIGHTFALL sufficient conditions

For `s=1`, let `U=P_S M_81 P_T` be the archived 729-dimensional Werner syndrome rectangle with `S=F3×{0}`, `T={0}×F3`, and let `P_U` be its coordinate projection. The exact projection produces

    C0 = P_U C = E_(0000,0000) + E_(2220,0000),    rank(C0)=1.

The remaining complement has a **genuinely nonzero same-conserved-grade interaction**, independently confirmed by polarizing the physical 16-subset form:

    2 Re<C0, K (C-C0)> = -1/8.

Using the earlier positive-eigenmode decomposition `C=C0+D0+D2+R`, a separate exact rational Gram solver gives

    ||D0||²=86/27,  ||D2||²=26/27, ||R||²=104/27,
    Q(C0)=9/16,   ||leak_(grade 0000)||²=9/32,
    ||R_(grade 0000)||²=20/9,  2Re<C0,KR>=-1/8.

Thus the strongest **old grade-resolved sufficient bound** has value

    [||D0||²+||D2||²/4] - ||R||²/2 - 2 sum_grade ||leak_grade|| ||R_grade||
       = 3/2 - sqrt(5/2) < 0.

The previous input-sensitive ungraded and uniform versions are weaker, hence they also fail to certify this witness. `||R||²>0` proves that the witness is outside the 4,209-dimensional linear lift. It is also beyond the Axiom *ambient-coordinate PSD* theorem: the coordinate-support triple `E_aa`, `E_cc`, `E_bb` has a signed rank-three combination

    Q_4(E_aa + E_cc - E_bb) = -3/16.

No larger ambient PSD coordinate support can contain this witness's full coordinate support. This negative rank-three **mutation** does not challenge the rank-two theorem; it shows precisely why the new rank-two factorization is necessary. The example also has four different `H`-syndrome labels and is outside the original single-coset affine-code range.

**Caution about the comparison:** The old grade-resolved condition is a **sufficient lower bound**, so its negative value means failure of that *certificate*, not failure of positivity. The theorem's quantitative margin `1/4` is independent of those imported premises.

## 4. Sharp heterogeneous controls and limits

For `n=4` and `t=(1/4,1/3,1/2,2/3)`, `L=1/12`, `M=1/36`; the two-diagonal sharpness example has `Q=+1/9`. Replacing the first parameter with `3/4` swaps `L=1/36`, `M=1/12` and produces `Q=-1/9`. The criterion is therefore an iff statement for the specified restricted class, not a conjectured universal activation threshold.

The **sitewise orthogonality assumption is essential**. If only global supports are orthogonal while some local alphabets overlap, the mixed kernel contains identity contributions and the formula with `M=prod t_j` can fail. For example `n=2`, basis words `00` and `10`, and `(t1,t2)=(3/4,1/10)`: the product threshold `L=9/40 >= M=3/40` holds, while `Q(E_00,00+E_10,10)=-9/10`, because the words share the second site. This is a scope counterexample, not a contradiction.

## 5. Reproducibility and prior art

Run the four standalone Python checkers in this directory:

    python3 verify_physical.py
    python3 verify_spectral.py
    python3 verify_two_block_complex.py
    python3 verify_heterogeneous.py

- **Direct physical arithmetic:** 16-subset partial traces on every stated four-qutrit exact sample; independent polarization of `-1/8` same-grade interaction; symbolic one-parameter identity and rank-three negative mutation.
- **Spectral baseline audit:** independent `Fraction`/SymPy rational 9×9 Gram reconstruction of both eigenspace projections and exact old-grade margin failure. No double counting of rank constraints in grade projections.
- **Complex/heterogeneous tests:** complex noncollinear `d=4,n=3` vectors in two 2-dimensional local blocks, exact physical partial traces at four rational parameters, and all-copy sharpness fixtures for `n=1,...,4`. Separate heterogeneous controls inspect both sides of the sharp threshold.

**Scope of verification:** These internal checks verify the explicit finite results and compare independent implementations. The general theorem follows from the written algebraic proof; no external human referee or proof-assistant formalization has signed off. A complete contemporary literature originality search remains open.

### Same-scope literature boundary (checked 2026-10-28)

- Bharti–Gajjala–Haug, *Two-copy nondistillability of Werner states: sharp partial-trace inequalities and finite-copy extensions*, arXiv:2607.24479 (July 2026), prove a sharp all-dimension two-copy inequality and discuss **tensor-factorized** witness classes. Our class may be non-factorized across copy sites and additionally handles heterogeneous `t_j`, yet these elementary components may have existing antecedents.
- P. Costa Rico, *New partial trace inequalities and distillability of Werner states*, Lett. Math. Phys. 115 (2025), DOI 10.1007/s11005-025-01935-y, supplies the matrix partial-trace formulation and rank-two context.
- Tejasvi S. Tomar, *Undistillability of Werner states from three, four and five copies* (October 2026), DOI 10.5281/zenodo.23604343, proves three-copy endpoint and reports four-copy qutrit bound `t=0.4979`; its four-copy endpoint remains open. The present restricted family does not change this physical bound.
- Z. Song and L. Chen, *A partial-trace matrix inequality and Werner-state distillability* (arXiv:2607.23416), prove a sharp two-copy result and a two-parameter nonactivation statement. Our heterogeneous conclusion is only for the locally orthogonal two-block witness family.

**Novelty status: INCONCLUSIVE.** The proof's basic PPT bound and orthogonal-block interference calculation are elementary and may be implied by prior tensor-stable positivity results. What this checkpoint demonstrates is a complete, exact rank-two family beyond the documented NIGHTFALL certificate union; it is not a claim of world-first or unrestricted theorem.

**Review target:** independent analysis of the complex partial transpose identity, strict previous-certificate exclusion, sitewise orthogonality quantifiers, and priority relative to known block-positive-map tensor-product results. Draft PR should remain unmerged until Vesper/Axiom independent cross-audit.
