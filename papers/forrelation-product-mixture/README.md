# Gaussian-sign Forrelation — companion working paper (19 Nov 2026)

**PUBLIC WORKING PAPER — not peer reviewed, not submitted to arXiv, and not a fully Lean-certified Gaussian theorem.**

Canonical public manuscript: [FORRELATION_COMPANION_WORKING_PAPER_20261119.md](FORRELATION_COMPANION_WORKING_PAPER_20261119.md).

## Exact constants and interpretation

| Certificate | Model | Lower bound on log component count |
|---|---|---|
| Sub-Gaussian / Gibbs | Exact independent F/G block mixture | 2N/pi² = 0.202642367285 N |
| Binary conditional entropy | Exact independent F/G block mixture | N phi(2/pi) = 0.219200546826 N |
| Uniform-marginal maximum atom | Exact 2N-coordinate product mixture | (2 log 2/pi) N = 0.441271200305 N |
| TV continuity, eta=1% | Approximate independent F/G block mixture | 0.205337603215 N - 0.112003068710 |

phi(t) = ((1+t)log(1+t)+(1-t)log(1-t))/2. The 0.2192 and 0.2026 constants are valid different lower bounds, not inconsistent estimates. The exact 0.44127 result assumes full coordinate-product components, whereas the robust 0.20534 result applies to the larger class of two-block-product mixtures. Do not claim 0.44127 for positive TV tolerance without a new proof.

## Reproducible finite checks

Run: python3 papers/forrelation-product-mixture/check_companion.py

The checker validates the constants, exact eight-sector N=2 sign law, rank-4 coordinate-product cover, identity-matrix equality case and 6700 rational small conditional-entropy instances. These are falsification checks, not a general proof. CI records the tested source SHA.

## Certification and priority custody

- Mathematical source: Aaronson–Ambainis Gaussian-sign Forrelation; classical Grothendieck sign-correlation identity.
- Reviewer-origin exponential obstruction: discussion of PR #858.
- Binary-entropy, robust TV and finite checks: PR #868.
- Generic two-block information-source Lean: PR #869.
- Conditional exponent terminal Lean: PR #871.
- UNPROVED in Lean: full Gaussian sign law, sign identity, orthogonal-matrix specialization, sharpened binary-entropy and maximum-atom theorems.
- Novelty and authorship review: OPEN. Common-information, nonnegative-rank and exponential mixture lower bounds predate this specialization.

The public repository working paper responds to an explicit request to publish a companion paper. It is not represented as a journal/arXiv submission or independent human review.
