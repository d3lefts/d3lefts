# Actual Efron–Stein pairs → global matching: proof ledger v1

**Date:** 2026-11-12. **Scope:** finite independent categorical products with coordinate-specific normalized laws; zero-mass symbols permitted. **Status:** exact analytic proof of global matching inequality; source-level Lean bridge submitted in draft PR #408, strict terminal matching mass theorem **not yet kernel-certified**.

## Formal goal

For a pointwise bounded real function \(f\) with \(\|f\|_\infty\le B\) and actual Efron–Stein/Hoeffding degree at most two, define \(h_{ij}=\operatorname{esComp}_p(\{i,j\},f)\) in the actual product space. For every matching \(F\) of pairwise-disjoint coordinate edges,

\[
\sum_{\{i,j\}\in F} \max_{a,b}|h_{ij}(a,b)| \le 4B.
\]

Here \(\max\) ranges over the entire alphabet, including zero-mass symbols; consequently the **pointwise** assumption \(|f(x)|\le B\) is needed on the entire finite input space. For merely essentially bounded \(f\), restrict each alphabet to its positive-probability support before taking maxima. Do not conflate the two scopes.

## Certified components and current proof attempt

1. Main-tree \`EfronSteinDegree.lean\` defines actual \`condExp\`, \`esComp\`, proves support dependence, Mobius inversion, and degree equivalence; main-tree \`QuadraticHoeffdingBridge.lean\` proves actual source-level degree-two truncation.
2. Draft \`ActualESPairMatchingBridge.lean\` proves \(\sum_a p_i(a)h_S(x_{-i},a)=0\) for every \(i\in S\), using resampling invariance and the **actual finite Mobius toggle**, rather than an externally assumed centeredness table. The sliced \`actualPairKernel\` recovers genuine \`esComp p {i,j} f\` for every input, independently of unmatched coordinates.
3. The recovered independently developed \`CenteredRectangles.lean\` provides exact weighted rectangle extraction. The new draft instantiates it for actual pair kernels and simultaneously chooses positively oriented rectangles for **every edge** in an arbitrary finite graph, including unmatched and densely interacting sites.
4. Main-tree \`QuadraticMatchedParity.lean\` proves the full even/odd selector cancellation and four-times-\(B\) matching budget for an *explicit complete block polynomial*, including all cross-block pair terms. Main-tree \`WeightedGreedyCover.lean\` proves the endpoint cover \(8B\), conditional only on a global matching-mass bound for the graph weights.
5. **Still missing in Lean:** a source-level parity identity that expands an arbitrary actual \`ESDegreeLE p f 2\` function over an arbitrary disjoint matching, with unmatched coordinates padded, and identifies the actual selected four-point terms from \`esComp\`. The existing global parity theorem's explicit \`BlockPolynomial\` is **not** yet constructed from that same actual \(f\). The global matching-mass inequality, exponent-two variance theorem, and arbitrary measurable/infinite-product extension therefore have no terminal Lean certificate.

## Analytic global parity identity

For each edge \(e=(i,j)\in F\), choose a maximal \(|h_{ij}(a,b)|\), and choose rectangle \(a_0,a_1;b_0,b_1\) with positive mixed difference \(\Delta_e\ge \|h_{ij}\|_\infty\). Choose independent uniform selector bits \(\sigma_e\). The *even* input sets \((X_i,X_j)=(a_{\sigma_e},b_{\sigma_e})\), the *odd* input sets \((X_i,X_j)=(a_{\sigma_e},b_{1-\sigma_e})\), and all unmatched inputs are fixed identically. Since \(f\) has Hoeffding interaction degree at most two:

- Constants and singleton terms cancel because their one-coordinate selector marginals agree;
- Every pair interaction spanning two different matched blocks cancels because the corresponding selectors are independent and the one-coordinate marginals agree;
- Every pair involving an unmatched coordinate cancels because that coordinate is fixed in both experiments;
- Every matched interaction contributes precisely \(\Delta_e/2\).

Therefore \(\mathbb E_{\rm even}f-\mathbb E_{\rm odd}f=\frac12\sum_{e\in F}\Delta_e\). Both expectations lie in \([-B,B]\), giving \(\sum_{e\in F}\|h_e\|_\infty\le\sum_e\Delta_e\le4B\).

**No minimum-atom, balanced-law, graph sparsity, or rank hypothesis.** This is an analytic mathematical argument, not a claim of a completed Lean proof.

## Independent falsification check

A separate exact \`fractions.Fraction\` replay was executed for 25 constructed heterogeneous five-coordinate quadratic models. It checked 50 source-extracted canonical pair kernels, true max-amplitude rectangle orientation, the global parity-expectation equality with one unmatched coordinate, and the \(4B\) matching bound. Some sampled coordinate laws may assign zero mass to symbols. This is finite regression, not mathematical certification.

## Decisive remaining experiment / stop rule

Implement a new declaration whose only mathematical hypotheses are \`hp\`, \`hp1\`, \`hf : ∀x, |f x|≤B\`, \`ESDegreeLE p f 2\`, \`IsMatching u v S\`, and distinct endpoints; its conclusion is the **actual** \(4B\) sum over source-derived pair amplitudes. Build the required general arbitrary-source parity identity either by (a) explicitly reindexing the certified low-support Efron–Stein sum into matched-block \`BlockPolynomial\` with unmatched-coordinate padding or (b) applying the two selector expectation functionals to each certified \`esComp p T f\` with \(|T|\le2\) and proving cancellation by support. Do not pass a \`matching_mass\` hypothesis, an externally supplied centered kernel, or an arbitrary equality \`f=quadraticModel\` as the terminal theorem's premise. If this cannot compile with strict axiom receipts, preserve the current scoped sublemma status without promotion.

## Provenance and certification

Strict compiler is Lean 4.33.0 with Turturean upstream commit \`2a6ceaef872ae993708950f951989134084b851a\`. Permitted axioms: \`propext\`, \`Classical.choice\`, \`Quot.sound\`. Each successful named declaration requires \`COMPILED\`, source SHA-256, and named axiom receipt with no \`sorryAx\`. A green unrelated job is not a matching theorem certificate. Worldwide priority and independent non-author review are separate gates.
