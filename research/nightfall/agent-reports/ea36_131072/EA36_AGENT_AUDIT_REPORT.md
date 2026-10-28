# NIGHTFALL / Agent audit 01 — an exact finite-to-continuous verification

**Research lead:** Devin J. Wright  
**Audit date:** 2026-10-28  
**Reviewer:** independent algorithm authored in a separate agent run, validated against the immutable original archive  
**Status:** **PASS — explicit finite upper-bound construction and its continuum interpolation**; prior-art priority, accepted Arena entry provenance, and general lower-bound certification remain separate questions.

## 1. Frozen inputs

The source is the original byte-frozen `NIGHTFALL_GitHub_Release_2026-10-27.zip` (214 entries), SHA-256:

`77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb`.

Nested certificate: `research/nightfall/artifacts/NIGHTFALL_Meta_Paper_v2.0_Source_and_Evidence.zip` (SHA-256 `e78bc5c90562033df412e0dbbd7265f37cb8228061bc7d436c792a8157d8cf96`).

Input: `release/reproduction/overlap_latest/NIGHTFALL_Erdos_Latest/heights_u70.txt` (2,156,159 bytes), SHA-256:

`a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e`.

Set `N=131072`, `D=2^70`, `H=N/2=65536`, `h=2/N=1/H`. The integer heights `A_0,...,A_{N-1}` satisfy `0 <= A_i <= D` and `sum A_i=H*D` exactly. Define `f(x)=A_i/D` on `[ih,(i+1)h)` and zero outside `[0,2]`. Define `g(x)=1-f(x)` on `[0,2]` and zero elsewhere. Hence both densities have support `[0,2]`, and `∫f=1`. The cross-overlap is `R(t)=∫ f(x)g(x+t)dx`.

## 2. Independently computed discrete certificate

For signed integer index `k`, define `B_j=D-A_j` on `0 <= j < N` and `B_j=0` outside that range, and let

`S_k=sum_{0 <= i < N} A_i * B_{i-k}`.

The GMP verifier was written without access to the original six-prime NTT implementation, its modular residues, or its original intermediate arrays. It uses a distinct Kronecker packing representation with digit base `Z=2^160`:

`P(Z)=sum_{i=0}^{N-1} A_i Z^i`,  `Q(Z)=sum_{j=0}^{N-1} (D-A_{N-1-j}) Z^j`.

Every coefficient of `P*Q` is bounded above by `N*D^2=2^157`, strictly less than `Z=2^160`. Thus ordinary nonnegative integer multiplication has **no carries between packed coefficients**; its `2N-1=262143` base-`Z` digits are exactly the entire signed-lag `S_k` sequence with `k=position-(N-1)`.

The verifier computes all of these digits with GNU MP 6.3.0, additionally compares 27 distinct peak, runner-up, boundary, and pseudorandom signed shifts to an `O(N)` direct integer summation, and verifies the input mass and range. Result:

`max_k S_k/(H*D^2) = 34788888032212764146872525963225147703298526879 / 91343852333181432387730302044767688728495783936`

`= 0.3808563701180293252462787636560246135327211883155...`

The **unique** maximizing signed index is `k0=-17280`.

### Newly computed runner-up and grid isolation margin

The unique runner-up is `k1=+36482` with

`S_k1/(H*D^2) = 34788888032196508685160787678357375369567622621 / 91343852333181432387730302044767688728495783936`

The exact positive grid margin is

`Δ = Q - R_grid(k1) = 8127730855869142433886166865452129 / 45671926166590716193865151022383844364247891968`

`= 1.77959011980857193866589683824655... × 10^-13`.

The drop toward signed-grid neighbors `k0-1` and `k0+1` is, respectively, approximately `2.74296923137e-12` and `3.14004064782e-12`.

**This Δ is a grid-only isolation margin.** Continuous shifts approaching the unique maximum yield values arbitrarily close to `Q`; there is no positive gap over all distinct real shifts.

## 3. Complete elementary finite-to-continuous bridge

**Lemma (affine cross-overlap).** For any grid-step `f` and `g` as defined above, extend `B_j=0` outside `0,...,N-1`. Write a real shift uniquely as `t/h=m+θ`, with `m` an integer and `0 <= θ < 1`. Then

`R(t) = (1/(H*D^2)) * [(1-θ)S_{-m} + θ S_{-(m+1)}]`.

