# Ryev #250 — independent quadratic-tower replay of the F16 phase block

**30 October 2026 · NIGHTFALL / CONSTELLATION · AI computational audit · R1 internal only.** Research leadership: Devin J. Wright. Original 3×5 block: PR #243 and its credited construction team. This work is an independently implemented, same-team arithmetic check; **not** a human independent review, Lean theorem, priority clearance, or worldwide original result.

## Frozen model and source

Let `F4=F2[w]/(w^2+w+1)` and `K=F4[u]/(u^2+u+w)`. We encode a+b*u as `(a)|(b<<2)` for 2-bit a,b. This is independent of source `F2[z]/(z^4+z+1)`. The least numeric tower root of the latter polynomial is `u=4`; evaluation gives the explicit source-to-tower bijection:

`[0,1,4,5,6,7,2,3,14,15,10,11,8,9,12,13]`.

The source subgroup `{1,6,7}` maps to `{1,2,3}`. The fixed source matrix, in source four-bit coefficients, is

```
14 12 15  3 7
15  4  9  6 8
 5  5  3 14 6
```

`source_81_words.json` contains all 81 anchored input/output pairs in lexicographic order. The source-table compact JSON digest is `9e36add8e024361e05be9c02aef07510d91c6f58d20812c79304227c71f77fc8`; frozen file-byte SHA-256 is `9c590a4643a078c0f1ff35c04a1ea73e83a6c9f8052d5c915e9676e71c255ca2`. Checker-file SHA-256 is `830b00efbaee102f4cf44ba83603022b2ec3e6ffaabb78704a6a14091e2db123`.

## Exact replay

```
python3 research/nightfall/agent-reports/ryev_f16_tower_20261030/verify_tower_independent.py \
  --verify-table research/nightfall/agent-reports/ryev_f16_tower_20261030/source_81_words.json
```

Locally (Python 3.13.5, no third-party libraries): PASS, 1,048,576/1,048,576 k=5 input vectors up to global `H`, every support pattern including zero; source 81 outputs injective. The six cube fibers have sizes `[1,3,3,3,3,3]`. Frobenius conjugation tests all four field automorphisms and the two subgroup automorphisms. Mutations: zero one phase column (216 collision pairs), swap two coefficients in only one row (11 collision pairs), tamper one source-table code (rejected), replace cubing by fourth power (rejected). A consistent **whole-column swap preserves injectivity** and is checked as a symmetry, not falsely advertised as corruption.

## 4×7 integration contract

Axiom may supply a JSON file containing **exactly four arrays of seven integers 0..15**. Run:

```
python3 research/nightfall/agent-reports/ryev_f16_tower_20261030/verify_tower_independent.py \
  --skip-full --matrix-4x7 candidate.json
```

The independent tower checker enumerates 3^6=729 anchored phase states. Its output reports the number of colliding unordered **pairs**, not merely repeated codewords, and the lexicographically minimal colliding input pair in the original source encoding. An all-zero matrix must produce 729 choose 2 = 265,356 colliding pairs. No zero-collision 4×7 matrix is claimed here.

## Transfer lemma (mathematical, not Lean-formalized)

Let `B:H^4 -> K^3` be the anchored cubing map from the frozen matrix and assume its exact 81-element injectivity. For an arbitrary signal `x ∈ K^k` with `s>0` nonzero coordinates, first query every `x_j^3`. For each positive coordinate choose any `u_j^3=x_j^3`. Because the cube fibers are exactly `H`-orbits, write `x_j = λ_j u_j`, with `λ_j∈H`. Take the first supported index `t` as anchor; set `η_j=λ_j/λ_t`. For each four-element nonanchor block use the legal linear query whose coefficients are `A_(r,0)/u_t` on the anchor and `A_(r,i)/u_j` on its four coordinates. Its cube equals `B(η_block)_r`, since `λ_t^3=1`. Hence recover all four phases. For each residual coordinate use `(x_t/u_t + z*x_j/u_j)^3` where `z` is the polynomial generator; the map `η ↦ (1+z η)^3` is injective since `1,z` are linearly independent over `F4`. The zero vector requires only coordinate queries. The exact count is `k + 3 floor((s-1)/4) + ((s-1) mod 4)` for `s>=1`. The output is unique up to global `H`.

**Formalization debt:** The existing PR #243 Lean file proves only finite arithmetic/81-word Boolean statements. A general Lean theorem needs (i) a finite-field `K` and `H` interface, (ii) cubing-fiber-to-orbit lemma, (iii) a supported-anchor choice for arbitrary `Fin k` vectors, (iv) a chunked partition with a verified 4-block + 1–3 tail count, and (v) a linear-form observation identity and reconstruction correctness. The local runtime lacks `lean`/`lake` binaries, so no Lean file was compiled or claimed to pass during this audit. Use pinned Lean 4.35.0 via the existing bridge before formal status upgrade.

**Scope/status:** Independent internal arithmetic, all k=5 signals and mutation tests completed. General written lemma is conditional on field facts and the 81-word injectivity, and is **not yet formally kernel-certified**. Publication-priority search, external mathematical review and 4×7 construction remain open. No changes to site publication claims, branch protection, original contributor credit, provider spending, or Gate C status.


## 30 October extension — adaptive 27-state block, distinct same-oracle replay

Source: verify_adaptive_tower.py (Git blob SHA 6233c192e93d3b888b3351acf320c811f06e9a36). Run:

    python3 research/nightfall/agent-reports/ryev_f16_tower_20261030/verify_adaptive_tower.py

The dedicated workflow also runs it. This source was separately written from producing PR #255, uses GF4[u]/(u²+u+ω) arithmetic, validates the full 16-element isomorphism, and is independent *internal* arithmetic, not external review.

Frozen same-model candidate: H=F4* and oracle (a·x)^3. First polynomial-coordinate row (1,2,3,4), followed by the six observed-cube-keyed second rows exactly as displayed in Tessera PR #255. The checker reconstructs the whole 27-entry phase/transcript dictionary in the tower field, including the zero fiber, and verifies no duplicate transcripts. The fiber sizes are 1,5,5,5,5,6.

Executed locally with Python 3.13.5: all 65,536 F16^4 signals (query count frequencies 4:61, 5:1350, 6:64125); all 5,461 F16^7 support/global-phase representatives plus the zero signal; and 12,000 reproducibly seeded seven-coordinate arbitrary-amplitude tests. Reconstruction is modulo one common H scalar and counts coordinate readings plus **both** adaptive block queries. Exact information lower bounds show the proposed worst-case counts 6 (k4) and 11 (k7) are tight **conditional on the written all-k transfer argument**. The replay independently checks the finite decoder rather than establishing an all-k Lean theorem.

Negative controls must fail: delete the first-output-zero branch; use a wrong second row for a legal first output; replace the oracle exponent 3 with 5; and attempt to choose the second row from the hidden *unpowered* first sum. Tower representatives 6 and 11 differ while their cube is identical, demonstrating why branch selection cannot legally distinguish them. A changed subgroup/exponent is a different oracle model, never a free decoder improvement.

**Precise remaining formal dependency:** give Lean 4.35.0 a general finite-field/subgroup interface, prove cube fibers are exactly H-cosets, and prove correctness of canonical-root normalization, supported anchor, three-phase block partition and terminal one/two-coordinate cases for arbitrary k. The runtime executing this checker has no Lean/Lake toolchain; therefore **no new Lean kernel theorem is claimed**. Existing PR #243's finite 81-state Lean check does not discharge this parametric proof. External human referee, same-model historical priority, and Vesper/owner promotion gates remain open. No new site claim or public scientific status change.
