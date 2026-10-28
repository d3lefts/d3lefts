# NIGHTFALL — Universal q-ary factor-to-trivalent incidence-network theorem

**Research lead:** Devin J. Wright  
**Independent agent audit:** 2026-10-28  
**Status:** Mathematical theorem with an explicit universal bijection proof, a polynomial-time machine-checkable structural certificate for every finite input, exact direct-contraction and symbolic-monomial tests. **No claim of original discovery of COPY tensor encodings, proof-assistant formalization, or a subexponential SAT algorithm.**

## The theorem

Fix any finite alphabet `Q` with cardinality `q >= 2`, any commutative semiring `R`, `n` declared variables, and a finite list of local factors

    f_j : Q^(r_j) -> R

with ordered scopes of variable names, allowing repeated variable names within a scope and zero-arity factors. Let `L = sum_j r_j` and `v` be the number of variables appearing at least once. Write

    Z(F) = sum_{x in Q^n} product_j f_j(x_scope(j))

for the original partition function.

There is an explicit bipartite factor-incidence/equality-bridge tensor network `G(F)` with exactly

    edges(G) = L + 2*(L-v) = 3L-2v,
    vertices(G) = L + (L-v) + m = 2L-v+m,
    maxdeg(G) <= max(3, max_j r_j),

such that **for every commutative semiring `R` and every factor-table assignment**,

    Z(F) = (q * 1_R)^(n-v) * Z(G(F)).                      (1)

Here `q * 1_R` denotes the sum of `q` copies of the multiplicative unit in `R`. In particular, when `R` is the ordinary integers, the displayed factor is the usual integer `q^(n-v)`. Construction time is polynomial in the supplied factor description size; large-arity factors require explicit tables or specified evaluators.

If every factor has at most three arguments, the graph has maximum degree at most three, independently of the number of occurrences per variable.

### Explicit construction

For each factor position `(j,k)` make a **left** occurrence vertex `O[j,k]`, with one wire to **right** factor vertex `F[j]`, at its `k`th port. Every occurrence vertex has the all-equal indicator tensor for its one to three incident wires. For each variable `i` occurring `d_i` times, connect its occurrence vertices in a path using `d_i-1` **right** binary-equality bridges. Each bridge contributes two wires and is a two-leg all-equal tensor. Factor vertex `F[j]` has precisely the original table `f_j`, with incidence port order matching the original scope order. A variable with zero occurrences contributes no graph edges.

### Universal proof by bijection of edge assignments

Consider any graph-edge label assignment that makes **all occurrence and bridge indicators equal to one**. The label on the factor edge at an occurrence must equal the labels of the adjacent bridge edges; the bridge's two wires must agree. Moving along the path of copies of a variable therefore forces all factor-edge labels of that variable to equal one symbol `x_i in Q`. Exactly one such `x_i` exists for each active variable.

Conversely, given an arbitrary assignment of the `v` active original variables, assigning every wire in the path of variable `i` the symbol `x_i` uniquely satisfies every equality tensor. These transformations are inverse. In each pair of corresponding assignments, every factor vertex receives the original ordered argument tuple, so the product of factor weights is identical. Summing over edge assignments is therefore identical to summing the products over the `v` active variables. Each of the `n-v` unused variables has `q` possible values and contributes the semiring scalar `q * 1_R`; these factors multiply, proving (1). Zero-arity factors are isolated tensor vertices and contribute their scalar entries in the same identity. The proof uses no positivity, division, field operations, or complexity-theoretic conjecture.

For a stronger formal-polynomial version, replace each factor table entry `f_j(a)` by a separate indeterminate `X[j,a]` and work in the free commutative semiring `N[X]`. The bijection proves equality of the resulting partition polynomials coefficient by coefficient. Every commutative-semiring specialization follows by substituting values for the indeterminates.

### Optimal edge count in the specified bridge grammar

Assume one left vertex per occurrence with exactly one incident factor wire; all auxiliary equality constraints are **right** binary bridges joining two left occurrence vertices of the **same variable**; each such bridge uses two wires; and the construction must impose common variable labels for arbitrary local factor tables. For each active variable with `d_i` occurrences, its auxiliary bridge multigraph must be connected. Otherwise two components can receive independent values, and local factors can detect the disagreement. A connected multigraph on `d_i` vertices requires at least `d_i-1` bridges. Thus any construction in this grammar uses at least

    L + 2 * sum_{i:d_i>0}(d_i-1) = 3L-2v

wires. The explicit path construction attains equality and preserves max degree three at occurrence vertices. **This is an optimum only inside the explicitly stated bridge grammar.** Arbitrary tensor decompositions can use different encodings and edge counts.

