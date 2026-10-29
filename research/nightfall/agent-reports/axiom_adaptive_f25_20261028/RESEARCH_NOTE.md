# AXIOM / NIGHTFALL — Direct pair-orbit audit, lift separation, and adaptive powered-sensing theorem

**Report date:** 2026-10-28 (America/New_York), 2026-10-29 UTC.  **Research lead:** Devin J. Wright.  **Derivation, adversarial proof, and exact verifier implementations:** Axiom (GPT-6).  **Sources:** Vesper issue #12, PR #31; Axiom PR #16.  **Evidence status:** exact independent finite checks PASS; analytic elementary proofs given below; external mathematical referee and priority reviews OPEN.

## A. Assigned audit: Vesper's nonadaptive iid F25 identifiability theorem

Freeze `F=F25`, `k,s>=1`, `m>=ceil(7k/2)+s`; independent uniformly random fixed rows `a_j in F^k` and known outputs `(a_j dot x)^4`. Equivalence `x~z` iff `z=omega x` for `omega in mu4=F5^*`. This section concerns **injectivity**, with exhaustive decoding only, and does **not** imply a polynomial-time inverse.

**Verdict: PASS (analytic count + separate finite exact execution).** An independent pair `(x,z)` has `(a dot x,a dot z)` uniform on `F^2`. Of 625 ordered pairs `(u,v)`, exactly `1+4*24=97` obey `u^4=v^4`, hence collision probability `rho=97/625` per row. For independent ordered nonzero signal pairs, the separate phase action `mu4 x mu4` and swapping have free orbit of size `4*4*2=32`. Thus the number of distinct collision events at the phase-orbit level is `(25^k-1)(25^k-25)/32`. Proportional nonphase pairs and zero collisions are excluded whenever `A` has rank `k`, with rank-deficiency probability bounded by `(25^k-1)/(24*25^m)` by a projective kernel-line union. Consequently

```
P[nonphase ambiguity] <= (25^k-1)/(24*25^m)
   + ((25^k-1)*(25^k-25)/32) * (97/625)^m.
```

For `m>=ceil(7k/2)+s`, the inequality `97^7<5^20` gives `25^2*(97/625)^(7/2)<1`. The independent-pair contribution is less than `5^(-s)/32` since `97/625<1/5`. The rank-deficiency contribution is less than `5^(-s)/75000`. Their sum is less than `5^(-s)`. The `k=1` independent-pair term vanishes. There is no forbidden independence assumption among different pair events; only the rows are iid.

**Crucial scope:** The theorem guarantees *uniform information-theoretic injectivity* of one iid design, not efficient decoding. Vesper's original proof and published scope are correct on these checks. The existing Frobenius-lift decoder at `ceil(149k/38)+s` meets a stronger *kernel-line* sufficient event. No claim that the near-3.5k random measurement law has an efficient inverse has been established here.

### A.1 Exact obstruction to conflating injectivity with lifted-kernel success

In dimension `k=2`, use **five fixed rows**, one for every `z in F5`:

```
a_z = (1,z), z=0,1,2,3,4.
```

For every `x=(x1,x2)`, its measurements are all five values of the polynomial `f_x(Z)=(x1+Z x2)^4`, degree at most four. If the five values of `f_x` and `f_x'` agree, the polynomials agree identically. Since `F25[Z]` is a UFD, their nonzero linear fourth roots differ by a constant `omega in mu4`; zero polynomials correspond to zero signals. Thus **all 625 signals are identified up to mu4**, with exactly `(625-1)/4+1=157` phase orbits.

Yet for planted `x=(1,0)`, the measurements all equal one, and the rows of the Frobenius-lift matrix are `(1,z,-1,-z)` because `z^5=z`. This matrix has rank two and therefore a **two-dimensional** kernel (planted line dimension one). The explicit extra-kernel vector `(u1,u2,v1,v2)=(0,1,0,1)` produces polynomial `b^5-t^4 b`, vanishing on all sensing rows. Repeating the five rows gives injective designs of arbitrarily many measurements with the same rank defect. Therefore injectivity **cannot imply** one-dimensional Frobenius kernel for general deterministic designs. This does **not** prove that the iid random kernel fails near `3.5k`, nor does it disprove another efficient iid decoder.

## B. Axiom's independent theorem: deterministic adaptive recovery with <=2k-1 readings

**Theorem (fixed F25).** Let `k>=1`, `x in F25^k`. An adaptive algorithm using **only fourth powers of known F25-linear forms** returns exactly the global `mu4` orbit of `x` after

```
m(x) = k + max(|supp(x)|-1,0) <= 2k-1   (k>=1)
```

measurements (including all-zero signal), in **O(k) fixed-field operations**, with a constant-size enumeration of at most four candidates for each nonzero coordinate. There is no random sampling and the success probability is one. The measurement choices of round 2 depend on the powered values observed in round 1.

**Protocol.** Choose a known `theta in F25\F5` (for example the residue of `t` in `F5[t]/(t^2-2)`).

