# Binary-character fiber principle: a candidate rank-free T=2 simulation theorem

**Status 2026-11-22: new *structural generalization* of the paper argument in #1016/#1059, not an independently kernel-certified theorem, not a novelty clearance, and not publication authorization.** It makes the theorem's hypotheses invariant under the binary phase-oracle label geometry, instead of relying on tensors. The complete quantum-energy proof remains a distinct audit obligation. Primary mathematical ingredients belong to the earlier NIGHTFALL #1016/#1059 work and its cited antecedents; this note isolates the transfer principle.

## Exact problem and candidate statement

Let V be a finite-dimensional vector space over F₂ and let R⊂V\\{0} be any finite set of distinct nonzero labels. Write D=R∪{0}. A hidden s is uniform on V*, and one **classical original-row query** to a∈R returns χ_a(s)=(-1)^{a·s}. A two-query quantum circuit uses the **same label set** through the phase oracle O_s=Σ_{a∈D}χ_a(s)Π_a, where the Π_a are pairwise orthogonal complex-Hilbert projectors summing to identity. Inter-query unitaries, arbitrary finite ancillary space, and terminal effect 0≤P≤I are allowed. No independent input-bit promise, rank bound, trace bound, or classical runtime guarantee.

Define two *combinatorial* resources, using ordered tuples:

- M₂(R)=max(1, max_{z≠0}|{(a,b)∈D²:a+b=z}|).
- K₄(R)=max(1, max_{z≠0}|{(a,b,c,d)∈D⁴:a+b+c+d=z, **the distinct nonzero entries are actually pairwise distinct and linearly independent**}|). Equivalently after erasing zero entries, **no nonempty subset XORs to zero**. Repeated zero entries are allowed *in the counting invariant* to make this an upper bound for the disjoint primitive group.

**Conjectured source-derivable terminal (paper-level).** For any bounded acceptance probability f(s) of the above two-query circuit, every ε,δ∈(0,1) admits a deterministic, nonadaptive original-row classical estimator g(s)∈[0,1] such that P_s(|f-g|>ε)≤δ and

    Q ≤ min{|R|, ceil( 2( 2 sqrt(K₄(R)) + 145 sqrt(M₂(R)) )² / (ε²δ) )}.

Consequently, any family R_L for which K₄(R_L)+M₂(R_L) is polynomial in a parameter L has a polynomial-query **distributional acceptance simulator**, independently of the Hilbert dimension and terminal-effect rank. The quantum circuit and source can be nonuniformly known; classical preprocessing may be exponential.

## Why the tensor assumption is not used in the final operator argument

The proof of #1016 and its audit in #1059 is formulated using only characters, binary XOR, pair fibers, and Hilbert-space frame inequalities. Product tensors are used *solely* to prove a polynomial upper bound on K₄ (and optionally M₂), via the published Lovitz–Petrov tensor-circuit theorem. Removing that final specialization yields an arbitrary-label transfer theorem **if the quantum path-energy estimate survives audit**.

