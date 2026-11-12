# Quadratic Influence and Rank-Optimal Observation on Arbitrary Product Spaces

**Author** Devin J. Wright · NIGHTFALL Research Program · independent mathematical draft v1.0, 12 November 2026.

**Main paper:** `Quadratic_Influence_and_Rank_Optimal_Observation.pdf` (17 pages) and fully self-contained editable LaTeX source `Quadratic_Influence_and_Rank_Optimal_Observation.tex`.

## Principal analytic statements

1. **Quadratic influence:** For any independent product source and bounded scalar input-degree-two f, `max_i I_i(f) >= Var(f)^2 / (C2 B^2)` where `C2=(10+2sqrt(2))^2 (1+sqrt(3))^2`.
2. **Sharp variance exponent:** Disjoint signed pairs give `Var=1/m` and maximal influence `1/m^2`.
3. **Rank-r Hilbert transfer:** `V(G)^2 <= 3*C2*r*B^2*max_i I_i(G)`.
4. **Adaptive prediction:** Risk <= covariance tail `tau_r` + target error `eta` after at most `min(n,ceil(12*C2*r*B^2/eta))` whole-symbol observations. Scalar case improves factor 12 to 4.
5. **Spectral oracle bound:** `R_q <= inf_r[tau_r+12*C2*r*B^2/q]` for integer `q>=1`.
6. **Unbounded adaptivity advantage:** f(A,Z)=Z_A, two adaptive queries exact; nonadaptive fixed set requires >m/2 observations for risk <1/2.
7. **Separate quantum application:** one-query probability vectors; locally encoded qubit/qudit registers have terminal noisy visibility `max Delta_i(t)>=t^4*a^2*Var(f)^2/(2*C2*B^2)` under stated full local SLD Gram conditions. The binary-source bound removes the extra 2.

## Provenance and negative assertions

The quadratic matching, boundedness budgets, fourth-moment and posterior-energy proofs are fully written in the manuscript; none invokes Turturean's all-degree theorem or Lean development. The article cites that work solely as relevant prior art. It reworks and extends NIGHTFALL v9.2 while removing the all-degree/Turturean-based theorem chain.

Not Lean-kernel-certified, independently refereed, globally priority-cleared, submitted, or guaranteed efficiently computable. The quantum physical observation contract is distinct from classical whole-symbol queries. Some antecedent mathematical ingredients (Hoeffding decomposition, Efron-Stein influences, decision-tree inequalities, and Grothendieck methods) are established background; scope-matched originality requires independent literature review.

## Reproduction

Requires `pdflatex` (TeX Live) for the paper and Python 3 standard library for the finite checker.

```bash
pdflatex -interaction=nonstopmode -halt-on-error Quadratic_Influence_and_Rank_Optimal_Observation.tex
pdflatex -interaction=nonstopmode -halt-on-error Quadratic_Influence_and_Rank_Optimal_Observation.tex
python3 -I check_quadratic_models.py
```

The script enumerates 16 heterogeneous finite-product models (n=3 or 4, mixed 2/3-symbol alphabets, rational unequal marginals), computes Hoeffding energies and resampling influences exactly, checks every disjoint interaction matching and every finite transcript's posterior drift, and validates sharpness and addressing examples. The precise universal constant is enclosed above by the rational 1229 for script's inequality check; the paper uses the smaller exact C2. Passing the checker is finite falsification evidence only.

`SHA256SUMS.txt` records the immutable source/checker/PDF digests.
