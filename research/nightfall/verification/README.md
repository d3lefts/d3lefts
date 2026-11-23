# NIGHTFALL eight headline trust boundaries — 2026-11-23

**Version:** 1, new implementation. **Status:** source- and scope-level gates proposed in this PR, kernel resource smoke pending CI. This is neither retrospective independent review nor a promotion of any of the eight discovery claims.

## Four adoption priorities

1. **Externally frozen specification / broader comparison.** The current `external_lean_comparator.py` freezes theorem contracts against an owner-controlled `main` snapshot. `check_headline_trust.py` adds a source-byte-bound eight-paper registry and rejects all unauthorized status promotions. `check_headline_import_closure.py` conservatively resolves local import-header dependencies, including all same-basename ambiguities, and fails if a PR changes any part of an eight-paper closure or compiler lock without new review. *Known limit:* these are byte-level guards, **not** Google's transitive-definition Lean Comparator, and cannot establish the semantic correctness of unchanged Lean statements.
2. **Resource-aware formal contracts.** `FiniteQueryCost.lean` defines expected and syntactic worst-case query charges for a finite decision tree; its exact-type contract checks a two-stage example under the pinned Lean bridge. `check_finite_query_cost.py` independently computes rational expected cost, worst-case cost, and terminal branch mass (including zero-probability branches). The example has expected cost **3/2** and syntactic worst cost **2**. This is a resource accounting theorem for a supplied tree only, not a proof of a quantum algorithm, its oracle semantics, correct branch distributions or termination for an unbounded loop.
3. **Adversarial agent collaboration.** `HEADLINE_REVIEW_PREREG_V1.json` fixes a prediction, alternative explanation, cheapest decisive test, and falsifying outcome for each paper; construction, separate reproducer, attacker and synthesis roles are proposed, **not recorded as executed independent reviews**. `check_headline_review_plan.py` rejects retroactive claims of completion.
4. **Measured effectiveness.** CI executes planted negative controls and `measure_headline_gate_preflight.py` writes an inspectable per-run test count/error count and wall-time. This is **synthetic tool testing**, not a randomized A/B trial of actual agents, fewer certification mistakes in practice, or causal scientific productivity gains.

## Eight publication tracks — exact boundary

| Headline | Bound source declaration | Key remaining mathematical/semantic gate |
| --- | --- | --- |
| Quadratic variance–influence | `InfinitePiQ2NativeHeterogeneousTerminal.native_heterogeneous_q2_105416_unconditional` | Finite product cannot silently become arbitrary-index measurable source |
| All-degree influence | `InfinitePiAAProductTerminal.infinitePi_aa_product` | Imported AA/Turturean dependencies, actual L²/degree assumptions and independent statement comparison |
| Route 1 / Wyner simulation | `Route1Polylog.route1_polylog_simulation` | Mixture source/oracle semantics, query-locality and any subsequent physical quantum or quadratic-Wyner transfer |
| Hilbert observability | `HilbertRankCore.rank_linear_5043_from_spherical` | Actual posterior/source section-to-rank-budget and adaptive query theorem |
| Task-revelation information cover | `InformationCover.reciprocal_KL_cover_weak_duality` | Adaptive stochastic KL/Bayes-risk/sequential-cost chain |
| Continuous-causal phase retrieval | `ContinuousPhaseObstruction.no_continuous_final_row_all_dimensions` | Arbitrary continuous causal prefixes, reachable histories, unconditional product-sphere zero theorem |
| Tensor-subcube exponent | `SubcubeSharpAllLevels.all_levels_sharp`, plus `SubcubeSharpness.full_space_extremizer` | Scope of linear subspaces versus affine/rank-free physical quantum simulation |
| Optimal physical quantum POVM | `ComplexPOVM.complex_povm_energy_optimal` | PSD normalization, physical model assumptions, arbitrary-dimensional and imported-terminal boundaries |

All paths, exact Git blob SHA-1 identities, citation PRs, and unsatisfied evidence gates live in `HEADLINE_TRUST_BOUNDARIES_V1.json`. The prior historical source ledgers and old proof passports are deliberately **not edited**. Historical kernel receipts retain their historical scope; no CI pass in this change upgrades them.

## Reviewer and contributor contract

