# Lean certification warrants — 22 November 2026

This additive layer reconciles **six independently identifiable, historically reported named Lean certification families** that were not individually represented in the central v2 overlay. Exact primary references are in [the machine registry](../../../docs/lean-warrant-bridge-v1.json). Each has an individual warrant, current source blob SHA, terminal declaration, historical run, explicit scope, and open review gates.

The frozen 67 historical source-matched files and the current pending-source custody files are **different evidence layers**. They are not rewritten and a `no-verified-receipt` entry in the old custody ledger is not a proof that a separate later named CI run failed. Conversely, the presence of a successful historical run does not establish end-to-end semantic equivalence, mathematical novelty, or a fresh checker replay.

This is **not** a claim of 100% certification census coverage. The initial deterministic checker covers already structured original v16 (15 claims), recent named-receipt passports, v2 named records, Lean overlay records and these six additional warrants; the remaining source files, workflows and PR histories require a separate evidence census, including off-main/closed work. All original source files are still tracked by the existing source custody gate. Existing filenames saying `passport` remain historical compatibility names; new scientific records are called **warrants**.

Run `python3 scripts/check_lean_warrant_coverage.py --self-test` to inspect the source-level classification, coverage sources and omissions without running Lean. Do not promote a theorem based on this metadata check.
