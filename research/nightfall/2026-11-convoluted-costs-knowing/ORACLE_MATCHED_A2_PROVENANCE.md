# A2 upload manifest and certification boundary

**Record date:** 2026-11-13. **Repository:** `d3lefts/d3lefts`; draft PR #450; branch `nightfall-oracle-matched-task-revelation-20261113`.

## Findings actually committed to this Git branch

- `ORACLE_MATCHED_TASK_REVELATION_A1.md`: finite singleton-oracle exact-leading-cost analytic theorem and general KL information-cover converse, including scope and limitations.
- `ORACLE_MATCHED_GROUP_INFORMATION_COVER_A2.md`: full source-level independent-output grouped-oracle theorem, fractional cover primal/dual, adaptive transcript testing converse, shared-cost schedule and recovery proof, and three-cycle example.
- `check_task_revelation_exact_ci.py`: finite rational A1 falsifier.
- `check_group_information_cover_exact_ci.py`: separate group-source likelihood and primal/dual falsifier.
- `check_group_cover_exact.py`: byte-identical copy of the **independently authored full A2 checker** from the conversation's A2 paper bundle; original Git blob SHA1 `40252bd31aa7cc19974b3b94d0a5cd25cbfc1dc8`, SHA-256 `558946c59fa800b0cdfd5c3cd72afaa84dc03d6bd0b2033654d2dff612a5b356`.
- `.github/workflows/nightfall-oracle-matched-task-revelation.yml`: CI executes all three checkers and logs hashes, without claiming that finite tests certify the universal theorem.

The existing A1/A2 analytic Markdown files contain the mathematical claims and their proof mechanisms; they are not merely a description of the existence of an inaccessible PDF.

## Separate complete paper / reproduction bundle (conversation artifact, **not** uploaded to GitHub)

The complete companion A2 ZIP contains a five-page PDF, editable TeX, full exact checker, README, and manifest. Its internal files have the following original SHA-256 digests, verified by inspecting the ZIP archive bytes independently in the current session:

```text
ed9a82d1419d819c64b73fc53bb4334f5653bedab455fb338516e0d1cfac7dbb  Oracle_Matched_Group_Information_Cover_A2.pdf  (ZIP member)
d823ee79c7f196ab871d7b9f64da378fb0e40101bee44e04016b2f88d0fe4eda  Oracle_Matched_Group_Information_Cover_A2.tex
558946c59fa800b0cdfd5c3cd72afaa84dc03d6bd0b2033654d2dff612a5b356  check_group_cover_exact.py
400467fcaa601117eecd93b7000538a9bd07b843c9867907c6fc66eee61b0cb1  README_A2.md
```

**File-version caveat:** the separately mounted local PDF was subsequently replaced/changed and has SHA-256 `cb98298c43fa88a95d45880f675c5652f8c190164d15fbfedf760d10854c7412`, even though its size remains 280357 bytes. The original manifest hash `ed9a82...` matches the PDF **inside the ZIP**, not the later standalone mounted PDF. A failing `sha256sum -c` against the later standalone version is a version mismatch, **not** a verified reproduction of the archive. Do not silently substitute one PDF for the other.

The full binary PDF and ZIP are currently **not committed to the Git repository**. The archive can be retained/downloaded from its conversation artifact; the repo contains the original full exact checker and complete analytic proof in Markdown. Do not cite a nonexistent Git PDF path.

## Exact independent replay

To reproduce the *committed* mathematical-instance falsifiers on this branch, run:

```bash
python3 research/nightfall/2026-11-convoluted-costs-knowing/check_task_revelation_exact_ci.py
python3 research/nightfall/2026-11-convoluted-costs-knowing/check_group_information_cover_exact_ci.py
python3 research/nightfall/2026-11-convoluted-costs-knowing/check_group_cover_exact.py
sha256sum research/nightfall/2026-11-convoluted-costs-knowing/check_group_cover_exact.py
```

Expected full checker output begins `PASS group-coverage exact audit: primal/dual 3/2`, and confirms 512 independent hidden-sign likelihood checks, 128 exact conditional-risk checks, and 12 exact finite stopping-time checks. These are **finite falsifiers**, not a proof of the asymptotic claim.

## Claim boundaries and next milestone

**Analytic theorem candidate (author-side):** for group experiments returning independent noisy components, the early versus late task-revelation acquisition leading cost is the task-prior average of fractional information-cover values versus the fractional cover value of the union of task supports. A universal adaptive KL converse and matching scheduled/continued SPRT upper are written out under the declared oracle.

**Not proved or claimed:** originality relative to Wald–Wolfowitz, Wu–György–Szepesvári (2015), Suruga, Li–Liu; a matching result for a general nonseparable mixed-observation or full-function posterior oracle; independent non-author referee approval; end-to-end Lean proof; external publication.

**Next decisive experiment:** ask an independent reviewer to reproduce the boundary-conditioned group-oracle KL identity and the fractional-schedule completion overshoot argument, then attempt to subsume the coefficient using the 2015 noisy group-feedback and 2026 KL-conversion theorems. Only after a non-subsumed structural generalization should this candidate be promoted as a major discovery.