- **Axiom:** construction hypothesis and alternate representation, own artifact/source digest.
- **Ryev:** independent code/finite model from mathematical specification without receiving construction checker implementation.
- **Lemnis:** proof attack and counterexample design, separate source/checker lineage, independent assumptions audit.
- **Vesper:** reconcile scope, prior art, false confidence and dependency status; independent evidence receipts required, not model agreement.
- **Owner:** approve any claimed general theorem, release, special trusted contract update or external priority claim.

These are future role proposals; originality of an existing theorem is attributed to the original authors and records, not reassigned by this document. A role label, repeated execution of one checker, or two jobs on separate machines **does not** establish independence. Conflict-of-interest screening is required before assigning reviews.

## Measurable live A/B proposal — not executed

Pre-register two groups on the **same fixed set of theorem updates**: existing scoped Lean receipt checking versus the new owner-frozen specification + closure + review contract. Freeze case allocation, budgets and evaluation rubric before agent outputs. Record raw source bytes, referee blind grades, forged/mismatched claim acceptance, wall-time from receipt start to decisive outcome, CI compute minutes, and false-rejection counts. Compare paired errors on *identical specifications*, count unresolved reports as unresolved (not successes), preserve failed revisions and test whether reviewer leakage occurred. A synthetic CI mutation pass is a prerequisite, **not** proof this workflow reduces real certification mistakes. Do not calculate claimed A/B gains without real independent trials.

## Freeze and promotion states

- In the initial bootstrap PR, there is no existing `main` ledger or new cost contract. CI marks that exception explicitly. Only an owner-reviewed merge establishes the reference boundary for future candidate PRs.
- After bootstrap, a candidate PR cannot silently alter the eight frozen claim identities, anchored source bytes, or exact cost theorem contract relative to `origin/main`; changed local imports/toolchain fail closure guard. An intentional rebaseline requires a new version, owner approval and fresh same-pin kernel evidence, not a bypass variable or an override embedded in an agent PR.
- Header import resolution can include false-positive ambiguous basenames and cannot inspect semantic dependencies hidden in generated code, plugins, macros or external Mathlib imports. The external compiler/source pins and full kernel replay remain separate requirements. No direct transitive-definition semantic audit is asserted.
- The `--trusted-ref origin/main` mechanism is secure **only if** branch protection, required checks, runner and workflow policy are owner-controlled. Authors able to modify and merge those controls can defeat the gate.
- A frozen theorem can still formalize the wrong physical model. Separately inspect all quantified assumptions, resource charges, source distributions, computation termination and observational oracle interfaces.
- **No automatic promotion:** required steps are accepted frozen statement, exact-source closure & pinned toolchain, actual Lean kernel declaration and axiom replay, independently reconstructed mathematical/physical model, dated prior art, owner signoff.

## Quick replay

```sh
python3 tests/test_headline_trust_and_cost.py
python3 tests/test_headline_import_closure.py
python3 tests/test_headline_review_plan.py
python3 scripts/check_headline_trust.py --trusted-ref origin/main
python3 scripts/check_headline_import_closure.py --trusted-ref origin/main
python3 scripts/check_headline_review_plan.py
python3 scripts/check_finite_query_cost.py research/nightfall/verification/route1_finite_cost_smoke.json
python3 scripts/measure_headline_gate_preflight.py --json-out lean-receipts/headline-synthetic-preflight.json
```

Actual Lean CI runs `scripts/lean_bridge.py --strict` with both named finite query-cost theorems and source-pinned exact-type contract, and uploads machine-readable receipts.

## Related research, credit, and limits

Google DeepMind/Google Quantum AI, *Discovering formally verified quantum programs with AI*, arXiv:2611.09822v3 (2026-11-16), https://arxiv.org/abs/2611.09822; source library https://github.com/google-deepmind/formal-quantum-computation (Apache 2.0). Their reported approach uses a separate Lean Comparator matching transitive definitions and proof statements to frozen specifications, with standard-axiom checks, quantum Hoare logic, branch-weighted expected resource semantics and multi-team shared coordination. **Nothing here imports their Comparator or claims their quantum performance gains as NIGHTFALL's.**

Transferred exploratory operators for future experiments (not results in this PR): Fourier/real-space Hamiltonian representation, Pauli/antisymmetry-aware simplification, Bernstein polynomial approximations, measurement-based uncomputation, one-hot quantum memory substitution, and adaptive oracle query grouping. Each needs a fixed target model, valid oracle charges, independent reproducer and falsifiable decision criterion before it can become a mathematical finding.

Next execution ledger: [#1172](https://github.com/d3lefts/d3lefts/issues/1172).
