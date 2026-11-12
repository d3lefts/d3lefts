# A source-function route to exponent-two influence using certified row costs

**NIGHTFALL | 2026-11-11 | analytic reconstruction v1.0**
**Status:** complete finite-product mathematical argument conditional only on the
pre-existing general product-row theorem; NOT a compiled full Lean influence theorem,
a human referee certificate, or a globally original discovery. This is a
simplification of the stronger `15(1+sqrt(3))` analytic proof already in the
repository, at the expense of a larger constant. Preserve both methods.

## Exact theorem and feasible set

Let `(Ω_i,p_i)` be a **finite** family of arbitrary nonempty finite probability
alphabets with independent product law, including arbitrarily small masses.
Discard zero-mass symbols for this analytic argument. Let
`f : Π_i Ω_i → [-B,B]` have Hoeffding interaction degree at most two,
where `B>0`. Set `V=Var(f)`,
`I_i=E Var_i(f|X_{-i})`, `M=max_i I_i`. Then

```
K = 4 π²
Drow = 15 + √3 (K + 7)
V ≤ Drow B √M;
V² ≤ [15 + √3 (4π²+7)]² B² M.
```

`Drow = 95.50298074615081...`. The original full quadratic argument gives
the **stronger** constant `15(1+√3)≈40.98`. This alternative is valuable
because the pointwise section estimate now follows directly from the already
kernel-checked arbitrary-product row theorem, without first building a
quadratic polynomial representation or the separate 16B Markov-switching
bridge. **The exponent two and atom/dimension independence are unchanged.**

## 1. Actual canonical decomposition and energy

Let `m=Ef`, `h_i=E[f|X_i]-m` and
`h_ij=E[f|X_i,X_j]-E[f|X_i]-E[f|X_j]+m`. (These are actual
finite-table conditional expectations; not abstract assumed coefficient
arrays.) Hoeffding degree ≤2 gives, pointwise on the positive support,

`f=m+Σ_i h_i(X_i)+Σ_{i<j}h_ij(X_i,X_j)`.

Every `h_i` is centered, every `h_ij` is separately centered, and different
Hoeffding components are orthogonal. Therefore

```
V=Σ_i ||h_i||²₂ + Σ_{i<j} ||h_ij||²₂,
I_i=||h_i||²₂ + Σ_{j≠i} ||h_ij||²₂.
```

Thus each squared component of a coordinate's section is at most `M`.

## 2. Matching rectangle weights from this actual f

For pair `(i,j)`, set `b_ij = max_{a,b}|h_ij(a,b)|`. Since
`h_ij` is separately centered,

```
h_ij(a,b)=E_{a',b'} [
  h_ij(a,b)-h_ij(a',b)-h_ij(a,b')+h_ij(a',b')].
```

The corresponding four-corner mixed difference equals the mixed
difference of `f`, since every other Hoeffding term is independent of
at least one of `i,j`. A rectangle whose signed difference is at least
`b_ij` therefore exists. For each matching, independently run the even
vs odd two-point coupling in every matched block. The experiments have
identical one-coordinate marginals and independent distinct blocks, so
all singleton and unmatched pair terms cancel. Their expectation
difference equals half the sum of the oriented mixed differences.
Both expectations lie in `[-B,B]`. Therefore

`Σ_{e in any matching} b_e ≤ 4 B.`

Greedily choose the highest remaining weight among pair edges, delete
incident edges, and repeat. Charge the full selected weight to both
endpoints. Every original edge meets a selected edge at least as heavy,
hence can be assigned to one endpoint `i` with cost `c_i≥b_e`. The
selected edges form a matching and the total endpoint cost obeys

```
c_i≥0,  Σ_i c_i ≤8B,
each unordered pair (i,j) assigned exactly once to
an endpoint i with b_ij≤c_i.
```

## 3. Actual-function section budget from the existing row theorem

For the normalized `g=f/B`, `|g|≤1` and Hoeffding degree≤2. The
already-compiled product row certificate (via the compiled
`ESDegreeLE ↔ HasProdDegreeLE` equivalence) supplies for **each x** a
row `a_i(x)≥0` with

```
Σ_i a_i(x) ≤ K=4π²,
|g(x)-g(y)| ≤ Σ_{i:x_i≠y_i} a_i(x).
```

