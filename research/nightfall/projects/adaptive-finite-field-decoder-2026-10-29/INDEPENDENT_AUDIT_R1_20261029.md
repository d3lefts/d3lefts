# Independent audit: sharp q=3 second-round bound and square-oracle digit packing

**29 October 2026 · NIGHTFALL · R1 mathematical candidate · review requested.**
Research lead: Devin J. Wright. Derivation and fresh finite checker AI-assisted. No human referee, established novelty, or publication authorization. **This branch is draft-only.** Preserve the older decoder manuscripts and their attributed results.

## 1. Original oracle: sharpness over an entire simultaneous second round

Fix K=F_(3^r), r>=2. The original powered oracle is (a·x)^2 (since q=3). Query all k coordinate squares, giving a known support S of size s and one sign ambiguity per supported coordinate. Normalize a supported anchor.

**Proposition A.** If all remaining m measurements are selected simultaneously after those k coordinate readings, reconstruction of every signal modulo global sign requires m>=ceil(max(s-1,0)/r). The existing characteristic-three cancellation construction attains this bound, and is therefore **optimal in this restricted coordinate-first, simultaneous-second-round model**.

**Proof.** Write h=s-1. For fixed first-round observations, the remaining phase assignments form {+1,-1}^h over F_3. The unpowered observations from any m simultaneous K-linear rows are an affine F_3-linear map c+T ε with T:F_3^h→K^m. Its target has F_3 dimension rm. If h>rm, pick a nonzero v in ker(T). Every v_i in F_3 equals ε_i−ε'_i for some ε_i,ε'_i in {+1,-1}. Thus two distinct phase assignments have identical **unpowered** observations, hence identical squared outputs, and share the first-round coordinate squares. Contradiction. The previously documented construction packs r relative signs per second-round measurement. QED.

At r=2,k=s=6, after six coordinate probes two additional simultaneous measurements are impossible; three are sufficient. This is **not** a global lower bound on arbitrary adaptive first-round schemes. The global transcript-count lower bound is eight total queries and the archived construction uses nine; the gap remains open.

## 2. Different oracle: square-power binary-digit packing over p>=5

Now take prime p>=5, K=F_(p^r), r>=2, **oracle (a·x)^2**, identifiable modulo {+1,-1}. For p>3 this differs from the original full-phase (a·x)^(p-1) oracle, so never compare the bounds as if they were for identical access.

Let d=floor(log2 p), B=rd-1. After k coordinate squares choose arbitrary nonzero roots u_j, write x_j=λ_j u_j with λ_j∈{+1,-1}, and anchor t. Partition the s-1 remaining relative signs η_j=λ_j/λ_t into blocks of size at most B. Choose a base-field basis β_0,...,β_(r-1) of K. Each full-block query (with legal coefficients β_i/u_j and anchor coefficient) has unpowered interior

λ_t · [ β_0 (2^(d-1)+sum_(j=0)^(d-2) 2^j η_(0,j))
      + sum_(i=1)^(r-1) β_i sum_(j=0)^(d-1) 2^j η_(i,j) ].

**Proposition B.** Each such squared query recovers all B relative signs, giving at most k+ceil(max(s-1,0)/B) total queries. This achieves the **global adaptive** k+1 lower bound for 2<=k<=B+1, within this square-power model.

**Proof.** The β_0 coordinate lies in A={1,3,...,2^d-1} mod p. Since 2^d<=p and p is odd, A∩(-A)=∅: the representatives in A are odd and their negatives are even positive residues. Thus one of the two square roots is uniquely oriented by its β_0 coordinate. Every remaining coordinate is a balanced binary sum; two distinct sign patterns differ by 2(n-n') with 0<|n-n'|<=2^d−1<p, so cannot coincide modulo p. For a partial block, set its unused relative phase slots to known +1 and implement these terms in the anchor coefficient; decoding is unchanged. The decision-tree inequality N_k>N_1^k for N_j=1+(p^(rj)-1)/2 gives the unconditional k+1 lower bound for k>=2. QED.

For p=5,r=2, this packs 3 signs per mixed query versus the 2 signs in the earlier r-phase subgroup construction. Example coefficients for (β_0,β_1) are anchor (2,0), phases (1,0),(0,1),(0,2). The eight patterns yield eight distinct square-orbits among the 13 possible outputs.

## 3. Mersenne-prime strengthening

**Proposition C.** If p=2^(d+1)-1 is prime, each square-power mixed query can encode **rd** independent relative signs, so the two-round total is k+ceil(max(s-1,0)/(rd)). Set the anchor shift c=2^d−1 in *each* of r basis coordinates and give each coordinate d signed binary weights 1,2,...,2^(d-1). Its alphabet is A={0,2,...,p-1}, satisfying A∩(-A)={0}; equality up to sign therefore forces identical relative phase patterns. For r=2, rd=2d exactly matches floor(log2((p²+1)/2)), the information maximum for one additional query. QED.

In particular p=7,r=2 packs **4** phases (16 distinct outputs among 25), and p=31,r=2 packs **8** phases. This is again *square-power subgroup* work, not an improvement to exponent p-1.

## Verification, prior art, and release gates

- New implementation uses only F_p-vector coordinates and quotient identification z~−z, rather than copying the earlier finite-field decoders. In a field of odd characteristic this is **exactly** the equality relation for squared outputs.
- Local full audit: **729 exhaustive** q3 rank/affine coefficient cases, **10,000** seeded two-query q3 collision reconstructions, q3 cancellation patterns for r=2..7, **27** uniform binary-digit models, **4** Mersenne models, **1,068** partial-prefix patterns, **3** negative controls. All passed. The attached short GitHub checker verifies central small witnesses; the fuller reproducibility package (SHA256 ZIP \`091cc7e5b91b3a76c58f36efec01296aa85f3a6fe875b157e50b2745da490640\`) is preserved in the originating research session, **not** asserted hosted on GitHub.
- Classical prior art: Balan–Casazza–Edidin's complement property and the 2025 *Phasebook* survey; the 2023 *Phase retrieval for affine groups over prime fields* paper concerns a different complex group-frame model. The existing [projective-phase subgroup dossier](PHASE_ALPHABET_PROJECTIVE_PACKING_20261029.md) credits subgroup translation results. A targeted 29 Oct 2026 search did not establish same-model novelty clearance.
- **Open gates:** non-author proof attack; fully separate prime-power and representative-selection replay; true same-hypotheses priority check; owner publication signoff. No website, main branch, or claim-status promotion.

**Exact falsifiers:** any two sign assignments with identical claimed full-block square orbit; any counterexample with padded known slots; any source showing the same packed-query formula earlier. **Stop rule:** retract or scope down immediately upon counterexample or earlier same-model result.