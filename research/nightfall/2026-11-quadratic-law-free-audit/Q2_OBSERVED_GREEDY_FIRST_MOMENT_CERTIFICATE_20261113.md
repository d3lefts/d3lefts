# Q2: original-source observed law and greedy-owned first-moment scope

**November 13, 2026 | source-identity/proof passport | no terminal Q2 certificate**

## Immutable source evidence

Historical strict Lean **4.33.0**, upstream pinned commit `2a6ceaef872ae993708950f951989134084b851a`, standard axioms `propext`, `Classical.choice`, `Quot.sound` only:

- [Run 43500988069](https://github.com/d3lefts/d3lefts/actions/runs/43500988069) certifies `ActualESFiniteSampleLaw.observedSample_update_outside`, `actual_source_observedSample_law`, `actual_source_observed_hilbert_first_moment`, Git blob `47e112bdd32dea19429ecb4741ecc4f793535793`.
- [Run 43501778239](https://github.com/d3lefts/d3lefts/actions/runs/43501778239) certifies the source-derived greedy cover and `ActualESOwnedSampleLaw.indexedNeighbors_mem`, `indexedNeighbors_injective_on_prefix`, `owned_sumVector_eq_source_prefix`, `actual_greedy_owned_product_law`, `actual_greedy_owned_first_norm_law`, `exists_actual_source_greedy_first_norm_law`, Git blob `f32d215782905863f55336304ea2f859ed949e2f`.
- The canonical graph interface `ActualESCanonicalPairGraph.lean` is Git blob `7ba07f6aebe13db631d44d463ed0e069b58c3bd7`, strictly built as a dependency in the latter run.

## Verified mathematical mechanism

Each pair edge is a two-element subset of **original** coordinates. The greedy endpoint owner partitions the complete edge set; for each owner i the `Finset` of other endpoints (J_i) contains distinct source labels. The source constructs costs (c_i\ge0) and (∑_i c_i\le8B), with no externally supplied matching weight or source cover.

Enumerate (|J_i|=n_i) real source sites injectively by (j_i:{0,…,n_i-1}\to J_i). For the genuine pair kernel (h_{i,j}(a,b)), define increments
\[
Y_{ik}(b)(a)=\sqrt{p_i(a)}\,h_{i,j_i(k)}(a,b),\qquad k<n_i.
\]
At any original source draw (X), the recursive sum is pointwise
\[
\operatorname{sumVector}(Y_i,n_i,\operatorname{observedSample}(j_i,n_i,X))(a)
=\sqrt{p_i(a)}\sum_{k<n_i}h_{i,j_i(k)}(a,X_{j_i(k)}).
\]
The source-observed prefix law is **exactly** the recursively independent product law for every finite observable (F). In particular, the first Hilbert norm moment appearing in the fourth-moment endpoint has the correct original-source distribution:
\[
\mathbb E_{X\sim p}\|\operatorname{sumVector}(Y_i,\operatorname{observedSample}(j_i,X))\|_2
=\mathbb E_{W\sim\otimes_{k<n_i}p_{j_i(k)}}\|\operatorname{sumVector}(Y_i,W)\|_2.
\]
This equality holds for arbitrary nonnegative normalized original coordinate masses, including zero-mass atoms, and empty (J_i).

## Remaining terminal dependencies

- Transport each oriented source pair (h_{i,j}) into the exact canonical owned-edge energy, including `first/second` orientation when the larger-cost owner is the second endpoint.
- Identify the source-observed recursive sum with the genuine ANOVA **conditional** owned section at every supported source state and prove a conditional Jensen contraction.
- Derive (s_i\le I_i(f)), (∑_i s_i=∑_{\{i,j\}}\|h_{ij}\|_2^2), and (∑_i z_i\le16B) from (f), not as supplied premises.
- Invoke the strict fourth-moment endpoint and numerical closure, then compile a single theorem with only the source product-law, (|f|\le B), and Efron–Stein degree-two hypotheses.
- Main's current **active** compiler pin is Lean 4.36.0-rc2. The historical 4.33 receipts here are **not** an active 4.36 kernel replay. Universal measurable/heterogeneous-alphabet lifts and global originality remain unproved.

This mainline import preserves exact blob identity but does not promote the sources into the frozen 67-file historical registry or claim a terminal result.
