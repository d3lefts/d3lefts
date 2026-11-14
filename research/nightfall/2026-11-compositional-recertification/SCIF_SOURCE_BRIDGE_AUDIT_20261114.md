# NIGHTFALL SCIF — exact canonical source recentering and influence transport

**2026-11-14, v0.1.** Formal setup: finite independent product coordinates
with common finite alphabet (zero-mass atoms allowed), one original
pointwise function `f` of canonical Efron–Stein degree <=2, and one
marginal update `p_k -> q_k`. Source metadata/authenticity are **external
premises**. The mathematical proof below is analytic and finite; the
separate exact Fraction checker confirms 20 fully expanded source
instances. **The explicit low-order component transport is not yet
kernel-certified in Lean.** Its degree-preservation and new-law true
energy identities are compiled in `SCIFSourceDegree.lean` and
`SCIFSourceEnergy.lean`, while the table algebra/owner repair is in #496.

## 1. Explicit old and new canonical components

For original product law p define the pointwise Hoeffding components
`h_S=esComp p S f`. Then

    f(x)=m + sum_i h_i(x_i) + sum_{i<j} h_ij(x_i,x_j)

at **every** x, not only almost surely. Let p' agree with p except
p'_k=q_k. Put

    beta = E_{q_k} h_k(Z)
    b_j(x_j) = E_{q_k} h_{kj}(Z,x_j).

Because old h_kj is centered in j under p_j,
`E_{p_j} b_j=0`. The following components are centered under
the NEW law, on their full alphabet:

    m' = m + beta
    h'_k = h_k - beta
    h'_j = h_j + b_j                 (j != k)
    h'_{kj} = h_{kj} - b_j          (j != k)
    h'_{ij} = h_{ij}                (i,j != k).

The sums still telescope exactly to f pointwise. Orthogonality and
uniqueness of centered Hoeffding decompositions for normalized
product laws identify these quantities with `esComp p' S f`.
This last **uniqueness/identification step is a Lean obligation**;
it is not discharged by the existing pair-table source alone.

The formulas imply that only the singleton k, its incident pairs,
their neighboring singletons, and the constant can change. All
other canonical components are pointwise identical. The intrinsic
pair graph is unchanged; #496 separately certifies the mixed
four-corner graph criterion for true source f.

## 2. Exact actual-coordinate influence updates

Use the true conditional-variance convention
`I_i^p(f) = E_p[(f-E_{p_i}(f|X_{-i}))^2]`.
For degree <=2,

    I_i^p=E_{p_i} h_i² + sum_{j!=i} E_{p_i p_j} h_ij².

For j != k the local update is

    I_j^{p'} - I_j^p =
        2 E_{p_j}[h_j b_j]
      + (E_{q_k p_j} - E_{p_k p_j})[h_kj²].

For the edited coordinate,

    I_k^{p'} - I_k^p =
        (E_{q_k}-E_{p_k})[h_k²] - beta²
      + sum_{j!=k} (
        (E_{q_k p_j}-E_{p_k p_j})[h_kj²]
        - E_{p_j}[b_j²]).

**Derivation:** The new singleton and pair contributions are
orthogonal by coordinate centering. For each j,
`E_{q_k}(h_kj-b_j)^2=E_{q_k}h_kj²-b_j²`.
Adding `(h_j+b_j)^2-h_j²` cancels the `b_j²`
terms and leaves the displayed cross term. The k formula follows
from the same variance identity for h_k and each incident pair.
No influence oracle, nonsingular marginal, division by p, or
probabilistic tolerance is introduced.

If an adjacency list and pair tables of size <=a² are stored,
re-evaluation of the directly affected raw tables takes
O((deg_H(k)+1) a²) arithmetic. Additional source checking, source
authentication, data structure updates, and task-program integrity
must be charged separately. No general computational optimality or
real-world wall-clock savings are claimed.

## 3. Fixed-owner amplitude repair

Let `eta=sum_a |q_k(a)-p_k(a)|`, and assume the old centered
pair amplitude satisfies `|h_kj(a,b)| <= c_owner(kj)`.

Then

    |b_j(b)| <= min(eta,1)*c_owner(kj)
    |h'_kj(a,b)| <= [1+min(eta,1)]*c_owner(kj).

The previous edge-owner map remains a **valid** owner assignment
with costs inflated by at most `1+min(eta,1)`, and its total
cost has the same multiplier. This is a certificate *repair*
upper bound, **not proof that the repaired owner is globally
minimum-cost**. The generic weighted-table proof was kernel-checked
in #496; actual-source instantiation in one terminal theorem still
requires the component identification and original source greedy
owner package.

## 4. Reproducible independent source expansion

`check_scif_canonical_full_source.py` implements the definition
of canonical conditional expectation directly as a weighted sum over
all held/unheld original source configurations, rather than calling
the recenter or update formulas. Twenty seeded four-coordinate,
three-symbol instances include zero-mass atoms and arbitrary
unary/pair potentials. At every original configuration it checks:

- The old/new canonical ANOVA identities, with all high-order terms 0.
- Every one of the edited singleton/pair component formulas.
- The *direct* source-resampling influences equal the canonical
  energy formulas before and after the edit.
- Both exact closed influence-update identities and the clipped
  owner-amplitude bound.

Recorded author-side result: **47,280 exact Fraction assertions PASS**,
Python standard library, seed 20261114. Original checker SHA256
`c8c5a18548d86bba54f4ec7d053f2ff212991823e0fb5e5a9ff619cbe0f9d669`.
These tests **cannot replace** an arbitrary-dimensional source-level
Lean identification or independent outside review.

## 5. Certification and novelty

| Claim | Current state |
|---|---|
| Canonical old->new Efron–Stein degree bound, arbitrary d | Strict Lean #503 (current source) |
| Exact new-source degree-two variance and influence = new component energies | Strict Lean #503 |
| Exact old/new canonical component formula | Analytic + Fraction checker; Lean bridge open |
| Exact local old/new influence difference | Analytic + Fraction checker + generic table Lean #496; canonical composition open |
| Fixed-owner clipped amplitude and total cost | Generic table Lean #496; source owner instantiation open |
| Real-world change capture and effect-time authorization | Not established here |
| Novelty relative to dynamic Hoeffding decompositions or incremental verification | Not established |

The next decisive Lean lemma should directly identify
`esComp p' {k,j} f` with
`esComp p {k,j} f - E_{q_k}[esComp p {k,j} f]`
under the single-source edit; its singleton counterparts can then
be obtained by the source decomposition and centering identities.
After that, compose the source energies into the exact I_i difference
and instantiate the #496 fixed-owner cover with the source-produced
greedy certificate in one terminal type.

This is a mathematical proof sketch plus a separately checked
finite experiment, **not** a published result or certified
end-to-end SCIF theorem.
