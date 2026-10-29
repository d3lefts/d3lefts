# Uniform intrinsic recovery of glued quadratic planar graphs over F₃ⁿ (n≥3)

**Axiom / NIGHTFALL, 2026-10-29.** Primary [#142](https://github.com/d3lefts/d3lefts/issues/142); companion [PR #144](https://github.com/d3lefts/d3lefts/pull/144). **R1 / OF-C theorem candidate, not externally refereed or novelty-cleared.** This uniform statement supersedes the fixed n=3 symbolic note in this branch without deleting that proof history.

## Theorem

Let n≥3, V=F₃ⁿ as an additive vector space, q=3ⁿ. Let f,g:V→V satisfy f(0)=g(0)=0, and assume:

1. Their polarizations B_f(h,t)=f(h+t)−f(h)−f(t), B_g(h,t) are F₃-bilinear (quadratic maps, allowing linear parts).
2. For each h≠0, t↦f(t+h)−f(t) and t↦g(t+h)−g(t) permute V (planarity).

Define P_f={(t,f(t),0):t∈V}, C_g={(0,g(u),u):u∈V}, S=P_f∪C_g⊂V³.

**(A) Hyperplane classification.** The affine hyperplanes containing at least q points of S are **exactly** {α(x)=0} and {γ(z)=0}, for nonzero linear forms α,γ∈V*, modulo nonzero F₃ scaling. There are exactly q−1 of them, and each contains q+q/3−1 points of S.

**(B) Codimension-two classification.** The affine codimension-two flats containing at least q points of S are **exactly** {x∈U} and {z∈U}, for linear codimension-two subspaces U≤V. There are 2·[n choose 2]₃ such flats, each containing exactly q+q/9−1 points of S, where

[n choose 2]₃ = ((3ⁿ−1)(3ⁿ⁻¹−1))/16.

**(C) Intrinsic recovery.** The marked intersections of the flats in (B) split into two intrinsically defined families, characterized by the relation |(F∩S)∩(F'∩S)|≥q. Same-family pairs have intersection at least q; cross-family pairs have exactly 2q/9−1 points. Intersecting all marked sections in either family recovers P_f and C_g respectively. Thus every invertible affine map of V³ sending S to another union satisfying the hypotheses must map its two planar graph components onto the two target components, up to exchange.

This theorem concerns the **affine geometry of the glued union**. It does not require disjoint reflection spectra or even that S is Sidon. If the reflection spectra are disjoint, PR #144's separate criterion makes S a maximal strong Sidon set.

## Proof

**1. Planarity implies nondegenerate scalar quadratic forms.** Let β∈V* be nonzero. For any h≠0, t↦B_f(h,t) is a bijective F₃-linear map, since it differs by a constant from the planar derivative. Hence β∘B_f(h,·) is a nonzero scalar functional. Therefore the polar form of the scalar quadratic Q_f=β∘f has zero radical. The same holds for Q_g=β∘g. Adding an arbitrary scalar linear form preserves the nondegenerate polarization.

**2. Elementary Gauss-sum bound with proof.** Let Q:V→F₃ be any quadratic polynomial with nondegenerate polar form (allowing linear and constant terms). For u∈F₃* and ψ(t)=exp(2πit/3), write G_u=Σ_{x∈V}ψ(uQ(x)). Then

|G_u|²=Σ_{h,x∈V}ψ(u[Q(x+h)−Q(x)])
=Σ_{h∈V}ψ(u[Q(h)−Q(0)]) Σ_{x∈V}ψ(u B_Q(h,x))=q.

The last equality follows from character orthogonality: for h≠0, the scalar linear functional B_Q(h,·) is nonzero, so its character sum vanishes; for h=0 the inner sum is q. Consequently |G_u|=√q. Fourier inversion for the number N_s of solutions Q(x)=s gives

N_s=(q+Σ_{u=1,2}ψ(−us)G_u)/3 ≤ q/3+2√q/3.

**3. Hyperplanes with a middle-coordinate component are light.** Every affine hyperplane in V³ has an equation α(x)+β(y)+γ(z)=s. Its intersection with S is the sum of the two level counts for α(t)+β(f(t)) and γ(u)+β(g(u)), minus 1 if s=0 (the shared origin). If β≠0, Step 2 gives

|H∩S|≤2q/3+4√q/3 < q,

because q=3ⁿ≥27 implies √q>4.

**4. Classify all other heavy hyperplanes.** If β=0 and both α,γ are nonzero, each linear level set contains q/3 points, so |H∩S|≤2q/3<q. If exactly one of α,γ is nonzero, then the level s=0 contains the full q-point component and q/3 points of the other component, subtracting the shared origin: q+q/3−1≥q. Every s≠0 level has only q/3 points. The zero linear form is excluded. Projective nonzero functionals on V number (q−1)/2; choosing either outer coordinate gives q−1 heavy hyperplanes. This proves (A).

**5. Classify codimension-two flats without enumerating them.** Every affine codimension-two flat F with |F∩S|≥q is contained in two distinct, nonparallel affine hyperplanes H₁,H₂; both contain at least q marked points, so by (A) they are among the classified coordinate-type heavy hyperplanes. If both are x-type, their common kernel U≤V has codimension two; the resulting F={x∈U} contains all q points of C_g and q/9 points of P_f, less the origin, totaling q+q/9−1. Similarly for two z-type hyperplanes. If one is x-type and the other z-type, their intersection contains q/3 points of each component, less the origin: 2q/3−1<q. Conversely every codimension-two U is the common kernel of two independent functionals, so all displayed flats occur. Their number is 2·[n choose 2]₃. This proves (B).

**6. Recover the components intrinsically.** Each z-type marked section is P_f together with C_g(u) for nonzero u∈U. Two such sections share all q points of P_f, plus possibly additional C_g points, so their marked intersection has at least q points. Likewise two x-type sections share C_g. For a z-type section indexed by U and an x-type section indexed by W, the marked intersection consists of the shared origin, q/9−1 nonzero C_g points from U and q/9−1 nonzero P_f points from W, totaling 2q/9−1<q. Thus the intrinsic section-intersection graph at threshold q has precisely two complete connected components, each indexed by the codimension-two subspaces U. Their common intersections recover P_f and C_g because ⋂_{codim U=2}U={0} (n≥3). Affine maps preserve all these incidence counts and intersections, so they preserve or exchange the recovered components. This proves (C). QED, **pending independent non-author mathematical review**.

## Exact n=3 specialization and original publication boundary

At n=3, q=27 and [3 choose 2]₃=13. There are **26** heavy hyperplanes, each with 35 points, and **26** codimension-two flats, each with 29 points. Same-family marked intersections have 27 points; cross-family have 5. The independently implemented `hyperplane_audit.py` verifies all 29,523 affine hyperplanes for the quadratic x² and quartic x⁴ planar maps, their 26 heavy hyperplanes and 26 rank-seven marked sections. Source SHA256 `b5639e60116378b4496c846d6e587a2c5b19ab09bbe42ebb5e9f0f285e10dece`; local Git blob SHA `4bd10f1975eb590766560ff49a11d8cfa4cd0276` matches GitHub. Negative control x³ fails.

**Concrete inequivalence application:** For F₂₇=F₃[T]/(T³−T+1), x² and x⁴ are both quadratic planar maps. This theorem forces every ambient affine equivalence of their two glued 53-point unions to preserve or exchange component graphs. PR #144's separate normalized-polarization commutator certificate rules out such component equivalence (all 676 quadratic commutators vanish, while 432 quartic commutators have rank 2). The *full* inequivalence conclusion therefore follows from this uniform theorem plus that finite commutator lemma, **subject to non-author proof review**.

**Closest dated comparator checked 2026-10-29:** [Plasma AI's two-orthogonal-parabolas maximal Sidon theorem (October 15, 2026)](https://erdosproblems.ai/wiki/theory/additive_bases/L208_two_parabola_maximal_sidon) already covers the quadratic special construction; [Beierle–Beyne (2025)](https://doi.org/10.5070/C65365565) covers classical planar-function structure. Planarity, Dembowski–Ostrom monomials, and planar-component EA inequivalence are classical. **The possible new delta is the uniform affine-intrinsic recovery of components after gluing; worldwide novelty remains unverified.** No claim about integer Erdős #156, #329, or asymptotic maximal Sidon improvements follows.

**Adversarial review contract:** Lemnis independently check every inequality, character orthogonality, codimension-two covering, and component-recovery quantifier. Ryev test transformed quadratic planar maps at q27 and q81 with independently generated field arithmetic, and inject an additive nonplanar map as a falsifier. Vesper conduct same-scope finite-geometric literature search. Stop and demote on any counterexample; do not upgrade beyond R1/OF-C or publish without owner authorization.
