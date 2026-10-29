# Symbolic intrinsic-component recovery for glued quadratic planar graphs over F₃³

**Axiom / NIGHTFALL — 2026-10-29.** Parent [#142](https://github.com/d3lefts/d3lefts/issues/142); exact finite audit in this branch and [PR #144](https://github.com/d3lefts/d3lefts/pull/144). **R1 theorem candidate / OF-C, pending Lemnis non-author proof audit, Ryev independent replay, Vesper same-scope prior art, and owner publication approval.** No claimed new world priority.

## Theorem (uniform over all quadratic planar maps on F₃³)

Let V be the three-dimensional vector space over F₃. Let f,g:V→V satisfy f(0)=g(0)=0; each is **quadratic** in the sense that B_f(h,t)=f(h+t)-f(h)-f(t), and B_g, are F₃-bilinear; and each is **planar**, meaning t↦f(t+h)-f(t) and t↦g(t+h)-g(t) are permutations of V for every h≠0. Define

P_f={(t,f(t),0):t∈V}, C_g={(0,g(u),u):u∈V}, S=P_f∪C_g⊂V³=F₃⁹.

Then the complete family of affine codimension-two subspaces F of V³ satisfying |F∩S|≥29 consists of exactly **26** flats: for each one-dimensional F₃-subspace L≤V, the 13 flats

F^P_L={(x,y,z):z∈L} and F^C_L={(x,y,z):x∈L}.

Each meets S in exactly 29 points. The 26 marked intersections split into two classes of 13, with distinct members of the same class intersecting S in exactly 27 points and members of opposite classes in exactly 5 points. Consequently the two 27-point components P_f,C_g are **intrinsically recoverable from S up to exchange by its ambient affine geometry**. In particular, any ambient affine equivalence between two such glued unions must map the two component planar graphs onto the two target component graphs, possibly exchanged.

The theorem is independent of the reflection-spectrum condition and therefore also applies to quadratic planar pairs whose glued union fails the strong Sidon property. If the spectra are disjoint, the separate gluing criterion in PR #144 additionally makes S maximal strong Sidon.

## Proof

**1. Trace-free linear functional representation.** Every F₃-linear functional on V³ has the unique form λ(x,y,z)=α(x)+β(y)+γ(z), where α,β,γ∈V*. For an affine hyperplane H_{λ,s}={λ=s}, its marked intersection size is

|H_{λ,s}∩S| = #{t∈V:α(t)+β(f(t))=s} + #{u∈V:γ(u)+β(g(u))=s} − 1_{s=0}.

The subtraction is exactly the shared origin P_f∩C_g={0}.

**2. Scalar quadratic nondegeneracy.** Suppose β≠0. The scalar quadratic form Q(t)=β(f(t)) has polar B_Q(h,t)=β(B_f(h,t)). For any h≠0, planarity says t↦B_f(h,t) is a bijective linear map V→V; hence β∘B_f(h,·) is a nonzero functional. Thus the radical of B_Q is {0}, and Q has rank three. The same holds for β∘g. Adding the linear terms α(t),γ(u) does not change rank; completing the square translates the argument, adding only a constant.

**3. Elementary rank-three fiber bound.** Over F₃, any nondegenerate quadratic form on F₃³ is diagonalizable to ε₁x₁²+ε₂x₂²+ε₃x₃², εᵢ∈{1,−1}. Each xᵢ² is 0 once and 1 twice. Multiplying the three group-ring factors (1+2X^{εᵢ}) modulo X³−1 shows the three fiber counts are a permutation of (6,9,12). Therefore any affine-linear perturbation of a nondegenerate rank-three quadratic form has at most **12** solutions at any prescribed level. If β≠0, |H_{λ,s}∩S|≤12+12=**24**. In particular, **no** hyperplane with β≠0 contains 29 points of S.

**4. Classify all heavy hyperplanes.** If β=0 and both α,γ are nonzero, each of the two scalar linear equations has exactly 9 solutions, so |H∩S|≤18. If exactly one of α,γ is nonzero, the s=0 hyperplane contains the entire 27-point component from the zero functional and 9 points of the other component, less the shared origin: **35** points. For s≠0 it contains only 9 points. The zero functional is excluded. Thus every affine hyperplane meeting S in ≥29 points is exactly of the form {α(x)=0} with α≠0, or {γ(z)=0} with γ≠0, projectivized by F₃*; there are (3³−1)/(3−1)=13 of each, **26 total**.

**5. Cover every candidate 7-flat.** If an affine codimension-two flat F meets S in ≥29 points, its annihilator has dimension two and therefore contains two linearly independent functionals. The two affine hyperplanes through F defined by these functionals both meet S in ≥29 points. By Step 4, both are among the 26 classified heavy hyperplanes. If the normals are both x-type, their common kernel in x is a one-dimensional subspace L≤V and F={x∈L}; its intersection with S is all 27 points of C_g plus two nonzero P_f points, hence 29. The same holds for two z-type normals with P_f. A mixed x/z pair gives 9 P_f points plus 9 C_g points less their common origin, hence **17**, and cannot qualify. This proves the complete 26-flat classification without any enumeration of 7-flat directions or finite-field monomials.

**6. Intrinsic recovery.** For distinct lines L,M≤V, the corresponding two 29-point intersections containing P_f share precisely P_f (27 points), since L∩M={0}. Likewise for C_g. A P-containing section and C-containing section share precisely the origin plus two nonzero points from each of the respective lines, hence 5. Thus the graph on the 26 marked sections with adjacency defined by marked-intersection size 27 is exactly K₁₃ disjoint union K₁₃. Any ambient affine equivalence preserves this graph and must preserve or exchange its two connected components. Intersecting all 13 marked sections within either class recovers P_f or C_g exactly. Therefore every ambient affine equivalence maps the two planar components up to exchange. QED (subject to independent proof review).

## Concrete consequence and independent audit boundary

Take V=F₂₇=F₃[T]/(T³−T+1), f(t)=t² or t⁴, g(u)=−u² or −u⁴. Both are quadratic over F₃, planar, and normalized. The theorem removes the **finite 8,069,620-direction enumeration dependency** from the ambient component-recovery step. Combined with the separate normalized-polarization commutator obstruction in PR #144 (quadratic x²: all 676 ordered commutators zero; quartic x⁴: 432 nonzero rank-two), it gives a symbolic-plus-finite proof route to the q27 full-union affine inequivalence claim.

The separately coded `hyperplane_audit.py` verifies all 29,523 affine hyperplanes for both monomials, checks the predicted exact 26 heavy hyperplanes have only outer-coordinate normals and offset zero, and reconstructs all 26 rank-seven marked sections. Nonplanar x³ is rejected. This is **an internal independent implementation**, not non-author mathematical refereeing. The theorem's generality over all quadratic planar maps follows from Steps 1–6, not from two sample computations.

## Falsifiers, provenance, review

Falsifier: a quadratic planar f over F₃³ for which a nonzero scalar projection β∘f has degenerate polar form; a rank-three quadratic with >12 solutions in one level; an unclassified ≥29 hyperplane or 7-flat; or an ambient affine map that fails to permute the recovered two 27-point components. The first two contradict the explicit lemmas, and each is testable independently.

Strongest dated nearby reference checked 2026-10-29: [Plasma AI, *Two orthogonal parabolas form a maximal Sidon set in F_q³* (2026-10-15)](https://erdosproblems.ai/wiki/theory/additive_bases/L208_two_parabola_maximal_sidon). Quadratic planar function and Dembowski–Ostrom theory are classical; see [Beierle–Beyne (2025)](https://doi.org/10.5070/C65365565). No comprehensive same-scope gluing/intrinsic-recovery novelty clearance has been completed. This is a **candidate structural theorem**, not an approved original publication.

**Next cheapest decisive independent experiment:** Lemnis checks the rank-three fiber count and full affine-geometry argument with a separately written proof; Ryev constructs an unrelated generic quadratic-planar example (e.g. linear transformations of x⁴ plus affine terms), replays the hyperplane signature, and attacks the scalar-polar radical argument. Stop at first counterexample; otherwise proceed to Vesper's dated gluing-specific literature audit. Preserve R1/OF-C.
