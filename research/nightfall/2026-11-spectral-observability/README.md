# Spectral Observability of Low-Interaction Systems

Research lead: Devin J. Wright / NIGHTFALL Constellation.
Checkpoint: 10 November 2026 US Eastern; v3 dated 11 November UTC.
Status: technical research synthesis; internal exact replay only; external proof review and novelty verification outstanding.

## Theorem inventory (as stated in supplied v3)

- Quadratic scalar influence on arbitrary independent alphabets: Var(f) <= 16(1+sqrt(3)) B sqrt(max_i I_i(f)), with |f| <= B.
- Quadratic Hilbert adaptive prediction: covariance-tail error tau_r plus eta after at most ceil(4 D^2 B^2/(a_r^2 eta)) coordinate queries, D = 16(1+sqrt(3)), a_r = Gamma(r/2)/(sqrt(pi) Gamma((r+1)/2)). Matching minimax order Theta(r/eta) for unit-ball rank-r outputs.
- Finite-alphabet nonadaptive prediction: fixed interaction degree d, at most m symbols per coordinate; C(d,m) = 2 d^2 3^(d-1) T_(d-1)(sqrt(m+1)); fixed q-query risk <= tau_r + C(d,m)^2 B^2/(4 a_r^2 q). Matching minimax order Theta_d(r m^(d-1)/eta).
- Degree three: top-degree matching, explicit four-bit pair-matching obstruction, sufficient fourth-moment certificate, and a logarithmic-loss influence bound for signed quadratic selector families. The general alphabet-free cubic inequality is OPEN.
- Conditional all-degree random-sign Hilbert transfer: relies on an unreviewed scalar law-independent premise and is not an unconditional theorem.

## New v4 iteration

[SELECTOR_LIFT_V4.md](SELECTOR_LIFT_V4.md) proves a reusable exponent-alpha selector-lifting lemma and tightens the selector logarithm from log(e+3 B^2/M) to log(e+2 B^2/M) by using the true degree-two selector influence budget.

[selector_pair_symbolic.py](selector_pair_symbolic.py) independently checks the exact four-bit degree-three ANOVA polynomial identities and finds a scope error in v3: pair-matching mass is 8(1-p)max(p,1-p)^2 for every 0<p<1, whereas v3's 8(1-p)^3 formula applies only for 0<p<=1/2.

[REVIEW_GATES.md](REVIEW_GATES.md) records the updated November 2026 literature, review limits, and decisive next step.

## Provenance and replay

Supplied v3 PDF SHA-256: 6b4a7420f15ff9d9b72d16b2f9d8362d2f41f35fa537030496606ad0cc22c5a6
Supplied v3 source ZIP SHA-256: 09a980b8f2a39b54352c94211822538ff9943b4163ef80d793049164c3921742
v4 exact checker SHA-256: b96e59d54cc6f425e7676d3d94dac61c52220eea8c81f837268cc3507eb4be7a

Original ZIP contains main.tex, matching-core.tex, categorical.tex, degree3.tex, measure.tex, queries.tex, accompanying checks, and SHA256SUMS. The original source ZIP and PDF are user-supplied inputs; they are NOT mirrored by these curated GitHub text files.

Local replay on the supplied original: SHA256SUMS passed; matching-audit.py, finitealphabet-audit.py, synthesis-audit.py, degree3-audit.py passed. The new independent symbolic checker passed. These checks do not formalize the full analytic claims and are not peer review.

Run the committed new check:

    python3 -I research/nightfall/2026-11-spectral-observability/selector_pair_symbolic.py

## Operator lineage

Quadratic matching -> law-independent scalar degree-two influence -> Hilbert rank-adaptive query theorem.

Signed categorical moment proxy -> root-sum influence -> finite-alphabet nonadaptive query theorem.

Quadratic scalar bound -> random-sign selector lift -> logarithmic restricted degree-three theorem.

Cubic hypergraph matching plus pair/link fourth moments -> OPEN universal degree-three certificate.

Unreviewed scalar arbitrary-product general-degree premise -> CONDITIONAL higher-degree Hilbert observation.

Do not promote this material into the externally certified or globally original category without separate review.

## Subsequent cubic research operators (11 November, under review)

The [cubic hidden-gems proof checkpoint](../2026-11-cubic-hidden-gems/README.md) establishes an optimized one-leaf projection reduction, influence-weighted top-degree covers, and a log-free bound for fair-sign/rank-one-leaf quadratic selector families, all as **analytic deductions under review**. These do not discharge the unrestricted cubic arbitrary-alphabet exponent-two theorem. The earlier logarithmic-loss selector theorem remains the statement documented in the original v4 source; it is superseded only for the narrower verified selector hypotheses. The exact-check CI validates finite instances, not the general proofs.
