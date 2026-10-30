# Exact projective inversion: full powered-sign output histograms without enumerating sign words

**Checkpoint:** 2026-10-30. **Research owner:** Devin J. Wright / NIGHTFALL; **AI contributor/auditor:** Ryev. **Stage:** R1, internal mathematical derivation and independent direct computational replay; external human mathematical review and detailed same-model priority remain OPEN. This is an operator for exact certificate checking, **not an established worldwide originality claim**.

**Attribution and chronology:** Lemnis independently obtained the r=2 seven-sign Fourier obstruction and rank-palette extension in [PR #264](https://github.com/d3lefts/d3lefts/pull/264) contemporaneously with Ryev's [PR #270](https://github.com/d3lefts/d3lefts/pull/270). Neither is an external human referee. The contribution of this note is the explicit all-r, all-m **full histogram inversion**, not independent invention of the seven-sign obstruction or of classical incidence geometry.

## Objective and oracle boundary

Given arbitrary coefficients c_1,...,c_m in the additive F3-vector space V=F3^r (r>=2, m>=1), write S(e)=sum_i e_i c_i where each e_i is +1 or -1 in F3. Identify sign tuples by simultaneous negation, leaving N=2^(m-1) sign classes. The legal **squared GF(3^r)-linear oracle** identifies additive sums up to a global +/- scalar: the zero sum and each nonzero projective point [v]={v,-v}. No hidden raw-sum access, no replacement of the square oracle by a full nine- or 3^r-symbol raw oracle. The zero output must be retained.

**Problem:** compute the complete histogram b_0, b_[v] of the N sign classes, without exhaustively visiting 2^(m-1) words.

The formula below generalizes the r=2 seven-sign obstruction in [FOURIER_AUDIT.md](FOURIER_AUDIT.md) to *all* r>=2 and *all* m>=1. It computes output counts, rather than only a lower bound on the largest bucket. As r grows the projective incidence set itself grows exponentially in r; the efficiency claim is polynomial in **m at fixed r**, not polynomial jointly in r and m.

## Exact closed formula

Let P=PG(r-1,3), the nonzero +/- orbits in V. Let D be the dual set of hyperplanes, indexed by the +/- orbits of nonzero linear functionals l:V->F3. Put

    v = |P| = (3^r-1)/2
    k = number of points in one hyperplane = (3^(r-1)-1)/2
    lambda = number of hyperplanes containing two fixed distinct points
           = (3^(r-2)-1)/2
    n = 2^(m-1).

For each dual projective functional l, set z_l = # {i: l(c_i)=0} and

    F_l = (-1)^(m-z_l) 2^z_l
    Z_l = (n + F_l)/3.

Then Z_l is **exactly** the count of sign orbits whose sum S(e) belongs to ker(l). It is an integer, including coefficient-zero and zero-output cases.

The entire squared-output histogram is recovered by

    b_0 = ( sum_{l in D} Z_l - k*n ) / (v-k)
        = ( sum_l Z_l - k*n ) / 3^(r-1),

and, for each projective output point p in P,

    b_p = ( sum_{l : l(p)=0} (Z_l-b_0)
            - lambda*(n-b_0) ) / (k-lambda)
        = ( ... ) / 3^(r-2).

All divisions are exact. The returned numbers are nonnegative integers and their sum is n.

### Proof and dependencies

**Signed-projection lemma.** For a fixed nonzero l, let A be the number of full +/- sign words whose linear projection l(S) is zero, and B,C the counts yielding 1,2. Sign reversal pairs B with C, so B=C and A=2Z_l. Then A+2B=2^m. Setting F=A-B gives F=3Z_l-2^(m-1). Appending one coefficient orthogonal to l doubles F; appending one nonorthogonal coefficient multiplies F by -1 (because 1+1=2=-1 in F3). Starting from F=1 yields the stated formula.

**Point/hyperplane incidence.** Let M be the 0/1 matrix with rows indexed by dual hyperplanes l and columns by projective points p, with M_(l,p)=1 iff l(p)=0. Every row and column sums to k; two distinct projective points lie together in exactly lambda dual hyperplanes. Thus

    M^T M = (k-lambda) I + lambda J.

Since Z=b_0*1+M b, sum_l Z_l=v*b_0+k*(n-b_0), which gives the b_0 formula using v-k=3^(r-1). Next M^T(Z-b_0*1)=(k-lambda)b+lambda*(n-b_0)*1. Since k-lambda=3^(r-2)>0, solve coordinatewise for b_p. QED.

**Application to powered linear forms:** the additive group of GF(3^r) is F3^r, and in odd characteristic y^2=z^2 iff y=+z or y=-z. The formula therefore computes every legal square-oracle bucket for an anchored sign palette, *provided all 2^(m-1) relative signs are present*. In a later adaptive branch where only a subset survives, the all-sign factorization no longer applies without a new mechanism; do not silently reuse this inversion there.

## Reproduction and independent finite oracle

    python3 research/nightfall/agent-reports/ryev_gf9_fourier_audit_20261030/verify_projective_inversion.py

Pure Python 3 stdlib. Independent direct oracle enumerates all 2^(m-1) sign tuples, folds sums by canonical +/- representation, and compares **every output bucket**, not only its maximum, to the projective inversion. Tested 84 coefficient systems across r=2,3,4; m=1,2,3,5,7,10,13; zero, repeated basis vectors, and seeded arbitrary coefficients. Every hyperplane count Z is additionally computed by direct summation from the observed bucket histogram. Zero-origin bucket included.

For m=200 and m=1000, reconstruction runs **without sign enumeration**, with exact integer mass and nonnegativity checks. Further checks include GL(r,3) basis covariance and a deliberately corrupted hyperplane count rejected by an independent direct projection check. No nonauthor human review was performed. The checker is an internal source-independent implementation, not proof of novelty.

**Operation count:** build v=(3^r-1)/2 representative points/dual normals. Each z_l uses m vector dot products, O(m*r*v) small-field arithmetic. Inverting the incidence relation by direct dot products uses O(r*v^2) finite-field arithmetic; the integer output counts have O(m) bits. Thus for fixed r the complexity is polynomial in m, compared to direct 2^(m-1) enumeration. This is a **computational improvement**, not a new information-theoretic query bound.

## Prior art, significance and next attacks

The symmetric projective point/hyperplane incidence matrix and its identity M^T M=(k-lambda)I+lambda J are established finite-geometry facts, not inventions of this session. See [Additivity of symmetric and subspace 2-designs](https://link.springer.com/article/10.1007/s10623-024-01452-4) (2024) and [Codes arising from incidence matrices of points and hyperplanes in PG(n,q)](https://www.sciencedirect.com/science/article/pii/S0097316518300402) (2018). The signed coefficient character product is likewise standard abelian Fourier structure. We have *not* established novelty of this special combined exact certificate or a global theorem advance. The useful reusable mechanism is translating the exact powered-output distribution into an invertible projective incidence transform.

**Adversarial audit priorities:** (i) boundary m=1 and all c_i=0; (ii) r=2 zero hyperplane pair count; (iii) non-square values wrongly counted as possible measured outputs; (iv) scalar quotient global +/- rather than per-coordinate signs; (v) spectra outside the complete 2^(m-1) cube (where this transform alone is insufficient); (vi) wrong projective incidence multiplicity; (vii) later adaptive rank drops. For the GF9 k8 lower theorem continue to rely on separate rank-path/affine-fiber proof review in Axiom PR #266 and Lemnis PR #264. This operator does not justify an extra global optimality claim.
