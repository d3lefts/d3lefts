# LEMNIS — Werner rank-constraint obstruction, anisotropic coupling, and Axiom cross-audit

**Date:** 2026-10-28 · **Program:** NIGHTFALL PHASESHIFT · **Lead:** Devin J. Wright · **Research role:** Lemnis (GPT-6) · **Direct assignments:** GitHub #13 and #15

**Evidence status:** exact finite checks PASS; mathematical proof of the stated conditional lifting inequality supplied below; complete source prior-art/independent human review PENDING. **No unrestricted four-copy Werner endpoint theorem or novelty claim.**

## Frozen contract and parent

- Physical model: four qutrit sites, t=1/2, complex 81×81 coefficient matrices C with matrix rank at most two.
- Quadratic form Q(C)=Σ_{J⊆{1,2,3,4}} (-1/2)^|J| ‖Tr_J C‖²_F = ⟨C,K C⟩, with K=(I−|Ω₃⟩⟨Ω₃|/2)^⊗4.
- Existing base class: U=P_S M₈₁(C) P_T, dim_C U=729, where H(a)=(a₃−a₁−a₂,a₄−a₁−2a₂) over F₃, S=F₃×{0}, T={0}×F₃.
- Imported mathematical premise: Q(C₀)≥0 for all rank≤2 C₀ in U, from the archived *nine-word* coefficient certificate and complementary-syndrome gluing. This is internally exact-checked; external referee review remains open.
- Archived L=U⊕W₀⊕W₂, dim_C L=4,209, with W₀=E₀∩U^⊥ and W₂=E₂∩U^⊥, where E₀,E₂ are positive eigenspaces of K with eigenvalues 1, 1/4 respectively.
- Frozen benchmark: uniform coupling bound ||(I−P_U)K P_U||²=1/2, independently replayed in prior checkpoint. Existing nonlinear sufficient bound w≥√2 c r+r²/2.
- Main new test: input-dependent off-sector norm h(C₀) and its strict improvement on an explicit rank-two matrix.

## Result 1: smallest rank obstruction to ordinary Schur-block PSD

Let A={(x,y,x+y,x+2y):x,y∈F₃} be the nine-word affine code. Choose any r distinct codewords a₁,…,aᵣ, for 1≤r≤9, and define Cᵣ=Σᵢ|aᵢ⟩⟨aᵢ|. Then **rank(Cᵣ)=r** and

    Q(Cᵣ)=r(2−r)/16.

Proof: distinct codewords agree in exactly one site. On these diagonal coordinates, the matrix of 16Q has diagonal entries +1 and all distinct off-diagonal entries −1; hence its r×r Gram is 2I−J. The value at the all-ones vector is r(2−r). Equivalently, 16Q(Σxᵢ|aᵢ⟩⟨aᵢ|)=2Σ|xᵢ|²−|Σxᵢ|².

Thus r=1 gives 1/16; r=2 gives 0; **r=3 yields −3/16**; r=9 gives −63/16. The first negative member of this family has rank three, which is immediately beyond the rank-two theorem. In particular, the operator compression K|U is indefinite on U. No nonnegative global scalar a can satisfy ⟨X,KX⟩≥a||X||² for every X∈U. The hypothesis needed for the *unrestricted ambient* positive Schur criterion b²<ad fails on this U. Applying Schur complements must preserve the rank constraint through the full proof.

Verifier A uses the local kernel and enumerates all 2⁹−1 nonempty codeword subsets. Independently, verifier B uses all 16 physical partial traces for those subsets, with no kernel import. Both PASS.

## Result 2: sharper input-sensitive coupling inequality

Let P=P_U be Hilbert–Schmidt projection onto the rectangular U. Decompose a rank≤2 complex C orthogonally as

    C=C₀+D₀+D₂+R,
    C₀=PC,
    Dᵢ∈Wᵢ (i=0,2),
    R∈L^⊥.

Define c=||C₀||_F, r=||R||_F, w=||D₀||²_F+(1/4)||D₂||²_F, and

    h(C₀)=||(I−P)K C₀||_F.

**Exact conditional theorem.** For any such rank-two C,

    Q(C) ≥ w − 2 h(C₀) r − (1/2)r².

Proof: C₀=P_S C P_T preserves matrix rank ≤2; consequently Q(C₀)≥0 by the archived base theorem. The D-eigenspaces are K-orthogonal to C₀ and R, and contribute exactly w. Since min spec(K)=−1/2, Q(R)≥−r²/2. Since R⊥U, |⟨C₀,K R⟩|=|⟨(I−P)KC₀,R⟩|≤h(C₀)r. Summing proves the inequality. In particular,

    **w ≥ 2 h(C₀) r + r²/2**

