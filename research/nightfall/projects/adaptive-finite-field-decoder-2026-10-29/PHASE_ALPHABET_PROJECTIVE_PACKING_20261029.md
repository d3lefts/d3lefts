# NIGHTFALL — A phase-alphabet theory of adaptive powered-field decoding

**Research note · 29 October 2026**  
**Program:** NIGHTFALL PHASESHIFT · program lead Devin J. Wright  
**Provenance:** Axiom supplied the initial two-round finite-field decoder. The later NIGHTFALL research sessions established full-base-field extension-degree packing and the characteristic-three cancellation construction. This note synthesizes those mechanisms and derives new finite-subgroup shift-cover criteria and examples.  
**Status:** self-contained algebraic deductions and standalone exact finite-field testing; independent mathematical refereeing and exhaustive source-priority review outstanding.

## 1. One common model and the necessary distinction

Let L=F_q and K=F_(q^r), with r>=2. Let H be a *specified multiplicative subgroup* of L^×, of order d>1. The oracle accepts an arbitrary K-linear form a on x in K^k and returns

    Phi_H(a.x) = (a.x)^d.

Since K^× is cyclic, its d-th roots of unity are precisely H. Thus Phi_H(u)=Phi_H(v) iff either u=v=0, or u=h*v for some h in H. The identifiable object is x modulo the common scalar action of H.

**Model distinction:** NIGHTFALL's original oracle uses exponent q-1 and therefore H=L^×. A proper subgroup H gives a *different powered measurement*, not an improvement under identical oracle access. The case q=3, d=2 belongs to both models. Its cancellation method generalizes to the square-power oracle over every odd base field.

In the first adaptive round query each coordinate x_j^d. For nonzero readings choose any u_j with u_j^d=x_j^d, so that x_j=lambda_j*u_j for lambda_j in H. This determines support S, size s. The task remaining is to recover lambda_j/lambda_t for a supported anchor t.

## 2. The phase-alphabet embedding

Choose an L-basis beta_1,...,beta_r of K, shifts c=(c_1,...,c_r) in L^r, and a block j_1,...,j_b of unknown relative phases (b<=r). Define eta_i=lambda_(j_i)/lambda_t for i<=b and pad eta_i=1 for b<i<=r. One legal second-round row has

    a_t = [sum_i beta_i (c_i+1_{i>b})]/u_t,
    a_(j_i)=beta_i/u_(j_i).

Its unpowered interior equals

    lambda_t sum_i beta_i (c_i+eta_i).

Since lambda_t^d=1, the returned value is

    [sum_i beta_i(c_i+eta_i)]^d.

