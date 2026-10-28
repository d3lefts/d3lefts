# Prior-art assessment — heterogeneous erasure reliability, 28 October 2026

**Research program:** NIGHTFALL / PHASESHIFT (Devin J. Wright)

**Verdict:** The proof is a valid mathematical specialization of standard methods within the stated measurement model, subject to its already documented mathematical scope. Its claimed ingredients do **not** establish a new general scheduling-complexity theorem or a new convex-optimization algorithm. Publication priority for the *exact translated-involution group-code formulation* has not been established. Report it as an independently checkable **application and synthesis** pending a deeper domain-specific novelty search.

## Closest earlier literature

1. **D. Shabtay and M. Kaspi (2006)**, “Parallel machine scheduling with a convex resource consumption function,” *European Journal of Operational Research* **173**(1):92–107, DOI [10.1016/j.ejor.2004.12.008](https://doi.org/10.1016/j.ejor.2004.12.008). Earlier convex workload-equivalent scheduling and NP-hardness for two machines; the later 2017 article makes the workload-partition equivalence explicit.
2. **A. Benoit, L. Marchal, Y. Robert, and O. Sinnen (2010)**, “Mapping Pipelined Applications with Replication to Increase Throughput and Reliability,” *SBAC-PAD 2010*, DOI [10.1109/SBAC-PAD.2010.16](https://doi.org/10.1109/SBAC-PAD.2010.16). Explicit heterogeneous independent failure probabilities; balancing failure products; reduction from strongly NP-complete 3-PARTITION. This is a strong prior-art match for the *hardness mechanism*, although its reliability success criterion differs from this code's “at least two labels survive” criterion. [Author presentation](https://graal.ens-lyon.fr/~abenoit/slides/sbacpad10.pdf).
3. **D. Oron, D. Shabtay, and G. Steiner (2017)**, “Approximation algorithms for the workload partition problem and applications to scheduling with variable processing times,” *European Journal of Operational Research* **256**(2):384–391, DOI [10.1016/j.ejor.2016.06.062](https://doi.org/10.1016/j.ejor.2016.06.062). The Workload Partition Problem minimizes a sum of convex functions of assigned bin weights. The NIGHTFALL cost `sum_c exp(W_c)` is an **immediate special case** (`g(t)=exp(t)`). The paper establishes strong NP-hardness for a variable number of bins and discusses an FPTAS with a fixed number. These discoveries precede NIGHTFALL.
4. **A. W. Marshall, I. Olkin, B. C. Arnold (2009/2011)**, *Inequalities: Theory of Majorization and Its Applications*, 2nd ed., Springer, DOI [10.1007/978-0-387-68276-1](https://doi.org/10.1007/978-0-387-68276-1). Classical Schur-convexity/majorization explains why balanced occupancy minimizes every symmetric convex occupancy penalty, including `sum_c binom(n_c,r)`. The distribution-free union-of-events identity is elementary inclusion–exclusion.
5. **Classical PARTITION / subset-sum dynamic programming**: reachable (cardinality, total weight) states and pseudo-polynomial algorithms predate NIGHTFALL. Its exact two-label Pareto frontier is a straightforward augmentation, applied to the specific code's two separate performance metrics.

## Claim-by-claim classification

| NIGHTFALL subclaim | Novelty status |
| --- | --- |
| `P_fail = R*(sum_c exp(W_c)-q+1)` | Elementary inclusion–exclusion after grouping sensors by code labels. **Application-level exact formula**, no general probabilistic novelty. |
| `sum_c exp(W_c)` minimized over class assignments | Special case of published convex **Workload Partition Problem**. |
| NP-completeness from 3-PARTITION in cyclic inversion-orbit codes | **Specific group-code reduction**, closely parallel to 2010 reliability-hardness arguments; general hardness phenomenon preexisting. |
| Dynamic program for q=2 and exact distance/reliability Pareto frontier | Classical cardinality-weight subset-sum DP applied to these two code metrics. |
| Exchangeably correlated erasure balancing | Classical majorization and conditional-uniform-subset arguments; specialized coding statement may be useful, global novelty **unverified**. |
| Translated-involution group-code identity joining all these | **Potentially distinctive synthesis**, with no exact-match paper found in this targeted search. Absence of a match does **not** establish priority. |

## Scope, validity and recommended publication language

- **Mathematical:** Written elementary proofs and exact finite checks continue to support the statements under their declared model. No Lean/Coq kernel proof was produced.
- **Historical:** The 2006, 2010, and 2017 papers preempt any claim that weighted convex allocation, variable-bin NP-hardness, or the PARTITION-based algorithm are new general discoveries.
- **Appropriate claim:** “An exact, reproducibly verified connection between translated involution-orbit codes and established convex workload-partition/reliability theory, with a joint adversarial-distance and erasure-reliability design formulation.”
- **Avoid:** “New NP-completeness phenomenon,” “new convex load balancing theorem,” “first reliability-aware partition algorithm,” and broad “previously unknown complexity transition.”
- **Remaining priority test:** Search older group-action/fingerprint/orbit observation codes for the exact translated involution measurement model, two-distinct-label injectivity criterion, and joint error–erasure Pareto formulation. The current search establishes neither first publication nor an exact duplicate for this narrow combination.

**Audit sources:** The primary journal pages, the 2010 author's presentation, and the source-linked NIGHTFALL proof. Mathematical novelty is distinct from reproducibility, and this memo corrects the project's earlier promotional emphasis accordingly.