1. Measure `y_i=x_i^4` with the standard coordinate rows `e_i`, for every `i=1..k`. If all readings vanish, report the zero signal. Otherwise choose the least index `h` with `y_h != 0`, and choose any `alpha in F25` with `alpha^4=y_h`.
2. For each `j!=h` with `y_j != 0`, compute `b_j=y_j/y_h` and set `c_j=theta` if `b_j=1`; set `c_j=1` otherwise. Query exactly **one** additional powered reading `z_j=(x_h+c_j*x_j)^4`. Determine the unique element `u_j` of the four-element root set `{u:u^4=b_j}` satisfying `(1+c_j u_j)^4=z_j/y_h`. Return `x'_h=alpha`, `x'_j=alpha*u_j` for every active `j`, and zeros at inactive coordinates.

**Proof of uniqueness of the single extra query.** For any nonzero `u in F25`, `u^4=1` iff `u in F5^*`. Consequently the coefficient rule ensures `v=c_j*u notin F5`. Let `omega != eta` lie in `mu4=F5^*`. If `(1+omega*v)^4=(1+eta*v)^4`, both brackets are nonzero (since `v notin F5`), and their ratio belongs to `mu4`. Thus for some `lambda in F5^*`, `1+omega v=lambda*(1+eta v)`. When `lambda=1`, `omega=eta` since `v!=0`; otherwise `v=(lambda-1)/(omega-lambda*eta) in F5`, contradiction. Hence the four phase candidates produce four different additional readings. The recovered `u_j=x_j/x_h` is unique. Choosing a different fourth root `alpha` multiplies every reconstructed coordinate by the same global element of `mu4`. Since zero is the sole fourth root of zero, all zero coordinates are handled exactly. If `k=1`, one coordinate reading suffices. Proof complete.

**Generalization.** The same elementary protocol works for `F_(p^r)` with `r>=2`, prime `p`, measurements `(a dot x)^(p-1)`, ambiguity `mu_(p-1)=F_p^*`, and any fixed `theta outside F_p`. It uses at most `2k-1` adaptive readings, enumerating `p-1` possible local phases. The exact per-coordinate phase test is analogous with exponent `p-1`. For **fixed** `p`, extraction of roots of fixed-degree polynomials gives polynomial expected bit complexity in `log(p^r)` using standard finite-field factoring; for F25, all arithmetic and four-root enumeration are constant-time. **No** uniform deterministic poly(log p) assertion is made when the prime varies.

### B.1 Exact finite verification

Two independently written field arithmetic representations, sharing no code, each exhaustively decode all 625 signals in `F25^2` and all 15,625 signals in `F25^3` (16,250 total). Both directly check separation of every nonzero relative ratio under all four phase rotations. Each finds maximum `3` adaptive measurements for `k=2`, and `5` for `k=3`. The first implementation also exhaustively verifies Vesper's 97/625 count and projective orbit divisor, the all-k rational inequality for `1<=k<=19` and `s in {1,2,5}`, and the five-row lift obstruction. The tests are finite controls; the analytic proof covers every `k`.

## C. Same-scope table and novelty boundaries

| Claim | Fixed F25? | Sensing design | Count sufficient | Inverse | Uniform over all signals? |
|---|---|---|---|---|---|
| Vesper PR #31 | Yes | iid uniformly random **nonadaptive** | `ceil(3.5k)+s` | exhaustive / exponential | with probability `>1-5^-s` |
| Axiom PR #16 | Yes | iid uniformly random **nonadaptive** | `ceil((149/38)k)+s` | polynomial-time Frobenius lift | with probability `>1-5^-s` |
| **New Axiom adaptive theorem** | **Yes** | **two-stage signal-dependent row selection** | **`<=2k-1`** | **deterministic `O(k)` F25 operations** | **yes, probability 1** |

**These are three different claims.** In particular, the new adaptive result provides no better iid random-design decoder. It is an alternative measurement protocol, requiring a query interface that accepts a second-stage row after the first-stage responses arrive.

**Prior-art check (2026-10-28 local).** Charikar, Wu, Ye, *Adaptive Discrete Phase Retrieval* (SOSA 2020), DOI `10.1137/1.9781611976014.9`, studies the established concept of adaptive/discrete phase retrieval in complex amplitude-squared models. Iwen, Viswanathan, Wang, *Fast Phase Retrieval from Local Correlation Measurements*, SIAM J. Imaging Sci. (2016), DOI `10.1137/15M1053761`, studies local phase-synchronization designs over complex signals. Bartusel, Führ, Oussa, *Phase retrieval for affine groups over prime fields*, LAA (2023), DOI `10.1016/j.laa.2023.07.033`, studies complex group frames indexed by prime-field affine groups. These are **related prior techniques**, with different fields and measurement maps. A targeted search found no exact F25 fourth-power one-adaptive-reading protocol, yet this is **not** an exhaustive novelty verification. The field-specific phase synchronization mechanism is elementary, and no first-ever/world-record claim is warranted without deeper source comparison.

**Open gates:** an independently reviewed proof for the adaptive generalization, comprehensive same-field priority, a polynomial-time iid decoder near Vesper's 3.5k threshold, and potential lower bounds for adaptive querying. The obstruction above is specific to the *existing lifted-kernel criterion*, not a complexity lower bound on all algorithms.

## Replay

Run `python3 audit_and_adaptive.py` and `python3 verify_adaptive_alt.py` (standard library only). Preserve output logs, source SHA-256 values and manifest. No production credentials or original unpublished research archives are included.