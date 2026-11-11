# Higher-order matching: proved structural lemma and a cubic moment obstruction

**NIGHTFALL research note — 2026-11-10. Status: elementary proofs given below; no general degree-three variance-squared influence theorem established.**

## The target

For every fixed d, seek a universal c_d>0 such that bounded real Hoeffding-degree ≤d observables under arbitrary independent product laws satisfy

    max_i I_i(f) >= c_d Var(f)^2 / ||f||_infty^2.

This is substantially stronger than the existing general-degree exponent-5/2 bound. It is not proved here.

## Lemma 1 — hypergraph matching amplitude budget

Let f be bounded by B on a finite product of finite alphabets, with Hoeffding decomposition f=Σ_{|S|≤d}h_S. For every matching M of pairwise disjoint supports S of size exactly d,

    Σ_{S∈M} ||h_S||_infty ≤ 2^d B.

**Proof.** For each S choose a tuple x_S attaining ||h_S||∞. By canonical degeneracy in every coordinate, averaging the full mixed difference Δ_S h_S(x_S,y_S) over an independent y_S gives h_S(x_S); therefore choose y_S so that |Δ_S h_S|≥||h_S||∞. Put independent fair two-point marginals on the coordinates in S. Compare the uniform even-parity and odd-parity distributions on the 2^d corner configurations, choosing their order so that the expectation of h_S increases. Their expectations differ by |Δ_S h_S|/2^{d-1}; all proper-coordinate marginals agree. Couple the matched blocks independently, use identical product marginals outside them. Every term h_T with |T|≤d not equal to one of the matched S has the same expectation under both global experiments: its intersection with each matched block is proper (unless T=S). Since the expectations of f differ by at most 2B, Σ_S ||h_S||∞ /2^{d-1}≤2B. QED.

**Corollary (greedy vertex cover with bounded total cost).** Sort positive-weight d-supports by decreasing b_S=||h_S||∞, greedily take disjoint supports, and assign c_i=b_S to each vertex of a chosen S (zero elsewhere). Then Σ_i c_i≤d·2^d B and every d-support T contains a vertex i with c_i≥b_T. This covers only the top-order interactions; lower orders require separate treatment.

## Lemma 2 — dimension-free sum of section oscillations

For any bounded degree-≤d function f on a finite product and any fixed x, let osc_i(x) be the range of the i-th coordinate section. Then

    Σ_i osc_i(x) ≤ 4 d² B.

**Proof.** Choose maximizing replacement symbols at every coordinate. Independently switch each coordinate with probability t. The resulting expectation q(t) is a polynomial of degree ≤d with |q(t)|≤B on [0,1]. Markov's polynomial derivative inequality on [0,1] gives |q'(0)|≤2d²B. Its derivative equals the sum of coordinatewise increases. Repeat for minimizing replacements and add the two bounds. QED.

In particular, summing the conditional coordinate standard deviations gives Σ_i E[sd(f|X_{-i})]≤2d²B.

## Proposition 3 — the naive cubic fourth-moment transfer is false

A tempting replacement for the independent-increment quadratic estimate is

    E[Z^4] ≤ C_d( c² E[Z²] + (E[Z²])² )

for degree-(d−1) sums Z of bounded canonical terms, each with norm ≤c, uniformly over product laws and number of terms. **Already false for d=3.**

**Explicit counterexample.** Let A=U−p, where U is Bernoulli(p), and let B_1,...,B_n be independent fair signs, all mutually independent. Set

    Z=A Σ_{j=1}^n B_j = Σ_j A B_j.

Each summand is canonical of degree two and has absolute value ≤1. Write v=p(1−p). Then

    s=E[Z²]=nv,
    E[Z⁴]=[p(1−p)^4+(1−p)p^4] (3n²−2n).

As p→0 and n→∞ with np→∞, the ratio E[Z⁴]/(s+s²) grows like 3/p, hence no universal C_3 exists. For example n=⌈p^(−2)⌉ gives this divergence.

This is a counterexample to the **proposed proof operator**, not to the desired variance-squared influence theorem. It identifies the shared rare coordinate as the precise obstruction: many nominally distinct top-order terms can inherit one rare multiplicative gate.

## Next operator

Seek a hierarchical conditional-moment decomposition by shared (d−2)-coordinate cores, or a codegree-sensitive inequality with a separately controlled high-codegree remainder. A valid closure must handle the A·ΣB_j example without assuming a distribution-independent L4/L2 constant. For d=3, test star, sunflower, and overlapping-pair families with exact rational arithmetic before asserting a universal inequality.

## Scope and provenance

The matching lemma and oscillation lemma are elementary extensions of mechanisms in the supplied quadratic manuscript, not established novel contributions. The counterexample is an explicit algebraic proof attack on the naive extension. No external novelty search or Lean certification is claimed.