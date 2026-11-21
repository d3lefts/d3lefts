#!/usr/bin/env python3
"""Exact-byte and evidence-scope audit for all 15 v16 NIGHTFALL active passports.

This checks provenance/metadata, not mathematical soundness, new Lean compilation,
human referee review, novel priority, or the state of a live external deployment.
"""
import argparse
import copy
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/active-passport-source-reconciliation-v2.json"
LEGACY = ROOT / "docs/active-proof-passport.json"
SHA1 = re.compile(r"^[0-9a-f]{40}$")
ALLOWED_KINDS = {
    "lean-scoped", "analytic-only", "exact-obstruction", "analytic-plus-exact-checker",
    "finite-computational-proof", "exact-family-proof", "analytic-with-finite-lean-core",
    "analytic-subclass", "analytic-plus-partial-lean", "conditional-with-scoped-lean",
    "lean-finite-construction", "lean-conditional", "lean-conditional-finite"
}
PR_CORRECTIONS = {"fair-sign-cubic", "universal-spectral", "semantic-fencing-authority"}

def git_blob(data):
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\x00" + data).hexdigest()

def source_bytes(path):
    assert isinstance(path, str) and path and "\\" not in path
    pure = pathlib.PurePosixPath(path)
    assert not pure.is_absolute() and "." not in pure.parts and ".." not in pure.parts
    full = ROOT.joinpath(*pure.parts)
    assert full.is_file() and not full.is_symlink(), f"missing/unsafe file: {path}"
    assert full.resolve().is_relative_to(ROOT.resolve())
    return full.read_bytes()

def source_check(artifact, verify_files):
    assert set(artifact) == {"path", "git_blob_sha1"} or (
        set(artifact) == {"path", "git_blob_sha1", "type"})
    assert SHA1.fullmatch(artifact["git_blob_sha1"])
    assert pathlib.PurePosixPath(artifact["path"]).suffix in {".lean", ".md", ".py", ".tex"}
    if verify_files:
        assert git_blob(source_bytes(artifact["path"])) == artifact["git_blob_sha1"], (
            "source hash drift: " + artifact["path"])

def check(data, verify_files=True):
    assert data["schema"] == "nightfall.active-passport-source-reconciliation.v2"
    assert data["as_of"] == "2026-11-21"
    assert data["baseline_registry"] == "docs/active-proof-passport.json"
    assert data["baseline_registry_version"] == 16
    assert SHA1.fullmatch(data["baseline_git_blob_sha1"])
    if verify_files:
        assert git_blob(source_bytes(data["baseline_registry"])) == data["baseline_git_blob_sha1"]
    active = json.loads(LEGACY.read_text())
    assert active["version"] == 16 and len(active["claims"]) == 15
    original = active["claims"]
    expected = [a["id"] for a in original]
    records = data["records"]
    assert [r["id"] for r in records] == expected and len(set(expected)) == 15
    summary = {"source_matched": 0, "lean_artifacts": 0, "lifecycle_corrections": 0}
    for r, legacy in zip(records, original):
        rid = r["id"]
        assert r["legacy_status"] == legacy["status"], f"legacy status altered: {rid}"
        assert r["dossier"]["path"] == legacy["source"], f"dossier changed: {rid}"
        source_check(r["dossier"], verify_files)
        source_check(r["primary_source"], verify_files)
        assert r["primary_source"]["path"] != r["dossier"]["path"], (
            "primary source is just the passport narrative: " + rid)
        assert len(r["actual_scope"]) >= 70 and len(r["next_decisive_test"]) >= 70, rid
        assert r["source_evidence_kind"] in ALLOWED_KINDS
        assert r["primary_source"]["type"] == (
            "lean" if r["primary_source"]["path"].endswith(".lean") else "manuscript")
        if r["primary_source"]["type"] == "lean":
            summary["lean_artifacts"] += 1
        refs = r["supporting_sources"]
        assert isinstance(refs, list) and len(set(x["path"] for x in refs)) == len(refs)
        for artifact in refs:
            source_check(artifact, verify_files)
            assert artifact["path"] not in {
                r["primary_source"]["path"], r["dossier"]["path"]}
        assert r["remaining_limitations"] == legacy["limitations"], (
            "historical limitations changed: " + rid)
        assert r["author_side_source_reconciled"] is True
        for field in ("independent_theorem_statement_review", "independent_human_referee",
                      "prior_art_cleared", "publication_authorized"):
            assert r[field] is False, f"faked promotion {rid} {field}"
        ev = r["receipt"]
        assert ev["status"] in {"legacy-referenced-not-replayed-in-this-change",
                                "no-end-to-end-lean-receipt"}
        if ev["ci_run"] is not None:
            assert isinstance(ev["ci_run"], int) and ev["ci_run"] > 0
            assert ev["status"] == "legacy-referenced-not-replayed-in-this-change"
        else:
            assert ev["status"] == "no-end-to-end-lean-receipt"
        if ev["head_sha"] is not None:
            assert SHA1.fullmatch(ev["head_sha"]) and ev["pr"] is not None
        if ev["pr"] is not None:
            assert isinstance(ev["pr"], int) and ev["pr"] > 0
        if r["formal_declaration"] is not None:
            assert r["primary_source"]["type"] == "lean"
            terminal = r["formal_declaration"].rsplit(".", 1)[-1]
            if verify_files:
                raw = source_bytes(r["primary_source"]["path"]).decode()
                assert re.search(r"\b(?:theorem|lemma|def)\s+" +
                                 re.escape(terminal) + r"\b", raw), (
                    "theorem declaration missing: " + rid)
        if rid in PR_CORRECTIONS:
            assert r["observed_pr_merged"] is True
            assert r["lifecycle_correction"] and "merged" in r["lifecycle_correction"]
            summary["lifecycle_corrections"] += 1
        else:
            assert r["lifecycle_correction"] is None
            assert r["observed_pr_merged"] is None
        summary["source_matched"] += 1
    assert summary["lifecycle_corrections"] == 3
    return summary

