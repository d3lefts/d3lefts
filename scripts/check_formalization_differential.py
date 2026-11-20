#!/usr/bin/env python3
"""Audit exact, staged differential evidence for finite computational claims.

This is a *replay of frozen bytes and their declared provenance*, not an execution
of the listed checker commands, an independence proof, a Lean kernel check, or a
certification of the source theorem. Run producer commands independently first.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import tempfile
from pathlib import Path

SCHEMA = "nightfall.formalization-differential/v1"
HEX64 = re.compile(r"[0-9a-f]{64}\Z")
VERSION = re.compile(r".+v[0-9]+\Z")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def file_at(root: Path, rel: str) -> Path:
    require(isinstance(rel, str) and rel and not rel.startswith("/"),
            "Missing/absolute file path")
    require(all(x not in ("", ".", "..") for x in rel.split("/")),
            "Noncanonical/escaping file path")
    p = (root / rel).resolve()
    require(p.is_relative_to(root.resolve()) and p.is_file(),
            "Missing or external input/output: " + rel)
    return p


def fingerprint(root: Path, rec: dict, role: str) -> bytes:
    require(isinstance(rec, dict), role + ": expected file object")
    path = file_at(root, rec.get("path"))
    claimed = rec.get("sha256")
    require(isinstance(claimed, str) and HEX64.fullmatch(claimed) is not None,
            role + ": invalid SHA-256")
    data = path.read_bytes()
    require(hashlib.sha256(data).hexdigest() == claimed,
            role + ": source or output hash mismatch: " + rec["path"])
    return data


def canonical_ndjson(data: bytes, count: int, role: str) -> None:
    require(isinstance(count, int) and not isinstance(count, bool) and count >= 0,
            role + ": invalid record count")
    require(not data or data.endswith(b"\n"),
            role + ": NDJSON must end with newline")
    rows = data.splitlines()
    require(len(rows) == count, role + ": row count mismatch")
    for line in rows:
        try:
            value = json.loads(line, parse_float=lambda _: (_ for _ in ()).throw(
                ValueError("floating-point JSON forbidden; use exact strings")))
        except (ValueError, UnicodeDecodeError) as exc:
            raise ValueError(role + ": non-exact or malformed NDJSON: " + str(exc)) from exc
        encoded = json.dumps(value, sort_keys=True, ensure_ascii=False,
                             separators=(",", ":"), allow_nan=False).encode("utf-8")
        require(line == encoded, role + ": noncanonical NDJSON record")


def audit(doc: dict, root: Path) -> dict:
    require(isinstance(doc, dict) and doc.get("schema") == SCHEMA,
            "Unknown manifest schema")
    source = doc.get("source")
    require(isinstance(source, dict) and
            isinstance(source.get("identifier"), str) and
            VERSION.fullmatch(source["identifier"]) is not None and
            isinstance(source.get("url"), str) and source["url"].startswith("https://"),
            "Source must include exact version and HTTPS URL")
    spec = doc.get("specification")
    fingerprint(root, spec, "specification")
    inputs = doc.get("inputs")
    require(isinstance(inputs, list) and inputs,
            "Frozen input manifest missing")
    input_paths = []
    for rec in inputs:
        fingerprint(root, rec, "input")
        input_paths.append(rec["path"])
    require(len(set(input_paths)) == len(input_paths), "Duplicated input file")
    stages = doc.get("stages")
    required = doc.get("required_stage_ids")
    require(isinstance(stages, list) and stages and isinstance(required, list) and required,
            "Nonempty stage DAG and declared coverage required")
    ids = [s.get("id") for s in stages if isinstance(s, dict)]
    require(len(ids) == len(stages) and all(isinstance(x, str) and x for x in ids)
            and len(set(ids)) == len(ids) and ids == required,
            "Required stage IDs must match manifest stages in order")
    seen = set()
    checked = 0
    for s in stages:
        sid = s["id"]
        require(isinstance(s.get("paper_lemma"), str) and s["paper_lemma"].strip(),
                sid + ": no precise source lemma")
        deps = s.get("depends_on")
        require(isinstance(deps, list) and len(set(deps)) == len(deps)
                and all(x in seen for x in deps),
                sid + ": undeclared, cyclic, or out-of-order dependency")
        implementations = s.get("implementations")
        require(isinstance(implementations, list) and len(implementations) >= 2,
                sid + ": two implementations required")
        modes, families, checker_paths, outputs, counts = set(), set(), set(), [], set()
        for impl in implementations:
            require(isinstance(impl, dict), sid + ": invalid implementation")
            mode = impl.get("mode")
            family = impl.get("lineage")
            require(mode in ("reference", "spec_independent"),
                    sid + ": implementation mode must be explicit")
            require(isinstance(family, str) and len(family.strip()) >= 3
                    and family not in families, sid + ": shared/ambiguous code lineage")
            require(isinstance(impl.get("command"), list) and impl["command"]
                    and all(isinstance(x, str) and x for x in impl["command"]),
                    sid + ": replay command absent")
            source_rec, output_rec = impl.get("checker"), impl.get("output")
            fingerprint(root, source_rec, sid + ": checker")
            payload = fingerprint(root, output_rec, sid + ": output")
            canonical_ndjson(payload, impl.get("records"), sid + ": output")
            checker_paths.add(source_rec["path"])
            modes.add(mode)
            families.add(family)
            outputs.append(payload)
            counts.add(impl["records"])
        require(len(checker_paths) == len(implementations),
                sid + ": duplicate checker implementation")
        require("reference" in modes and "spec_independent" in modes,
                sid + ": reference and specification-only verifier required")
        require(len(counts) == 1 and all(o == outputs[0] for o in outputs[1:]),
                sid + ": differential output mismatch")
        seen.add(sid)
        checked += len(implementations)
    claims = doc.get("claim_boundaries")
    require(claims == {"independent_code_audited": False,
                       "formal_semantics_proven": False,
                       "full_theorem_certified": False,
                       "external_peer_review": False},
            "This byte-level evidence gate must not promote semantic or theorem status")
    return {"stages": len(stages), "checker_outputs_verified": checked,
            "independent_spec_verifiers_documented": len(stages),
            "scope": "frozen-bytes-and-differential-output-only",
            "semantic_soundness_checked": False}


def self_test() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        for name, content in {
            "spec.txt": b"source theorem stage contract v3\n",
            "input.txt": b"frozen exact input\n",
            "ref.py": b"# reference implementation\n",
            "ind.py": b"# independent specification-only implementation\n",
            "ref.ndjson": b'{"value":"1/3"}\n',
            "ind.ndjson": b'{"value":"1/3"}\n',
        }.items():
            (root / name).write_bytes(content)
        def f(name: str) -> dict:
            return {"path": name, "sha256": hashlib.sha256((root / name).read_bytes()).hexdigest()}
        base = {
            "schema": SCHEMA,
            "source": {"identifier": "arxiv:example.v3", "url": "https://arxiv.org/abs/example"},
            "specification": f("spec.txt"),
            "inputs": [f("input.txt")],
            "required_stage_ids": ["lemma-A1"],
            "stages": [{
                "id": "lemma-A1", "paper_lemma": "Lemma A.1", "depends_on": [],
                "implementations": [
                    {"mode": "reference", "lineage": "original-cpp", "command": ["python3", "ref.py"],
                     "checker": f("ref.py"), "output": f("ref.ndjson"), "records": 1},
                    {"mode": "spec_independent", "lineage": "fresh-python", "command": ["python3", "ind.py"],
                     "checker": f("ind.py"), "output": f("ind.ndjson"), "records": 1},
                ],
            }],
            "claim_boundaries": {
                "independent_code_audited": False,
                "formal_semantics_proven": False,
                "full_theorem_certified": False,
                "external_peer_review": False,
            },
        }
        require(audit(base, root)["stages"] == 1, "Positive fixture failed")
        mutations = [
            lambda d: d.update(schema="unrecognized"),
            lambda d: d["source"].update(identifier="arxiv:example"),
            lambda d: d["specification"].update(sha256="0" * 64),
            lambda d: d["inputs"][0].update(sha256="0" * 64),
            lambda d: d.update(required_stage_ids=["lemma-A2"]),
            lambda d: d["stages"][0].update(depends_on=["lemma-A1"]),
            lambda d: d["stages"][0]["implementations"][1].update(lineage="original-cpp"),
            lambda d: d["stages"][0]["implementations"][1].update(mode="reference"),
            lambda d: d["stages"][0]["implementations"][1]["checker"].update(
                path="ref.py", sha256=f("ref.py")["sha256"]),
            lambda d: d["stages"][0]["implementations"][1].update(records=2),
            lambda d: d["stages"][0]["implementations"][1]["output"].update(sha256="0" * 64),
            lambda d: d["stages"][0]["implementations"][0].update(command=[]),
            lambda d: d["claim_boundaries"].update(full_theorem_certified=True),
            lambda d: d["claim_boundaries"].update(formal_semantics_proven=True),
        ]
        for ix, mutate in enumerate(mutations):
            obj = copy.deepcopy(base)
            mutate(obj)
            try:
                audit(obj, root)
            except ValueError:
                continue
            raise AssertionError("Malformed evidence accepted: negative control " + str(ix))
        # Change source bytes without altering its pinned digest.
        (root / "input.txt").write_bytes(b"tampered\n")
        try:
            audit(base, root)
        except ValueError:
            pass
        else:
            raise AssertionError("Altered raw input accepted")
        # Same hash values are not enough: all program outputs must match exactly.
        (root / "input.txt").write_bytes(b"frozen exact input\n")
        (root / "ind.ndjson").write_bytes(b'{"value":"2/3"}\n')
        obj = copy.deepcopy(base)
        obj["stages"][0]["implementations"][1]["output"] = f("ind.ndjson")
        try:
            audit(obj, root)
        except ValueError:
            pass
        else:
            raise AssertionError("Divergent canonical outputs accepted")
    return len(mutations) + 2


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    require(args.self_test or args.manifest is not None,
            "Pass --manifest for frozen stage artifacts or --self-test")
    if args.self_test:
        print("PASS:", self_test(), "adversarial mutation controls")
    if args.manifest is not None:
        doc = json.loads(args.manifest.read_text(encoding="utf-8"))
        print("PASS:", json.dumps(audit(doc, args.root), sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError, UnicodeError) as exc:
        raise SystemExit("FAIL: " + str(exc)) from exc
