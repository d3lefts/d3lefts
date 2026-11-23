#!/usr/bin/env python3
"""Fail-closed source and scope gate for NIGHTFALL's eight headline tracks.

Does not run Lean, inspect transitive theorem assumptions or certify mathematical
originality. The trusted main-branch manifest is checked independently of PR
edits once the initial bootstrap is merged.
"""
import argparse
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

REL = "research/nightfall/verification/HEADLINE_TRUST_BOUNDARIES_V1.json"
IDS = (
    "headline-01-quadratic", "headline-02-all-degree",
    "headline-03-route1-wyner", "headline-04-hilbert",
    "headline-05-information-cover", "headline-06-causal-phase",
    "headline-07-subcube", "headline-08-povm",
)
FROZEN_FLAGS = ("independent_statement_review", "independent_kernel_replay_this_change",
                "dated_prior_art_cleared", "owner_publication_authorized")
ALLOWED_EVIDENCE = {"finite-heterogeneous-product-support", "scoped-lean-source",
                    "conditional-algebraic-component", "finite-lp-duality-component",
                    "fixed-prefix-obstruction-component"}


def git_blob_id(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()


def trusted_bytes(root: Path, ref: str) -> bytes | None:
    if not re.fullmatch(r"[A-Za-z0-9_./-]+", ref) or ref.startswith("-") or ".." in ref:
        raise ValueError("invalid trusted git ref")
    result = subprocess.run(["git", "-C", str(root), "show", f"{ref}:{REL}"],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if result.returncode == 0:
        return result.stdout
    if b"does not exist" in result.stderr or b"exists on disk, but not in" in result.stderr:
        return None
    raise ValueError("trusted baseline inaccessible (ref missing or git error)")


def check_declaration(source: str, qualified_name: str) -> None:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_'.]*(?:\.[A-Za-z_][A-Za-z0-9_']*)+", qualified_name):
        raise ValueError("invalid qualified declaration")
    simple = qualified_name.split(".")[-1]
    # Do not mistake a name only mentioned inside a comment or a quotation for a declaration.
    matches = re.findall(r"(?m)^\s*(?:theorem|lemma|def)\s+([A-Za-z_][A-Za-z0-9_']*)\b", source)
    if simple not in matches:
        raise ValueError("missing named Lean declaration: " + qualified_name)


def check_source(root: Path, src: dict) -> None:
    path = src.get("path")
    if not isinstance(path, str) or not path.startswith("research/nightfall/") or not path.endswith(".lean"):
        raise ValueError("untrusted Lean source path")
    if Path(path).is_absolute() or ".." in Path(path).parts:
        raise ValueError("source path traversal")
    absolute = root / path
    if not absolute.is_file() or not absolute.resolve().is_relative_to(root.resolve()):
        raise ValueError("missing or external Lean source: " + path)
    raw = absolute.read_bytes()
    observed = git_blob_id(raw)
    if observed != src.get("git_blob_sha1"):
        raise ValueError("SOURCE_BLOB_DRIFT: " + path)
    check_declaration(raw.decode("utf-8"), src.get("declaration"))


def validate(obj: dict, root: Path | None = None) -> dict:
    if obj.get("schema") != "nightfall.headline-trust-boundaries/v1":
        raise ValueError("unknown schema")
    if obj.get("as_of_utc") != "2026-11-23":
        raise ValueError("this immutable v1 checkpoint must be versioned, not rewritten")
    records = obj.get("records")
    if not isinstance(records, list) or [x.get("id") for x in records] != list(IDS):
        raise ValueError("eight canonical claim identities/order required")
    if not isinstance(obj.get("policy"), dict) or len(obj["policy"]) != 4:
        raise ValueError("missing policy")
    paths = set()
    for r in records:
        for field in ("title", "claim_scope", "gap"):
            if not isinstance(r.get(field), str) or len(r[field]) < 35:
                raise ValueError("missing precise claim/gap: " + r["id"])
        if r.get("evidence") not in ALLOWED_EVIDENCE:
            raise ValueError("unreviewed claim promotion")
        if not isinstance(r.get("citation_pr"), int) or r["citation_pr"] <= 0:
            raise ValueError("missing research attribution pointer")
        if any(r.get(flag) is not False for flag in FROZEN_FLAGS):
            raise ValueError("promotion requires separate independent evidence: " + r["id"])
        modules = [r.get("source")] + r.get("supporting", [])
        if any(not isinstance(src, dict) for src in modules):
            raise ValueError("malformed source record")
        for src in modules:
            if not isinstance(src.get("git_blob_sha1"), str) or not re.fullmatch("[0-9a-f]{40}", src["git_blob_sha1"]):
                raise ValueError("bad source digest")
            if src.get("path") in paths:
                raise ValueError("shared source must have its own lineage rationale")
            paths.add(src.get("path"))
            if root is not None:
                check_source(root, src)
    return {"schema": "nightfall.headline-scope-audit/v1", "status": "SOURCE_BOUND_NO_PROMOTION",
            "tracks": 8, "lean_source_anchors": len(paths),
            "kernel_replayed": False, "transitive_definitions_checked": False,
            "independent_review_completed": False}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    p.add_argument("--trusted-ref", help="owner-controlled baseline ref, e.g. origin/main")
    p.add_argument("--json-out", type=Path)
    a = p.parse_args()
    root = a.root.resolve()
    candidate = (root / REL).read_bytes()
    report = validate(json.loads(candidate), root)
    if a.trusted_ref:
        base = trusted_bytes(root, a.trusted_ref)
        if base is None:
            report["freeze_state"] = "INITIAL_BOOTSTRAP_NOT_YET_EXTERNAL"
        elif candidate != base:
            raise ValueError("HEADLINE_SCOPE_OR_SOURCE_REBASELINE_REQUIRES_OWNER_CONTROLLED_NEW_VERSION")
        else:
            report["freeze_state"] = "FROZEN_AGAINST_TRUSTED_BASE"
    else:
        report["freeze_state"] = "BASE_NOT_CHECKED"
    if a.json_out:
        a.json_out.parent.mkdir(parents=True, exist_ok=True)
        a.json_out.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
