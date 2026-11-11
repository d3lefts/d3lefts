# Dated prior-art comparison for the universal observability proof chain

**Checked:** 11 November 2026. **Status:** Targeted primary-source comparison, **not** a comprehensive historical priority certificate. Review the current literature again immediately before publication.

## The direct base, not a NIGHTFALL discovery

1. **S. Aaronson and A. Ambainis (2014), The Need for Structure in Quantum Speedups**, Theory of Computing 10 (2014): the low-degree influential-variable conjecture and its classical query consequence on the *uniform Boolean cube*. https://www.theoryofcomputing.org/articles/v010a006/
2. **David Turturean (6 November 2026), A proof of the Aaronson–Ambainis conjecture**, arXiv:2611.09773: proves an influence lower bound proportional to \(\mathrm{Var}(f)^{5/2}/d^6\) for bounded real polynomials under the *uniform cube* law; a Lean 4 formalization is public at https://github.com/physical-superintelligence/aaronson-ambainis. NIGHTFALL imports his Boolean-cube antipodal/level and certificate mechanisms, and its finite general-product formalization is separately pinned with a **weaker coefficient**.
3. **G. Blanc, J. Docter, C. Strassle and L.-Y. Tan (8 November 2026)**, arXiv:2611.11626: exposition and Boolean query consequences of Turturean's solution. It explicitly credits him.
4. **T. Huffstutler, D. Miloschewsky and S. Podder (9 November 2026)**, arXiv:2611.12795: a completion-framework proof and deterministic query consequences in the partial Boolean-function/cube setting, also directly relevant when evaluating the proposed adaptive-query result.

## Adjacent product-probability precedent

5. **G. Grimmett, S. Janson and J. Norris, Influence in product spaces**, Advances in Applied Probability 48A (2016), 145–152, DOI 10.1017/apr.2016.46: influence/threshold comparisons valid over general product spaces. Its event/sharp-threshold formulations are adjacent; this check did not establish that it implies or reproduces the specific *bounded low-Hoeffding-degree variance-power* inequality or the Hilbert spectral prediction budget. Any equivalence requires an explicit normalization/assumption reduction.
6. **Classical Hoeffding–Efron–Stein decomposition**: orthogonal ANOVA expansion, resampling influence identities, and energy bounds are classical foundations. The identity \(\mathbb E_{X_i}T(f_{X_i})=T(f)-I_i(f)\) is not represented as globally original merely because it is instantiated in the new chain.

## Scope comparison and unresolved novelty questions

| Theorem under discussion | What is inherited | What is **proposed** beyond the cited result | Required priority check |
| --- | --- | --- | --- |
| Finite heterogeneous-product influence | Turturean cube theorem/level method | Arbitrary finite coordinate probability masses, zero atoms, general finite alphabets, resampling normalization | Compare against pre-existing biased-cube/product extension work |
| Finite-to-arbitrary independent-product lift | Finite scalar inequality and classical conditional expectations | An explicit law-free analytic extension preserving the quantitative constant | Check earlier finite-partition/martingale transfer lemmas; likely standard technique |
| Hilbert sign-mgf compression | Gaussian quadratic moments and Rademacher sign tools | Rank-dependent trace influence bound with explicit logarithmic factor | Check vector-valued influence and adaptive Hilbert query literature |
| Adaptive spectral observation | Efron–Stein identity, classical greedy influence descent, fixed spectral projection | Formula \(\lceil(40/3)U\log(1+4U)\rceil\) independent of input dimension and atom masses | Match query model, known laws, rank/tail definition, accuracy and constructive/runtime demands |
| Abstract exponent-transfer operator | All of the above analytic ingredients | One reusable \(q>1\) finite-scalar-to-Hilbert-adaptive implication | Check whether this is already a standard folklore implication before originality claims |

No dated source examined here was verified to state exactly the same complete arbitrary-law Hilbert result with this coefficient and query model. **That is not evidence of global novelty**, only a bounded search outcome. A mathematical specialist must inspect additional literature and reductions before a new-contribution claim is approved.

**Provenance rule:** never conflate uniform-cube flip influence with conditional-variance resampling influence without writing the conversion, or interpret a successful Lean compile of the finite scalar base as proof of the complete adaptive theorem.