**Proof.** Fix `i` and a point `x` in `[ih,(i+1)h)`. The translated point `x+t` occupies cell `i+m` for exactly length `(1-θ)h` of the `i`th cell and cell `i+m+1` for exactly length `θ h`; when either cell is outside the common support, its zero-extended `B` value is zero. Consequently the integral of `f(x)g(x+t)` over the `i`th cell is

`A_i / D^2 * h * ((1-θ)B_{i+m}+θ B_{i+m+1})`.

Sum over `i`. Since `h=1/H`, the formula follows. **QED.**

A separate independent implementation compared this formula with exact rational interval-intersection geometry on **1,720** deterministic small examples. All passed. Those tests are software controls; the argument above is the actual proof.

**Corollary (continuous global supremum and unique peak).** Each real-shift value is a convex combination of two adjacent grid-shift values. Outside `[-2,2]`, the overlap vanishes. Therefore

`sup_{t in R} R(t) = max_{-N < k < N} S_k/(H*D^2) = Q`.

The unique maximizing signed index `k0=-17280` corresponds to the **unique physical real shift**

`t0 = -k0*h = +17280/65536 = 135/512`.

This independently certifies the explicit **upper** bound `μ <= Q` on the minimum-overlap constant, assuming the reproduced finite arithmetic, the stated definition, and normal computation integrity. It establishes neither the exact value of `μ` nor a new universal lower bound.

## 4. New quantitative perturbation stability certificate

Let `\tilde A` be another vector of admissible integer numerators on the same grid, with `0 <= \tilde A_i <= D`. Set `T=sum_i |\tilde A_i-A_i|`. Let `\tilde S_k` be the corresponding signed overlap numerators. Directly expanding the bilinear difference gives

`|\tilde S_k-S_k| <= 2D*T`  for every signed grid lag `k`.

Hence, for any `k != k0`,

`\tilde S_k0 - \tilde S_k >= (S_k0 - S_k) - 4D*T >= (H*D^2)*Δ - 4D*T`.

It follows that **if**

`T < (H*D*Δ)/4 = 8127730855869142433886166865452129 / 2361183241434822606848`

then `k0` remains the **unique maximizing grid lag**, and the same affine interpolation lemma proves that the physical maximizing real shift remains `135/512`. In particular, every such integer perturbation with `T <= 3,442,227,910,668` satisfies this condition. When `\tilde A` also has unchanged sum `H*D`, it remains an admissible unit-mass step-density witness.

This is a strict, witness-specific stability ball, *not* an optimality assertion for the global optimization problem. The bound has been newly calculated from the independently recovered runner-up margin; no separate novelty or priority claim is made for the general Lipschitz argument.

## 5. Reproduction

Requirements: Python >=3.10; `g++` with GMP development headers/libraries (`libgmp-dev`). No original NTT residues are used in this independent checker.

```bash
python3 replay_erdos_gmp.py NIGHTFALL_GitHub_Release_2026-10-27.zip
```

This checks the archive hash and CRC, extracts the nested original witness, recompiles the independent GMP source, verifies every signed-lag digit and 27 direct sums, tests the affine overlap formula on 1,720 small exact-rational geometries, and emits a JSON report. The archived full NTT/CRT replay is an entirely separate earlier evidence path.

Files in this independent review packet:
- `independent_gmp_audit.cpp` — new source-independent exact integer convolution, full grid maximum and runner-up.
- `verify_bridge.py` — independent small exact overlap geometry controls.
- `replay_erdos_gmp.py` — byte-frozen release input and independent checker orchestrator.
- `replay_report.json` — full reproducible scope, environment, hashes and result.

## 6. Explicit unverified boundaries

- The **accepted Einstein Arena leaderboard submission** at `0.3808564043546676` is a separate object; its original accepted file/cell count are still under recovery (issue #6).
- Our verified 131,072-cell mathematical upper-bound witness exceeds the Arena's 100,000-entry competition limit; its numerical strength cannot be presented as an officially accepted submission.
- Scientific priority against newer constructions requires a separate dated and normalized literature audit.
- This computation and its elementary lemma are an internally executed agent verification. It is **not** an external specialist referee report and **not** a proof-assistant kernel certificate.

**Verdict:** `PASS` for the explicit rational step-function upper bound, unique continuous maximizing shift, runner-up grid margin, and the stated sufficient stability radius. `INCONCLUSIVE` for source priority and platform entry identity; no inference toward a global lower bound.