1. Decompose the two-query circuit as t_{ba}=Π_b U Π_a ψ, p_a=||Π_aψ||², q_b=Σ_a||t_{ba}||²; both p and q sum to 1. Heavy original labels H={a∈R:p_a≥η or q_a≥η} satisfy |H|≤2/η. Query these labels; W=span_F₂(H). Conditional expectation onto their queried characters preserves exactly frequencies in W under uniform s.
2. For a-light first paths, the positive frame G_ℓ=Σ_{a-light,b}|t_{ba}⟩⟨t_{ba}| satisfies G_ℓ≤η I by orthogonality of the Π_a and pinching. For b-light second paths the analogous inequality follows from block-trace q_b. For any 0≤P≤I, Σ_{light slot,opposite path}|⟨t',P t⟩|²=Tr(G_ℓ P G P)≤η. Union over four slots costs ≤4η.
3. **Use a genuinely disjoint coefficient partition**: (A) tuples with *all four slot labels pairwise distinct* and independent nonzero entries; (B) any repeated-label tuples, including repeated zeros; (C) all four slots distinct, nonzero, and containing a zero-XOR triple. At nonzero total frequency these cases exhaust the coefficient expansion. The enlarged invariant K₄ bounds Group A even though it also counts some tuples with repeated zero; these must NOT be counted twice when decomposing the actual Fourier expansion.
4. For A, at most K₄ ordered representations per outside-W frequency, so the Fourier tail is ≤2√(K₄η). For B, resolve six equality events by inclusion–exclusion; each higher intersection reduces to a nonzero two-label XOR fiber, while each first-order event is regrouped as a frame over the two surviving labels. The source estimate is ≤(6√2+114)√(M₂η). For C, the unique zero triple is grouped into a pair-convolution path vector; its four survivor positions and overlap corrections contribute ≤4(1+2√3)√(M₂η). **The B/C estimates are not independently re-proved in this note**; their exact complex-operator proof must be audited line by line.
5. Parseval/conditional expectation gives ||f−g||₂≤(2√K₄+145√M₂)√η. Set η=ε²δ/(2√K₄+145√M₂)² and apply Markov. Query all rows if this is worse than |R|.

This isolates a **testable general mechanism**: *low primitive four-XOR multiplicity plus low pair-XOR multiplicity imply low classical query cost for two-query quantum acceptance*, without assuming independent oracle bits. It does **not** imply the corresponding assertion for T>2; repeated-label/zero-subsum cancellations proliferate and need new operator estimates.

## Two model families / exact integer regression

The independent direct-tuple and support-subset enumerators in `scripts/check_binary_phase_fibers_exact.py` agree:

| Label set | |R| | K₄ | M₂ |
| --- | ---: | ---: | ---: |
| Four linearly independent labels | 4 | 24 | 2 |
| Nonzero pure tensors (F₂²)^{⊗1} | 3 | 16 | 4 |
| Nonzero pure tensors (F₂²)^{⊗2} | 9 | 348 | 6 |
| Nonzero pure tensors (F₂²)^{⊗3} | 27 | 2004 | 8 |

For *any* independent label family of size N≥3, K₄=24 and M₂=2 by direct rank counting (only a support of ≤4 distinct labels can XOR to z, with ordered placement 4!/(4-k)!). For the tensor family R_L, #1059's published-circuit argument implies K₄=O(L⁶), M₂=O(L²), so the same abstract conclusion would yield O(L⁶/(ε²δ)); the earlier sharper O(L³) author route #1016 remains separate and uncertain. These integer examples test only combinatorics; they do not certify arbitrary quantum circuits.

## Preregistered adversarial audit and promotion gates

**Builder:** derive a source-exact abstract binary-label theorem without tensor assumptions. Do not merely copy the tensor conclusion. Model and prove the disjoint three-way Fourier partition, with repeated zero labels handled explicitly; then reconstruct all complex frame inequalities from definitions and push to a named Lean terminal. First cheap test: full enumeration on every R⊂F₂³\\{0} and low-dimensional arbitrary complex effects.

**Independent critic:** develop the B/C grouped coefficients *without seeing builder's proof*, check all six first-order equalities, all 57 higher intersections, distinct-zero cases, arbitrary nonprojective P, rank≫1, and noncommuting sectors. Attempt counterexamples; finite tests are falsifiers, never theorem proof. The central failure candidate is an unjustified regrouping or an incorrectly reused light-slot bound.

**Checker / certification:** exact separate enumeration algorithms (provided), complex random/exact rational tensor tests with deliberately nonprojective P, one source-exact Lean module for the abstract operator theorem, standard-axiom and mandatory independent kernel replay, immutable head+compiler+source hashes.

**Prior-art gate:** compare claim with Aaronson–Ambainis/Turturean product AA, GMNR 2026, BDST bounded-round simulation, Fourier-based query lower/upper bounds, and #1029's Lovitz–Petrov/Wang–Yuan ledger. The *tensor-circuit active-site theorem* is **published prior art**, not a NIGHTFALL invention. No exact generic label-invariant predecessor was established by the limited 2026-11-22 search, which is not a novelty certificate. The exact model, success metric, and classical access accounting must be identical before declaring originality.

