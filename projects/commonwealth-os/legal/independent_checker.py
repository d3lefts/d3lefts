"""Source-different audit of the fictional legal proof object.

Does not import the producer's kernel. The two checkers intentionally perform
independent parsing, evidence lookup and step replay. Both are DEMO ONLY.
"""
from __future__ import annotations

from datetime import datetime
from hashlib import sha256
import json
from pathlib import Path
import re


def check(document):
    try:
        if document["schema"] != "commonwealth.legal-derivation.demo.v1":
            raise ValueError("unknown protocol")
        if (document["mode"], document["jurisdiction"]) != ("DEMO", "FICTIONAL_RIVER_COUNTY"):
            raise ValueError("real authority not supported")
        clock = datetime.strptime(document["as_of"], "%Y-%m-%d").date()
        observed = datetime.strptime(document["known_at"], "%Y-%m-%d").date()
        source_rows, fact_rows, rule_rows = (document[name] for name in ("sources", "facts", "rules"))
        if not isinstance(source_rows, list) or not isinstance(fact_rows, list) or not isinstance(rule_rows, list):
            raise ValueError("invalid collections")
        if not source_rows or not rule_rows:
            raise ValueError("no legal basis")
        if any(not isinstance(row, dict) or not isinstance(row.get("id"), str)
               for rows in (source_rows, fact_rows, rule_rows) for row in rows):
            raise ValueError("invalid record")
        def table(rows):
            out = {r["id"]: r for r in rows}
            if len(rows) != len(out):
                raise ValueError("duplicate record ID")
            return out
        sources, facts, rules = table(source_rows), table(fact_rows), table(rule_rows)
        def valid_date(value):
            if not isinstance(value, str) or re.fullmatch(r"\d{4}-\d{2}-\d{2}", value) is None:
                raise ValueError("invalid date syntax")
            return datetime.strptime(value, "%Y-%m-%d").date()
        def in_scope(row):
            lower = valid_date(row["valid_from"])
            upper = valid_date(row["valid_until"]) if row.get("valid_until") else None
            publication = valid_date(row["observed_at"])
            return lower <= clock and (upper is None or clock < upper) and publication <= observed
        for src in sources.values():
            if src.get("status") != "ACTIVE" or src.get("authenticity") != "FICTIONAL":
                raise ValueError("source not active/fictional")
            if not str(src.get("locator", "")).startswith("fictional://"):
                raise ValueError("external source not permitted")
            if not isinstance(src.get("text"), str) or not isinstance(src.get("sha256"), str):
                raise ValueError("bad source")
            if re.fullmatch("[0-9a-f]{64}", src["sha256"]) is None:
                raise ValueError("bad digest")
            if sha256(src["text"].encode("utf-8")).hexdigest() != src["sha256"]:
                raise ValueError("content changed")
            if not in_scope(src):
                return {"status": "INDETERMINATE"}
        atoms = {}
        for row in fact_rows + rule_rows:
            parent = sources.get(row.get("source_id"))
            if parent is None or not isinstance(row.get("quote"), str) or not row["quote"] or row["quote"] not in parent["text"]:
                raise ValueError("unanchored proposition")
            if not isinstance(row.get("reviewer"), str) or not row["reviewer"].strip():
                raise ValueError("reviewer missing")
            if not in_scope(row):
                return {"status": "INDETERMINATE"}
        def atom(name):
            if not isinstance(name, str) or re.fullmatch("[a-z][a-z0-9_]{0,79}", name) is None:
                raise ValueError("bad predicate")
            return name
        for row in facts.values():
            a = atom(row["predicate"])
            value = row["value"]
            if type(value) is not bool:
                raise ValueError("not Boolean")
            if a in atoms and atoms[a] is not value:
                raise ValueError("inconsistent evidence")
            atoms[a] = value
        for row in rules.values():
            atom(row["conclusion"])
            pos, neg = row.get("when_true"), row.get("when_false")
            if not isinstance(pos, list) or not isinstance(neg, list):
                raise ValueError("bad rule")
            if set(pos) & set(neg):
                raise ValueError("impossible rule conditions")
            for a in pos + neg:
                atom(a)
        goal = atom(document["goal"])
        if not isinstance(document["proof"], list) or len(document["proof"]) > 10000:
            raise ValueError("bad proof")
        validated = {}
        support = {}
        for step in document["proof"]:
            if not isinstance(step, dict):
                raise ValueError("bad step")
            kind, identifier = step.get("kind"), step.get("ref")
            if kind == "fact":
                row = facts[identifier]
                name, value = row["predicate"], row["value"]
            elif kind == "rule":
                row = rules[identifier]
                if any(validated.get(p, None) is not True for p in row["when_true"]):
                    return {"status": "INDETERMINATE"}
                if any(p not in validated or validated[p] is not False for p in row["when_false"]):
                    return {"status": "INDETERMINATE"}
                name, value = row["conclusion"], True
            else:
                raise ValueError("unknown step")
            if name in validated and validated[name] is not value:
                raise ValueError("contradictory deduction")
            validated[name] = value
            origin = sources[row["source_id"]]
            support[origin["id"]] = {key: origin.get(key) for key in ("sha256", "status", "valid_from", "valid_until", "observed_at", "authenticity", "locator")}
        if validated.get(goal) is not True:
            return {"status": "INDETERMINATE"}
        return {"status": "SUPPORTED_IN_FICTIONAL_MODEL", "dependencies": dict(sorted(support.items()))}
    except (KeyError, ValueError, TypeError, OverflowError) as ex:
        return {"status": "INVALID", "reason": str(ex)}


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Independent fictional legal proof checker")
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()
    result = check(json.loads(args.bundle.read_text(encoding="utf-8")))
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result["status"] == "SUPPORTED_IN_FICTIONAL_MODEL" else 1


if __name__ == "__main__":
    raise SystemExit(main())
