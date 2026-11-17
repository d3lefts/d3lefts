#!/usr/bin/env python3
"""Check the Nov 15 source-specific Lean receipt custody (not a Lean compiler or literature audit)."""
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CURRENT=ROOT/"docs/current-lean-proof-receipts-20261116.json"
MANIFEST=ROOT/"docs/current-lean-proof-receipts-20261115.json"
EXPECTED={
"unrestricted-q2-105":("ed945639f7cbe26ba8fdb50d691127c01cdf863f",43671321904,"unrestricted-finite-product"),
"conditional-q2-96-six-cover":("8de1ad77a9f218d0df3673d8574ddd6592556865",43676624010,"conditional-implication-only"),
"one-increment-hilbert":("52b36e1bb6cec2ae1f26bf35323b87581efbf76f",43676488130,"one-increment-only"),
"finite-five-cover-obstruction":("16e228ef88a87eec7908fdc829735dd63419094a",43677348342,"finite-abstract-lemma-only"),
}
def check():
    m=json.loads(MANIFEST.read_text("utf-8"))
    assert m["current_unrestricted_degree_two"]["coefficient"]==105.741756923658
    assert m["current_unrestricted_degree_two"]["pr"]==564
    assert m["current_unrestricted_degree_two"]["receipt_run"]==43671321904
    assert m["unrestricted_sub100"]=="NOT PROVED"
    entries=m["november15_named_lean_receipts"]
    assert isinstance(entries,list) and len(entries)==5
    found=set()
    for e in entries:
        identifier=e["id"]
        assert identifier not in found, ("duplicate",identifier)
        found.add(identifier)
        path=Path(e["source"])
        assert not path.is_absolute() and ".." not in path.parts
        source=(ROOT/path).read_bytes()
        sha=hashlib.sha1(b"blob "+str(len(source)).encode()+b"\x00"+source).hexdigest()
        declared=e["source_git_blob_sha1"]
        assert re.fullmatch("[0-9a-f]{40}",declared),("invalid sha",identifier)
        assert sha==declared,("source mutated",identifier,sha,declared)
        assert e["all_length_c96_proved"] is False
        expected=EXPECTED.get(identifier)
        if expected:
            blob,run,status=expected
            assert declared==blob and e["pinned_lean_original_run"]==run and e["source_proof_status"]==status
        elif identifier=="pure-sector-q2-95":
            assert e["pinned_lean_original_run"]==43664979586
            assert e["source_proof_status"]=="restricted-unconditional"
        else:
            raise AssertionError(("unregistered claim",identifier))
        name=e["theorem"]
        if name and name!="See source for exact named declarations":
            assert re.search(r"\btheorem\s+"+re.escape(name)+r"\b",source.decode("utf-8")),("missing theorem",identifier)
        assert "scope" in e["certification_scope"].lower() or len(e["certification_scope"])>30
    assert found==EXPECTED.keys()|{"pure-sector-q2-95"},found

    current=json.loads(CURRENT.read_text("utf-8"))
    assert current["previous_unrestricted_degree_two"]==m["current_unrestricted_degree_two"]
    newest=current["current_unrestricted_degree_two"]
    assert newest["pr"]==587 and newest["receipt_run"]==43732382337
    assert newest["independent_scalar_run"]==43732382354
    assert abs(newest["coefficient"]-105.41623981998771)<1e-12
    fresh=current["november16_named_lean_receipts"]
    assert len(fresh)==1 and fresh[0]["id"]=="unrestricted-q2-105-416"
    e=fresh[0]
    p=Path(e["source"])
    assert not p.is_absolute() and ".." not in p.parts
    source=(ROOT/p).read_bytes()
    blob=hashlib.sha1(b"blob "+str(len(source)).encode()+b"\x00"+source).hexdigest()
    assert blob==e["source_git_blob_sha1"]==newest["source_git_blob_sha1"]=="eb9d1422f14f0f742fa79e7424c269ab83b22ba2"
    assert e["pinned_lean_original_run"]==newest["receipt_run"]
    assert e["independent_scalar_run"]==newest["independent_scalar_run"]
    assert e["original_head"]==newest["original_head"]=="784c76669d08fa60e170c32fc379a6768c50e9e1"
    assert re.search(r"\btheorem\s+"+re.escape(e["theorem"])+r"\b",source.decode("utf-8"))
    assert e["source_proof_status"]=="unrestricted-finite-product" and e["all_length_c96_proved"] is False
    assert current["unrestricted_sub100"]=="NOT PROVED"
    q=json.loads((ROOT/"docs/active-proof-passport.json").read_text("utf-8"))
    assert q["current_named_certificate_scope"]["finite_q2"]["strongest_merged"]["pr"]==587
    assert q["last_certificate_reconciliation_20261115"]["unrestricted_96_57352"]=="OPEN"
    assert q["current_named_lean_receipts"]=="docs/current-lean-proof-receipts-20261116.json"
    frontier=json.loads((ROOT/"research/catalogue/CURRENT_FRONTIER.json").read_text("utf-8"))
    assert frontier["best_unrestricted_source_q2_certified"]=="q2-unrestricted-105-416"
    assert frontier["unrestricted_sub100_unconditional"]=="not_proved"
    print("PASS: v16 six exact-blob Lean receipt scopes including newest C105.416; unrestricted C96 OPEN")
if __name__=="__main__":check()
