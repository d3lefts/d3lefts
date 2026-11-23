# Direct product-sphere BU route: published theorem -> causal phase retrieval

**Date:** 2026-11-22. **Status:** paper-level theorem reduction using a published topological input. It is **not** an independent original topological theorem, not a Lean `ProductSphereZero` certificate, and not a worldwide priority ruling on the causal phase-retrieval application.

## Recovered parallel unrestricted paper proof and independent AI audit

The complete **unrestricted-in-dimension, unrestricted-in-attainable-prefix** oriented-row causal phase-retrieval proof already exists in merged [PR #995](https://github.com/d3lefts/d3lefts/pull/995), in [PROOF_PASSPORT.md](../../continuous-causal-phase-20261122/PROOF_PASSPORT.md). Merged [PR #1000](https://github.com/d3lefts/d3lefts/pull/1000), in [INDEPENDENT_AUDIT_CLAUDE_20261122.md](../../continuous-causal-phase-20261122/INDEPENDENT_AUDIT_CLAUDE_20261122.md), checked the $(\\mathbb Z/2)^2 equivariant bundle argument, reachable-history extension, causal collision, and n=2 / zero-row cases, finding no gap. The proof should be credited to that parallel construction and audit; this document only records its exact source transfer.

**Key model distinction:** 'unrestricted' means all n>=2, all continuously chosen **oriented measurement rows** on their genuinely attained prefix histories, and every m<=2n-2. It does **not** mean all physically continuous rank-one *projector*-valued selectors on attained histories: [independent detector-holonomy audit](../../continuous-causal-phase-20261122/TOPOLOGY_SOURCE_AND_DETECTOR_HOLONOMY_20261122.md) constructs a physically continuous detector that has no continuous signed-row lift on its actual history space. The oriented-row proof is mathematically complete at paper level and cannot be silently extended to that larger class.

This already settles the mathematical source dependency via Chan–Chen–Frick–Hull; no extra geometric ATLAS Sard proof is required to validate the cited paper theorem. The ATLAS path is an independent **kernel formalization / geometric library** project, not a missing condition of the existing paper proof. New conditional quantitative Lean receipts [45065543797](https://github.com/d3lefts/d3lefts/actions/runs/45065543797) and [45065903920](https://github.com/d3lefts/d3lefts/actions/runs/45065903920) certify the exact causal/risk implications, NOT the separately published product-sphere zero theorem in Lean. Historical originality and a non-AI specialist audit are distinct gates.

## The highest-leverage external reference, checked at its source

Yu Hin Chan, Shujian Chen, Florian Frick and J. Tristan Hull, *Borsuk–Ulam theorems for products of spheres and Stiefel manifolds revisited*, [arXiv:1902.00935](https://arxiv.org/abs/1902.00935), published in *Topological Methods in Nonlinear Analysis* 55 (2020), 553–564.

- Theorem 2.5 gives Ramos's recurrence for the obstruction parity `r(n1,...,nk;V)` for `(Z/2)^k`-representation summands.
- Remark 2.7 (especially equation (2)) proves every `(Z/2)^k`-equivariant map from `S^{n1}×...×S^{nk}` into the sum of `nj` copies of the pure sign representation at factor `j` has a zero. In particular, for `k=2, n1=n2=n-1` this gives **precisely the external topology input** of `ProductSphereZero n (n-1) (n-1)`. Maps with fewer outputs are covered by zero padding, not by changing the dimensions.
- For the mixed character, Theorem 2.5 gives a parity recurrence for the representation `V_(1,1)`: with `r=n-1,s=n-2` pure coordinates plus one mixed coordinate, the obstruction is the coefficient `alpha^(n-1) beta^(n-2)(alpha+beta)=alpha^(n-1)beta^(n-1) ≠ 0` in `F2[alpha,beta]/(alpha^n,beta^n)`. Hence the corresponding mixed zero property holds under the same published theorem (or by Euler/Stiefel-Whitney obstruction). The mod-2 coefficient nonvanishing is independently captured by the **finite algebra** statements in `ProductSphereObstruction.lean`; no false claim is made that these prove the full topological statement in Lean.
- The source explicitly attributes the general theorem to **Ramos (1996)** and previously known cohomological-index work of **Fadell–Husseini (1988)**. The topological novelty is **theirs, not NIGHTFALL's**.

## Exact topological specialization

The domain `SpherePair n` is the product `S^{n-1}×S^{n-1}` of unit spheres in `R^n`, with independent antipodal flips `(u,v)->(-u,v),(u,-v)`. A `U` coordinate is odd under the first flip and even under the second; a `V` coordinate transforms oppositely. With `r,s ≤ n-1`, `ProductSphereZero n r s` says every continuous equivariant map to `R^r_(1,0) ⊕ R^s_(0,1)` has a zero.

Proof from the cited result: pad a given map by zero coordinates to a map to `R^(n-1)_(1,0) ⊕ R^(n-1)_(0,1)`. By Remark 2.7 the latter has a zero; hence the former does too. The corner case `n=2` is included: source has `n1=n2=1`, no dimension-zero ambiguity. This uses a **named published theorem** with the exact sign representation; it does not rely on a conjectural transversality argument.

## Model-specific causal application

Use existing original-source `ProductSphereCausalComposition.lean` (reachable-prefix theorem, code in main) with `n≥2`, `m≤2n−2`. Color the m stages U/V with `r,s ≤ n−1`, then apply the **now published-source-supported** `ProductSphereZero n r s` statement. Its output `u,v` yields the genuine equal causal transcripts of `x=u+v` and `y=u−v`, with distinct global-sign orbits. The proof of continuity of the test maps uses only continuous selectors restricted to **attained**, actual histories; it does not postulate selection continuity on virtual histories, nor a Tietze extension for unreachable histories.

Therefore the mathematically justified, source-dependent result is that no deterministic reachable-continuous adaptive real rank-one squared-intensity protocol with fewer than `2n-1` readings is universally injective up to sign. The **upper bound** is the classical fixed-frame complement property, achievable with `2n-1` generic real measurement vectors. Combine these *only if their signal and measurement models are exactly matched*.

This is a **paper-level full theorem route conditional only on accepting an established external published Borsuk–Ulam theorem**, not an unconditional new Lean theorem. The external result already establishes the abstract topology. NIGHTFALL's mathematical opportunity is the specific causal phase-retrieval reduction and the reachable-history regularity threshold. Novelty of this application still needs a dated specialist search.

The quantitative consequence is in [README.md](README.md): for any Euclidean radius R, the same transcript collision can be scaled to two points in the R-ball at quotient distance R, yielding decoder-independent worst-case risk at least R/2 and squared risk at least R²/4. For `m≤2n-3`, the additional mixed-character zero forces orthogonal `u,v`, giving two indistinguishable points **on the radius-R sphere** with quotient distance `sqrt(2)*R`, decoder error floor `R/sqrt(2)`, and squared error floor `R²/2`. These quantitative claims are written proofs; the universal scaling and decoder lemmas are not all Lean-compiled.

## Formalization fork: what PR #1111 should now prioritize

- **Fast mathematical paper proof:** cite Theorem 2.5 / Remark 2.7 exactly, prove the representation and reachable-prefix maps correspond to the hypothesis, close physical phase-transcript induction, and attach the quantitative decoder corollaries. This route does **not** require implementing all of the external cohomology or Sard proof in Lean.
- **Full Lean kernel goal:** either formalize the external product-of-spheres theorem via cohomological obstruction in a separate trusted module (with exact characteristic class, bundle and no-zero contradiction), or complete the concrete zero-fiber C∞ boundary manifold construction already pursued by #1111/#1108/#1106. The latter is longer but provides reusable geometric formalization infrastructure. **Neither route has a complete Lean certificate in the current branch.**
- **Independent audit B:** instantiate Ramos/CCFH with the actual `S^{n-1}` dimensions and pure/mixed group representations, test `n=2`, `r=0`, `s=0`, continuity on `SpherePair` including nonphysical histories of the *comparison*, and verify that the causal tests really transform under both flips. Independently reprove the exact minimax two-point bound and verify its scaling formula. Check Ullrich (arXiv:2610.33781), real phase-retrieval frame literature, and other adaptive recovery sources for the exact model.

## Stop/promotion contract

A named published theorem plus a source-matched model reduction is a valid paper proof dependency; it is **not the same kind of evidence** as a standalone Lean kernel proof, source-free theorem originality, or referee acceptance. If source signs, dimensions, or continuity hypothesis do not match, demote the paper claim until corrected. Do not add a certified topological declaration or inflate existing Warrant/Proof Passport counts.
