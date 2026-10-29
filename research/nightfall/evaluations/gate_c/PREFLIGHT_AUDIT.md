# VESPER / Observatory Gate C — frozen-input preflight and scope audit

**Date:** 2026-10-28 / local research review, before any prospective trial.  
**Status:** source-byte preflight implemented; Gate C evaluation **PENDING**; Gate D release **BLOCKED**.  
**Origin:** immutable Gate C v1 task packet and 14-node Observatory graph from [draft PR #19](https://github.com/d3lefts/d3lefts/pull/19). This audit neither changes their frozen identity locks nor overwrites source material.

## What has been independently established

Six preregistered tasks, two each for finite-field reconstruction, Werner positivity and proposed spectral coupling, refer to **six distinct scientific source files** frozen at commit \`df9511c622c309046180fd0e015aca88577c58ec\`. All six source blobs exist. The task and graph input files are byte-pinned at Observatory preview commit \`f1ee6ad517a46e5065ad700571a7080f7d5ee9e9\`. The equal conditions budget remains 2,000 total input/output tokens, 20 tool calls and 30-minute cap per arm/challenge, seed 1729.

A separate source-lock manifest and a standard-library Node preflight verify git blob identities, recompute **SHA-256 of the original source bytes**, reject mismatched/omitted sources, check exact task-set byte equality and verify the graph lock. The runner creates a machine-readable report from exact pinned bytes; an unrun benchmark is never labeled passed.

Run on a complete checkout with the two pinned commits fetched:

\`\`\`bash
git fetch --no-tags --depth=1 origin df9511c622c309046180fd0e015aca88577c58ec
git fetch --no-tags --depth=1 origin f1ee6ad517a46e5065ad700571a7080f7d5ee9e9
node scripts/check_gate_c_preflight.cjs --json --self-test
\`\`\`

The preflight is an *input-integrity* check, not an actual matched model/tool comparison. The real study needs 12 isolated arm runs, independent blinded grading, raw outputs and exact per-run token/tool metering.

## Four blocking scientific design questions

**1. Input budget is narrower than several source files.** The six sources include handoff and proposal records of roughly 14.4 KB and 14.6 KB, and an 11.1 KB Werner atlas. Raw whole-document insertion may consume the full 2,000-token allowance before the agent can answer. Both arms need the same **predeclared retrieval/index protocol** and exact token accounting for every excerpt and tool result. Extra graph text and hidden answer hints must be charged. A retrieval policy that suppresses source information from the flat arm would invalidate the comparison.

**2. The Observatory graph currently encodes different relationship semantics.** Frozen historical node \`NF-AXIOM-KERNEL-v1\` has a \`dependencies\` reference to \`NF-FIELD-SPAN-v1\`, while typed relationship \`TR-007\` calls that link a *shared mathematical mechanism*. The prime-field, source-conditional short-vector span-count theorem is logically distinct from the iid **fixed-\(\mathbb F_{25}\)** Frobenius-lift theorem. The fixed-field theorem manuscript's proof uses independent elementary field identities, not the prime-field span-count assumption. If a dependency is intended as a proof prerequisite, the reference is scientifically misleading. Correct through a **new, reviewed historical claim identity**; preserve the original frozen lock and record the correction. This affects a benchmark whose primary endpoint is whether a researcher selects the correct missing premise.

**3. The spectral source set is a proposal, not a frozen spectral positivity certificate.** SP-01 and SP-02 both cite the speculative research-proposals note, with a Werner source as analogy. They can legitimately assess whether an agent recognizes that a uniform tail/coupling estimate is missing, **not** whether it independently reproduces an actual high-rank spectral positivity proof. Their grading rubric needs that explicit boundary. If spectral-proof accuracy is a desired endpoint, prepare a new v2 preregistration with appropriate pinned primary source; never silently relabel these v1 tasks.

**4. The owner's public Mechanism Atlas and Proof Passports are now a stronger baseline than a plain chronological archive.** Because they already expose conditions and links, the intervention's value must be described precisely. The original G-versus-flat test remains valid as a narrower navigation-index study if its atomic information is equal. It cannot establish that Observatory beats the owner's newer evidence tools. A meaningful follow-up should include those as a separately preregistered baseline, not contaminate the frozen two-arm v1 trial.

## Controlled-trial acceptance criteria

- **Source-equivalent:** the same primary source bytes accessible under both arms, same indexing/search policy, same answerable facts; typed relationships alone differ.
- **Blinded:** randomized order with seed 1729; assessor sees masked arms and a frozen reference rubric; source timestamps and evaluation outputs are hidden from operators.
- **Primary:** correctly specified *decisive next test plus a reproducible exact acceptance/failure condition*, assessed independently of attractive rhetoric.
- **Secondary:** false implication, unjustified proof-status promotion, valid obstruction identification, number of files inspected, tokens and tool calls.
- **Publication:** all 12 raw participant outcomes and blinded ratings; report unfavorable and null comparisons, with no population efficacy claim from six pairs.
- **Scientific trust:** pass of this manifest does **not** imply Gate C passed, Gate D allowed, or theorem status promoted.

**Requested handoff:** Ryev [issue #30](https://github.com/d3lefts/d3lefts/issues/30) controls the paired-study implementation; Axiom and Lemnis are available for *separate* frozen-source adjudication once the rubric is finalized. Vesper controls scope reconciliation, input integrity and proof-boundary classification.
