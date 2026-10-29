# AXIOM / NIGHTFALL — Frobenius-incidence stratification for uniform F25 reconstruction

**Date:** 29 October 2026 (America/New_York). **Research lead:** Devin J. Wright. **Independent derivation and executable audit:** Axiom (GPT-6). **Archive mandate:** Vesper, GitHub issue #12, comment 6486312340. **Evidence:** complete mathematical argument, two separately coded exact finite-field checks. **Status:** internally proved improvement relative to existing Axiom PR #16 bound; comprehensive external novelty and referee reviews OPEN.

## Frozen model, no goalpost changes

Let `F=F_25`, characteristic five, `k>=1`, `s>=1`, and let rows `a_1,...,a_m` be independent and uniformly distributed in `F^k`. For unknown `x in F^k` observe `y_j=(a_j·x)^4`. The only global phase ambiguity is `mu_4={t in F^*:t^4=1}=F_5^*` (four elements). Set the linearized `m by 2k` matrix

    M_y[j]=(a_j1^5,...,a_jk^5,-y_j*a_j1,...,-y_j*a_jk).

**Theorem (rank-stratified uniform recovery).** For

    m >= ceil((149/38)*k)+s,

with probability strictly greater than `1-5^(-s)` over **one sampled A**, simultaneously for **every nonzero x in F^k** the kernel `ker_F M_(A,x) = F*(x^5,x)`. On that event, zero is uniquely determined and every nonzero vector is exactly recoverable up to `mu_4` by deterministic Gaussian elimination plus constant-size fourth-root enumeration in F25. Complexity `O(mk^2)` F25 operations for each decoded input (fixed field and standard dense elimination), polynomial bit cost in k,m. This improves the previous `ceil(2941k/500)+s` guarantee under identical sensing law, quantifiers and algorithm.

**Stronger exact version.** Define `rho=121/625` and `c_*=2 log(25)/log(625/121)`, approximately `3.92076988517`. The same conclusion holds for `m>=ceil(c_* k)+s`. The rational certificate `121^149<625^111` proves `149/38>c_*` without floating-point arithmetic. The method has asymptotic first-moment ceiling `c_*` for the rank-one exceptional class; no optimal sample-complexity assertion is made.

## Proof

### 1. Frobenius reduction and uniqueness of the planted line

For any `x!=0`, the Frobenius identity `a^5·x^5=(a·x)^5` shows `w_x=(x^5,x)` is in `ker M_(A,x)`. For a putative other vector `(u,v)`, define

    P_x,u,v(a)= a^5·u -(a·x)^4(a·v).

Choose a nonsingular F-linear change of coordinates on the sensing row with first coordinate `t=a·x` and remaining coordinates `b=(b_1,...,b_(k-1))`. Frobenius rewrites this homogeneous polynomial uniquely as

    P(t,b) = delta*t^5 + L(b)^5 -t^4 C(b),             (1)

where `delta in F` and `L,C` are F-linear forms on `F^(k-1)`. (The coefficient map `(u,v)->(delta,L,C)` has kernel precisely the planted line; it is onto by invertibility of the coordinate change and Frobenius.) Since the monomials `t^5,b_i^5,t^4 b_i` are distinct in characteristic five, and each polynomial variable has degree at most five below 25, the polynomial vanishes at all rows iff `delta=L=C=0`, iff `(u,v) in F w_x`. Thus every nonzero quotient direction is a genuine nonzero polynomial.

### 2. Exact row zero probability by twisted-rank class

Write `n=k-1`. If `L,C` are **F-linearly independent**, then for uniformly random `b`, the pair `(L(b),C(b))` is uniform on `F^2`. Conditional on any `t` and any `L(b)`, exactly one value of `C(b)` satisfies `(1)` when `t!=0`; if `t=0`, one value `L(b)=0` suffices, with probability `1/25`. Therefore the **unconditional zero probability is exactly `1/25`**.

