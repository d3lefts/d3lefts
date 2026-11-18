#!/usr/bin/env python3
"""Independently check PUBLIC metadata from genuine local SWE tool-agent pilots.

This does not fetch private raw transcripts or patches and does not certify
their authenticity. It does not rerun either model or a hidden grader.
It fails closed on mismatched task identities, denominator, provenance
shape, or attempts to label public smoke results as blind scores.
"""
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
DATA=HERE/"TWO_MODEL_PUBLIC_RECEIPT.json"
HEX=re.compile(r"^[a-f0-9]{64}$")
EMPTY=hashlib.sha256(b"").hexdigest()

def verify():
    x=json.loads(DATA.read_text(encoding="utf8"))
    assert x["schema"]=="nightfall.swe.two-real-model-public-calibration.v1"
    assert x["accepted_blind_model_scores"]==0
    assert x["budget"]["model_turns"]==9
    assert x["comparison_design"]=="retrospective_matched_protocol_not_externally_preregistered"
    models=x["model_weights"];tasks=x["tasks"]
    assert set(models)=={"qwen2.5-coder:1.5b","qwen2.5-coder:3b"}
    assert set(tasks)=={"DispatchQ-B1","ArtifactGraph-B2"}
    assert len(set(models.values()))==2
    for digest in models.values():
        assert HEX.fullmatch(digest)
    assert x["runner_image_id"].startswith("sha256:")
    assert HEX.fullmatch(x["runner_image_id"][7:])
    for task,t in tasks.items():
        assert re.fullmatch("[a-f0-9]{40}",t["commit"])
        assert HEX.fullmatch(t["issue_sha256"])
        assert HEX.fullmatch(t["canary_sha256"])
        assert HEX.fullmatch(t["candidate_source_sha256"])
        assert t["checks"] in (13,20)

    records=x["observations"]
    assert len(records)==4
    assert {(r["task"],r["model"]) for r in records}=={
        (task,model) for task in tasks for model in models}
    task_counts={}
    for r in records:
        t=tasks[r["task"]]
        assert r["blind_grade"] is None
        assert r["model"] in models
        assert 1 <= r["tool_calls"] <= 9
        assert 0 <= r["write_calls"] <= r["tool_calls"]
        assert type(r["smoke_exit_code"]) is int and r["smoke_exit_code"]==0
        assert r["canary_passed"] + r["canary_violated"]==t["checks"]
        assert r["canary_unexpected_errors"]==0
        assert r["canary_violated"]>0, "smoke pass cannot prove contract success"
        assert HEX.fullmatch(r["patch_sha256"]) and HEX.fullmatch(r["transcript_sha256"])
        assert type(r["workflow_run"]) is int and r["workflow_run"] > 0
        assert type(r["artifact_id"]) is int and r["artifact_id"] > 0
        changed=r["changed_files"]
        assert type(changed) is list
        if changed:
            assert changed==["dispatchq/queue.py"] and r["task"]=="DispatchQ-B1"
            assert r["patch_sha256"]!=EMPTY and r["write_calls"]>=1
        else:
            assert r["patch_sha256"]==EMPTY
        if r["model"]=="qwen2.5-coder:1.5b":
            assert r["workflow_run"]==44390828857
        else:
            assert r["workflow_run"]==44390828722
        task_counts.setdefault(r["task"],[]).append((r["model"],r["canary_passed"],r["canary_violated"]))
    for task,vals in task_counts.items():
        assert len(vals)==2
        assert len({(v[1],v[2]) for v in vals})==1, (task,vals)
    assert next(r for r in records if r["model"]=="qwen2.5-coder:3b" and r["task"]=="DispatchQ-B1")["changed_files"]
    assert not next(r for r in records if r["model"]=="qwen2.5-coder:1.5b" and r["task"]=="DispatchQ-B1")["changed_files"]
    print("PASS FOUR true tool-model public metadata receipts, two model weight digests, two frozen tasks")
    print("PASS zero blind agent scores; both public canaries distinguish full-contract violations from smoke passes")
    print("PASS Qwen3B DispatchQ net edit did not improve independent public canary outcome")
    print("LIMIT: source-exact public log and artifact claims only; private traces and patches not independently replayed")

if __name__=="__main__":
    verify()