def self_test(data):
    def rejected(name, mutate, verify=False):
        sample = copy.deepcopy(data)
        mutate(sample)
        try:
            check(sample, verify_files=verify)
        except (AssertionError, KeyError, IndexError, ValueError, TypeError, OSError):
            return name
        raise AssertionError(f"INVALID CONTROL PASSED: {name}")
    controls = [
        rejected("missing passport", lambda a: a["records"].pop()),
        rejected("duplicate identity", lambda a: a["records"][1].update(id=a["records"][0]["id"])),
        rejected("source hash drift", lambda a: a["records"][0]["primary_source"].update(git_blob_sha1="0"*40), True),
        rejected("dossier drift", lambda a: a["records"][0]["dossier"].update(git_blob_sha1="0"*40), True),
        rejected("legacy status rewrite", lambda a: a["records"][0].update(legacy_status="peer-reviewed")),
        rejected("fabricated human review", lambda a: a["records"][0].update(independent_human_referee=True)),
        rejected("fabricated novelty", lambda a: a["records"][0].update(prior_art_cleared=True)),
        rejected("fabricated publication authority", lambda a: a["records"][0].update(publication_authorized=True)),
        rejected("wrong theorem declaration", lambda a: a["records"][0].update(formal_declaration="Invented.theorem"), True),
        rejected("PR merged-state forgery", lambda a: a["records"][8].update(observed_pr_merged=False)),
        rejected("invalid supporting source", lambda a: a["records"][2]["supporting_sources"][0].update(git_blob_sha1="0"*40), True),
        rejected("path traversal", lambda a: a["records"][0]["primary_source"].update(path="../../hidden.lean"), True),
        rejected("false primary equals dossier", lambda a: a["records"][0]["primary_source"].update(path=a["records"][0]["dossier"]["path"])),
        rejected("baseline substitution", lambda a: a.update(baseline_git_blob_sha1="0"*40), True),
    ]
    assert len(controls) == 14
    return controls

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    data = json.loads(LEDGER.read_text())
    results = check(data)
    print("PASS: 15/15 individually source-matched; "
          f"{results['lean_artifacts']} Lean primary artifacts; "
          f"{results['lifecycle_corrections']} lifecycle corrections. "
          "No new theorem/reviewer/novelty certificate.")
    if args.self_test:
        print("PASS: 14 negative controls: " + ", ".join(self_test(data)))

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
