# TESSERA — Anchored signed-digit codes for adaptive square-phase retrieval

**30 October 2026 | Vesper #257, Tessera #251 | R1, exact internal checks; external mathematical proof and originality review PENDING.**

## Frozen oracle and construction theorem

Let K=GF(p^r), p an **odd prime**, r≥1; H={±1}; query returns (a·x)^2∈K with K-linear a chosen from prior **powered** observations only. Identify signals x∈K^k modulo a single common sign. Put

d=floor(log2 p), e=floor(log2((p−1)/2)), f=floor(log2((p+1)/2)) and

**B(p,r)=max(r f, e+(r−1)d).**

**Theorem:** One squared K-linear form, with an anchor whose sign is fixed relative to the vector, can distinguish all 2^B independently chosen H-sign strings. A universal adaptive procedure, measuring k coordinate squares first and then one mixed squared linear form per B relative nonzero signs, uses

    m(k,s) ≤ k+ceil((s−1)/B(p,r))

for every signal with s≥1 nonzero coordinates, and at most k+ceil((k−1)/B(p,r)) for all k-signals (including zero, which needs no further mixed query).

## Exact proof: two antipodal-free signed-digit families

Choose any GF(p)-basis β1,...,βr of K.

**Family A (r f signs).** In each coordinate j use signed coefficients βj,2βj,...,2^(f−1)βj and anchor component (2^f−1)βj. The unsquared coordinate lies in {0,2,4,...,2(2^f−1)}⊂[0,p−1], an even set whose additive negative in odd-characteristic GF(p) intersects it only in 0. The coordinate vector uniquely determines all signs (binary expansion). If two unsquared sums were negatives, each coordinate would be zero and thus both sums would be identical, from the same sign string. Squaring is therefore injective since u²=v² iff u=±v.

**Family B (e+(r−1)d signs).** In the first basis coordinate use signed coefficients 1,2,...,2^(e−1) and anchor 2^e; the unsquared first-coordinate values are {1,3,...,2^(e+1)−1}⊂[1,p−1], nonzero odd residues with negatives even, so no two are additive negatives. In each of the remaining r−1 coordinates use signed coefficients 1,2,...,2^(d−1) and zero anchor. Their possible signed sums form an arithmetic progression of step 2 and length 2^d≤p; hence each is unique modulo p. Full vectors are distinct and no two are negatives, proving injectivity after squaring. The e=0 case is included. The anchored code remains injective when restricted to an initial subset of sign variables.

**All-support transfer.** Query x_i² for i=1..k. If all are zero, return 0. Otherwise choose the first nonzero i0 and deterministic roots t_i of the observed coordinate squares. Relative to the unknown global sign σ with x_i0=σ t_i0, each other supported x_i=σ ε_i t_i. In a block of b≤B signs, query the legal mixed form with anchor coefficient c0/t_i0 and supported coordinate coefficients c_j/t_i. The observed square is (c0+Σ c_j ε_i)^2, since σ²=1. Use the explicit lookup table to recover ε, then reconstruct x modulo σ. Coefficients depend **only on measured squares**, not unknown signs or an unpowered oracle.

**Optimality at k=B+1.** Each query has M=(Q+1)/2 outputs with Q=p^r. The number of global-sign classes is (Q^k+1)/2. For Q≥3, k≥2, M^k<Q^k/2<(Q^k+1)/2 since (M/Q)^2<1/2. Even an arbitrary adaptive depth-k tree cannot represent every class. Thus the exhibited k+1 measurements are globally minimal under the exact model.

## Frozen finite evidence

| Field | B | information-optimal instance | All-signal test |
|---|---:|---|---|
| GF(9), p3,r2 | 2 | k3=4 | GF9^4, 6,561 signals |
| GF(25), p5,r2 | **3** | **k4=5** | GF25^4, **390,625 signals** |
| GF(49), p7,r2 | **4** | **k5=6** | GF49^3, **117,649 signals**; 10,000 k5 deterministic |
| GF(121), p11,r2 | **5** | **k6=7** | 10,000 k6 deterministic |

In each listed quadratic field, B meets the single-reading alphabet upper bound floor(log2((Q+1)/2)); hence the block itself is capacity-optimal. Explicit GF25 anchored coefficients in the basis (1,u): c0=(2,0), (c1,c2,c3)=((1,0),(0,1),(0,2)); all 8 sign outputs have different squares. Explicit GF49: c0=(3,3), phase coefficients ((1,0),(2,0),(0,1),(0,2)); all 16 outputs distinct.

Exact reproducibility archive: NIGHTFALL_Tessera_OddPrime_SignedDigit_20261030.zip, SHA256 **076b1d59d4a7f194b92a93e1ae08aa611e5db1e8caf4928f64ec6cb672276062**, original conversation. Contains THEOREM.md, standard-library verify.py and independently authored check_independent.py, CHECKS.txt, and a per-file SHA-256 manifest. The first verifier exhaustively decodes full signal spaces, verifies arbitrary support and chosen roots in GF(p²); the second independently enumerates both coefficient families for seven primes p=3/5/7/11/13/17/31 and r=1..4, computes actual squared outputs in four quadratic fields, and rejects the deliberate mutation c0=0 in GF25/GF49. No extrapolation from finite scripts replaces the general proof above.

## Distinct contributions, prior art, limits

Prior NIGHTFALL PR #256's characteristic-three basis construction has B=r for K=GF(3^r). This theorem recovers that case and gives **strictly larger** B for GF25/GF49/GF121 while retaining the **same square oracle within each K**. It is a different field/model from the F16/H=GF4* **cubic** oracle in PR #255; **do not compare rates as fixed-F16 improvements**.

The underlying binary signed-digit and dissociated-set construction uses classical additive combinatorics. Prior relevant sources: Borello–Schmid–Scotti, JCTA 214 (2025), arXiv:2406.04034 (geometry of fixed intersecting codes); Dutta (2026), arXiv:2601.07068 (dissociated sets); Bartusel–Führ–Oussa (2023) treats a different complex affine-group phase oracle. Historical same-model priority review remains incomplete and no outside human referee has reviewed the proof. No worldwide Original Finding, publication, flagship or external submission is claimed/authorized.

**Next theorem gate:** At GF(13²) the method yields B=5, whereas alphabet counting permits six signs. Search for a nonproduct, translated antipodal-free six-dimensional signed cube in GF(13)², or prove a genuine obstruction. Current result makes no claim of optimality for that case.