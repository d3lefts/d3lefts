# Gluing Planar Difference Graphs into Maximal Sidon Sets: a Reflection-Spectrum Criterion

**Axiom / NIGHTFALL, 2026-10-29.** Parent #46 (Erdős #156), secondary #49; self-designed #142. **Stage R1: proof candidate and exact internal checks, not external refereeing, novelty certification, or publication.** Owner Devin J. Wright retains publication authority.

## Formal theorem

Let H be a finite abelian group of odd order q≥3. Let f,g:H→H be normalized planar functions: f(0)=g(0)=0 and for every h≠0, each additive derivative t↦f(t+h)−f(t), u↦g(u+h)−g(u) permutes H. Put

P_f(t)=(t,f(t),0), C_g(u)=(0,g(u),u), A=P_f(H)∪C_g(H)⊂H³.

Define reflection spectra R_f={f(t)+f(−t):t≠0} and R_g analogously.

**Theorem.** A is strong Sidon (all unordered sums including doubles distinct) **if and only if** R_f∩R_g=∅. Whenever this holds, |A|=2q−1 and A is **maximal strong Sidon** in H³. Each reflection spectrum has exactly (q−1)/2 elements, so disjointness is equivalent to a partition of H\{0}.

**Explicit nonquadratic-polynomial family.** For p odd, q=p^n, n/gcd(n,k) odd, f(t)=t^(p^k+1), g(t)=μt^(p^k+1) with μ nonsquare, the hypotheses hold. In particular F27, f=t⁴, μ=−1 gives a 53-element maximal strong Sidon set in a group of order 19,683. No affine inequivalence to the quadratic example is claimed.

## Proof (all cases)

1. **Graph uniqueness.** If t+s=v+w and f(t)+f(s)=f(v)+f(w), put h=t−v=w−s. For h≠0, derivative injectivity gives v=s, t=w; otherwise the unordered pairs already coincide. Hence P_f is strong Sidon, likewise C_g. Their intersection is only 0.
2. **Reflection.** The sums f(t)+f(−t) are nonzero for t≠0 and equal only when the indices are ±-equal, by the preceding Sidon property. Since H has odd order, |R_f|=(q−1)/2, similarly g.
3. **Mixed sums.** P(t)+C(u) has first and third coordinates t,u. If both nonzero it is uniquely determined and cannot equal P+P (third 0) or C+C (first 0). If either is zero it is the same unordered pair involving the shared origin. The only distinct P+P/C+C collision is P(t)+P(−t)=C(u)+C(−u), with t,u≠0; precisely the reflection-spectrum intersection. This proves the iff.
4. **Maximality witnesses.** Let x=(α,β,γ)∉A. If α≠0, solve f(w+α)−f(w)=β−g(γ) uniquely and write x=C(γ)+P(w+α)−P(w). If α=0,γ≠0, solve g(v+γ)−g(v)=β and write x=P(0)+C(v+γ)−C(v). If α=γ=0,β≠0, fix h≠0 and solve f(s+h)−f(s)=f(h)−β, giving x=P(h)+P(s)−P(s+h). In every case the subtracted point differs from both added points; otherwise x∈A or β=0. Thus adjoining x repeats an unordered pair sum. Count |A|=q+q−1.
5. **Planar monomial.** Let d=gcd(n,k), m=n/d odd. D_a(t^(p^k+1))=a^(p^k+1)[(t/a)^(p^k)+(t/a)+1]. A nonzero y satisfying y^(p^k)=−y would, after m Frobenius iterations, satisfy y=−y, impossible in odd characteristic. Thus every derivative permutes. Similarly z^(p^k+1)=1 implies z²=1, so gcd(p^k+1,q−1)=2 and nonzero monomial values are exactly the squares. The reflection sets are 2·squares and 2μ·squares, complementary for nonsquare μ.

## Executable falsification

Run the two standard-library scripts in this directory: verify.py and structural_audit.py. The first independently enumerates every unordered pair sum, including diagonals, and tests **every external point** for addability using a direct sum dictionary. The second independently constructs tuple-field arithmetic, checks every nonzero derivative and both reflection spectra, then constructs and verifies a blocking triple for **every external point** without consulting the first checker. Both use exact arithmetic.

| q | exponent | size | distinct sums | blocked outside | direct / structural |
|---:|---:|---:|---:|---:|---|
|3|2|5|15|22|PASS / PASS|
|5|2|9|45|116|PASS / PASS|
|7|2|13|91|330|PASS / PASS|
|11|2|21|231|1310|PASS / PASS|
|27|4|53|1431|19630|PASS / PASS|

F27 is F3[T]/(T³−T+1), irreducible because the polynomial has no root in F3. Negative controls: μ=1 produces a literal sum collision at every q; nonplanar t³ in characteristic 3 fails the derivative-permutation test. No randomness, tolerances or sampling. The complete locally frozen archive additionally carries JSON receipts and SHA-256 manifest.

## Dated source and publication boundary

**Closest prior work checked 2026-10-29:** Plasma AI, [Two orthogonal parabolas form a maximal Sidon set in F_q³](https://erdosproblems.ai/wiki/theory/additive_bases/L208_two_parabola_maximal_sidon), posted October 15, 2026. It already proves the q²/μq² special case and **2q−1 size**. Do not claim that special case, constant, or finite-group analogue as new. Other context: [Redman–Rose–Walker 2022](https://doi.org/10.1137/21M1454663) uses characteristic two and a different Sidon convention; [Erdős #156](https://www.erdosproblems.com/156) is OPEN for integer intervals, with Ruzsa 1998 O((N log N)^(1/3)). Planar monomials and finite-field semifield theory are classical. A targeted web search did not locate the general gluing iff, but this is **not a global priority clearance**.

**Exact proposed novelty delta:** the iff classification by complementary reflection spectra for *arbitrary normalized planar maps on odd abelian groups*, plus a transfer to nonquadratic planar monomials. Whether those examples are genuinely inequivalent to the quadratic construction is OPEN. No carry-free transfer to integer intervals, no improved asymptotic maximal-Sidon bound, no #49 nested-prefix theorem.

**Publication stages:** R0 registered in #142; R1 this draft. R2 awaits Lemnis non-author proof attack, Ryev independently implemented verifier and dated expert literature/equivalence comparison. R3 human owner approval and public versioned paper, R4 separate significance gate. **Single blocking lemma:** establish a genuinely inequivalent nonquadratic glued family or an independently significant new classification consequence not already implied by classical planar-function equivalence. Otherwise demote to a useful generalization, not an original publication. **#46 N184,k9 remains UNDECIDED.**


## Additional adversarial affine-equivalence test — negative result

The standalone C++17 program codim2_standalone.cpp constructs both q27 x² and x⁴ glued sets using independent polynomial-ring arithmetic and exhaustively enumerates **all 8,069,620** two-dimensional subspaces of the dual F3^9. For each, it records the largest intersection with one of the nine affine codimension-two fibers. The histograms agree **exactly**; both have maximum 29, attained for 26 quotient maps. This invariant therefore **cannot distinguish** the quartic example from the previously known quadratic one. It does not prove equivalence. The program has a self-contained source generator and an exact combinatorial subspace count check, and is now in dedicated CI. This is a negative test of the proposed inequivalence route, not a new originality claim. Do not repeat low-order affine intersection scans without a new structural prediction.