Thus for every coordinate i and replacement symbols s,t,

`|f(x^{i←s})-f(x^{i←t})| ≤2B a_i(x)`.

Define the actual centered section in `H_i=L²(p_i)` by
`U_i(s;X_{-i})=f(X_{-i},s)-E_{p_i} f(X_{-i},·)`. The
variance-of-a-bounded-variable inequality gives

```
||U_i(·;X_{-i})||_{H_i}
 ≤ (max_s f(X_{-i},s)-min_t f(X_{-i},t))/2
 ≤ B a_i(X).
```

Averaging and summing (finite sums, no selection issues) yields

`Σ_i E_{X_{-i}} ||U_i(·;X_{-i})||_{H_i} ≤ K B.`

**Critical simplification:** the earlier proof's 8B section budget is
replaced by the weaker `4π²B` budget, but it is obtained with no
explicit quadratic-polynomial representation, no separate Markov
interpolation and no section witness hypotheses. The newly added
`QuadraticActualRowOscillation.lean` targets precisely this
function-level implication.

## 4. Additive projection

Let `q_x(t)=∏_i (E_i+t(Id-E_i)) f(x)`. Every factor is Markov for
`t∈[0,1]`, so `|q_x(t)|≤B`. Hoeffding degree two makes `q_x`
quadratic, and `g_1(x)=m+Σ_i h_i(x_i)` satisfies

`g_1(x)=-2q_x(0)+4q_x(1/2)-q_x(1)`.

Hence `|g_1(x)|≤7B`. As `g_1` is additive over a finite product, its
global range equals the sum of the ranges of individual `h_i`.
The scalar variance/range estimate gives

`Σ_i ||h_i||_{L²(p_i)} ≤7B`.

Consequently `Σ_i ||h_i||²₂ ≤7B√M`. This additive bridge remains to be
formalized for the actual f; the algebraic 7B polynomial interpolation
has a separate kernel certificate.

## 5. Actual independent assigned Hilbert increments

For each endpoint i let `S_i` be the distinct neighbors whose
interaction edges were assigned to i. Define

```
Y_ij(·;X_j) = h_ij(·,X_j) in H_i=L²(p_i),
Z_i=Σ_{j in S_i}Y_ij,
s_i=E||Z_i||², z_i=E||Z_i||.
```

The variables `Y_ij` are independent (different neighbor coordinates),
have mean zero in `H_i` (pair degeneracy), and obey
`||Y_ij||≤b_ij≤c_i` pointwise. Their second moments add exactly.
Orthogonality and unique edge ownership yield

`0≤s_i≤I_i≤M`, and
`Σ_i s_i=Σ_{i<j}||h_ij||²₂`.

Conditioning `U_i` on the assigned-neighbor sigma-field leaves
`h_i+Z_i`. Jensen and the triangle inequality thus yield
`z_i≤E||U_i||+||h_i||`, so

`Σ_i z_i≤(K+7)B`.

This conditional expectation identity, precise product-to-Hilbert
increment instantiation, and energy ownership are **the remaining
load-bearing actual-f Lean interface**; nothing in the row proof
allows them to be assumed silently.

## 6. Fourth moment, interpolation and conclusion

For the *actual* independent centered Hilbert increments with
`||Y_ij||≤c_i`, the already kernel-checked all-n moment identity gives

`Q_i:=E||Z_i||⁴ ≤ c_i² s_i+3s_i²`.

Hölder interpolation of `L¹,L²,L⁴` gives
`s_i³≤z_i² Q_i`. If `s_i>0`, divide by `s_i` and take
nonnegative square roots:

`s_i≤z_i sqrt(c_i²+3s_i)≤z_i(c_i+√(3M))`.

This is also true when `s_i=0`. Since `z_i≤√s_i≤√M`,

```
Σ_i s_i
 ≤ Σ_i c_i z_i + √(3M) Σ_i z_i
 ≤ 8B√M + √3 (K+7)B√M.
```

Combining this with the additive energy gives the announced

`V≤[7+8+√3(K+7)]B√M=[15+√3(4π²+7)]B√M`.

No minimum atom, alphabet size, pair graph degree or dimension enters the
coefficient. The proof uses exactly one source-function row statement,
one actual matching construction, one actual additive projection, and
one actual-independent-increment interpolation.