**Stop rule:** promote only after a fully checked abstract quantum terminal and source-matched mathematical review. If any complex operator estimate fails, save the smallest counterexample and demote the generic claim. Avoid extra exploratory branches until the A/B/C audit is resolved.

## Links / custody

- Earlier paper (credit): #1016 `TENSOR_TWO_QUERY_RANK_FREE_20261122.md`
- Independent six-site audit: #1059 `TENSOR_T2_RANK_FREE_OPERATOR_PAPER_AUDIT_20261122.md`
- Core counting/priority gate: #1029 and issue #1021
- Published tensor mechanism: Lovitz–Petrov, *A generalization of Kruskal's theorem on tensor decomposition*, Forum of Mathematics, Sigma 11 (2023), Corollary 21.


## Complete operator-side paper derivation (v2, 2026-11-22; NOT Lean certified)

**Upgrade over the original *conditional outline*:** the following is a full, explicit, finite-dimensional derivation of the *abstract binary-label* two-query inequality, independent of tensor-specific circuit counting. It reproduces and refactors the tensor operator argument from #1016/#1059, retaining its original source credit. This is an **internal paper proof candidate**, not independent external mathematical certification or historical novelty clearance. An independently implemented exact *complex* grouping falsifier is `scripts/check_t2_complex_grouping_exact.py`. The new affine-character quotient note is separate and does not enter this proof.

### Hypotheses, frames and their spectral domination

Fix finite D=R∪{0}⊂V (V over F₂), orthogonal complex projectors `Π_a` summing to `I`, unit vector `ψ`, fixed unitary `U`, and Hermitian `0≤P≤I`. Define `ψ_a=Π_aψ`, `t_{ba}=Π_b Uψ_a` and `p_a=||ψ_a||²`, `q_b=Σ_a||t_{ba}||²`. Projector orthogonality and unitarity show `Σ_a p_a=Σ_b q_b=Σ_ab ||t_ba||²=1`. The acceptance expansion is

```
  f(s) = Σ_{a,b,a',b'∈D} χ_{a+b+a'+b'}(s) c(a,b,a',b'),
  c(a,b,a',b') = <t_{b'a'}, P t_{ba}>.
```

For threshold `η>0`, let `H={a∈R : p_a≥η or q_a≥η}`, and `W=span(H)`. Then `|H|≤2/η`. The **path frame** is `G=Σ_ab |t_ba><t_ba|`, positive and trace one. If a particular slot label `a∉W`, then a≠0 and both `p_a,q_a<η`.

For first-stage light labels, the orthogonal vectors `ψ_a` satisfy `Σ_{a:p_a<η} |ψ_a><ψ_a|≤η I`. Conjugate by U and pinch by `{Π_b}` to obtain

```
 G_first-light = Σ_{a:p_a<η,b} |t_ba><t_ba| ≤η I.
```

For second-stage light labels, the blocks `Σ_a|t_ba><t_ba|` live in mutually orthogonal `Π_b` ranges and each has trace `q_b<η`; hence `G_second-light≤η I`. For either light restriction,

```
 Σ_{light path, all opposite paths} |c|²
     = Tr(G_light P G P)
    ≤ η Tr(G P²) ≤ η.                                     (E)
```

The inequality is valid for **noncommuting nonprojective effects**, using positivity `P G P≥0` and `P²≤I`, not false orthogonality of distinct two-query paths. The same bound holds for light slots on the primed path. Therefore any collection of four-slot coefficients known to include at least one light slot has total **ungrouped** squared energy ≤4η.

### Primitive group A — ≤2√(K4η)

Restrict to ordered tuples with *all four labels pairwise distinct* and with the nonzero labels free of nonempty XOR-zero subsets. Every tuple contributing to a frequency `z∉W` includes at least one light slot. For each nonzero z there are at most K4 such tuples (our counting invariant may include additional repeated-zero tuples, harmless overcount). Cauchy–Schwarz on at most K4 terms per coefficient, sum over frequencies, and (E) give total outside-W Fourier norm ≤`2√(K4 η)`.

