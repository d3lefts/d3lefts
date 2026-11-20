# Amplifying Claude's Theorem H: tensor-simplex frame obstruction (2026-11-19)

**Status:** independent paper-level generalization of `SUBCUBE_FAMILY_20261119.md` (Theorem H), with exact small-instance code checks. Not Lean-certified, externally peer-reviewed, or globally novelty-cleared. It strengthens only a **no-cheap-exact-frame** theorem; it does **not** establish any superpolynomial quantum-classical advantage or the unrestricted necessity conjecture.

## Objective and preregistered structural target

Use Theorem H's *representation-before-computation* mechanism to amplify its frame-cost exponent without changing the short-sum-subspace regime. The ingredients are standard binary simplex codes, tensor-product code distance, and the same forced additivity/dual-incidence argument used in the parallel proof. Check the simplest parameter cases exactly and retain the quantum-advantage question as explicitly OPEN.

## Theorem H+ (tensor-simplex family; author-side proof)

Fix an integer `q>=2` and tensor depth `L>=1`. Let

    m = q^L,
    n = (2^q-1)^L,
    R(q,L) = {v_1 tensor ... tensor v_L : each v_i in F_2^q \ {0}}
              subset F_2^m.

There are `n` distinct rows and they contain the `m` singleton standard-basis rows, so the row rank is `m`. Let `N_r` denote the maximum dimension of a subspace of the **at-most-`r`** sumset, as in the source Conjecture E.

**(i) Small short-sum subspaces.** For every integer `r>=1`,

    N_r(R(q,L)) <= r log_2(n+1)
                = O_q(r log m).

This is exact quantifier accounting: the at-most-`r` sumset includes zero, so it should be bounded by `(n+1)^r`, **not by `n^r`**. The source `TOWERS_20261119.md` omitted this extra zero/shorter-sum option; its asymptotic conclusion remains valid after correction.

**(ii) Frame lower bound.** If `B` is any `(c,c',h)`-frame for `R(q,L)` with `c,c'>=1` and `h>(q+1)c`, then

    c >= (q*2^(q-1)/(2^q-1))^L,
    c*c' >= (q*2^(q-1)/(2^q-1))^L.

No condition on `c'` beyond `c'>=1` is used. For `q=2` this is exactly Theorem H's `(4/3)^L = m^(log_2(4/3))` bound.

**(iii) Near-linear exponent.** Let

    alpha(q) = log_q( q*2^(q-1)/(2^q-1) ).

Then `c >= m^alpha(q)` and `alpha(q) -> 1` as `q->infinity`. For example, `q=512=2^9` yields `q*2^(q-1)/(2^q-1)>256`, so

    c > 256^L = (512^L)^(8/9) = m^(8/9).

For the precise `epsilon=delta=1/4` smoothing parameter quoted in the source Theorem H, `h(2cT)>=792cT`; thus **`T=1`, `q=512` satisfies `h>(q+1)c`**, and the corresponding frame cost is at least `m^(8/9)`. The large but fixed `q` is legitimate in this asymptotic claim; the physical number of input rows is enormous, but finite.

For any fixed exponent `0<alpha<1`, choosing a sufficiently large fixed `q` and then a fixed sufficiently large `T` to guarantee `h(2cT)>(q+1)c` yields a sequence with `Lambda_T(R(q,L)) >= m^alpha` but `N_{a(T)}=O(log m)` for any fixed polynomial `a` and that fixed `T`. This amplifies **only the failure of Conjecture E's exact-frame implication**, not the underlying quantum-query advantage question.

## Proof of (i)

Each sum of at most `r` input rows can be expressed by **exactly `r` choices from `R union {0}`** by padding with zero. Hence

    |r dot R| <= (n+1)^r.

If a `k`-dimensional vector subspace lies inside this set, it contains `2^k` elements, so `2^k<=(n+1)^r` and `k<=r log_2(n+1)`. With fixed `q`, `log_2(n+1)=Theta_q(L)=Theta_q(log m)`. No additive-combinatorics theorem is invoked.

## Proof of (ii)

1. **Local tensor splitting forces additive representations.** Every base factor `v in F_2^q\{0}` is a sum of at most `q` standard unit factors. For any non-singleton tensor row `C=v_1 tensor ... tensor v_L`, split a non-unit factor `v_i` into the corresponding unit vectors, producing at most `q` child rows `C_j` with `C=sum_j C_j`. Choose a frame representation `rep(C) subset B` of size at most `c`, and likewise `rep(C_j)`. The symmetric difference of the parent and child representations is a dependency among at most `(q+1)c<h` frame vectors. By `h`-independence it must be empty. Thus `rep(C)=Delta_j rep(C_j)`. Iterating yields

       rep(C) = Delta_{z in supp(C)} rep(e_z),

   where the `e_z` are the tensor singleton rows (coordinate units of `F_2^m`). Even if the chosen row representations were initially non-unique, this conclusion holds for any choices under the declared high-girth hypothesis.

