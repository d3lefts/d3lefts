# NIGHTFALL: November 11 manuscript and PR reconciliation

**Status:** Research-source bookkeeping and specialist-review checklist; not independent proof or priority certification. This entry is part of the November 11, 2026 review branch.

## Canonical publication candidate and retained history

- `papers/finite-product-influence/Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v7.tex`: consolidated **29-page** author-review manuscript, with two local `\input` files for rank-optimal observation. Compiled locally using `latexmk -pdf -interaction=nonstopmode -halt-on-error`.
- Source Git blobs: main .tex `41189b83a514ce419835f076ecc88164f56586b5`; rank intro `e5549dd4bec89520d2683d06cf512dee7da3e9e8`; rank section `3e963d43e5b1893d747ca61050a328e6aaa098ec`.
- Independent local SHA-256: main source `9c5a2a8dafc5aa39af6fda0fbf4800a020e4a8bafa82290039b54d2c2f516f31`; intro `d78b2383beb65d54dcb6b1b267d4e7ff6681ede897cdffc6e33d9a6818a0604d`; section `5b2ea26f8949fe66ff9e7c3e048a7a192fbb1b72caa033b2b4cfddd08437195e`.
- Locally generated PDF SHA-256: `884a3f59a6108559897e808516b2a87d6c9441403cf35f25f6a69df487aee4f6` (29 pages; no PDF binary committed by this PR).
- Earlier sources must remain immutable: PR #379/v5 and PR #382/v6. The v6 .tex was reconstructed byte-for-byte from its archived v5 baseline before v7 edits and independently matched the pinned v6 Git blob `0f8c173fe0b5d723d5a65cde972f259e043cf97c`.

**Independent exact finite replay:** `papers/finite-product-influence/check_rank_posterior_exact.py` (Git blob `2321cbeef3a97efb8b1c1df8579ed1d047a1573e`, SHA-256 `710c5c74110889c611a2bd5a7bb1ed3df450038cb4a02a7f41604cd092373428`) checked 1,638 actual heterogeneous-product conditional posterior energy transitions and 384 rank-dependent lower-bound cases using exact rational arithmetic. Digest `5fc2d5221f4a27ad606beb948c27f278b4645761ac6b3bbeac4df0850703454b`. This is a finite falsifier, not an end-to-end proof.

## One mechanism, not two discoveries

- **PR #335 (merged):** cubic top-degree vertex-cover transfer using averaging over a core and charging removed ANOVA variance to the core influences; dependent on the scalar quadratic theorem.
- **PR #381 (draft):** same core-removal mechanism generalized to an arbitrary high-degree function with at most two active coordinates outside its `k`-coordinate backdoor; useful algebraic sharpening but do not count as independent discovery of that mechanism. The claim `V² <= (5043+2k)B²M` can be strengthened by importing the better scalar quadratic coefficient from v6/v7 to `V² <= [225(1+sqrt(3))²+2k]B²M`.
- **Separate candidate from #381:** the exact sharp norm `||P_<=d-1 f||_infty <= (2^(2d-1)-1)||f||_infty` has its own Chebyshev interpolation proof and Bernoulli extremizers. It has not passed specialist worldwide prior-art review; classical Chebyshev/fourier-growth mechanisms must be credited.
- **PR #380 (draft, exact negative control):** cubic shared rare-core model defeats a direct use of the quadratic independent-increment fourth-moment estimate. It does *not* refute cubic exponent two.
- **PR #349 (merged):** tripartite cubic reduction and open dimension-free link-energy inequality; no unrestricted cubic bound.

## Proof and release gates

1. **Valid scope:** all-degree analytic law-free scalar influence `V^(5/2)/d^6`, derived from Turturean's original uniform Boolean cube machinery. Independently audit the two-draw, fractional-row, median and resampling bridges.
2. **Stronger degree two:** scalar constant `225(1+sqrt(3))²`, vector constant `675(1+sqrt(3))²r`, finite-product posterior upper cap `ceil(2700(1+sqrt(3))²rB²/eta)`, and explicit `r/(4eta)` lower family. Verify full coupling/section and posterior arguments rather than promoting the currently scoped Lean sublemmas.
3. **Formal boundary:** the finite heterogeneous-product `(5/2,6)` theorem alone has an earlier pinned Lean certificate with a smaller numerical coefficient; later 4B/8B/16B, n-increment fourth-moment and posterior-energy lemmas are isolated. No v7 end-to-end Lean theorem, non-author independent review, or global originality certificate is claimed.
4. **Release:** never submit to arXiv or call v7 externally reviewed without the author's explicit approval. CI records build/source checks, not proof validity.
5. **Branch hygiene:** #373/#377/#378 have scoped successful Lean work but some head CI also fails website/provenance guards due new unclassified Lean source files. Register named declarations and exact source/CI receipts in the provenance ledger on the owning branches; never bypass the guard.

**Recommended next decisive experiment:** independently prove or break the algebraic rank/projection-to-posterior step on small *actual* heterogeneous categorical products, then solicit a non-author specialist referee on v7. For cubic, condition on shared cores and estimate variance-of-conditional-energy rather than reusing independent moment inequalities.
