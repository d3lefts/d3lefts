# NIGHTFALL Q2 → Q3: retirement and proof-status ledger (2026-11-17)

**Disposition:** This autonomous research push is closed for reporting purposes. This is a preservation/triage record, **not** a claim that the unrestricted cubic Aaronson–Ambainis exponent-two theorem has been established. No external submission or human referee sign-off occurred.

## Stable checked dependencies already on main

1. **Unconditional infinite-product quadratic influence inequality**: merged [PR #776](https://github.com/d3lefts/d3lefts/pull/776), exact head `89d15c6ccb9caf255f4fec90e01bd6a1b7e6f15d`, [integrated run 44171646200](https://github.com/d3lefts/d3lefts/actions/runs/44171646200). `lake build Nightfall`, named standard-axiom audit, and `lake check` passed on that source head. The named terminal is `Nightfall.InfinitePiQ2UnconditionalTerminal.infinitePi_q2_105416_ae`; arbitrary index universe, a.e. L² bound, triple original-residual-zero hypothesis, original influences. Numeric coefficient ≈105.416. **Not yet named Lean-equivalent to the canonical closed ANOVA order-≤2 subspace**.
2. **Finite source cubic top-degree vertex-cover theorem**, merged [PR #787](https://github.com/d3lefts/d3lefts/pull/787) as `3fb165c4a35df8ea6ad5362c949d701be26b6de7`. Exact theorem head `b773d4771b8272cc2d0b7ce331b26f2e98437f64`, [integrated run 44206657422](https://github.com/d3lefts/d3lefts/actions/runs/44206657422): `lake build Nightfall`, strict named axioms, and `lake check` pass. For bounded degree-≤3 finite independent source with top-cubic vertex cover H and M=max coordinate influence,
   `Var(f) ≤ D B sqrt(M) + |H| M`,
   where `D = 2(1+sqrt(2))*sqrt(3) + 11901/6250`. The cubic result is **restricted by the cover H** and does not establish a uniform bound without it. The integrated `Nightfall/Main.lean` on main was inspected after merge and contains both the a.e. Q2 terminal and C105.416 Q3 cover checks.

## Independent exact finite research checkpoints merged as research, not theorems

3. **Two-replica fair-Walsh transfer and no-go:** [PR #799](https://github.com/d3lefts/d3lefts/pull/799) merged as `f6a495db98fd9cc4d2d7b3913f0308223dcdab91`. [Run 44215516377](https://github.com/d3lefts/d3lefts/actions/runs/44215516377) passed committed SHA-256 verification and two Python stdlib rational checkers. See [replica proof note](REPLICA_BERNSTEIN_TRANSFER.md), [binary checker](check_cubic_replicalift_exact.py), [heterogeneous categorical checker](check_cubic_replicalift_categorical.py) and [source hashes](SOURCE_SHA256SUMS). **Author-side derivation:** for a pure Efron–Stein cubic f and a quadratic fair-sign truncation Q built by independent coordinatewise two-copy selectors,
   - mean fair-sign variance of Q = (3/4) Var(f);
   - mean fair-sign coordinate influence of Q = (3/8) of source influence;
   - amplitude |Q| ≤ 5 B.
   For arbitrary degree≤3, retained expected variance ≥ (1/2)Var(f), expected Q-influence ≤(1/2) source influence, amplitude ≤5B. An unstructured exchange of `E[max_i I_i]` and `max_i E[I_i]` fails by an unbounded factor; generic annealed Q2 does not follow from standard Q2. No Lean kernel or external mathematical review of these claims.
4. **Exact fair-binary cubic routing obstruction:** [PR #797](https://github.com/d3lefts/d3lefts/pull/797) merged as `dcf391b4429a882b7526f9cb6e59c5c5b2dd280b`, [run 44212432185](https://github.com/d3lefts/d3lefts/actions/runs/44212432185) green. The eight-sign pure cubic in [proof note](../2026-11-12-cubic-overlap/FAIR_BINARY_ROUTING_OBSTRUCTION.md) has `||f||∞=1, Var(f)=1, max_i I_i(f)=1/2` and hence exact ratio `Var(f)^2/(B^2 M)=2`. Its 256-state direct influences, Walsh spectrum and fourth moments are checked by [stdlib checker](../2026-11-12-cubic-overlap/check_fair_binary_routing.py). This improves the *within-program explicit cubic lower-bound example*, and falsifies the specific coefficient-one spike-tail shortcut. It is **not** a counterexample to existence of some universal exponent-two constant, nor an externally validated record.

## Present mathematical frontier — OPEN

For any bounded degree-≤3 real f on arbitrary independent products, prove or refute existence of an absolute C such that
`Var(f)^2 ≤ C B^2 max_i I_i(f)` where `I_i = E Var(f|X_-i)`. No proof is known in this program at retirement.

The new **decisive proof obligation** is an *annealed quadratic inequality constrained to the source-consistent replica lift*. In an unstructured random environment the analogous inequality is false; selecting a random fair coordinate yields mean variance 1 but maximum mean influence 1/n. A valid argument must exploit source-consistent pairing / operator structure to charge environmental selection to the original coordinate influences. Separate known obstructions: shared-rare-core fourth-moment spikes ([PR #380](https://github.com/d3lefts/d3lefts/pull/380)) and balanced fair-binary routing spikes (#797). Counterexample searches do **not** prove impossibility of exponent two.

**Priority gate:** compare exact quantitative source/marginal scope against Turturean (Nov 2026), Huffstutler et al., Blanc et al., and Girish–Mittal–Nehoran–Raz (2026). Neither the repo nor an internal proof is evidence of worldwide originality.

**ANOVA gate:** finite canonical ANOVA ↔ mixed-third-difference Lean draft [#792](https://github.com/d3lefts/d3lefts/pull/792) remained pending exact-head integrated Lake CI when this ledger was written. The full infinite-product closed-Hoeffding-span equivalence is still not Lean proved. Other parallel dependent-law and operator branches are **not** declared complete by this retirement record.

## Retired redundant Q2 pull requests (closed, not merged)

Historical routes [#774](https://github.com/d3lefts/d3lefts/pull/774), [#773](https://github.com/d3lefts/d3lefts/pull/773), [#761](https://github.com/d3lefts/d3lefts/pull/761), [#743](https://github.com/d3lefts/d3lefts/pull/743), and [#741](https://github.com/d3lefts/d3lefts/pull/741) were closed **without deleting branches or source**. Their target integration is superseded by merged #776 and, for the label-source influence equality, merged #762; some historical lemmas are preserved as distinct approaches, not asserted to have been copied verbatim into #776.

## Certificate/passport boundaries

- Main includes the checked Q2 terminal and the finite top-cover Q3 terminal with exact-head kernel receipts.
- The replica reduction and routing witness are finite replay results/author-side mathematical constructions; CI checks examples, source digests and scripts, **not universal proofs**.
- Open PRs #792, #794, #800, #791 and dependent-law drafts need their own exact-head proof and review gates. No automatic merger, source promotion, or novelty upgrade follows from this ledger.
- No classical, dependent-law, infinite-product Q3, universal-degree, or quantum-corollary claims are inferred from the above partial results.

**Retirement stop rule:** preserve these results and do not accumulate further coefficient polishing or new branches without a mathematically decisive change in the source-consistent annealed inequality, a certified unrestricted cubic theorem, or a genuine counterexample to it.