2. **Dual incidence and rank.** For `b in B`, define `Z_b={z: b in rep(e_z)} subset [q]^L`. By step 1,

       b in rep(C) iff |Z_b intersect supp(C)| is odd.

   Let `M` be the `m x |B|` binary matrix whose columns are the actual vectors `b`, and `A` the `|B| x m` matrix whose rows are the incidence vectors `1_{Z_b}`. Since `sum_{b in rep(e_z)} b=e_z` for all singleton rows, **`M A=I_m`**. Hence `rank(A)=m`, so at least `m` of its rows `1_{Z_b}` are nonzero. This argument does not assume B globally independent and does not assume any large-alphabet representation model.

3. **Tensor code minimum distance.** The base binary evaluation code

       E_q : F_2^q -> F_2^(2^q-1), (E_q z)_v = <v,z>,

   has length `2^q-1`, dimension `q`, and exact minimum distance `2^(q-1)`: for each nonzero `z`, exactly half of the `2^q` base vectors have dot product one, and zero never contributes. The `L`-fold tensor-product code `E_q^{tensor L}`, whose coordinates are precisely the row parities indexed by `R(q,L)`, has minimum distance `2^((q-1)L)`. This standard product-code distance identity also follows by induction: if a nonzero tensor-codeword has a nonzero block, there are at least `d` nonzero blocks and each has weight at least `d^(L-1)`.

4. **Count odd intersections.** Every nonempty `Z_b` produces a nonzero input codeword, and thus occurs in at least `2^((q-1)L)` row representations. Step 2 gives at least `m=q^L` such `b`. Counting pairs `(b,C)` with `b in rep(C)` both ways yields

       q^L * 2^((q-1)L)
          <= sum_C |rep(C)| <= c*(2^q-1)^L,

   hence `c >= (q*2^(q-1)/(2^q-1))^L`. QED.

## Exact finite replay (not a universal proof)

Run

    python3 -I research/nightfall/structural_information/dichotomy_tests/check_tensor_simplex.py

The independent checker constructs every tensor row as a GF(2) bitmask and evaluates **every nonzero input secret**, not a random sample, for nine cases:

    (q,L) = (2,1),(2,2),(2,3),(2,4),
            (3,1),(3,2),(4,1),(4,2),(5,1).

Observed minimum weights are respectively `2,4,8,16,4,16,8,64,16`, matching `2^((q-1)L)` exactly; including `q=4,L=2` with `m=16,n=225` and all `65,535` nonzero secrets. The finite checker has no timeouts or numerical tolerances. It verifies the tensor code input, **not** the universal frame lower bound, which rests on the paper proof.

## Limitations, adversarial audit and next test

- This is a **representation-system lower bound**. It cannot by itself prove that a quantum algorithm has a superpolynomial query advantage over classical edge/row queries. There might be efficient non-frame simulation for this family.
- Any claim of global mathematical novelty needs a dated specialist search covering tensor simplex codes, locally decodable codes, recursive parity computation, generalized Fourier checking, quantum learning from subcube parities, and local representations. Base-code distance and tensorization are known and explicitly credited.
- **Audit key failure modes:** at-most vs exactly-`r` sumsets, missing singleton rows, character-zero conventions, proof of `MA=I_m`, whether `h>(q+1)c` is actually supplied by the chosen `h(T,epsilon,delta)`, and unjustified conversion from frame lower bounds to quantum advantage.
- **Next decisive experiment:** for `T=1`, analyze bounded quantum acceptance polynomials `Q(s)` whose Fourier spectrum lies in `2R(q,L)`. Either construct a classical simulator `poly(L)` for all such `Q` or find a specific scalar acceptance probability requiring `q^{Omega(L)}` classical row queries. Start with the small `q=2` family so brute tests and any exact certificate are inexpensive; stronger `q` concerns frame obstructions only.

## Source and provenance

- Independent generalization of the parallel worker's `SUBCUBE_FAMILY_20261119.md`, `TOWERS_20261119.md` (active `structural-information-theory` branch).
- Binary simplex code distance and product-code distance are classical coding theory; e.g. see MacWilliams & Sloane, *The Theory of Error-Correcting Codes*. The contribution here is the explicit forced-additivity/dual-counting transfer to the source `(c,c',h)` frame definition, **not** the underlying coding theory.
- Does not supersede the separate [cactus block-merging review PR #955](https://github.com/d3lefts/d3lefts/pull/955); the two checks stress different parts of the research program.
