"""Small, deterministic DEMO-only legal derivation checker.

No source becomes authoritative merely by appearing here. A correct derivation
from a bad legal interpretation is still a bad legal conclusion. Never use this
checker to approve real permits, elections, enforcement, or public expenditure.
"""
from __future__ import annotations

from datetime import date
from hashlib import sha256
import json
import re
from pathlib import Path

SCHEMA = "commonwealth.legal-derivation.demo.v1"
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
HASH_RE = re.compile(r"^[0-9a-f]{64}$")
ATOM_RE = re.compile(r"^[a-z][a-z0-9_]{0,79}$")


def _day(value):
    if not isinstance(value, str) or not DATE_RE.fullmatch(value):
        raise ValueError("dates must use YYYY-MM-DD")
    return date.fromisoformat(value)


def _active(item, as_of, known_at):
    start = _day(item["valid_from"])
    end = _day(item["valid_until"]) if item.get("valid_until") else None
    learned = _day(item["observed_at"])
    return start <= as_of and (end is None or as_of < end) and learned <= known_at


def _atom(name):
    if not isinstance(name, str) or not ATOM_RE.fullmatch(name):
        raise ValueError("invalid predicate name")
    return name


def _items(bundle, field):
    entries = bundle[field]
    if not isinstance(entries, list):
        raise ValueError(field + " must be a list")
    result = {}
    for entry in entries:
        if not isinstance(entry, dict) or not isinstance(entry.get("id"), str):
            raise ValueError(field + " entries need string IDs")
        if entry["id"] in result:
            raise ValueError("duplicate " + field + " id " + entry["id"])
        result[entry["id"]] = entry
    return result


