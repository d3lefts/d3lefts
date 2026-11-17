# Proof Passport — DQ2 dependent residual-degree structural transition

**Passport ID:** NF-DQ2-RIGIDITY-MIXTURE-20261117-v0.1
**Draft PR:** https://github.com/d3lefts/d3lefts/pull/785
**Certification status:** AUTHOR-SIDE EXACT ALGEBRA + SOURCE-HEAD GITHUB CI; **not Lean-kernel verified, externally audited, or novelty-cleared**.

## Claims and gates

| ID | Claim | Evidence | Gate |
|---|---|---|---|
| DQ2-R1 | Exact 4-site Ising residual-word rank 15 for all 0<|r|<1 | 15x15 explicit determinant polynomial; 73-point exact interpolation; independent joint-law rational replay | Exact-algebra checker PASS; Lean pending |
| DQ2-R2 | Generic residual-degree collapse for positive binary laws, any finite n>=4 | Nonzero minor + algebraic nonvanishing + four-coordinate fiber conditioning | Analytic proof; external review pending |
| DQ2-R3 | Rigidity for *all finite* 1D Ising chain lengths n>=4 and all nonzero | Four boundary minors with 439 total exact determinant evaluations; full-support four-block conditioning | Exact-algebra PASS; Lean pending |
| DQ2-R4 | Rigidity for stationary countably infinite 1D Markov chain | Finite four-boundary lemma; conditional disintegration; Markov eigenvalue r, tail-triviality | Analytic corollary, measure-theory audit pending |
| DQ2-M1 | m-component product-mixture variance-minus-latent-variance Q2 bound | Total variance + product C2 + variational influence comparison; finite Fraction replay | Analytic corollary, Lean pending |
| DQ2-M2 | Linear m factor necessary even for full-support mixtures | Noisy duplicated labels, selector f=Y_{L1}, exact ratio m; m=2..5 | Rational spot checks PASS; symbolic argument; Lean pending |
| DQ2-M3 | Latent variance term necessary | Two hidden-biased product regimes; mean of n spins, influence ≤1/n² and variance tends to a² | Analytic counterexample |

## Reproduction (no external Python packages)

```bash
python3 scripts/check_dependent_degree_collapse_exact.py
python3 scripts/check_ising_chain_boundary_rigidity_exact.py
python3 scripts/check_latent_regime_count_sharp.py
python3 scripts/check_latent_mixture_q2_exact.py
```

**Source Git blob IDs** (as retrieved from draft branch):
- `check_dependent_degree_collapse_exact.py`: `845db5c2fd6dc6c6dbac48c18ba8f0480dd232fc`
- `check_ising_chain_boundary_rigidity_exact.py`: `d2feff9d3f0a30783581075bf49e38ce6b6cb64f`
- `check_latent_regime_count_sharp.py`: `5ae88000acf7062ebc56c49e53219f252e61987d`
- `check_latent_mixture_q2_exact.py`: `f7cbdaa084f77871f0d8cdfd9b77c974e96e70bd`

**GitHub Actions exact-head PASS prior to passport addition:** `a7d8ffc36f36cf7c9dd581881aa28be2ede15475`, run https://github.com/d3lefts/d3lefts/actions/runs/44185427284 . This is a reproducible source checker success, **not** a Lean or peer-review receipt. On any later source revision, the current-head CI gate must be rechecked.

## Novelty, scope and transfer

**Novelty unresolved.** Check dependent Hoeffding/oblique projections (Il Idrissi et al., 2025; Chastaing et al., 2012), noncommuting conditional expectations, finite-fiber tensorization, classical mixture inequalities. Product C2 is a dependency on previously compiled NIGHTFALL original-source work; PR #776 is a separate integration gate. No best-constant claim.

**Failure diagnosed:** ordered heat-bath residual words are not an interaction-degree grading under dependent laws; the degree-two nullspace is generically trivial.

**Reusable mechanism:** algebraic rank certificate for noncommuting operator words + conditional four-fiber lifting + latent-variance decomposition. Apply to correlated sensors, hierarchical sources and recertification where shared hidden state can masquerade as distributed evidence.

**Next decisive task:** independent mathematical reproduction of one boundary determinant from the true joint law, then Lean proof of four-spin determinant nonvanishing, then a new nontrivial dependence-adapted degree operator based on oblique/latent components. Do not merge or claim landmark priority before these gates.
