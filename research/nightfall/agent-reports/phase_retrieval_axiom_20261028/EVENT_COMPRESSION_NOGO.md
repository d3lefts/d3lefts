# AXIOM / NIGHTFALL — rigorous no-go for duplicate-event compression of the F25 Frobenius-lift union bound

**Research owner:** Devin J. Wright. **Mathematical derivation and exact independent check:** Axiom (GPT-6). **Date:** October 28, 2026 (New York) / October 29 UTC. **Assignment:** GitHub Issue #12, Vesper's structural F25 iid recovery campaign. **Status:** a self-contained restricted no-go theorem with exact arithmetic controls. It is **not** a sample-complexity lower bound, a complexity-theoretic hardness theorem, or a refutation of the original lifting algorithm. External referee and originality review remain OPEN.

## Problem model

Let F=F25, q=25, k>=2, and A have m independent uniformly random rows in F^k. The unknown x has fourth-power readings y_j=(a_j·x)^4; all nonzero x share the physical ambiguity mu4=F5*. The Frobenius-lift decoder expects its m-by-2k planted-kernel matrix to have a one-dimensional kernel for every x. A previous exact upper bound uses projective union counting of the bad kernel polynomials

    P_{x,u,v}(a)=sum_i u_i a_i^5 - (a·x)^4 sum_i v_i a_i.

Its exceptional projective family has sharp one-row zero density rho=121/625. The leading first-moment coefficient is

    c_* = 2 log(25) / log(625/121) ≈ 3.92077.

A natural optimization is to identify repeatedly counted bad events under projective/symmetry changes and union only over distinct row-zero sets. The following exact theorem shows why this *duplicate-event quotient* cannot lower the leading coefficient.

## Theorem: exponentially many distinct sharp bad events

For **every** two-dimensional F-linear subspace W of the dual vector space (F^k)^*, select an arbitrary ordered basis of independent linear forms L,B in W. Define the bad lifted-kernel row polynomial

    P_W(a) = B(a)^5 - L(a)^4 B(a).

Let E_W(A) be the event that P_W vanishes on every row of A. Then:

1. Each P_W is a **genuine nonplanted** Frobenius-lift polynomial for the nonzero signal x characterized by L(a)=a·x, with coefficients u_i=(coeff_i B)^5 and v_i=(coeff_i B). Hence E_W is contained in the **uniform lifted-kernel failure** event.
2. The one-row density is exactly **121/625** for every W; P[E_W(A)]=(121/625)^m.
3. Choosing one basis for each W produces **pairwise distinct events** E_W: the row-zero sets uniquely determine the two-dimensional space W. The number of these events is at least

       G_k = [k choose 2]_25
           = ((25^k-1)(25^k-25))/((25^2-1)(25^2-25))
           >= 25^(2k-4),    every k>=2.

Consequently, merely quotienting the exceptional bad events by coincidences of their *entire row-zero sets*, then applying a first-moment union bound without exploiting correlations between **distinct** events, still incurs at least

    G_k (121/625)^m >= 25^(2k-4) (121/625)^m.

For any fixed c<c_* and m<=c k+O(1), this **sum of event probabilities diverges exponentially in k**. Therefore such a de-duplication-only proof cannot certify a uniform vanishing failure probability below c_*.

### Proof

**Planted-lift compatibility.** Given L,B linearly independent, choose x with L=a·x and choose u_i=(coefficient_i B)^5, v_i=coefficient_i B. Then sum u_i a_i^5=B(a)^5 by Frobenius, so P_{x,u,v}=P_W. The candidate (u,v) is outside the one-dimensional planted line because B is independent of L. The row event is a genuine kernel-rank defect for this x.

**Exact 121 count.** The map a→(L(a),B(a)) is surjective and uniform on F^2. The equation z^5−t^4z=0 has exactly **one solution z=0** for t=0, and exactly **five solutions z=c t, c∈F5** for every t≠0. Thus the root-pair count is 1+24*5=121 out of 625. Independence over m rows yields rho^m.

**Distinct arrangement geometry.** The homogeneous polynomial factors exactly over F:

    B^5−L^4B = product_(c in F5)(B−cL).

Its row-zero set is the union of **five distinct codimension-one F-hyperplanes** with normals B−cL. Any other hyperplane H lying in this union would have at most 5 q^(k-2) points, since it intersects each distinct component in codimension one inside H. As q=25>5, this is strictly less than |H|=q^(k-1). Hence every maximal hyperplane contained in the zero set must be one of these five; the set of components is intrinsically determined by the zero set. The F-linear span of their normals is exactly W. Therefore equal row-zero sets force equal W, proving pairwise distinctness. Since the iid all-rows event has product support, equal events would force equal one-row zero sets as well.

**Count and asymptotic consequence.** The Gaussian-binomial count of two-dimensional subspaces of F^k is G_k as displayed. For k>=2, factor out q^(2k-4): the remaining ratio `(1−q^(−k))(1−q^(1−k))/[(1−q^(−2))(1−q^(−1))]` is at least one. At m=ck+O(1), the logarithm of the individual-event union sum has leading coefficient `k[2 log q +c log rho]`, strictly positive whenever c<c_*. This proves the stated limitation of the particular union-bound operator.

## Exact independent checker and falsification scope

Standalone 

    python3 verify_incidence_barrier.py

uses independently written F25 arithmetic in `F5[u]/(u²−2)`. In k=3 it constructs all **651** two-dimensional subspaces by their 651 distinct projective normal vectors, builds the five factor-hyperplanes of each, and verifies **651 distinct arrangement fingerprints**. It calculates the full exact row-zero count **3025/15625=121/625** for three independently selected arrangements. It checks G_2=1, G_3=651, G_4=407526 and `G_k>=25^(2k-4)` through k=24; the all-k inequality follows analytically from the proof. The standalone source contains no dependency on the earlier PR #16 implementations.

This is an **obstruction to duplicate-event compression alone**. Many inequivalent events can overlap heavily. Exploiting their *intersections*, designing a nonlinear fallback, or proving a stronger random rank-concentration theorem could still yield a polynomial-time decoder below the old coefficient. No lower bound on the true failure probability is inferred, and Vesper's 83/24 information-theoretic pairwise result remains logically distinct.

## Priority and next operation

The geometry uses standard Gaussian binomial coefficients, factorization over finite fields, and projective hyperplane arrangements. No worldwide mathematical priority is asserted. To surpass this no-go with the **same iid sensing law and same all-signals efficient-decoding objective**, the next proof must exploit joint incidence/correlations among distinct E_W or a decoder capable of handling nonplanted lifted-kernel directions. This theorem identifies the exact structural lever that a further first-moment-only counting argument lacks.