def evaluate(bundle):
    """Replay a submitted linear proof against its exact sources.

    Statuses: SUPPORTED_IN_FICTIONAL_MODEL / INDETERMINATE / INVALID.
    SUPPORTED is *not* a legally authoritative verdict, regardless of input.
    """
    try:
        if not isinstance(bundle, dict) or bundle.get("schema") != SCHEMA:
            raise ValueError("unsupported proof schema")
        if bundle.get("mode") != "DEMO" or bundle.get("jurisdiction") != "FICTIONAL_RIVER_COUNTY":
            raise ValueError("live/official jurisdictions are forbidden")
        as_of, known_at = _day(bundle["as_of"]), _day(bundle["known_at"])
        sources = _items(bundle, "sources")
        facts = _items(bundle, "facts")
        rules = _items(bundle, "rules")
        proof = bundle["proof"]
        if not isinstance(proof, list) or len(proof) > 10000:
            raise ValueError("invalid proof steps")
        goal = _atom(bundle["goal"])
        if not sources or not rules:
            raise ValueError("no legal sources or rules supplied")
        for source in sources.values():
            body = source["text"]
            digest = source["sha256"]
            if not isinstance(body, str) or not isinstance(digest, str) or not HASH_RE.fullmatch(digest):
                raise ValueError("invalid source bytes/digest")
            if sha256(body.encode("utf-8")).hexdigest() != digest:
                raise ValueError("source hash mismatch: " + source["id"])
            if source.get("authenticity") != "FICTIONAL" or not str(source.get("locator", "")).startswith("fictional://"):
                raise ValueError("source not marked fictional: " + source["id"])
            if source.get("status") != "ACTIVE":
                raise ValueError("source is suspended/withdrawn: " + source["id"])
            if not _active(source, as_of, known_at):
                return {"status": "INDETERMINATE", "reasons": ["source not applicable/known: " + source["id"]]}
        for item in list(facts.values()) + list(rules.values()):
            sid = item["source_id"]
            if sid not in sources:
                raise ValueError("missing referenced source: " + sid)
            if not isinstance(item.get("quote"), str) or not item["quote"] or item["quote"] not in sources[sid]["text"]:
                raise ValueError("missing verbatim source anchor: " + item["id"])
            if not isinstance(item.get("reviewer"), str) or not item["reviewer"].strip():
                raise ValueError("unreviewed interpretation: " + item["id"])
            if not _active(item, as_of, known_at):
                return {"status": "INDETERMINATE", "reasons": ["claim not applicable/known: " + item["id"]]}
        claimed = {}
        for fact in facts.values():
            predicate = _atom(fact["predicate"])
            value = fact["value"]
            if type(value) is not bool:
                raise ValueError("fact must have explicit Boolean value")
            if predicate in claimed and claimed[predicate] != value:
                raise ValueError("contradictory premises for " + predicate)
            claimed[predicate] = value
        for rule in rules.values():
            _atom(rule["conclusion"])
            for field in ("when_true", "when_false"):
                if not isinstance(rule.get(field), list):
                    raise ValueError("rule missing condition list")
                for predicate in rule[field]:
                    _atom(predicate)
            if set(rule["when_true"]) & set(rule["when_false"]):
                raise ValueError("contradictory rule conditions")
        derived = {}
        dependencies = {}
        for number, step in enumerate(proof, 1):
            if not isinstance(step, dict):
                raise ValueError("bad proof step")
            if step.get("kind") == "fact":
                fact = facts.get(step.get("ref"))
                if fact is None:
                    raise ValueError("unknown fact in proof")
                name, value = fact["predicate"], fact["value"]
                if name in derived and derived[name] != value:
                    raise ValueError("proof contradiction")
                derived[name] = value
                sid = fact["source_id"]
                dependencies[sid] = sources[sid]["sha256"]
            elif step.get("kind") == "rule":
                rule = rules.get(step.get("ref"))
                if rule is None:
                    raise ValueError("unknown rule in proof")
                if not all(derived.get(p) is True for p in rule["when_true"]):
                    return {"status": "INDETERMINATE", "reasons": [f"unproved positive premise at step {number}"]}
                if not all(p in derived and derived[p] is False for p in rule["when_false"]):
                    return {"status": "INDETERMINATE", "reasons": [f"unproved explicit exception denial at step {number}"]}
                name = rule["conclusion"]
                if name in derived and derived[name] is False:
                    raise ValueError("proof contradiction")
                derived[name] = True
                sid = rule["source_id"]
                dependencies[sid] = sources[sid]["sha256"]
            else:
                raise ValueError("unknown proof step kind")
        if derived.get(goal) is not True:
            return {"status": "INDETERMINATE", "reasons": ["goal not derived"]}
        return {"status": "SUPPORTED_IN_FICTIONAL_MODEL",
                "goal": goal, "jurisdiction": bundle["jurisdiction"],
                "as_of": bundle["as_of"], "known_at": bundle["known_at"],
                "dependencies": dict(sorted(dependencies.items())),
                "limitations": ["synthetic evidence only", "legal interpretations not externally validated",
                                "source discovery/completeness not certified", "not an official decision"]}
    except (KeyError, TypeError, ValueError, IndexError) as exc:
        return {"status": "INVALID", "reasons": [str(exc)]}


def source_change_status(previous_receipt, next_sources):
    """Conservative change detector. Unchanged hashes do not establish currency."""
    try:
        deps = previous_receipt["dependencies"]
        current = {s["id"]: s["sha256"] for s in next_sources}
        changed = sorted(sid for sid, digest in deps.items() if current.get(sid) != digest)
        return {"status": "RECHECK_REQUIRED" if changed else "SOURCE_DIGESTS_UNCHANGED",
                "changed_dependencies": changed,
                "warning": "Legal status, completeness and temporal applicability still require rechecking."}
    except (TypeError, KeyError, AttributeError) as exc:
        return {"status": "INVALID", "reasons": [str(exc)]}


def main():
    import argparse
    parser = argparse.ArgumentParser(description="DEMO ONLY legal derivation replay")
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()
    outcome = evaluate(json.loads(args.bundle.read_text(encoding="utf-8")))
    print(json.dumps(outcome, sort_keys=True, indent=2))
    return 0 if outcome["status"] == "SUPPORTED_IN_FICTIONAL_MODEL" else 1


if __name__ == "__main__":
    raise SystemExit(main())
