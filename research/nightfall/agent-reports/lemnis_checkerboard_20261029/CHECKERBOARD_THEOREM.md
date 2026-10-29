# LEMNIS — Mixed-side orthogonality and sharp Werner partial-trace positivity

**Research lead:** Devin J. Wright (NIGHTFALL PHASESHIFT). **Mathematical development/checkers:** Lemnis (GPT-6). **Checkpoint:** 29 October 2026 UTC. **Review status:** internally proved, independently implemented exact finite checks; external specialist proof review and same-scope priority INCONCLUSIVE. This is a restricted family theorem, not a global Werner-state result.

## Main theorem (marginal-orthogonal rank-r transfer)

Let `H=⊗_{j=1}^n C^{d_j}` and `0<=t_j<=1`. For any complex `C=Σ_{i=1}^r X_i` with `X_i=|u_i><v_i|` rank one, define

    Q_t(C)=Σ_{S⊆[n]}(-1)^|S|(∏_{j∈S}t_j)||Tr_S(C)||_F²,
    A_i=||u_i||||v_i||, z_i=Tr(X_i)=<v_i,u_i>,
    L=∏_{j=1}^n(1-t_j), M=∏_{j=1}^n t_j.

Assume **marginal-orthogonality**: for distinct i,h and *every proper* subset S⊊[n],

    <Tr_S X_i, Tr_S X_h>_HS=0.

Then the *exact* interference identity and lower bound are

    Q_t(C)=Σ_i Q_t(X_i)+(-1)^n M(|Σ_i z_i|²−Σ_i|z_i|²)
          >=L Σ_i A_i²+(-1)^n M(|Σ_i z_i|²−Σ_i|z_i|²).

Consequently the whole marginal-orthogonal class is nonnegative if `L>=M` for even n, or `L>=(r-1)M` for odd n. If `d_j>=r` at every site, both conditions are **necessary and sufficient** for nonnegativity over the entire class. Necessity follows from r mutually sitewise-orthogonal diagonal product words, choosing two opposite diagonal signs for even n and r equal signs for odd n. If L<M for even n, an exact rank-two negative is obtained. If L<(r-1)M for odd n, an exact rank-r negative is obtained. Thus the parameter boundaries are sharp.

### New geometric certificate: checkerboard orthogonality

The marginal-orthogonality hypothesis follows from a strictly more flexible **local mixed-side separation** condition. Suppose for each rank-one summand `i` there are tensor-product local subspaces `U_{i,j}` and `V_{i,j}` such that

    u_i ∈ ⊗_j U_{i,j},  v_i ∈ ⊗_j V_{i,j},

and **for each pair of summands i≠h, at every tensor site j**, one has

    U_{i,j} ⟂ U_{h,j}   OR   V_{i,j} ⟂ V_{h,j}.

The separating side may change with the site and with the pair. For every proper trace S there is a retained site j; at that site the two reduced operators have orthogonal row or orthogonal column supports, hence their Hilbert–Schmidt cross inner product vanishes. In particular all summands are HS-orthogonal before any trace. This permits arbitrary complex entanglement of each u_i,v_i across the copy sites, and only requires rank(C)≤r, not that any projected component has rank≤r.

The row-only theorem in Vesper draft PR #38 and the row-and-column two-block theorem in Lemnis PR #35 are *strict subsets* of this checkerboard class. The threshold is exactly the same as theirs on this enlarged class. The newly articulated marginal-orthogonality criterion also permits further decompositions unrelated to local product subspaces, provided their exact proper-marginal conditions can be certified.

### Proof of the rank-one diagonal bound

With F_j the unitary swap between two replicas at site j, the standard rank-one two-replica identity gives

    Q_t(|u><v|)=<u⊗v, (⊗_j[I-t_j F_j])(u⊗v)>.

Each local factor has spectrum {1-t_j,1+t_j}; since t_j∈[0,1], the tensor product has least eigenvalue `L`. Thus `Q_t(X_i)>=L A_i²`. Under the proper-marginal orthogonality premise the polarization identity has only the full trace S=[n] cross terms; they sum to the exact expression above. If n is even, use `|Σ z_i|²≥0` and `|z_i|²≤A_i²`. If n is odd, use `(Σ|z_i|)²≤rΣA_i²` and `Σ|z_i|²>=0`. This proves the thresholds; the diagonal product words described above attain the boundaries.

## Four-qutrit strict test: all local levels and nonzero same-grade coupling

Let computational words be `a=0000`, `c=2220`, `e=0001`, `f=0002`, `g=2222`, `b=1111`. Define

    u=|a>+|c>+|e>+(1/10)|f>,
    v=|a>+|c>+(1/10)|g>,
    X=|u><v|,   Y=-|b><b|,   C=X+Y.

For sites 1,2,3 the row supports of X,Y are orthogonal (`{0,2}` versus `{1}`); at site 4 the row supports overlap, while **column** supports are orthogonal (`{0,2}` versus `{1}`). This uses the new checkerboard condition and violates the row-only requirement, independent of how one chooses the two rank-one factors. `rank C=2` because its column supports are independent. Both the total row alphabet and total column alphabet equal `{0,1,2}` at **every** site.