## Reproducibility, gates and stop rule

- **Existing compiled source:** `product_row_bound` and
  `prodDegree_iff_esDegree`, `full_matched_rectangles_le_four`
  on explicit block polynomials, `matching_budget_to_endpoint_budget`
  given a matching-mass theorem, and
  `arbitrary_law_many_hilbert_fourth` for concrete centered independent
  vectors. Distinct current theorem types must not be conflated.
- **Strict verified (separate scoped Lean gates):**
  `QuadraticActualRowOscillation.lean` proves the genuine all-section
  `8π²` comparison under actual `ESDegreeLE` (Lean 4.33, PASS
  [run 43118938808](https://github.com/d3lefts/d3lefts/actions/runs/43118938808)).
  `CenteredRectangle.lean` proves the exact weighted pair rectangle
  average for separately centered pair kernels (Lean 4.35, PASS
  [run 43118938773](https://github.com/d3lefts/d3lefts/actions/runs/43118938773)).
  `QuadraticEndpointInterpolation.lean` proves the scalar step from an
  *explicitly supplied* L1/L2/L4 interpolation hypothesis and Hilbert
  moment bound to endpoint energy (Lean 4.35, PASS
  [run 43119753547](https://github.com/d3lefts/d3lefts/actions/runs/43119753547)).
  The newer centered-section extension has now independently passed strict
  Lean 4.33 [run 43120669405](https://github.com/d3lefts/d3lefts/actions/runs/43120669405),
  together with the two original row statements in the same exact source. The
  old two-declaration receipt remains archival, not superseding the new gate.
- **Still missing in Lean:** Efron–Stein component centering and exact
  component/section representation; actual-f matching coupling that
  produces `∀ matching,Σb≤4B`; the true additive `Σ||h_i||≤7B`
  inequality; concrete endpoint assignment and Hilbert kernel
  instantiation; actual conditional expectation/Jensen; exact
  `L¹,L²,L⁴` interpolation and final energy equality.
- **The target full end-to-end Lean declaration is NOT compiled.**
  A conditional closure theorem that assumes these source-function
  bridges is not an end-to-end substitute.
- **Audit:** compare theorem types and source hashes to successful
  pinned receipts; independently inspect zero-mass handling,
  resampling-influence normalization, four-corner orientation, and
  `s_i=0` cases. Human novelty review remains open.
- **Stop rule:** if a bridge does not compile with only foundational
  axioms, retain its exact failing obligation; do not upgrade the
  public passport's status or replace a proof by numeric tests.


## Further simplification: eliminate the 7B additive interpolation entirely

The same certified row cost also controls the **actual** additive
Hoeffding functions without a separate quadratic Markov/7B proof.
Indeed, each `h_i(s)=E_{X_{-i}}f(X_{-i},s)-Ef` is centered. For any
symbols s,t, the row statement of §3 gives

```
|h_i(s)-h_i(t)|
  ≤ E_X |f(X_{-i},s)-f(X_{-i},t)|
  ≤ 2B E_X a_i(X).
```

Hence `range(h_i)≤2B E a_i(X)`. The elementary scalar
variance/range inequality yields
`||h_i||₂≤B E a_i(X)`, and summing gives

`Σ_i ||h_i||₂≤KB`,

**entirely from the same source-function row**. Thus the 7B additive
projection step in §4 is optional for a weaker—but fully
variance-squared—target. The two budgets now agree:

```
Σ_i E||U_i||≤KB,
Σ_i||h_i||₂≤KB,
Σ_i z_i≤2KB,
Σ_i c_i≤8B.
```

The same independent-Hilbert fourth moment and interpolation give

```
V ≤ [8+(1+2√3)K] B √M
  = [8+4π²(1+2√3)] B √M,
V² ≤ [8+4π²(1+2√3)]² B² M.
```

The coefficient is `184.23566779069478...`, deliberately weaker
than §1's `95.50298...`, but it **eliminates the actual additive
projection formalization gate**. For finite-product end-to-end Lean
formalization, this is currently the cheapest legitimate target.
It still requires a genuine actual-function matching mass proof and
actual assigned-increment orthogonality/Jensen/fourth-moment
instantiation; it is not a proof-by-assumption of those interfaces.
