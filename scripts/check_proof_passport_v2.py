#!/usr/bin/env python3
"""Fail-closed NIGHTFALL Passport v2 metadata/source auditor. NOT a Lean compiler."""
import argparse
import copy
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "proof-passport-v2.json"
SHA1 = re.compile(r"^[a-f0-9]{40}$")
RECORD = {"id","title","assertion_status","claim_scope","source","formal","receipt",
          "dependencies","limitations","credit","review","certification","next_test"}
ALLOW = {"scoped-formal-evidence", "external-reference-only", "quarantined"}

def check(d, files=True):
    assert d["schema"] == "nightfall.proof-passport-overlay.v2" and d["version"] == 2
    assert re.fullmatch(r"2026-\d{2}-\d{2}", d["as_of"])
    assert len(d["records"]) >= 5
    by_id = {}
    for r in d["records"]:
        assert RECORD <= r.keys(), "required passport field absent"
        rid = r["id"]
        assert isinstance(rid,str) and re.fullmatch(r"[A-Z0-9-]{8,}",rid)
        assert rid not in by_id, f"duplicate {rid}"
        by_id[rid] = r
        assert r["assertion_status"] in ALLOW
        assert len(r["claim_scope"]) >= 80
        assert len(r["limitations"]) >= 2 and all(len(s) > 30 for s in r["limitations"])
        assert len(r["credit"]) > 20 and len(r["next_test"]) > 30
        assert r["review"] == {
           "statement_equivalence":"pending-independent","non_author":"pending",
           "prior_art":"pending","publication_authorization":"not-requested"}
        assert r["certification"] == {
           "kernel_replayed_in_this_change":False, "independent_semantic_audit":False,
           "worldwide_novelty":False, "globally_complete":False}
        assert not r["formal"]["exact_statement_independently_reviewed"]
        src = r["source"]
        if src["kind"] == "repository":
            assert r["assertion_status"] in {"scoped-formal-evidence","quarantined"}
            p = pathlib.PurePosixPath(src["path"])
            assert not p.is_absolute() and ".." not in p.parts and p.suffix == ".lean"
            assert src["repository"] == "d3lefts/d3lefts"
            assert SHA1.fullmatch(src["git_blob_sha1"])
            assert SHA1.fullmatch(r["receipt"]["head_sha"])
            assert r["receipt"]["outcome"] == "reported-success"
            assert isinstance(r["receipt"]["run_id"],int) and r["receipt"]["run_id"]>0
            assert r["receipt"]["url"] == ("https://github.com/d3lefts/d3lefts/actions/runs/"
                                              +str(r["receipt"]["run_id"]))
            assert "4.36.0-rc2" in r["formal"]["toolchain"]
            if files:
                full=ROOT.joinpath(*p.parts)
                assert full.is_file() and not full.is_symlink(),f"source missing {p}"
                b=full.read_bytes()
                blob=hashlib.sha1(b"blob "+str(len(b)).encode()+b"\0"+b).hexdigest()
                assert blob == src["git_blob_sha1"],f"source drift {p}"
                name=r["formal"]["declaration"].rsplit(".",1)[-1]
                assert re.search(r"\b(?:theorem|def)\s+"+re.escape(name)+r"\b",
                                 b.decode("utf-8")),f"declaration absent {name}"
        else:
            assert src["kind"] == "external" and r["assertion_status"] == "external-reference-only"
            assert src["url"].startswith("https://")
            assert src["fingerprint"] is None and src["local_archive_replayed"] is False
            assert r["receipt"]["run_id"] is None and r["receipt"]["outcome"] == "no-local-run"
            assert r["receipt"]["head_sha"] is None
    for rid,r in by_id.items():
        assert isinstance(r["dependencies"],list) and len(set(r["dependencies"]))==len(r["dependencies"])
        for dep in r["dependencies"]:
            assert dep in by_id and dep != rid, f"unknown/self dependency {rid}: {dep}"
    seen, stack = set(),set()
    def visit(rid):
        assert rid not in stack, f"dependency cycle {rid}"
        if rid in seen:return
        stack.add(rid)
        for dep in by_id[rid]["dependencies"]:
            visit(dep)
            assert by_id[dep]["assertion_status"] != "quarantined" or by_id[rid]["assertion_status"] == "quarantined", f"undemoted dependency {rid}"
        stack.remove(rid)
        seen.add(rid)
    for rid in by_id:visit(rid)
    return len(by_id)

def self_test(d):
    assert check(d,files=False)>=5
    tests=[]
    def bad(label, edit):
        c=copy.deepcopy(d);edit(c)
        try:check(c,files=False)
        except (AssertionError,KeyError,TypeError,ValueError):tests.append(label);return
        raise AssertionError(f"BAD MUTANT ACCEPTED: {label}")
    bad("invented independent review", lambda c:c["records"][0]["review"].update(non_author="passed"))
    bad("fake kernel replay",lambda c:c["records"][0]["certification"].update(kernel_replayed_in_this_change=True))
    bad("source swap",lambda c:c["records"][0]["source"].update(git_blob_sha1="invalid"))
    bad("false run",lambda c:c["records"][0]["receipt"].update(run_id=-1))
    bad("missing prerequisite",lambda c:c["records"][1].update(dependencies=["MISSING"]))
    bad("cycle",lambda c:(c["records"][1].update(dependencies=["NF-WYNER-ABSTRACT-W"]),
                           c["records"][2].update(dependencies=["NF-ROUTE1-POLYLOG-M"])))
    bad("external promoted",lambda c:c["records"][-1].update(assertion_status="scoped-formal-evidence"))
    bad("foreign source path",lambda c:c["records"][0]["source"].update(path="../wrong.lean"))
    bad("contradicted dependency not demoted",lambda c:c["records"][1].update(assertion_status="quarantined"))
    bad("duplicate identifier",lambda c:c["records"][1].update(id=c["records"][0]["id"]))
    assert len(tests)==10
    return tests

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--self-test",action="store_true")
    args=ap.parse_args()
    data=json.loads(MANIFEST.read_text())
    count=check(data)
    print(f"PASS: {count} passports; exact source blobs; graph; fail-closed review statuses (no Lean run)")
    if args.self_test:
        t=self_test(data)
        print("PASS: 10 mutation guards: "+", ".join(t))
if __name__=="__main__":
    try:main()
    except Exception as exc:
        print(f"FAIL: {exc}",file=sys.stderr)
        sys.exit(1)
