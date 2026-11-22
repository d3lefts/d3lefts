# NIGHTFALL flagship execution checkpoint — 2026-11-22

**Research gate:** provisional universal lower-bound proof candidate.
Do **not** equate this with an independently verified mathematical theorem,
novel result, a Lean certificate, or a publication-ready contribution.

The claim in [PROOF_PASSPORT.md](PROOF_PASSPORT.md) is much stronger than
the initial six-versus-seven numerical experiment: it proposes
\(m_{\rm cont}(n)=2n-1\) for every \(n\ge2\), even when the
measurement row is adapted continuously at *every* reading.
If correct, \(m_{\rm cont}(4)=7\). The proof uses a two-colour virtual
history and the nonvanishing top Stiefel–Whitney class of a direct sum
of pullback tautological bundles on a product of projective spaces.

## Minimal reproduction

From this directory:

    python3 verify_parity_exact.py

Expected: 120 exact rational parity cases pass in dimensions 2–6.
No third-party dependencies. This confirms only *finite algebraic
identities*.

Optional numeric stress (requires NumPy, SciPy):

    python3 phase_collision_probe.py

Seed 20261122; \(n=4,m=6\), genuinely prior-history-dependent bounded
rows, direct transcript collision tolerance <1e-8. A tested local
run produced approximately 1.53e-16 discrepancy. Numeric candidate
exists only as an illustration; the all-policy theorem depends on the
topological zero lemma.

## Subagent division — independent by design

**A / mathematical construction:** Re-derive all-policy proof from
scratch without relying on the passport's intermediate conclusions.
Seek simpler elementary equivalent of product-sphere zero theorem.
Prove the collision pair satisfies \(x\ne\pm y\) even on zero strata.

**B / adversarial topology:** Independently audit \(G=(Z/2)^2\)
representation, quotient \(B=RP^{n-1}\times RP^{n-1}\),
associated bundle \(rL_U\oplus sL_V\), and
\(w_{r+s}=\alpha^r\beta^s\). Find any flaw in degree/rank/action.
Try to construct a nowhere-zero equivariant map as counterexample.

**C / causal-model auditor:** Attack the reachable-only-history
assumption. Investigate nonclosed full history images, restriction
to radius-two ball, Tietze extension, projection to unit ball,
and agreement of the extended and actual protocols on the ball.
Explicitly audit arbitrary continuous policies from stage two onward.

**D / independent computation:** Replay the Python tests;
build a separate implementation with a different row family, and
check the original measurements directly for computed collision pairs.
Search for any numerical disagreement that falsifies the proposed
induction. Avoid treating numerical success as theorem certification.

**E / prior art:** Date-pin source statements of classical fixed
phase retrieval and product-sphere Borsuk–Ulam, read Ullrich
arXiv:2610.33781, and search specifically for continuity of causal
ROW SELECTION versus continuity of individual measurement functionals.
Report overlap, stronger earlier theorem, or independent novelty.
Use precise citations.

**F / Lean integration:** Prefer two kernel theorem layers:
(1) a separate-sign-equivariant product-sphere zero theorem (may need
mathlib topology infrastructure), and (2) virtual-history and collision
induction plus compact extension. Do not use a topological axiom or
a sorry disguised as a theorem. Log toolchain and axioms.

## Gates and thresholds

- **Strong counterexample:** one valid continuous causal six-reading
  \(\mathbb R^4\) protocol with universal sign recovery (including
  support boundaries) falsifies the theorem candidate.
- **Proof failure:** counterexample to the product-BU representation
  lemma, a failed continuity bridge, or a parity/induction gap.
- **Independent mathematical acceptance:** reviewer B and C reproduce
  the argument independently, with any gaps closed.
- **Formal acceptance:** Lean kernel checks the end-to-end statement
  with source-exact CI and an ordinary axioms report.
- **Novelty:** dated specialist literature audit; no auto-promotion
  from mathematical validity.
- **Stop rule:** no more generic numerical parameter tuning; advance
  proof review, exact-model comparison, and formalization first.

## Credit and collaboration

Baseline Lean work: [PR #695](https://github.com/d3lefts/d3lefts/pull/695)
and [PR #699](https://github.com/d3lefts/d3lefts/pull/699).
Topological operator: classical Stiefel–Whitney and
product-sphere equivariant Borsuk–Ulam methods, not invented anew.
No claim of external peer review, scholarly priority, or a proof
beyond the explicitly specified assumptions is made here.
