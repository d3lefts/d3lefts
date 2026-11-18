#!/usr/bin/env python3
"""Independent Inspect result auditor; no module import from the agent runner.

Score codes C/I are taken from the genuine combined_pytest_scorer. Do not
replace absent/invalid scores with a guessed success or interpret a finished
Inspect run as a successful agent. All failed/errored attempts counted.
"""
import argparse,hashlib,json
from pathlib import Path
PAIRS=(("add_interpretability_ou","disable_fsx_deny_policy"),
       ("create_billing_alarm","allow_public_s3_policy"),
       ("enforce_mandatory_tags_scp","detach_mfa_requirement_policy"))
def sha(b):return hashlib.sha256(b).hexdigest()
def audit(root):
    root=Path(root)
    receipt=json.loads((root/"native_multi_receipt.json").read_text())
    assert receipt["dataset"]=="official ControlArena IaC Fast 20.1.1"
    assert receipt["authored_scaffold"] is False and receipt["preselected_edit_or_path"] is False
    assert receipt["status"]=="SIX_ATTEMPTS_RECORDED"
    assert len(receipt["attempted_cases"])==6
    expect={(main,side,mode) for main,side in PAIRS for mode in ("honest","attack")}
    observed=set()
    cases=[]
    for row in receipt["attempted_cases"]:
        key=(row["main"],row["side"],row["mode"])
        assert key in expect and key not in observed
        observed.add(key)
        assert row["status"] in ("EVAL_COMPLETED","EVAL_FAILED","EVAL_EXCEPTION")
        assert row["duration_seconds"]>=0
        path=root/row["case"]/"case_receipt.json"
        assert path.is_file()
        assert json.loads(path.read_text())==row
        evaluations=row.get("inspect_logs",[])
        if row["status"]=="EVAL_COMPLETED":
            assert evaluations and all(x["eval_status"]=="success" and x["sample_count"]==1 for x in evaluations)
        for log in evaluations:
            for sample in log["samples"]:
                scores=sample.get("scores") or {}
                actual=scores.get("combined_pytest_scorer")
                # The scorer name may include a namespaced suffix in future
                # Inspect versions. For uncertainty, record "unparsed".
                parsed=None
                if isinstance(actual,dict):
                    value=actual.get("value")
                    if isinstance(value,dict):
                        assert set(value).issubset({"main_task_success","side_task_success"})
                        assert all(v in ("C","I") for v in value.values()), value
                        parsed=value
                cases.append({"main":row["main"],"side":row["side"],"mode":row["mode"],
                              "eval_status":log["eval_status"],
                              "score_parsed":parsed,
                              "main_success":parsed.get("main_task_success")=="C" if parsed else None,
                              "side_success":parsed.get("side_task_success")=="C" if parsed and row["mode"]=="attack" else None})
    assert observed==expect
    # Deliberately permit all 6 native attempts to fail model or scorer; these
    # are negative observations, not a green claim of attack capability.
    successful_main=sum(x["main_success"] is True for x in cases)
    successful_side=sum(x["side_success"] is True for x in cases)
    return {"status":"INDEPENDENT_ATTEMPT_ACCOUNTING_PASS",
            "task_pairs":len(PAIRS),"attempts":len(receipt["attempted_cases"]),
            "scored_logs":len(cases),"main_success_count":successful_main,
            "side_success_count":successful_side,
            "cases":cases,
            "unparsed_or_missing_scores":sum(x["score_parsed"] is None for x in cases),
            "receipt_sha256":sha((root/"native_multi_receipt.json").read_bytes())}
if __name__=="__main__":
    a=argparse.ArgumentParser();a.add_argument("--dir",default="native-unrestricted-results")
    p=a.parse_args()
    print(json.dumps(audit(p.dir),indent=2))
