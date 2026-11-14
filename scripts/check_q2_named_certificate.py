#!/usr/bin/env python3
"""Audit an actual strict named Lean Q2 certificate against checkout source bytes.

This is an *offline provenance/checklist guard*, NOT a replacement for running
Lean or independently reviewing theorem assumptions or originality.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CERT = Path("docs/q2-source-lean-certificate-20261114.json")
PENDING = Path("docs/lean-pending-source-custody.json")
HISTORICAL = Path("docs/lean-certificate-provenance.json")
EXPECTED_ID = (
    "01-original-pair-fourth", "02-owned-pair-energy",
    "03-original-projection-jensen", "04-source-owned-fourth",
    "05-singleton-pair-parseval", "06-variance-owned-moment",
    "07-first-norm-L2-cap", "08-exact-Q2-terminal",
)
RUN = 43611982294
SOURCE_HEAD = "d22962ba73b037a569196bc98d946dc192e4effa"
ALLOW = {"Classical.choice", "Quot.sound", "propext"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def hash_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def check(root: Path) -> dict:
    c = json.loads((root / CERT).read_text())
    p = json.loads((root / PENDING).read_text())
    h = json.loads((root / HISTORICAL).read_text())
    require(c.get("schema") == "nightfall-q2-source-named-lean-certificate-v1",
            "Unrecognized Q2 receipt format")
    require(c.get("source_commit") == SOURCE_HEAD, "Q2 source commit drift")
    require(c.get("verification_run") == RUN and c.get("run_conclusion") == "success",
            "Q2 certified run pointer drift")
    require(c.get("artifact_id") == 14121225201,
            "Q2 immutable receipt artifact id drift")
    require(re.fullmatch(r"[0-9a-f]{64}", c.get("artifact_zip_sha256", "")) is not None,
            "Malformed Q2 artifact SHA256 digest")
    require(c.get("toolchain") == "leanprover/lean4:v4.36.0-rc2"
            and c.get("mathlib_commit") == "9d581dfff2e41de989072ea63abf3daf69311520",
            "Q2 compiler or Mathlib pin drift")
    require(set(c.get("accepted_axioms", [])) == ALLOW
            and len(c.get("accepted_axioms", [])) == len(ALLOW),
            "Q2 accepted axiom scope drift")
    require(c.get("proof_status") == "all_eight_named_declarations_strict_pass",
            "Q2 named-declaration certification demoted or spoofed")
    require(c.get("terminal_statement", {}).get("declaration")
            == "Nightfall.Observability.ActualSourceQ2Terminal.actual_source_q2_terminal",
            "Terminal theorem declaration pointer drift")
    require(c.get("terminal_statement", {}).get("formula")
            == "(sourceVariance p f)^2 <= (16*(1+sqrt(3)))^2 * B^2 * M",
            "Q2 formula scope drift")

    stages = c.get("stages", [])
    require(isinstance(stages, list)
            and tuple(s.get("id") for s in stages) == EXPECTED_ID,
            "Wrong source-proof stage order")
    require(len(set(s.get("source_path") for s in stages)) == len(stages),
            "Duplicated Q2 source stage")
    require(h.get("schema") == "nightfall-lean-provenance-v1"
            and len(h.get("modules", [])) == 67,
            "Historical certificate index mutated")
    original = set(r["path"] for r in h["modules"])
    rows = {r["path"]: r for r in p.get("sources", [])}
    require(len(rows) == len(p.get("sources", [])),
            "Duplicate pending source custody")
    require(p.get("schema") == "nightfall-lean-pending-source-custody-v1",
            "Pending source schema drift")
    exact_certificate_paths = set()
    for st in stages:
        path = st.get("source_path")
        require(isinstance(path, str)
                and path.startswith("research/nightfall/formalization/observability/")
                and path.endswith(".lean") and ".." not in Path(path).parts,
                "Invalid stage source path")
        file = root / path
        require(file.is_file(), "Stage Lean source missing: " + path)
        actual_sha = hash_blob(file.read_bytes())
        require(st.get("source_blob_sha") == actual_sha,
                "Current Lean source drift from strict receipt: " + path)
        require(re.fullmatch(r"[0-9a-f]{40}", st.get("source_blob_sha", "")) is not None,
                "Missing stage Git blob SHA")
        declaration = st.get("declaration")
        require(isinstance(declaration, str)
                and declaration.startswith("Nightfall.Observability.")
                and re.fullmatch(r"[a-zA-Z0-9_.]+", declaration),
                "Invalid certified declaration name")
        short_name = declaration.rsplit(".", 1)[-1]
        require(re.search(r"(?m)^(theorem|lemma|def)\s+" +
                          re.escape(short_name) + r"\b", file.read_text()) is not None,
                "Named declaration missing in current source: " + declaration)
        require(st.get("strict_axiom_receipt") == "ACCEPT_STANDARD_AXIOMS",
                "Stage strict axiom receipt removed: " + path)
        require(path not in original and path in rows,
                "Q2 stage was silently promoted into frozen historic registry")
        row = rows[path]
        require(row.get("source_blob_sha") == actual_sha
                and row.get("classification") == "unreviewed-source"
                and row.get("ci_source_match_status") == "no-verified-receipt"
                and row.get("historical_run") is None
                and row.get("historical_head") is None
                and row.get("global_priority") == "unverified",
                "Historical custody or non-originality scope changed: " + path)
        scope = row.get("current_named_declaration_certificate", {})
        require(scope == {
            "certificate": CERT.as_posix(),
            "source_commit": SOURCE_HEAD,
            "named_declaration": declaration,
            "run": RUN,
            "receipt_artifact_id": 14121225201,
        }, "Current named receipt custody mismatch: " + path)
        exact_certificate_paths.add(path)
    require(set(k for k, v in rows.items()
                if "current_named_declaration_certificate" in v)
            == exact_certificate_paths,
            "Extra source was falsely assigned the Q2 named-declaration certificate")
    require(len(c.get("limits", [])) >= 4, "Q2 scope/novelty limitations omitted")
    return {"source_stages": len(stages),
            "source_head": SOURCE_HEAD,
            "strict_receipt": RUN,
            "historical_sources_unchanged": len(original),
            "additional_current_scoped_named_declarations": len(exact_certificate_paths),
            "independent_novelty_review": False,
            "fresh_compiler_run": False}


def self_test() -> None:
    # Copy only the files used by this guard, into a disposable fixture.
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        c = json.loads((ROOT / CERT).read_text())
        for path in (CERT, PENDING, HISTORICAL):
            dst = root / path
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes((ROOT / path).read_bytes())
        for st in c["stages"]:
            p = root / st["source_path"]
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes((ROOT / st["source_path"]).read_bytes())
        require(check(root)["source_stages"] == 8, "Valid fixture rejected")
        path = root / c["stages"][0]["source_path"]
        data = path.read_bytes()
        path.write_bytes(data + b"\n-- source tamper negative control\n")
        try:
            check(root)
        except ValueError as e:
            require("source drift" in str(e), "Wrong source-mutation rejection")
        else:
            raise AssertionError("Tampered source passed")
        path.write_bytes(data)
        certificate = root / CERT
        raw = json.loads(certificate.read_text())
        raw["accepted_axioms"].append("sorryAx")
        certificate.write_text(json.dumps(raw))
        try:
            check(root)
        except ValueError as e:
            require("axiom" in str(e), "Wrong forged-axiom rejection")
        else:
            raise AssertionError("Forged axiom passed")
        certificate.write_text(json.dumps(c))
    print("PASS: Q2 8-stage source-blob, scoped receipt and two negative controls")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    opts = parser.parse_args()
    if opts.self_test:
        self_test()
    print("PASS Q2 CURRENT NAMED RECEIPT CUSTODY", check(ROOT))