If `L,C` span a space of dimension at most one and are not both zero, a coordinate `z` reduces (1) to `delta*t^5 + B z^5 -D t^4 z`. At `t=0`, the zero probability is `1/25` when `B!=0`, otherwise one. At every `t!=0`, the polynomial in `z` has at most five roots if `B!=0`, otherwise one root if `D!=0`. Hence in all cases

    Pr[P(a)=0] <= rho=(1+24*5)/625=121/625.

The bound is **sharp**, attained by `P(t,z)=z^5-t^4 z`: `t=0` gives one zero, and every nonzero `t` gives five values `z/t in F_5`. If `L=C=0`, `delta!=0` and the probability is precisely `1/25`.

**Essential caveat:** the classification uses the **Frobenius-root form `L`**, not the raw `b_i^5` coefficient vector. Testing ordinary proportionality of raw vectors can misclassify the exceptional family. The independent code uses `L` directly.

### 3. Projectivize both event families correctly

The rank-deficiency event for `x` is unchanged on replacing `x` by any `lambda*x`, `lambda in F^*`: scaling `y_j` by `lambda^4` multiplies the second `k` columns of `M_y` by `lambda^4`, an invertible transformation. It therefore suffices to union over the

    N=(25^k-1)/24

projective signal lines. This scaling is by **all 24 nonzero field scalars**, not only the four indistinguishable phase scalars.

For each x, the nonplanted coefficient space is `F^(2k-1)`, excluding zero, modulo multiplication of its underlying polynomial by `lambda in F^*`. This free action has projective orbit size 24. In coordinates `(delta,L,C)` the action is `(lambda*delta,lambda^(1/5)*L,lambda*C)`, preserving the rank-one/two partition, and polynomial-zero events. (The fifth-root automorphism exists uniquely over F25.)

For forms on an n-dimensional F-vector space, the number of ordered pairs `(L,C)` with rank one is

    (25^n-1)*(25+1),

and rank two is `(25^n-1)*(25^n-25)`, with the latter interpreted as zero for `n<=1`. Including all `25` delta values and dividing by 24 yields exact nonplanted projective coefficient counts

    R1=25*(25^n-1)*26/24,
    R2=25*(25^n-1)*(25^n-25)/24,
    R0=1  (L=C=0, delta!=0).

These are nonnegative integers for every `k>=1`, and `R0+R1+R2=(25^(2k-1)-1)/24`. In particular, for `k=1`, `R1=R2=0`, and the proof retains the scalar-polynomial exception correctly.

By independence across the m sensing rows and the union bound on **projective polynomial classes**,

    Pr[exists x!=0: dim ker M_(A,x)>1]
       <= N*(R1*rho^m +(R2+1)*25^(-m)).          (2)

This is a strict improvement on assigning rho to all `25^(2k)` vectors for each x: the worst-zero-density polynomials have only about `25^k` classes per x, whereas independent-form polynomials have about `25^(2k)` classes but zero probability `25^-1` per row. No unjustified probabilistic independence between bad directions is assumed.

### 4. Uniform all-k bound with an exact integer certificate

For all `k>=1`, directly from these exact counts,

    N<25^k/24,
    R1<(13/12)*25^k,
    R2<=25^(2k-1)/24.

Consequently (2) is strictly less than

    (13/288)*25^(2k)*rho^m
      + (25^(3k-1)/576 +25^k/24)*25^(-m).         (3)

Let `c=149/38>3` and `m>=ceil(c*k)+s`. The elementary integer comparison

    121^149 < 625^111

is equivalent to `625*rho^c<1`. Since `rho<1/5`, the first term of (3) is strictly below `(13/288)*5^(-s)`. As `c>3` and `k>=1`, the second term is below

    (1/(25*576)+1/(625*24))*5^(-s).

The exact rational constant

    13/288 +1/14400+1/15000 < 1

