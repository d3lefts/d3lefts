# Attempt 003 — measured quadratic-derivative rank theorem

2026-11-23. **Paper-level proof, exact finite arithmetic replay, executable source-query simulator; neither Lean-certified nor independently referee-reviewed.** Historical originality is not cleared. Not a closed InclusionBench class relation.

## Contract

Objective: close the uniform classical-runtime gap for a nontrivial coherent two-phase-query family, with worst-case rather than average-case error. Frozen source: NIGHTFALL attempt 002 076b301499e960ea856c6e27c8f2167adde8cdb8; InclusionBench v0.4.3 326065e17df73039332b4fd974b1e335dc4b5e68. Competing methods: direct signed Fourier-term Monte Carlo (4^r samples for a flat rank-2r derivative spectrum); standard Forrelation estimation and Pauli propagation. Significance: halve the rank exponent in query cost, account for physical oracle queries, and match the rank exponent by reduction. Audit: independent direct Walsh source calculation versus block calculation, exact second moments and Forrelation embedding; separately exercise the actual succinct simulator on a 64-bit address. Stop at the stated derivative promise and terminal effect; no score or unconditional class claim.

## Theorem

Let G=F_2^n, N=2^n, x,y:G→{−1,1} arbitrary phase tables available by original classical coordinate queries, H normalized Walsh-Hadamard, D_x and D_y their diagonal phase operators, and X_h the translation by a known h∈G. The actual normalized state is ψ=D_y H D_x |+^n⟩ and accepting projector P=(I+X_h)/2. Assume only that d(b)=y(b)y(b+h)=(-1)^q(b) for a Boolean quadratic polynomial q. Let B be its alternating polar matrix of rank 2r. No promise on x or on the degree of y away from this measured derivative.

For every 0<ε,δ<1, a uniform randomized algorithm approximates p=⟨ψ,Pψ⟩ within ε with probability at least 1−δ on EVERY promised pair x,y. It uses at most

  2(1+n+binom(n,2)) + O(2^r ε^(-2) log(2/δ))

physical oracle queries and O(poly(n) + poly(n)·4^r ε^(-2) log(2/δ)) bit operations, up to polynomial precision/accumulator overhead. In particular if r=O(log n), it runs in polynomial time for inverse-polynomial accuracy and polynomial failure exponent. No exponentially large phase table or array is emitted. For h=0 the result is p=1 directly. The algorithm may also be used when x,y are uniformly computable from an ordinary binary input, and with the usual per-input bounded-error gap it gives a BPP algorithm for any total language whose decider has this promised normal form. This is NOT a claim that arbitrary BQP circuits have that form.

For a worst-case family with n=2r+2 and y fixed and known, estimating p to a sufficiently small constant error with constant success probability requires Ω(2^r/r) classical oracle queries for r≥1, using the standard Forrelation lower bound. Thus the rank exponent of the sampling term is optimal up to logarithmic factors. This lower bound concerns the black-box phase-table model, not unrelativized complexity classes.

## Proof

1. **Source equality.** Define normalized Fourier coefficients Wf(k)=N^(-1)Σ_b f(b)(−1)^{k·b}. Direct conjugation gives D_y X_h D_y=D_d X_h. Therefore E=2p−1=N^(-1)x^T A x, A=H D_d X_h H, with matrix entries A_ij=Wd(i+j)(−1)^{h·j}. A is real orthogonal and symmetric, because d is invariant under h and X_h is an involution. No path-pair dephasing or average-case approximation is used.

2. **Learn the derivative.** Obtain q(b) with exactly two original y queries. Evaluate q at 0, each e_i, and each e_i+e_j, i<j; recover constant c, linear coefficients ℓ_i=q(e_i)+c, and B_ij=q(e_i+e_j)+q(e_i)+q(e_j)+c. All operations in F_2. The promise that q is quadratic is essential; these evaluations do not certify that promise on arbitrary tables.

3. **Walsh affine support.** Let K=ker B and L=im B=K^⊥. The function q(u)+c is linear on K. Find k0 satisfying k0·u=q(u)+c for a basis of K by Gaussian elimination. Translating the Walsh sum by u∈K proves it vanishes unless k∈k0+L. Symplectic elimination yields pairs p_i,t_i with B(p_i,t_i)=1 and all cross-pair polar products zero, plus a basis of K. For k in the support, let α_i=q(p_i)+c+k·p_i and β_i=q(t_i)+c+k·t_i. The four-term sum over one pair equals 2(−1)^{α_iβ_i}; hence Wd(k)=2^(−r)(−1)^{c+Σ_i α_iβ_i}. This computes any needed entry in poly(n) time without enumerating L. |L|=D=2^(2r).

4. **Coherent blocks.** For each coset C=u+L, A maps the input coset C+k0 to C and has zero entries from other cosets. Since A is orthogonal, each such D×D submatrix M is orthogonal, including when the cosets coincide. Let v,w be the sign vectors x restricted to the two cosets. Define μ_C=v^T M w/D∈[−1,1]. Then E is the uniform mean of μ_C. Choosing u uniformly on n bits samples C uniformly.

