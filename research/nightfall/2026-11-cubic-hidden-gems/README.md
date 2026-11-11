# Cubic hidden gems — reviewed research checkpoint

**Status:** working draft; internally checked finite examples, not independently refereed, not fully Lean-formalized, and not certified novel. The unrestricted cubic variance-squared influence inequality remains OPEN.

Research lead: Devin J. Wright / NIGHTFALL Constellation. Date: 11 November 2026 UTC.

[Complete proof note](PROOF_NOTE.md) documents:

1. Optimal independent one-leaf coloring for every degree d: alpha_d = 1 - d^(-1/(d-1)). For d=3, alpha_3 = 1-1/sqrt(3), improving the previous 3/8 and reducing the selector transfer factor from 48 to 27+9sqrt(3).
2. Influence-weighted and exact-energy cubic hitting-set certificates. Allows growing cover cardinality when covered influence is small. The connected cyclic example has repeated pairs and cover number >=k, while total cover influence is B sqrt(M)/sqrt(2).
3. Dimension-free l1-valued quadratic influence and **log-free fair-sign/rank-one-leaf cubic selector** inequalities, conditional on the original quadratic matching proof. This covers dense control interaction patterns, including arbitrarily biased leaf features, without an alphabet-size factor.

4. [Two-draw scalarization obstruction](AUDIT_TWO_DRAW_MAX.md): an exact bounded degree-two family saturates exponent two, yet the expected maximum control influence after leaf-pair scalarization is unbounded relative to the original maximum. This falsifies a natural expectation/max interchange, not the cubic conjecture.

5. **Bounded shared-control theorem:** for additive leaves with t controls and no leaf-rank/moment restriction, V <= B sqrt(M)+t M. In the two-control cubic case, M >= V^2/(9B^2); full proof is in [Operator D](PROOF_NOTE.md#operator-d-bounded-shared-controls-arbitrary-high-rank-leaf-sections-exact-strengthening).

6. **Rank-sensitive adaptive observation:** after reading t shared controls, the projected Hilbert-valued leaf system is additive. The sharp additive budget gives error <= tau_r+eta after at most t+max(1,ceil(B^2/(4 a_r^2 eta))) queries, with a_r=Gamma(r/2)/(sqrt(pi)Gamma((r+1)/2)). This remains a compositional analytic theorem under review.

**Not claimed:** universal cubic exponent two, leaf-Hilbert sections of unrestricted rank, global priority, or complete machine checking.

## Exact finite replay

From the repository root:

```bash
python3 -I research/nightfall/2026-11-cubic-hidden-gems/check_exact.py
python3 -I research/nightfall/2026-11-cubic-hidden-gems/verify_l1_quadratic.py
python3 -I research/nightfall/2026-11-cubic-hidden-gems/verify_bounded_controls.py
python3 -I research/nightfall/2026-11-cubic-hidden-gems/attack_two_draw_max.py
```

CI: [NIGHTFALL cubic hidden-gems exact replay](../../../.github/workflows/nightfall-cubic-hidden-gems.yml). It records SHA-256 hashes of checked branch files in an Actions artifact. The source research archive `NIGHTFALL_Cubic_Hidden_Gems_v1.zip` had SHA-256 `5d7c8dd0870dfdbe83f3fcdd7fe627f7b15f87d6c4eb29fb4c6c95a28451ecf5`. The scripts committed here preserve the tests but condense comments, so their hashes need not match that archive's individual manifest.

## Related proofs and precedent

- [Quadratic spectral observability and cubic frontier](../2026-11-spectral-observability/README.md) — imported quadratic theorem, not kernel-complete.
- [PR #335](https://github.com/d3lefts/d3lefts/pull/335) — cubic top-degree covers and disjoint sunflowers; complementary to dense-control selector families.
- [PR #336](https://github.com/d3lefts/d3lefts/pull/336) — Lean-checked **sublemmas only**, not end-to-end cubic influence.
- O'Donnell and Zhao, *Polynomial Bounds for Decoupling, with Applications*, CCC 2016: https://doi.org/10.4230/LIPIcs.CCC.2016.24. Earlier one-block decoupling must receive priority credit.
- Turturean, *A proof of the Aaronson–Ambainis conjecture*, submitted 6 Nov 2026: https://arxiv.org/abs/2611.09773.

**Next decisive theorem:** an alphabet-independent bound for generalized degree-two selectors with arbitrary Hilbert-valued leaf sections, or an explicit counterexample to that assertion.