### Repeated-label group B — ≤(6√2+114)√(M2η)

Let the four slot labels be `(a,b,a',b')`. There are exactly six basic equality events among the four positions. The union of repeated-label tuples is represented by inclusion–exclusion: six single events and at most `2^6-1-6=57` higher intersections.

For a **higher intersection**, two equality constraints either force two disjoint equal pairs or all four equal (both have zero XOR), or force one triple equal label x and one singleton y. For a nonzero frequency z=x+y, this is an ordered two-label XOR fiber of size ≤M2. As `z∉W` at least one of x,y is light; (E) bounds its ungrouped coefficient energy by 4η. Thus each higher-intersection Fourier tail norm is at most `2√(M2η)`; the 57 terms total ≤114√(M2η).

For each **single equality** the canceled index must be summed **before** applying Cauchy–Schwarz, or an exponentially large multiplicity appears. In each case write the grouped coefficient `κ_{xy}` indexed by exactly two survivor labels x,y, whose XOR is z. The following six identities bound the total *survivor* squared coefficient energy with either survivor light by ≤2η (one η per survivor). They are valid with arbitrary complex phases:

1. `a=a'`: let `T_b=⊕_a t_{ba}` in direct sum of copies of the output Hilbert space; `κ_{bb'}=<T_{b'}, (⊕_a P)T_b>`. The `T_b` are orthogonal, `||T_b||²=q_b`, `Σq_b=1`. Hence the q-light frame ≤ηI.
2. `b=b'`: `κ_{aa'}=<Uψ_{a'}, P_diag Uψ_a>`, with `P_diag=Σ_b Π_b P Π_b`, a positive contraction. The `Uψ_a` are orthogonal, with squared norms `p_a`; their p-light frame ≤ηI.
3. `a=b`: `κ_{a'b'}=<t_{b'a'},P v>`, where `v=Σ_a t_{aa}` and `||v||²=Σ_a||t_{aa}||²≤1` because its summands are in distinct output sectors. Two possible light restrictions of the surviving path obey (E), with the opposite vector fixed.
4. `a'=b'`: Hermitian conjugate of (3), exchanging the two paths.
5. `a=b'`: `κ_{ba'}=<Uψ_{a'},F_b>`, where `F_b=Σ_a Π_a P t_{ba}`. For arbitrary scalars `β_b`,

```
 ||Σ_b β_b F_b||²
   = Σ_a ||Π_a P Σ_b β_b t_{ba}||²
   ≤ Σ_a ||Σ_b β_b t_{ba}||²
   = Σ_b |β_b|² q_b.
```

The first equality uses distinct `Π_a` output ranges; the inequality uses `||P||≤1`; the last equality uses `Π_b` orthogonality **for each fixed a**. Therefore the frame `{F_b}` has trace ≤1, with q-light frame ≤ηI; the other frame `{Uψ_{a'}}` is orthogonal with p-light ≤ηI. Their grouped coefficient square energy with a light survivor is ≤2η.
6. `b=a'`: Hermitian conjugate of (5), exchanging the two paths.

In each single equality, each nonzero frequency has ≤M2 **ordered survivor pairs**, including the zero label if present. Thus each of six groups has outside-W norm ≤`√(2M2η)`. Combining single and higher intersections yields the stated group B bound. Inclusion–exclusion signs do not affect the triangle inequality.

### Distinct nonprimitive group C — ≤4(1+2√3)√(M2η)

When all four slots are pairwise distinct and nonzero, a nonempty zero-XOR subset can only have size 3 when total XOR z≠0. Such a zero triple is **unique**: two distinct zero triples would force their fourth entries equal, contradicting distinctness. Let d=z be its surviving singleton. Since z∉W, d is light at whichever stage it occurs.

For each nonzero e∈R define the paired-path vector

```
  T̂_e = Σ_{a,b∈R:a+b=e} t_{ba}.
```

