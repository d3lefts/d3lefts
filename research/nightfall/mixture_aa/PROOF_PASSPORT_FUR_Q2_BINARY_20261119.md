# Proof Passport: Binary degree-two FUR via real Grothendieck (v0.1)
Date 2026-11-19 | Original independent author-side research lane PR #926 | Coordinates with Claude PR #919.

## Claim and conditions
For an arbitrary finite posterior pi on a mixture of **binary** independent-product input laws, including zero-probability atoms, and a **globally** bounded quadratic f:{-1,+1}^n→[0,1], define the shared monotone threshold latent lift G(theta,U)=f(h_theta(U)). The input mean-absolute increment on the hidden coordinate (exactly the repository's ProductInfluence.pincr with coordinate theta) obeys

    Imax := max_i I(theta;X_i) >= (L_theta(G)/(1+8 K_G))^4,

where K_G is any universal real Grothendieck constant and information is in nats. K_G<1.783 is independently documented by the standard Grothendieck literature; using K_G=2 yields a conservative numerical instance.

Under product mean_increment applied to G of global degree≤3, either an observable seed coordinate has a polynomially large mean-absolute increment or the displayed information alternative holds. The resulting **binary degree-two FUR dichotomy** is proved on paper, conditional on the standard real Grothendieck inequality and product mean_increment. It does NOT establish all-alphabet FUR or the unqualified polylog-M simulator.

## Mechanism and operator
- Normalize f=c+a·x+B(x,x). Bound ||a||_1≤1/2 and bilinear cut norm ||B||_{∞→∞}≤2 by f∈[0,1] and polarization.
- For arbitrary correlated input pair (X,Y), Delta=X−Y, Mid=(X+Y)/2, p=max_i Pr[Xi≠Yi], use Hilbert vectors Delta_i/(2√p) and sign(B(Delta,Mid)) Mid_j in H=L²(pair law).
- Real Grothendieck gives E|B(Delta,Mid)|≤4K_G√p. Therefore E|f(X)−f(Y)|≤p+8K_G√p.
- Under the latent threshold coupling p_i=Eθθ' |biasθi-biasθ'i|, Cauchy-Schwarz gives p_i²≤2Varθ(biasθi)≤I(theta;X_i) by Bernoulli Pinsker in nats. Hence Imax≥Lθ^4/(1+8K_G)^4 without a triangle-inequality loss.
- The dependence on M disappears because the norm comparison is dimension-free even when pair coordinates are globally correlated by theta.

## Verification and source custody
Proof source:
- FUR_BINARY_GROTHENDIECK_DEGREE2_20261119.md: complete author-side argument, including each numerical constant and coupling.
- FUR_POINTWISE_COUPLING_DEGREE2_20261119.md: general finite-alphabet product-pair pointwise bound through classical Markov and explicit invalid max/expectation interchange.

Executable checks:
- fur_q2_grothendieck_exact_audit.py: exact rational norm calculations, 16 correlated joint-pair quadratic examples, 2,048-label one-hot obstruction to naive max-swapping (not FUR).
- fur_pointwise_exact_audit.py: exact rational polynomial mismatch-thinning for 16 product-pair quadratic examples and degree-five parity negative control.
- test_fur_q2_grothendieck_exact_audit.py / test_fur_pointwise_exact_audit.py / test_fur_binary_information_proxy_exact.py: fifteen falsifier and adversarial regression tests total.
- fur_binary_information_proxy_exact.py: 24 exact finite posterior checks of q²≤2 Var(bias), including asymmetric weights and zero atoms; Pinsker itself is an external analytic dependency.
- Workflow .github/workflows/nightfall-fur-q2-coupling-audit.yml.

CI (exact head c21f97fc8de847d2b2a5d795f5f71eaaa20fbe7f):
https://github.com/d3lefts/d3lefts/actions/runs/44640686460
Status: success; 15/15 tests; two exact 16-instance coupling families and 24 exact finite posterior bias-variance audits.
Artifact: https://github.com/d3lefts/d3lefts/actions/runs/44640686460/artifacts/14585154088
Artifact SHA256: 08f8d24db6988a6f39c1ed1703b0ab9805654b11fb25aef5b81ce402d2ace72c.
All tests are **finite falsification only**; neither Grothendieck nor the universal quantum theorem is proved by the numeric computations.

External theorem source checked this session:
https://elliotpaquette.github.io/high-dimensional-probability/lectures/15-grothendieck.html
Its Theorem 1 gives the required matrix-to-Hilbert inequality and a classical K_G upper bound. Known prior art on distributional AA: Girish–Mittal–Nehoran–Raz, arXiv:2609.35327. This prior-art check is targeted and NOT novelty clearance.

## Certification status
- Paper derivation: complete author-side; NOT independent non-author referee.
- Exact finite falsifier: CI pass, with preserved artifact. This does not prove the general theorem.
- Lean kernel certificate: NOT attempted/NOT available for the new Grothendieck or latent-information bound. Existing product mean_increment is separately Lean-checked in the original product-space project.
- End-to-end binary mixture simulation: NOT composed/NOT Lean-checked under this passport. The Mixture-AA brief contains its own provisional entropy-potential reduction.
- Arbitrary finite alphabets and arbitrary degree d: OPEN.
- Novel contribution: UNDETERMINED pending dated prior-art and external proof review.
- Publication, merger or competitive record: NOT authorized by this certificate.

## Adversarial reviewer B (designated before reviewing future results)
1. Inspect the expansion and polarization: ensure Q has no diagonal and its cube bound implies cut norm ≤2.
2. Confirm the sign-weighted Hilbert vectors have unit L² norms even when X,Y have fully correlated coordinates.
3. Verify the precise Grothendieck matrix/Hilbert formulation (not the complex variant) and no hidden dimension/alphabet dependence.
4. Verify the sharper Bernoulli variance bridge: q_i²≤E(pθ-pθ\')²=2Varθ(pθ)≤I_i by Pinsker in nats; check zero posterior and zero atoms.
5. Inspect the exact ProductInfluence.pincr normalization and conditional lift degree≤3 for arbitrary posterior sections.
6. Try counterexamples with arbitrary binary correlated sources before assuming all-alphabet transfer.
7. Check the precise entropy-potential/Markov stopping-time and deterministic-query simulator statement, including prior-art overlap.

No outside referee/second independent agent completed these obligations. Do NOT self-certify them.

## Cheapest decisive next test and stop rule
Start with source replay and a paper proof attack on Grothendieck scaling and posterior resampling. Attempt a minimal Lean terminal with the real Grothendieck inequality as an explicit *hypothesis*, not an unreviewed axiom; discharge elementary algebra before porting the theorem itself. If the inequality requires a false boundedness or alphabet condition, demote. If binary closure withstands review, investigate block-valued Grothendieck transfer to arbitrary alphabets; don't extrapolate from sign coordinates.

## Discovery graph and transfers
Mixture-AA target → latent product lift → hidden-coordinate mean-absolute increment → arbitrary-coupling quadratic Walsh representation → Grothendieck operator → binary information certificate → conditional binary FUR → pending query simulator.
Transfer: dimension-free stability of bounded quadratic functions under **arbitrarily correlated** sparse coordinate perturbations, potentially useful in statistical stability, latent mixture inference and proof-certificate cost analysis.

## Primary collaborator handoff
Claude's active Mixture-AA PR #919 was informed via:
https://github.com/d3lefts/d3lefts/pull/919#issuecomment-7025412857
No merge or claim promotion is implied.
