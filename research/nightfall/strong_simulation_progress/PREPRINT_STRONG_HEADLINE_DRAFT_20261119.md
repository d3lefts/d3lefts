# Classical Simulation of Quantum Queries over Latent Product Sources
## Strong bounded-round simulation: preprint revision candidate (2026-11-19)

> **Editorial status: PROVISIONAL / DO NOT CITE AS A CERTIFIED THEOREM.**
> This is preprint-ready replacement text, **not** a revised PDF and **not** a
> claim of external peer review or a Lean-certified simulation theorem.
> The previously certified polynomial-in-`1/δ` theorem for arbitrary bounded
> low-degree functions and arbitrary finite mixtures remains valid, retains
> its original theorem number, and must not be removed.
>
> Primary sources: BDST, *Quantum Speedups Require Structure or Depth*,
> arXiv:2608.19158 (uniform strong bounded-round simulation); Girish,
> Mittal, Nehoran, Raz, *Distributional Variants of the Aaronson–Ambainis
> Conjecture*, arXiv:2609.35327 (distributional gadget, biased source blocks).
> Author-side proof: [COMPONENT_IDENTIFICATION_20261119.md](COMPONENT_IDENTIFICATION_20261119.md).
> Independent audit and outstanding obligations:
> [INDEPENDENT_AUDIT_20261119.md](INDEPENDENT_AUDIT_20261119.md).
> Finite conditional combinatorics:
> `research/nightfall/formalization/product_space/ComponentIdentification.lean`,
> pinned Lean 4.36.0-rc2 CI run
> https://github.com/d3lefts/d3lefts/actions/runs/44487229739.

### Proposed revised title / leading finding

**Classical Simulation of Quantum Queries over Latent Product Sources:
Strong Bounded-Round Simulation and the Cost of Source Identification**

**Leading abstract (pending closure and review).** We investigate classical
simulation of quantum query acceptance probabilities when inputs are drawn from
known mixtures of independent product laws. Our general, Lean-checked baseline
provides polynomial inverse-failure bounds for arbitrary bounded low-degree
functions, including source laws with zero-probability atoms. We additionally
propose a stronger result for bounded-round quantum algorithms when every atom
of each product component has probability at least `c>0`: for a mixture of
`M` components, a deterministic classical decision tree approximates the
acceptance probability to fixed additive accuracy with failure at most `δ`,
using polynomial dependence on `M, t, 1/ε, 1/c` and **polylogarithmic**
dependence on `1/δ` for every fixed number of quantum query rounds. The proof
uses a dimension-independent component-identification lemma, dyadic
uniform-source encoding, uniform-cube strong simulation, and Bernstein
interpolation of an approximating failure-event polynomial. The
component-identification finite arithmetic has been kernel checked in Lean,
but the full analytic and simulator-transfer proof remains unverified.
These statements concern query complexity, not computation time, and the
mixture and its component laws are known to the simulator.

### Proposed strengthened theorem (claim conditional until discharged)

Let `A` be a `t`-query quantum algorithm making `d` oracle-query rounds
with acceptance-probability function `f:X→[0,1]`. Assume a standard coherent
value oracle for finite input alphabets `Σ_i` and a **known** law
`ν = Σ_{j=1}^M w_j P_j`, where each `P_j=⊗_i p_{ji}` and
`p_{ji}(a)≥c>0` for all indices and atoms. For `0<ε≤ε_0` and
`0<δ<1/2`, the proposed bounded-round strong transfer constructs a
deterministic whole-symbol decision tree `T` with

```
Pr_{X~ν}[ |T(X) - f(X)| > 5 ε ] ≤ δ
depth(T) ≤ M · 2^{O(d²)}
                 ( t · log(M/(ε δ c)) / ε )^{O(d)}
           + M² · O( t² log(M/(ε δ)) / (ε² c²) ).
```

Constants in the `O(·)` notation are universal in the intended BDST
parameter regime; the displayed asymptotic is **not yet independently
verified** pending an explicit fixed-point choice of dyadic block length and
full conditional duel accounting. No polynomial-time implementation is claimed.
For unbounded `d` this display does not imply a useful efficient simulator.
The dependence on `c` excludes zero-mass atoms; the baseline general
mixture theorem continues to cover them at polynomial inverse-failure cost.