At t_j=1/2, `L=M=1/16`, `z_X=2,z_Y=-1`. Therefore the new theorem guarantees the exact positive margin `Q(C)>=1/16`.

An independent explicit enumeration of all 16 physical partial traces yields

    Q(C)=39201/20000 > 1/16,
    2 Re<X,KY>=-1/4,

and verifies that *every proper-trace cross term vanishes*. The prior cross interaction between the syndrome rectangle P_U C and its complement is also **nonzero within the same conserved difference grade**:

    2 Re<P_U C, K(C-P_U C)>=-1/4.

An independent exact rational eigenspace/Gram audit of the archived 4209-mode decomposition gives

    Q(P_U C)=9/16,
    w=306359/135000,
    ||R||²=645059/270000,
    w−||R||²/2=193459/180000,
    Σ_grade ||leak_grade||² ||R_grade||² = 5/12,

with just one nonzero overlapping-grade product. The strongest previous grade-resolved sufficient lower bound is therefore

    193459/180000 − 2 sqrt(5/12) < 0.

This is failure of that **sufficient certificate**, not negative physical Q. The residual R is nonzero, excluding the old 4209-dimensional linear lift; the previous uniform/input-sensitive tubes are weaker, hence fail as well.

Axiom's ambient-coordinate PSD theorem is inapplicable: the coordinate support contains the three diagonal units E_aa, E_cc and E_bb. Their pairwise Hamming distances are 3,4,4; exact sign selection yields a diagonal **rank-three** mutation with `Q=-3/16`. Thus no ambient-PSD coordinate subspace can contain the witness's complete support. This is an ambient support obstruction, not a rank-two counterexample.

**Why the row-only theorem genuinely fails for this C:** The range of C is the two-dimensional span of u and b. Any vector with nonzero u coefficient has local site-4 row support including both symbols 0 and 2. Its orthogonal site-4 local support would therefore be at most symbol 1, and a second vector in span(u,b) supported only on symbol 1 must be proportional to b. The original vector has a nonzero symbol-1 slice (the coefficient of |0001>) overlapping b's symbol-1 local support; their site-4 reduced supports cannot be orthogonal. More directly, every rank-two decomposition into independent row factors spans exactly range(C); the site-4 reduced support of every vector with nonzero u component includes symbols 0,1,2. It cannot be orthogonal to the support of any nonzero second range vector. Thus there is no Vesper-compatible row-only two-block representation.

## Negative mutation for weakening the hypothesis

Requiring separation at only *some* sites is insufficient. At n=2, take `C=E_(00,00)+E_(10,10)` and `t=(3/4,1/10)`. The two words share site 2, violating checkerboard separation there. Although L=9/40>=M=3/40, the physical form is `Q(C)=-9/10`. The precise all-sites local OR condition cannot simply be discarded.

## Distinct independent audit of Axiom PR #16

An independent F25 realization `F5[w]/(w²+w+2)` independently exhausts all 15,624 nonzero `δ t⁵+B z⁵−D t⁴ z` triples. Exact zero-count histogram `{1:2880,25:11424,49:600,121:720}`; maximum zero density `121/625`. Independent-rank polynomials over three variables yield exactly 625 zeros of 15,625 rows, i.e. 1/25. Projectivizing the k=2 coefficients produces 650 exceptional rank-one classes and one δ-only class. Exact integers verify the 149/38 theorem's union bound for k=1..20 and s∈{1,2,5}, including `121^149<625^111`.

The manuscript's **all-k** claim follows analytically from a projectivization with free scalar action and separate exact rank classes, plus the displayed inequalities; finite enumeration alone cannot prove the universal theorem. The k=1 corner has no b variables, R1=R2=0, and N=1; its independent probability is exactly 25^(-m). Our review verifies this algebraic mechanism and the enumerated arithmetic, not external publication priority or a replacement algorithm.

## Reproducibility and prior-art boundary

Run `verify_checkerboard.py`, `verify_rational_physical.py`, `verify_predecessor_projection.py` (needs SymPy for exact rational Gram elimination), and `verify_f25_projective.py` with Python 3; no floating-point correctness predicates in the critical witness/projection checks. A frozen SHA-256 manifest is included.

Earlier mathematical ingredients, such as two-replica swap identities, rank-one block positivity, partial-trace norm inequalities, and signed graph balancing, have substantial prior art. Closest relevant published context inspected: Costa Rico, *Lett. Math. Phys.* 115:47 (2025), DOI `10.1007/s11005-025-01935-y`; Costa Rico & Wolf, *J. Math. Phys.* 67, 082203 (2026); Bharti–Gajjala–Haug, arXiv:2607.24479 (2026); Song–Chen, arXiv:2607.23416 (2026). These publications are not a comprehensive priority search for the exact checkerboard/marginal-orthogonality formulation. Publication originality and independent expert proof acceptance remain **OPEN**. No unrestricted four-copy Werner theorem, global optimal threshold, or universally stronger decoder is claimed.