5. **Rectangular estimator.** Conditional on C, draw t independent uniform indices I_a from C and t independent uniform J_b from C+k0; the two lists are independent, even when C=C+k0. Query the 2t signs. Put K(i,j)=D M_ij v_i w_j and Z=t^(−2) Σ_{a,b} K(I_a,J_b). Then E[Z|C]=μ_C. Because M is orthogonal and v,w are sign vectors, E[K²]=D, E[(E[K|I])²]=1, and E[(E[K|J])²]=1. Expanding the variance of the t² terms, disjoint index pairs have zero covariance; identical pairs have covariance D−μ_C²; pairs sharing exactly one index have covariance 1−μ_C². Consequently the exact identity is

  Var(Z|C) = [D+2(t−1)−(2t−1)μ_C²]/t².

With t=2^r=√D the conditional variance is at most 3 and total variance at most 4 (law of total variance, |μ_C|≤1). Independent groups of ceil(32/ε²) trials give failure probability ≤1/8 for estimating E to ε by Chebyshev. Take the median of an odd O(log(2/δ)) number of groups; the usual binomial tail bound gives failure ≤δ. Convert to (1+estimate)/2 and clip to [0,1]. This is a worst-case guarantee for each fixed oracle input, using fresh classical randomness. Each trial costs 2t oracle queries, t² poly(n) arithmetic; dyadic signed entries make exact accumulation possible. Sampling the coset elements uses a computed basis of L, not a materialized table. Direct sampling of one Fourier term and one coordinate uses weights of magnitude 2^r and worst-case second moment 4^r; the rectangular covariance structure halves that query exponent. No claim of halved arithmetic exponent for the present implementation.

6. **Near-matching lower bound.** Write an address as (a,b,s,w), a,b∈F_2^r, s,w∈F_2, and h the w-coordinate vector. Fix q(a,b,s,w)=a·b+s and y=(-1)^{w q}; then d=(-1)^q and rank B=2r. Let z=(a,b), chirp c(z)=(-1)^{a·b}, and swap S(a,b)=(b,a). Given arbitrary sign functions f,g on F_2^(2r), set x(z,0,w)=c(z)f(z), x(z,1,w)=(-1)^w c(z)g(Sz). Every x query uses a single f or g query. Here L is the z-space, k0 is the s vector, Wd(k0+z)=2^(−r)c(z). The matrix within a paired block has entries 2^(−r)c(z+z')(-1)^w. Using c(z+z')=c(z)c(z')(-1)^{z·Sz'} cancels the two chirps, and the w factors cancel. All four cosets have the same bilinear value (transpose for reversed orientation). Hence exactly

  2p−1 = 1/(D√D) Σ_{z,v} f(z)g(v)(−1)^{z·v},

ordinary normalized Forrelation. The standard Ω(√D/log D) bounded-error randomized query lower bound for the constant-gap Forrelation problem transfers via this one-query reduction (choose estimation accuracy below half the relevant probability gap). This lower bound is independent of the cost of learning the derivative, since y is fixed. No lower bound on the n² preprocessing term is asserted.

## Actual checks

- `python3 derivative_audit.py`: PASS: 1056 exact source/block/variance cases; 32 Forrelation embeddings; rank 0 through 6. Exhaustive all x,y,h at n=2, additional seeded higher-rank examples and exact enumeration of rectangular-sample variance for small blocks. The direct Walsh source route is separate from the block estimator.
- `python3 derivative_sim.py`: n=64, rank=6, estimate=499/512, exact=1, physical queries={'x': 18432, 'y': 4162}. The sampler never constructs 2^64 entries. This seeded numerical trial is illustrative, not a proof of the confidence bound.
- Source SHA-256 from executed local copies: audit fa533db4f9023d47cce92848260ade45845301cd1dbf37ce5fb60db8584422aa; simulator 4bb3744871ab5c17f7a2aefa20bde992a772159967af60920b3d0fb148474b77. Recompute hashes on checkout.
- Neither Lean nor Docker was available locally. Do not represent this as a Lean receipt. The formalization targets are the Walsh support lemma, block identity, rectangular exact second-moment identity and uniform algorithm accounting. No claim manifest because there is no closed benchmark pair.

## Prior art (dated 2026-11-23)

Aaronson–Ambainis, Forrelation: A Problem That Optimally Separates Quantum from Classical Computing, https://doi.org/10.1137/15M1050902 — provides the transferred lower bound. Bravyi–Gosset–Grier–Schaeffer, Classical algorithms for Forrelation, https://arxiv.org/abs/2102.06963 — established square-root-size Forrelation estimation including a faster affine-subspace runtime. Quadratic Walsh spectra and Pauli propagation are standard (e.g. Carlet, https://www.math.univ-paris13.fr/~carlet/chap-fcts-Bool-corr.pdf; Stahlke, https://arxiv.org/abs/1305.2186). The distinctive scoped synthesis here is learning a single measured derivative from original phase queries, using its polar rank instead of the ambient address dimension, and matching its exponent by a source-exact reduction. Related Pauli-propagation and IQP reductions are plausible prior art; the same-model novelty claim remains provisional. Do not claim the rectangular estimator, Fourier spectrum or Forrelation algorithm alone as original. No external submissions.

## Next gate

A non-author should reproduce the source conjugation, variance covariance count and lower-bound chirp cancellation. Formalize them in Lean with the source model explicitly stated; separately connect promised succinct phase functions and error gap to the benchmark's actual machine model. Explore a faster block Forrelation routine and low-rank derivative learning via polar sketches, or generalize to sums of measurement shifts with bounded rank-weighted cost. An unrestricted class relation still needs a new structural theorem; a promise/black-box result cannot be scored as an unrelativized inclusion.