### Proof architecture and precise caveats

**A. Component identification.** Given two product components, a
`[0,1]`-valued coordinate-degree-`r` function `f`, two centers
`u,v∈[0,1]`, error `ε` and failures `≤η`, if
`Δ=|u-v|-3ε>0`, the candidate non-adaptive test queries at most
`ceil(π² r² log(1/η)/(8 ε² c²))` coordinates and has summed
type-I/type-II error at most `max(η,2η/Δ)`. The version in the
current source is a paper argument. Its conditional mean/failure accounting,
weighted overlap inequality and the abstract Hellinger cutoff were independently
kernel-checked at the cited Lean CI; the Bernstein interpolation and product
law interface remain to be connected.

**B. Strong biased-product transfer.** Approximate each finite-alphabet
coordinate law by dyadic probabilities with block length `m`, yielding a
pushforward of uniform `m`-bit blocks with atomwise error `≤2^{-m}`.
The quantum pullback uses `2mt` Boolean-oracle queries and `2d` rounds.
BDST supplies a uniform-cube simulator with depth `D(m)`.
Consistent conditional decoding of the blocks produces a deterministic
whole-symbol tree under the rounded product law. To transfer back to the
original law, clip its leaf values to `[0,1]` and approximate the event
`|f-T|>2ε` by the binomial-tail polynomial
```
k = ceil( 2 log(1/η) / (9 ε^4) );
r = floor(5 k ε² / 2);
φ(z) = Σ_{j=r+1}^{k} binom(k,j) z^{2j}(1-z²)^{k-j}.
```
On `[-1,1]`, `0≤φ≤1`; `φ≤η` when `|z|≤ε`; and
`φ≥1-η` when `|z|≥2ε`. The polynomial
`G(x)=φ(f(x)-T(x))` has coordinate degree at most
`h(m)=2k(2t+D(m))`. If `2^{-m}≤min(c/2,cη/h(m))`, Bernstein
interpolation of `E G` between the rounded and exact marginals incurs
`≤η`. The failure bound transfers with a factor `4η`. The uniform
base makes `m` logarithmic in `1/c` apart from the fixed-point
dependence on `D(m)`; the much larger `1/a` in GMNR's particular gadget
comes from its *biased-source* blocks, not from an established lower bound
on uniform-source encoding.

**C. Mixture tournament.** Run the `M` product simulators, observe their
complete transcripts and outputs, then generate the `M(M-1)/2` pairwise
likelihood-ratio tests for pairs whose outputs differ by at least `4ε`.
All tests should be generated from the preliminary simulator transcripts
and evaluated without allowing prior duel outcomes to alter the future
conditioning. The true component, when its own simulator is correct,
wins all decisive duels except on a small weighted exceptional set.
Therefore an undefeated candidate, when present, outputs within `5ε`
of `f`. The **weighted conditional testing error bound** is currently a
paper argument and still requires an independently checked full proof.
Choosing the internal failure parameter at scale `εδ/M²` gives the
advertised `log(M/(εδ))` tests.

### Evidentiary status (must travel with this draft)

| Claim | Status |
| --- | --- |
| Previously published-in-repo general mixture theorem, polynomial in 1/δ | Existing Lean certification; keep unchanged |
| Finite conditional mean/failure and Hellinger cutoff in Lemma 1 | Lean kernel compile + standard axioms, run 44487229739 |
| Complete Lemma 1 with Bernstein law interpolation and product tensorization | Paper proof, incomplete Lean bridge |
| Dyadic product transfer with log(1/c) | Paper construction + independent analytic audit; fixed-point bound still outstanding |
| Weighted conditional M-component tournament | Paper argument; independent proof and counterexample tests outstanding |
| Full strong bounded-round mixture theorem | **PROVISIONAL; neither Lean certified nor independently reviewed** |
| Novelty of any complete theorem | Preliminary literature comparison only; not certified |

**Promotion gate:** Explicit constants/fixed-point proof; fully grounded
coherent finite-alphabet query model; separate conditional duel audit;
nonvacuous adversarial exact tests; complete analytic formalization;
independent non-author mathematical review; dated specialist prior-art
review. Only then replace the preprint's principal unconditional headline.