completes the desired `Pr(failure)<5^(-s)` for all integers `k,s>=1`. The proof also holds with `c=c_*` because then `625*rho^c=1` and the displayed total prefactor remains less than one; the integer rational certificate is the separately checkable simpler headline.

### 5. Exact decoder and the zero signal

Given `A,y`, construct `M_y` and find a basis for its kernel. On the uniform good event, a nonzero input yields a one-dimensional kernel, spanned by `(u,v)=(lambda*x^5,lambda*x)` with `lambda!=0`. Choose a nonzero coordinate `v_i` and solve `c^4=u_i/v_i^5` in F25; exactly four roots exist, and the four candidates `c*v` equal `mu_4*x`. Every candidate can be checked against all measurements. Gaussian elimination costs `O(mk^2)` field operations; lookup of the fourth-root table is constant cost in fixed F25.

If `x!=0` and `Ax=0`, then `(0,x)` is an extra kernel direction of `M_(A,x)` outside the planted line, contradicting the good event. Thus on that event `Ax=0` iff `x=0`, so all-zero y uniquely identifies x=0. This also rules out a hidden zero-signal ambiguity. Identifiability of x up to mu4, one-dimensional lifted-kernel recovery, and the actual decoder are separate statements, each justified above.

## Independent executable evidence

- `verify_stratified_incidence.py`: genuinely separate representation F5[v]/(v²−3); exhausts all 15,624 nonzero two-variable polynomial triples, exact zero-count histogram `{1:2880,25:11424,49:600,121:720}`, 720 sharp exception cases; evaluates independent-form zero fractions over F25^3, and symbolic projective counts and rational bounds for k=1..9. The histogram is a verification control, not the universal proof.
- `verify_incidence_B.py`: independently written pair-arithmetic implementation over F5[w]/(w²−2) checks rank-one and rank-two densities over F25^3, exact projective incidence counting, and both rational exponent certificates. No imported functions from checker A.
- Existing `verify_f25_independent.py` in PR #16 separately checks all-signal decoder/ambiguity fixtures. It is **not** rerun just to manufacture another experiment count.

## Same-scope comparison and originality limitations

| Evidence | Fixed field? | Sensing law | Guaranteed simultaneous all-x event | Measured m | Status |
|---|---|---|---|---|---|
| Axiom original PR #16 | F25 | iid uniform fully random rows | lifted kernel line and mu4 decoder | `ceil(2941k/500)+s` | previous internally proved bound |
| **This theorem** | **F25** | **same iid uniform fully random rows** | **identical event and decoder** | **`ceil(149k/38)+s`** | internal analytic proof plus 2 separate checkers |
| NIGHTFALL October 15 systematic LLL | q grows strongly with k | `[I_k;B]` systematic design | mu4 recovery under specific conditional/LLL proof | 2k | **different sensing law and field-size regime; not a head-to-head record** |
| Bartusel–Führ–Oussa (2023) | prime fields in a complex group-frame model | affine-group orbit frames, complex phaseless projections | group-frame phase retrieval | distinct | established adjacent prior art, not the same finite-field powered-linear map |
| Tan–Balzano–Draper (2011) | finite fields | random linear measurements of low-rank matrices | low-rank matrix reconstruction | distinct | established adjacent information-theoretic method |
| Kueng–Rauhut–Terstiege (2017) | real/complex | random rank-one linear measurements | low-rank Hermitian recovery | distinct | established adjacent lifting literature |

The classification is built from elementary finite-field algebra and projective counting. **External publication priority, equivalence to other additive-polynomial evaluation codes, and novelty at the field level remain unconfirmed.** Do not promote PR #16 to an established world-first research finding until rigorous same-scope literature search and external proof review.

### Reproduce

```bash
python3 verify_stratified_incidence.py
python3 verify_incidence_B.py
```

No extra dependencies. The scripts and the exact run logs are part of the archive commit. The strongest unconditional claim made in this note is mathematical validity of the displayed *conditional-on-sensing-law* random-design theorem, as established by the self-contained argument; external human referee acceptance remains open.