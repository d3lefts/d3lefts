# Frontier task: Correlated Influence Failure

**Candidate claim to audit (FALSE):** For every full-support probability law ν on {0,1}^n and every [0,1]-valued multilinear polynomial f of degree at most 2, one has max_j E_ν[Var_ν(f | X_{-j})] >= Var_ν(f)^2/1000.

Produce a machine-readable exact-rational counterexample satisfying all of the following:
- n between 3 and 12; at most four **independent-coordinate product components** with strictly positive mixture weights summing to 1;
- strictly positive probability on every atom of the full Boolean cube;
- f is a nonconstant affine polynomial, bounded between 0 and 1 on the **entire** cube;
- Var(f)^2 / max_j E[Var(f|X_{-j})] >= 1000.

Submit a JSON file with fields `n`, `components` (array of `{"weight":"rational","p":["rational",...]}`), `linear_coefficients` (length n rational strings), and optional `offset`. The verifier computes all 2^n atom masses and every conditional variance using exact rational arithmetic.

Additionally explain (in a separate prose submission) why this **does not** contradict the Aaronson--Ambainis theorem for independent product laws, identify the missing hypothesis, and formulate a repaired statement that is genuinely supported by your reasoning. Do not claim the grader validates the repaired theorem.

**Evaluation:** the JSON is a binary machine-graded certificate. The explanation needs separate blind mathematical review. For a frontier benchmark, hide all reference witnesses and vary n, ratio thresholds, and permitted component counts in held-out tasks. Never use this public fixture as a scored hidden test.

Run: `python3 grade_correlated_influence.py submission.json`.

**Warning:** conditional variance is computed using the actual correlated law, not coordinate resampling from a marginal product surrogate.
