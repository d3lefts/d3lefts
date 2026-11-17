# AURORA evidence packet

`reference-run.json` records the exact source hashes, command, input parameters, recorded checker output, and known limits for the archived `labs/output.csv` trace.

A SHA-256 digest checks byte identity against the manifest; it does **not** authenticate the creator, prove the source code correct, or validate a physical model. To verify actual provenance, the manifest would need binding to a trusted identity/revision in a separately governed workflow.

Recheck the source and compare replay output:

```bash
python3 labs/aurora.py --seed 2026 --trials 5000 --policy quorum --out labs/output.csv
python3 labs/audit.py labs/output.csv
python3 -m unittest discover -s labs -p 'test_*.py' -v
```

An independently written trace arithmetic checker is useful; formal independence of research criticism requires separate human or otherwise genuinely independent verification and testing of assumptions.
