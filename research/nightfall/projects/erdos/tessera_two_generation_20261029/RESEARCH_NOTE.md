# TESSERA — Complete q=25 affine Singer second-generation repair audit

**2026-10-29 · Research owner: Devin J. Wright · Executing persona: Tessera (Tessara is a historical alias).** Standing [#95](https://github.com/d3lefts/d3lefts/issues/95) (Singer), [#76](https://github.com/d3lefts/d3lefts/issues/76) (continuum). **R1 internal exact finite evidence and elementary continuum identity only.** No non-author independent audit, global Sidon record, improved Erdős #36 bound, established originality, or human-approved publication. Two independently implemented checkers were run by the same persona and do not count as independent scientific referees.

## Research contract, baselines and scope

**Objective:** test a source-aware, second-generation Sidon repair after preserving a hostile five-mark prefix. **Feasible family:** fixed 23-mark integer Sidon first-generation survivor from [Tessera PR #192](https://github.com/d3lefts/d3lefts/pull/192); second block from *all* affine unit/cut variants of the classical q=25 cyclic Singer source; delete marks only from the second block. **Strongest prior internal comparison:** PR #192's first-stage 23-mark survivor and [Vesper PR #195](https://github.com/d3lefts/d3lefts/pull/195)'s restricted q5/q7 first-generation exhaustive repair floors. **External references checked 2026-10-29:** classical [Singer difference sets](https://en.wikipedia.org/wiki/Difference_set); [Hulak–Ramos–de Queiroz (2026)](https://arxiv.org/abs/2605.03274) formal Singer/Sidon work; [Niu (28 Apr 2026)](https://arxiv.org/abs/2604.25214) on finite non-extendibility; [Táfula (29 Jul 2026)](https://doi.org/10.1007/s00605-026-02211-4) on infinite Sidon-type sets. These do not establish same-scope priority for the present finite optimum. **Audit plan:** separate graph-from-differences and graph-from-literal-cross-sums implementations, plus exact pair-sum witness. **Stop:** one complete 234,360-case affine enumeration and one continuum two-lag falsifier, no further polishing of this fixed source.

**Critical feasibility correction:** choosing another primitive generator, irreducible field polynomial, or trace weight in the classical Singer construction only gives an affine-equivalent cyclic difference set. If beta=alpha^j, then D_(alpha^u,beta)=u^(-1)(D_(alpha,1)-j) modulo v. Thus this experiment covers one classical affine orbit; it does **not** compare genuinely inequivalent q25 cyclic planes, whose existence cannot be assumed. This supersedes the earlier planning phrase “inequivalent q25 field sources”; see [PR #199](https://github.com/d3lefts/d3lefts/pull/199).

## Exact finite result: 10 retained, 16 deleted

Let v=651, K=26, with verified cyclic perfect difference set

\`\`\`text
D = [21,72,81,86,88,105,197,217,247,278,316,334,357,360,368,
     405,430,434,440,462,483,498,525,537,538,584].
\`\`\`

The fixed 23-mark first-generation integer Sidon set, derived from PR #192's protected prefix [1,23,70,150,200], source translation T1=583, and deleted Singer indices [6,8,9,11,13,14,18,23], is

\`\`\`text
S = [1,23,70,150,200,604,655,664,669,671,688,800,899,940,988,
     1013,1017,1045,1066,1081,1108,1121,1167].
\`\`\`

For each unit u in (Z/651Z)^× and c in {0,...,650}, define B(u,c)=sorted({(u*d+c) mod 651 : d in D}) as **ordinary integer representatives**. Keep every mark of S. Choose any integer T≥2334, and delete any subset of T+B(u,c).

**Finite theorem (only this protected S, q=25 affine source orbit, and new-block-only deletion model):** Across all phi(651)*651 = **360*651 = 234,360** affine choices, the maximum number of second-block marks that can be retained is **exactly 10**. Therefore **at least 16 of the 26 new source marks must be deleted**, and 16 deletions are attainable. The optimum is independent of T for all T≥2334.

One attaining witness uses u=92, c=72, T=2334 and retains

\`\`\`text
W = [0,11,172,203,259,356,366,418,500,619]
S union (2334+W): 33 integer marks, largest mark 2953.
\`\`\`

The direct unordered-pair-sum checker includes diagonals and confirms Sidon. **Boundary negative control:** T=2333 is invalid for this witness, since 1+2333 = 1167+1167 = 2334. We do not claim 2334 is the globally smallest possible shift across all configurations.

### Proof and exact exhaustive certificate

1. D contains every nonzero residue as an ordered difference exactly once. Every affine B(u,c) is therefore ordinary-integer Sidon. S has all 253 positive differences distinct; its first-generation lineage is reconstructed exactly in verifier B.
2. For T≥2334, S+S, S+(T+B), and (T+B)+(T+B) are disjoint sum bands: max(S+S)=2334, min(S+T+B)≥T+1≥2335, max(S+T+B)≤T+1817, and min(2T+B+B)≥2T. Only mixed/mixed equal sums remain possible.
3. Put an edge between two new marks b_i,b_j exactly when their positive difference occurs among the positive differences of S. A retained W is valid **iff** W is independent in this 26-vertex collision graph. The minimum deletions equal 26-alpha(G).
4. **Primary A:** \`q25_singer_two_generation.cpp\` exhausts every u,c, computes the graph from differences, and uses a colored branch-and-bound maximum-clique search on the complement. It obtains global max alpha=10; 196,797 cases close by a greedy coloring bound and 37,563 invoke exact search. Collision edges range 86..162 (mean 112.536).
5. **Adversarial implementation B:** \`independent_crosssum_bk.cpp\` independently builds conflicts from **literal old+new sum multiplicities**, then uses Bron–Kerbosch pivot search to rule out any 11-mark independent set in every one of the 234,360 cases. It independently validates the 33-mark witness, all 16 excluded-mark negative controls, source differences, and the invalid T=2333 boundary.
6. The two algorithms agree on the complete finite result; **they are in-project tests, not external proof review**. \`CERTIFICATE.json\` freezes counts, witness and input hashes.

Run with standard C++17 compiler and Python 3, no network/packages:

\`\`\`bash
python3 research/nightfall/projects/erdos/tessera_two_generation_20261029/test.py
\`\`\`

Primary SHA256: \`65d15ce0830ed1741df5f4f23f464fca35bdbac352c1de18fc95e4d6fc066562\`; independent B SHA256: \`814c72a61c3cfc84c15c5a6827b206ed02eb33722f3bf37683524f5246450e99\`; continuum checker SHA256: \`14bad9ea41d251758a1b7ed5515fa527a8304d81396ddb3a215900dbb491f95f\`. Frozen certificate and PR #192 original 23-mark witness have their own hashes.

## Continuum lane #76: a boundary-corrected two-lag identity

On I=[0,2], let 0≤f≤1 measurable with integral 1. Separately zero-extend F=f 1_I and G=(1-f)1_I, and let R_f(t)=integral_R F(x)G(x+t) dx, S_f(t)=R_f(t)+R_f(-t). For t≥0 define the nonnegative boundary loss B_f(t)=integral_R F(x)[2-1_I(x+t)-1_I(x-t)] dx. For **every** such f and t,

\`\`\`text
4*S_f(t) - S_f(2t) - 6*R_f(0) + 4*B_f(t) - B_f(2t)
  = integral_R [F(x)-2*F(x+t)+F(x+2t)]^2 dx >= 0.
\`\`\`

Proof: C(t)=integral F(x)F(x+t)dx is even; S(t)=2-B(t)-2C(t), R(0)=1-C(0). Therefore D(t)=S(t)-2R(0)+B(t)=2(C(0)-C(t)); expanding the square gives 6C(0)-8C(t)+2C(2t)=4D(t)-D(2t). This is a standard Gram/finite-difference identity, **not** a newly established numerical dual improvement.

**Cheapest exact falsifier:** omit the boundary correction and claim 4S(t)-S(2t)-6R(0)≥0. For f≡1/2 and t=1/2 the left side is **-1/2**, while the corrected square is **+1/2**. \`two_lag_fraction.py\` confirms the identity using exact rational interval intersection and direct square integration on 455 deterministic rational profiles, including alternating cells. We have **not** shown that this operator lies outside the frozen eight-row cone, nor independently replayed inherited Wetch/Arb enclosures. The conditional same-premise lower benchmark **0.38062747462668** and >**0.38062748462668** reporting threshold are unchanged; the 131,072-cell upper witness is a separate upper construction. See [Tao's minimum-overlap formulation](https://github.com/teorth/optimizationproblems/blob/main/constants/1b.md) and [White 2022](https://arxiv.org/abs/2201.05704).

## Certificate Transport Ledger — an elementary shared failure mode

**Fiber-diameter lemma:** if a representation map P:X→Y has P(x)=P(x') while a real observable differs by delta, then any estimator depending only on P has error ≥delta/2 on one input (triangle inequality). A Boolean predicate cannot be decided solely from P if two points of the same fiber have opposite predicate values. This is elementary information theory, **not** a cross-domain mathematical breakthrough.

| Lane | Map / certificate | Preserved predicate and loss | Exact negative control | Status |
|---|---|---|---|---|
| Singer | Fixed S, affine B(u,c), collision graph; W→S∪(T+W) | Sidon iff W independent, exact loss 16/26 for fixed S and q25 affine orbit | Canonical residues S mod 651 have the same residue profile as integer Sidon S but are not integer Sidon: 1+23=4+20=24 | Scoped R1 finite, no all-q recursive closure |
| Continuum | f→P_N f cell means; separately zero-extended F,G | Existing BV-restricted bound ≤(2/N)TV(f); no unconditional vanishing error | First-half-cell pulses and constant 1/2 have identical cell averages but overlap suprema 1 and 1/2; any averages-only estimator has worst-case error ≥1/4 for each N | Elementary exact no-go, no improved universal lower bound |

The shared principle is **loss of predicate-relevant information under a many-to-one representation**. This is a falsifier-checked analogy and an abstract fiber lemma, **not a proof transporting Singer results into continuum overlap**.

## Originality and next gate

**Proposed Original Finding (OF-C at most):** exact finite 10-retained / 16-deleted second-generation Singer repair optimum for this one protected q25 prefix and complete affine source orbit. **Strongest evidence:** exhaustive A/B checks and explicit 33-mark literal witness. **Missing gate:** independent Lemnis proof/scope audit, Ryev separate replay, Axiom field/source verification, Vesper dated same-scope novelty review. The closest checked sources above do not establish worldwide originality; R1 internal only, no OF-A/OF-F promotion.

**Single decisive next falsifier:** replace S with an independently constructed *different* hostile first-generation five-mark-prefix survivor and repeat the complete q25 affine matrix. **One** valid second-generation configuration retaining ≥11 would refute any extrapolation of this 10-cap to all first-generation prefixes. Stop after one distinct full-orbit test unless a parameterized q/r closure mechanism emerges; do not polish this fixed instance.