is a sufficient positivity criterion for the *original rank-two C*. This conclusion imposes no rank bound on R. It is strictly sharper than the prior uniform criterion because h(C₀)≤c/√2. The improved condition is input-sensitive and may be checked in exact rational arithmetic by applying the finite operator K to C₀.

### Explicit strict rank-two separation from old criterion

Use ternary word labels (row, column) and let C have the four nonzero entries:

    C[(0000),(0000)] = 4
    C[(0000),(1111)] = 1
    C[(1000),(2121)] = 1
    C[(0000),(0121)] = 1.

This C has **matrix rank exactly two**. Its U component is C₀=4|0000⟩⟨0000|, with c²=16. The last entry splits into an E₀ component and the residual

    R=(1/3) Σ_{x∈F₃}|x000⟩⟨x121|.

Crucially, **rank(R)=3**, r²=1/3, and Q(R)=−1/6, despite rank(C)=2. The two pure off-diagonal entries and the E₀ portion of the last entry supply w=8/3.

The input-sensitive coupling norm is exactly **h(C₀)²=9/2**. Thus the new certified margin is

    w−2hr−r²/2 = 5/2 − √6 >0,

since (5/2)²=25/4>6. The old uniform bound would require w−r²/2≥√2 c r = 4√(2/3), which fails since (5/2)²=25/4<32/3. Therefore the new positivity class contains a rank-two matrix **outside the old nonlinear tube**. Independent full partial traces give the exact physical value **Q(C)=7/2**. This explicitly demonstrates a strict gain in the certified rank-two class while allowing a negative projected residual.

### Leakage check on all 729 coordinate directions

Direct expansion of K on each basis entry (a,b) of U yields, by its difference-word Hamming weight j,

| j | Number of U coordinates | h(e_{ab})² |
|---:|---:|---:|
| 0 | 9 | 9/32 |
| 1 | 72 | 3/8 |
| 2 | 216 | 1/2 |
| 3 | 288 | 1/2 |
| 4 | 144 | 0 |

These exact values independently agree with the archived 81-fibre Fourier spectrum. Note that for general C₀, h(C₀) must be computed from the full quadratic Gram, including off-diagonal terms among coordinates in the same fibre; the table alone is **not** a diagonal functional formula for arbitrary C₀.

## Assignment 13: independent Axiom downstream arithmetic cross-check

The public Axiom package claims P₁₁(q)<2^−96 under its Gaussian short-vector **span-count lemma** and field-size assumptions. Lemnis wrote a separate exact-rational proof of the *displayed conditional exponent sum*, without importing the published verifier code. Define

    g(k,n)=11[(4189/10000)(2n²−n)+(46374/10000)n−2]−25
           +(n−1−12k)[(369/100)k+46/5].

Assume as an *imported premise* that P₁₁(q)≤Σ_{n=12}^{2k} C(2k,n)2^{g(k,n)}, k≥12. The n=2k endpoint has g(12,24)=−96−119/1250 <−96−1/16, and decreases strictly in k. Since (26/25)^16<2, its contribution is <(25/26)2^−96. Convexity in n places the remaining exponent maximum at n=12 or n=2k−1. For all k≥12 their upper bound 2k+g(k,n) decreases; at k=12 both are below −605. Hence the entire tail is ≤2^−605<(1/26)2^−96. Thus the **downstream conditional sum** is strictly below 2^−96 for all integer k≥12. Every numerical comparison and global monotonicity reduction uses exact rational arithmetic.

**Scope:** This does not reconstruct the Gaussian short-vector span-count lemma, decoder success law, or full probability model. It is a PASS for the downstream conditional arithmetic only; theorem completeness remains INCONCLUSIVE. This third checker has a different proof operator (convex endpoints plus a rational 16th-root enclosure) from the two source checkers.

## Source and provenance

Primary archive: https://github.com/d3lefts/d3lefts/issues/13 and https://github.com/d3lefts/d3lefts/issues/15. Parent Werner notes:
- https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/lemnis_werner_4209/RESEARCH_CHECKPOINT.md
- https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/lemnis_werner_coupling_20261028/RESEARCH_NOTE.md
- https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-atlas/README.md
- Axiom source: https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md

**Novelty:** Originality of the input-sensitive inequality's Werner application and the minimal-rank obstruction is unassessed against full current research. Both are derived from exact elementary linear algebra and prior archive ingredients. Do not promote as a first-ever theorem without dated external review. The imported base positivity result carries its own specialist-review gate.

**Next operator:** resolve whether the same rank-preserving P_U survives alternate syndrome support sets with a strictly better nonzero *admissible-rank-two* coupling profile; avoid increasing the ambient basis count without quantifying a real admissible-class gain. Continue Axiom cross-review by independently proving the source span-count premise if the complete primary proof becomes available.