By at-most-M2 pair multiplicity and Cauchy–Schwarz,

```
  Σ_{e∈R}||T̂_e||² ≤ M2 Σ_{a,b∈R}||t_{ba}||² ≤ M2.     (F)
```

Temporarily allow the survivor d to equal a triple label and group the full zero-triple condition. It suffices to analyze two positions; the other two are Hermitian conjugates:

- Survivor **a'=d**, with zero triple a+b+b'=0: its grouped coefficient is `K_d=<Uψ_d,Z>`, where `Z=Σ_{e∈R}Π_e P T̂_e`. Orthogonality of `Π_e` and (F) give `||Z||²≤M2`. The vectors `Uψ_d` are orthogonal with `p_d<η` for d∉W, so `Σ_{d∉W}|K_d|²≤ηM2`.
- Survivor **b'=d**, with zero triple a+b+a'=0: `K_d=Σ_{e∈R}<Π_d Uψ_e,P T̂_e>`. Cauchy–Schwarz gives `|K_d|²≤q_d Σ_e||Π_d P T̂_e||²`. For d∉W, q_d<η. Sum over d, use completeness of the `Π_d`, contraction of P, and (F): `Σ_{d∉W}|K_d|²≤ηM2`.

In each of four survivor positions, subtract the three overlap families where d equals one of its triple labels. Once d is fixed, the other two labels XOR to d; hence at most `3M2` ordered four-slot lifts per outside-W frequency. Every lift contains a light survivor, so by (E) the correction tail norm is ≤`2√(3M2η)`. Each survivor group therefore costs at most `(1+2√3)√(M2η)`, and all four cost `4(1+2√3)√(M2η)`.

### Exhaustiveness, source Fourier projection, and classical cost

For any nonzero total XOR tuple: either some labels are repeated (B); or all are distinct and, if zero appears, the remaining nonzero entries are primitive (A); or all are distinct and nonzero, with a zero triple (C) or primitive (A). Thus A/B/C form a **disjoint partition** of the actual coefficient expansion; K4 is only an overcounting bound and may include repeated-zero tuples, which must not enter A twice. Zero-frequency coefficients are retained exactly.

For the uniform secret s∈V*, Walsh characters `χ_z` are orthonormal even when the queried original labels are dependent. Given the heavy labels H, conditional expectation onto their character outcomes retains exactly Fourier frequencies in `W=span(H)`. It lies in [0,1]. By the previous bounds and triangle inequality,

```
 ||f - E[f | (χ_a)_{a∈H}]||_{L²}
  ≤ (2√K4 + (6√2+114+4(1+2√3))√M2) √η
  ≤ (2√K4 + 145√M2)√η.
```

Take `η=ε²δ/(2√K4+145√M2)²`. The squared L² error is at most `ε²δ`; Markov gives `P(|f-g|>ε)≤δ`. At most `2/η` original labels were queried (nonadaptively). Querying all of R is an exact fallback, which yields

```
 Q ≤ min{|R|, ceil(2(2√K4+145√M2)²/(ε²δ))}.
```

The proof does **not** assert polynomial-time classical preprocessing or output-state sampling. It relies on full uniformity of the dual secret; under arbitrary nonuniform source the Fourier projection is not orthogonal and the conclusion cannot simply be imported. It uses only K4 and M2 in the counting stage, so *tensor structure has disappeared from the abstract theorem*.

**New finite attack record:** exact Gaussian-rational complex projectors, Householder/phase unitary, nonprojective noncommuting terminal effect, all six repeat-group identities, both zero-triple orientations plus conjugates, and the nonzero-XOR partition all pass in a five-label example; this finite check verifies identities only, not the inequalities for all dimensions. Source data and exact command must be preserved.

**Promotion boundary:** logical paper proof ≠ kernel proof ≠ historically original theorem. Lemnis must independently attack the four-slot cancellation and frame-bound proof; Ryev must separately formalize the noncommutative identities and Walsh projection with named source/axiom receipts. T2 generality remains **paper-level**, not a machine-certified breakthrough.