### #3SAT corollary (self-contained and independent of contraction algorithms)

Normalize CNF clauses by deleting tautologies and duplicate literals. Empty clauses give zero satisfying assignments directly. For the remaining nonempty clauses of arity at most three, use their Boolean OR tables over `Q={0,1}`. Then

    #SAT(F) = 2^(n-v) * Z(G(F)),
    s = 3L-2v <= 9m,
    maxdeg(G(F)) <= 3.

The reduction is polynomial time and exact. **It makes no assertion about how quickly arbitrary tensor networks can be contracted.** Any proposed faster counting algorithm must separately prove its contraction theorem and its assumptions. This package neither invokes nor verifies a claimed subexponential contraction result.

## Independent machine proof architecture

1. `make_certificate.py` produces a graph in a transparent JSON schema from scopes and factor tables. The example contains an isolated original variable, repeated appearances and a negative-weight factor.
2. `check_structural_certificate.py` imports no compiler implementation. It checks factor incidence/port ordering, bipartition, every occurrence and binary-bridge shape, claimed variable identity, the exact edge formula and the equivalence classes of all wires under equality tensors. It verifies **one connected equality class per active variable, with no cross-variable identification**. Once this invariant holds, the universal polynomial identity follows from the proof above for **every choice of table entries**, without enumerating assignments.
3. `verify_universal_factor_compiler.py` uses a second route: full direct network edge-state enumeration on small instances, independent direct original-partition sums, and formal-monomial multiset equality (the strongest finite test).
4. `exhaustive_cnf.py` checks *all* 3,829 multisets of at most three canonical nonempty clauses using at most three Boolean variables, including repeated clauses. This includes 2,357 full edge contractions and 29,912 ordinary truth assignments.
5. `adversarial_controls.py` checks that 11 deliberate corruptions of a valid structural proof are rejected. Two further source-level controls exhibit a contradictory pair of unary factors that becomes spuriously satisfiable if a required equality bridge is removed, and check the exact unused-variable multiplier for weighted ternary factors.
6. `verify_universal_factor_compiler.py` also enumerates all 2,144 small simple bridge graphs with fewer than `d-1` edges for `d <= 6`, confirming their disconnection. The general lower bound comes from the elementary connected-graph argument above.

The independent structural checker is a **polynomial-time verifier of each explicit construction**, not a formal proof-assistant kernel for the quantified theorem. The universal mathematical proof appears in this note, whose finite consequences are tested below.

## Dated tests and reproducibility

Run from this directory:

```bash
python3 check_structural_certificate.py example_graph.json
python3 verify_universal_factor_compiler.py
python3 exhaustive_cnf.py
python3 adversarial_controls.py
```

Expected counts, independently generated on 2026-10-28:

| Check | Passed |
|---|---:|
| All canonical #3SAT formula multisets `n<=3`, `m<=3` | 3,829 |
| Full bit-edge contractions among those formulas | 2,357 |
| Independent ordinary truth assignments among those formulas | 29,912 |
| Random valid normalized 3CNF structures | 245 |
| Random empty-clause contradiction controls | 175 |
| Random signed weighted q-ary factors (`q=2,3,4`, 170 each) | 510 |
| Further independent direct contractions in random tests | 671 |
| Additional formal-monomial polynomial comparisons in random tests | 663 |
| Small bridge graphs enumerated below connectedness threshold | 2,144 |
| Source-level edge/unused-variable counterexample controls | 2 |
| Corrupted structural certificates rejected | 11 |

All calculations use Python standard-library integer arithmetic, free-of-rounding combinatorics and fixed seeds.

## Scope, provenance and priority

This is a **universal algebraic generalization with independent machine-verification infrastructure**, not evidence that the standard COPY tensor idea is new. Existing literature describes duality between graphical models and tensor networks and the conversion of #SAT using equality/COPY tensors; see:

- [Duality of graphical models and tensor networks](https://academic.oup.com/imaiai/article/8/2/273/5041985) (2019).
- [Exponential time complexity for contracting tensor networks](https://academic.oup.com/comjnl/article/69/4/613/8555574) (2026), explicitly describing a #3SAT-to-Boolean tensor-network encoding.
- [Source OpenAI contraction manuscript](https://github.com/openai/math/blob/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026/build/quantitative-reduction.tex) (2026), whose contraction bound is not part of this proof.

The work's concrete reproducibility contribution is a fully exposed finite-instance structural proof gate, stress tests over signed weighted alphabets, and the explicit grammar-scoped edge-minimality accounting. No publication-priority claim is made for the algebraic correspondence.