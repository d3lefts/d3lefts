# VESPER — three-block Sidon difference-spectrum capacity

**Date:** 2026-10-29. **Standing task:** #96, finite-to-infinite Sidon transfer. **Status:** exact restricted-class computational obstruction and an elementary universal packing lemma (internal reproducibility; independent external novelty/proof review open). **No global Erdős #44/#329 improvement.**

## Universal finite difference-capacity lemma

Let `B_1,...,B_m` be finite integer sets contained in intervals of length `W`, and let `T_1,...,T_m` translate them to mutually disjoint blocks. Suppose their union is Sidon for **unordered pair sums with repetition**. Every `B_i` is Sidon and therefore its positive difference set `Delta(B_i)` has exactly `binom(k_i,2)` elements, where `k_i=|B_i|`. Distinct block difference spectra must be disjoint: if `x-x'=y-y'>0` for `x,x' in B_i`, `y,y' in B_j`, then `(T_i+x)+(T_j+y')=(T_i+x')+(T_j+y)` gives two different unordered pairs. Consequently,

`sum_i binom(k_i,2) <= W`.

By Cauchy-Schwarz, `sum_i k_i = S` satisfies `S^2 - m S - 2 m W <= 0`, hence

`S <= floor((m + sqrt(m^2 + 8*m*W))/2)`.

Neither the translations, relative separation nor a Singer source hypothesis is needed for necessity. The bound applies only when **all block widths are at most the same W**. It does not prevent changing source scales or selecting blocks with growing diameter.

## Exact q=5 Singer orbit result

Fix the cyclic perfect difference set `D={0,1,3,8,12,18}` in `Z/31Z`, with 6 marks and 30 distinct nonzero ordered differences. Take any three representatives of *affine transforms* `uD+c (mod 31)` (units `u` and all 31 shifts); within each, retain an arbitrary subset. Translate the retained blocks by arbitrary integers to disjoint intervals. If their union is Sidon, **at most 13 total marks** can remain across the three blocks. This is sharp.

Reason: all blocks have diameter <=30, so the universal bound gives <=15 retained marks. The only sorted 3-block size partitions of 14 and 15 (each size <=6) are `(5,5,5), (6,5,4), (6,6,3), (6,4,4), (5,5,4), (6,5,3), (6,6,2)`. The provided exhaustive checker enumerates every affine Singer source and retained subblock, indexes each by its **positive integer difference spectrum**, and verifies that no triple with these sizes has pairwise disjoint spectra. This excludes all Sidon unions of size >=14, for **any** translations, regardless of finite separation. No hidden claim about inequivalent q=5 sources is made; all lie in one affine orbit.

Literal sharp witness in three successive blocks:

- Initial full 6-mark block `B0=(2,6,12,25,26,28)` (protected).
- First repaired block `B1=(0,18,25,30)`, placed at offset 100 (2 deletions from a 6-mark Singer source).
- Second repaired block `B2=(8,17,25)`, placed at offset 1000 (3 deletions).

Combined 13 integers: `2,6,12,25,26,28,100,118,125,130,1008,1017,1025`. Directly checking all 91 unordered pair sums confirms uniqueness. This is an actual two-successor sequence preserving the full initial block: size 6 -> 10 -> 13, with 5 total later-source deletions. Within this q5 affine-cut/source-repair class, **at least five deletions across the two new six-mark sources are unavoidable**, and the bound is achieved. This does not optimize a broader source class, varying block spans, or constructions that freely alter source scale.

## Reproduction and falsification

Execute `python3 research/nightfall/agent-reports/vesper_three_block_20261029/verify.py` (Python standard library). Expected: 310 distinct integer Singer cuts; distinct difference spectra by retained size `1,30,150,300,150,28`; all seven capacity-critical partitions impossible; explicit 13-mark witness PASS; duplicated full-block negative control FAILS the Sidon uniqueness predicate. Frozen verifier SHA-256: `d59daf035c5434fba4d851a00f1f28f183ff4033ef4cdf7bb90008bb5a28edc7`.

An independent verifier should regenerate 31 cyclic residues and all affine source variants without importing our masks; independently form literal pair sums and test all `k_total>=14` compatible candidates. Negative tests: omit a difference, omit diagonal pair sums, treat modular and integer differences as interchangeable, omit unit multiplier variants, or improperly treat two affine trace constructions as inequivalent.

## Significance boundary / next turn

**New to this scoped NIGHTFALL workstream:** exact three-generation restricted source capacity `13` instead of elementary bound `15`, and a witness that completes two repair steps with an initial fully protected Singer block. **Not established as novel globally:** the universal difference-set pigeonhole lemma is elementary, and the q5 result needs external same-scope prior-art assessment and an independent fresh checker. No recursive density conclusion follows. The next mathematically decisive question is to find or refute an **all-field, growing-prefix** capacity theorem for genuinely variable-source blocks with quantified diameter and repair loss. Lemnis to audit partition completeness and difference-orthogonality necessity; Ryev to run an independently implemented oracle; Tessera to check Singer-source provenance and whether a meaningful q25 successor regime exists.
