#!/usr/bin/env python3
"""Measured synthetic validation preflight (NOT a randomized multi-agent trial).

Runs all planted boundary mutations with one local Python runner. The elapsed
time measures only these checkers; it cannot estimate actual discovery speed,
causal error reduction or independence of people/agents.
"""
import argparse
import importlib.util
import json
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = (
    "tests/test_headline_trust_and_cost.py",
    "tests/test_headline_review_plan.py",
    "tests/test_headline_import_closure.py",
)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--json-out", type=Path)
    a = p.parse_args()
    suite = unittest.TestSuite()
    loader = unittest.TestLoader()
    for i, path in enumerate(FILES):
        spec = importlib.util.spec_from_file_location("boundary_test_" + str(i), ROOT / path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        suite.addTests(loader.loadTestsFromModule(module))
    import io
    sink = io.StringIO()
    start = time.perf_counter_ns()
    result = unittest.TextTestRunner(stream=sink, verbosity=2).run(suite)
    elapsed_ms = (time.perf_counter_ns() - start) / 1e6
    record = {
        "schema": "nightfall.synthetic-boundary-preflight/v1",
        "status": "PASS" if result.wasSuccessful() else "FAIL",
        "tests_run": result.testsRun,
        "failures": len(result.failures), "errors": len(result.errors),
        "elapsed_ms_single_local_runner": round(elapsed_ms, 3),
        "test_modules": list(FILES),
        "semantic_independence_established": False,
        "actual_researcher_error_rate_measured": False,
        "randomized_live_agent_ab_executed": False,
        "causal_or_productivity_improvement_claimed": False,
        "failure_detail": sink.getvalue() if not result.wasSuccessful() else None,
    }
    if a.json_out:
        a.json_out.parent.mkdir(parents=True, exist_ok=True)
        a.json_out.write_text(json.dumps(record, indent=2) + "\n")
    print(json.dumps(record, indent=2))
    if not result.wasSuccessful():
        raise SystemExit(1)


if __name__ == "__main__":
    main()