By the L-basis, equality of two outputs means that, for some h in H,

    c_i+eta_i = h(c_i+eta'_i)    for every i,

with the zero case included. Consequently phase recovery is exactly injectivity of the **projective phase-alphabet embedding**

    E_c : H^r -> K/H,
    eta -> [sum_i beta_i(c_i+eta_i)]_H.

Here K/H denotes the orbit space including zero. The quotient class can be computed from the powered output. Finding a d-th root returns an arbitrary orbit representative; test at most d possible H scalings to recover eta by membership in H^r. Partial blocks are padded by known relative phases. Naively discarding dimensions is unsafe for shift-cover designs.

## 3. Exact collision criterion (the unifying theorem)

For each multiplier h in H\{1} and coordinate i, define

    E_(i,h) = {(u,v) in H^2 : c_i+u = h(c_i+v)}.

Then E_c is injective **if and only if** for every h!=1 either

(A) at least one E_(i,h) is empty; or

(B) every E_(i,h) is exactly {(-c_i,-c_i)} (necessarily -c_i in H).

**Proof.** Equality of powered outputs is precisely equality up to an element h of H. When h=1, the basis forces eta=eta'. For h!=1, all possible equal-output pairs form the Cartesian product of E_(i,h). If one factor is empty, there is no pair. A diagonal solution u=v requires (1-h)(c_i+u)=0, hence u=v=-c_i; it is unique. If every coordinate has exactly this diagonal pair, both vectors coincide and give zero output. In any remaining case, there exists an off-diagonal solution in some coordinate while every other coordinate has a solution; their product gives distinct tuples with the same powered output. QED.

Two useful sufficient certificates follow.

**Uniform weak transversal.** If one c in L satisfies

    (c+H) intersect h(c+H) subset {0} for every h in H\{1},

then the constant shift vector (c,...,c) works. This includes the cancellation construction c=1, H={+1,-1}, over *every odd characteristic*, where c+H={0,2}.

**Shift-blocker cover.** Define

    B(c) = {h in H\{1}: (c+H) intersect h(c+H) is empty}.

If the union B(c_1) union ... union B(c_r) equals H\{1}, then the shift vector works. This allows full r-packing even when no constant shift works.

**Two-round reconstruction.** Under either condition, every vector is exactly reconstructed modulo H using

    m = k + ceil(max(s-1,0)/r)

powered queries, for any finite-field extension K/L of degree r. The online extra work per mixed query is O(rd) base-field operations plus one d-th root extraction. An explicit finite algorithm always exists; polynomial-time randomized finite-field root extraction applies when the representation and H are supplied. No deterministic poly(log q) generic root-finding claim is made.

## 4. Uniform existence theorem for sparse phase groups

**Theorem.** Suppose H<=L^× has cardinality d>1 and

    q-1 > d(d-1)^2.

There exists c in L^× with (c+H) intersect h(c+H) empty for every h in H\{1}. Consequently r relative phases can be recovered per mixed query, and the two-round bound from Section 3 holds for all k.

**Proof.** For a fixed h!=1, an intersection requires c+u=h(c+v), i.e.

    (h-1)c=u-hv,   u,v in H.

Since hH=H, the nonzero right sides number at most d(d-1); u=hv produces c=0 and is excluded. Thus at most d(d-1) nonzero c are forbidden for each of the d-1 multipliers h. At most d(d-1)^2 nonzero c are forbidden altogether. The strict size inequality guarantees an admissible c. QED.

The counting argument is deliberately elementary, not a claim to invent finite-field subgroup-difference theory. With the H elements given, a good shift can be selected deterministically from any d(d-1)^2+1 distinct nonzero elements of L by checking the forbidden sets, with work polynomial in d and log q.

## 5. Explicit cases beyond characteristic three

Each row below gives the base field, phase subgroup, and certified shifts for r=2. A full block retrieves two relative phases with *one* powered query. In dimension k=3, the complete protocol uses four measurements, meeting the universal adaptive counting lower bound.

| L | H | d = oracle exponent | shifts (c_1,c_2) | certificate type |
|---|---|---:|---|---|
| F_3 | {1,2} | 2 | (1,1) | uniform weak transversal, original q=3 theorem |
| F_5 | {1,4} | 2 | (1,1) | uniform weak transversal, new square-power model |
| F_7 | {1,2,4} | 3 | (3,3) | uniform weak transversal (intersection only at zero) |
| F_13 | {1,3,9} | 3 | (2,2) | strict uniform transversal |
| F_13 | {1,5,8,12} | 4 | **(2,4)** | complementary blocker cover |
| F_17 | {1,4,13,16} | 4 | (2,2) | strict uniform transversal |
| F_19 | {1,7,11} | 3 | (2,2) | strict uniform transversal |
| F_31 | {1,2,4,8,16} | 5 | **(3,5)** | complementary blocker cover |
| F_41 | {1,9,32,40} | 4 | (2,2) | strict uniform transversal |

For F_13 with H={1,5,8,12}, the set B(2)={5,8} and B(4)={12}; no single c in F_13 supplies a uniform weak transversal. Hence nonuniform shifts materially increase packing ability. For F_31 with H={1,2,4,8,16}, B(3)={4,8} and B(5)={2,16}.

## 6. Exact single-query dichotomy in the original full-phase model

Take H=L^×, so d=q-1 as in NIGHTFALL's original decoder. Fix coordinate queries, an anchor, and one additional affine-linear powered query intended to resolve a batch of b independently unknown relative phases.

- For q=3, the maximum universally recoverable batch size is **r**, and the cancellation construction attains it.
- For q>=4, the maximum universally recoverable batch size is **r-1**, and the previously published independent-anchor-basis construction attains it.

**Upper bound b>r for the full subgroup.** In every finite field with q>=3, L^×-L^×=L. If b>r, the b coefficient vectors are L-linearly dependent; choose a nonzero dependence vector v in L^b. Express each v_i as a difference of two nonzero base-field phases. This yields two distinct phase assignments with identical *unpowered* query values.

**Stronger obstruction b=r for q>=4.** If the b nonanchor coefficient vectors are dependent, the same argument applies. Otherwise change to the basis formed by those r vectors, giving F(eta)=c+eta in L^r. Fix h in L^×\{1}. For every c_i, the equation c_i+u=h(c_i+v) with u,v in L^× has at least q-2>=2 solutions. At most one solution is diagonal; choose an off-diagonal solution in one coordinate and any solution in the others. The two phase tuples differ while their powered results agree. Hence a single mixed query cannot resolve r phases. The r-1 construction is therefore locally optimal.

This is an exact obstruction **for one anchored query after coordinate calibration**, not a global lower bound on all multi-query adaptive schemes for k>r.

## 7. Global information lower bound and exact-optimal range

Write Q=q^r, d=|H|. One powered query has M=1+(Q-1)/d outputs. The number of globally distinguishable signal classes in K^k/H is N_k=1+(Q^k-1)/d. Any adaptive decision tree using m queries obeys M^m >= N_k. The identity

    N_(a+b) - N_a N_b = (d-1)(Q^a-1)(Q^b-1)/d^2 > 0

for d>1, a,b>=1 implies m>=k+1 for k>=2. Thus **whenever an r-phase packing certificate exists, its k+1 queries are globally optimal for 2<=k<=r+1**. This includes the new F_7 cubic and F_13 quartic examples above, in their respective oracle models.

## 8. Verification, literature boundary, and research agenda

Run `python3 verify_unified.py` with Python 3. The verifier uses stand-alone integer-pair arithmetic for K=F_(p^2), enumerates every phase assignment in each tested two-phase block, performs 11,500 exact vector reconstructions across nine specified subgroup models, and independently exhausts *all* affine shift pairs in F_3, F_5, F_7, F_13 for selected subgroup orders. In particular it checks that no full-phase pair works over F_5 or F_7 and that 32 good shift pairs exist for the F_13 quartic subgroup. The first run caught a **genuine short-block decoding issue** in a naive implementation; the published checker uses correct known-phase padding and passes.

Related material includes Balan, Casazza and Edidin (2006) on phase retrieval and the complement property; classical finite-field shifted subgroup intersection literature, including Vyugin, Solodkova and Shkredov (2016); the earlier paper *Translates of subgroups of the multiplicative group of a finite field* (1975); and Zhou–Wu (submitted 18 October 2026), *Covering finite fields by translates of multiplicative subgroups*, arXiv:2610.25228. These papers address related group/translation structures; no exhaustive review of whether the exact decoder synthesis appears elsewhere has been completed. Avoid publication-level priority claims until referee review.

**Next research target:** maximize the subgroup phase packing capacity P(q,H,r), allowing >r phases per powered measurement when H-H is a proper subset of L. In sparse-subgroup regimes, the linear-dependence obstruction from the full-phase model fails; additive combinatorial codes may improve the r-phase bound. For multi-query groups, investigate optimal cover designs and globally optimal adaptive query counts for k>r+1.
