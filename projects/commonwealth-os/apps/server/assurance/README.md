# Bounded, source-different assurance experiment

Generate 216 deterministic fixture traces with real SQLite v0.4 commands, source-level independently verified signed passports, and pipe them to an independent exact-integer Python oracle:

```bash
node assurance/generate-cases.mjs | python3 assurance/check_cases.py
```

The finite universe is 3 voters choosing one of yes/no/abstain each, 4 exact rational denominator bases and strict/non-strict two-thirds. All examples use a fictional institution and mock officials. The Python code checks state edges, actors, vote uniqueness, quorum, lock epochs, exact threshold and outcome independently of the source application.

This is a *bounded exhaustive test*, not a Lean theorem about compiled JavaScript/PostgreSQL or actual statutory authorization. The Lean project in PR #613 is a separate conditional model certificate. Record any counterexamples, update the fixture and proof obligation, and never promote tests into a proof by repetition.
