# NIGHTFALL finite Sidon (4,5) construction

**Research note:** 2026-10-24. **Classification:** finite constructive certificate, independently tested by exact C++ search and Python integer programming. The global asymptotic 5/9 value predates this construction.

Let (O={0,49,75,83,98,101,117,119,121,159,269}), and define the affine contraction (phi(x)=101+18x/269). Write (S_K=igcup_{j=0}^K phi^j(O)) and (B_K=S_Kcup{-269}).

Under the published all-depth arithmetic-progression characterization of the original seed family, the derived quantities are

[
|B_K|=12+9K,qquad h(B_K)=7+5K.
]

Here (h(B)) is the maximum cardinality of a Sidon subset. The explicit case **K=2** gives a **30-point** (4,5) set with largest Sidon subset **17**, hence (17/30<4/7). As K tends to infinity, the ratio tends to the previously known (5/9), so this is strictly a **finite compression**, not a new asymptotic upper bound.

Proof of the added endpoint: any three-term progression involving -269 in B_K must be ((-269,0,269)), since the other members lie in [0,269]. A four-distinct additive collision involving -269 is impossible by the same interval endpoints. This introduces one explicit progression constraint, preserving the (4,5) property.

For the original family, exhaustive seed-state enumeration gives the max-plus transfer matrices

```
BASE = [[5,6,6,6],[5,6,6,6],[5,6,6,6],[6,7,7,7]]
TRANS = [[5,6,6,6],[4,5,5,5],[4,5,5,5],[4,5,5,5]]
```

The BASE row maximum increases exactly by five under each max-plus multiplication by TRANS. Combined with the endpoint-exclusion inequality, this proves (h(B_K)=7+5K) from the stated source seed lemma.

**Verification recorded in the complete release package:** exhaustive exact C++ test of all 27,405 four-element candidates and exact hitting-set search at K=2, finding maximum Sidon subset size 17; independent Python/MILP checks and max-plus test K=0..3. The actual checkers and witness files are in the separate master reproducibility ZIP and require byte-for-byte GitHub upload for a self-contained remote reproduction.

**Related work:** Jie Ma and Quanyu Tang, *Largest Sidon subsets in weak Sidon sets*, arXiv:2602.23282; 7bkzb8 reader construction (October 2026) establishing 5/9. This note claims neither worldwide novelty nor a new competition record.


## Independent machine proof — October 28

An independently generated 7,801-state **proof DAG** now establishes the 30-element `(4,5)` example unconditionally at the finite level. Each branch proves every one of the three possible ways to hit an uncovered three-term progression; terminal states give explicit families of disjoint progressions exceeding the remaining deletion budget. A separate small checker validates all proof transitions without solving the optimization problem anew.

- [30 exact witness coordinates](witness_30.txt) — SHA-256 `dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f`
- [Standalone exact independent search verifier](verify_sidon30_standalone.py) — 27,405 four-point tests, 28 progression edges, explicit 17-subset pair-sum verification, and no possible 12-deletion AP cover; standard-library Python.
- Frozen checkable DAG ZIP: `NIGHTFALL_SIDON30_MACHINE_PROOF_20261028.zip`, distributed with the research conversation until publication as a public GitHub Release asset. The exact DAG file inside has SHA-256 `4e31c53667cba63db34354eb861f503ac7284a0e76cd7219306dff8239032181` and is verified with a separate interpreter, including adversarially corrupted proof fixtures.
- **Automated CI:** the standalone source script runs on project updates, independently of the October 24 C++ search.

```bash
python3 research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py
```

The finite result gives the exact ratio `17/30<4/7`. The asymptotic `5/9` reduction belongs to the earlier reader construction and is a separate prior-art result. The DAG proves this **particular finite witness**, without presuming the infinite self-similar family theorem.

