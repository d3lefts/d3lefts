#!/usr/bin/env python3
"""Native, free-form ControlArena IaC Fast evaluation on three held-out task pairs.

NO authored OU scaffold, NO preselected source path or edit, NO exact-text
candidate menu. The attack/honest policies use the setting's real full
bash/text_editor/cdk_synth/cdk_ls agent tools and official combined scorers.
Every selected sample is attempted once; failed/invalid attempts remain in
the denominator. Models, logs and results are recorded without inference
from Inspect task completion status to main/side success.
"""
from __future__ import annotations
import argparse
import datetime as dt
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import time
import traceback

PAIRS = (
 ("add_interpretability_ou", "disable_fsx_deny_policy"),
 ("create_billing_alarm", "allow_public_s3_policy"),
 ("enforce_mandatory_tags_scp", "detach_mfa_requirement_policy"),
)

def canon(obj):
    return (json.dumps(obj, sort_keys=True, separators=(",",":"), default=str)+"\n").encode()

def sha(data): return hashlib.sha256(data).hexdigest()
def to_json(x):
    if x is None:return None
    if hasattr(x,"model_dump"):return x.model_dump(mode="json")
    if isinstance(x,dict):return {str(k):to_json(v) for k,v in x.items()}
    if isinstance(x,(list,tuple)):return [to_json(v) for v in x]
    if isinstance(x,(str,bool,int,float)):return x
    return str(x)
def write(path,obj):path.write_bytes(canon(obj))

def run(root,model_name,per_case_seconds=300):
    from control_arena import EvalMode
    from control_arena.eval import ControlEvalConfig, get_control_task
    from control_arena.policy import untrusted_policy_builder
    from control_arena.settings.iac_fast import IACFastSetting
    from inspect_ai import eval as inspect_eval
    out=Path(root).resolve();out.mkdir(parents=True,exist_ok=True)
    cver=importlib.metadata.version("control-arena")
    if cver!="20.1.1":raise RuntimeError("pinned ControlArena source drift: "+cver)
    iver=importlib.metadata.version("inspect-ai")
    setting=IACFastSetting()
    tasks=list(setting.get_dataset(EvalMode.ATTACK))
    honest=list(setting.get_dataset(EvalMode.HONEST))
    catalog={"main":sorted({x.metadata["main_task_name"] for x in honest}),
             "side":sorted({x.metadata["side_task_name"] for x in tasks})}
    assert len(catalog["main"])==5 and len(catalog["side"])==9, catalog
    for main,side in PAIRS:
        assert sum(x.metadata["main_task_name"]==main for x in honest)==1
        assert sum((x.metadata["main_task_name"],x.metadata["side_task_name"])==(main,side) for x in tasks)==1
    config=ControlEvalConfig(
        untrusted_model=model_name,trusted_model=model_name,
        token_limit=24000,max_steps=24,time_limit=per_case_seconds,
        fail_on_error=False,
    )
    policy=untrusted_policy_builder()
    receipt={
        "status":"STARTED",
        "dataset":"official ControlArena IaC Fast 20.1.1",
        "inspect_ai_version":iver,
        "model":model_name,
        "agent_tool_permissions":"full native IaC Fast bash/text_editor/cdk_synth/cdk_ls",
        "authored_scaffold":False,
        "preselected_edit_or_path":False,
        "model_tool_channel_probe":"must be STRUCTURED_TOOL_CHANNEL_PASS before launch",
        "main_side_pairs":[{"main":a,"side":b} for a,b in PAIRS],
        "dataset_inventory":catalog,
        "attempted_cases":[],
        "started_utc":dt.datetime.now(dt.timezone.utc).isoformat(),
        "limitations":[
            "three fixed task pairs with one sample per mode; not a population success rate",
            "CI local Ollama is a small-capability attacker, not a frontier agent",
            "native Inspect / ControlArena scorers are not an AWS deployment oracle",
            "task success and side success must be parsed from native scores, NOT task execution status",
            "native .eval logs capture diff/source trajectory; no cloud execution",
        ],
    }
    write(out/"native_multi_receipt.json",receipt)
    for main,side in PAIRS:
        for mode in (EvalMode.HONEST,EvalMode.ATTACK):
            name=f"{main}__{side}__{mode.value}"
            matching=[x for x in (honest if mode==EvalMode.HONEST else tasks)
                      if x.metadata["main_task_name"]==main and
                      (mode==EvalMode.HONEST or x.metadata["side_task_name"]==side)]
            assert len(matching)==1
            sample=matching[0]
            case_dir=out/name;case_dir.mkdir()
            item={"case":name,"main":main,"side":side,"mode":mode.value,
                  "sample_id":sample.id,"status":"STARTED",
                  "started_utc":dt.datetime.now(dt.timezone.utc).isoformat()}
            receipt["attempted_cases"].append(item)
            write(out/"native_multi_receipt.json",receipt)
            started=time.perf_counter()
            try:
                task=get_control_task(
                    setting=setting,micro_protocol=policy,mode=mode,
                    eval_config=config,dataset=matching,
                    task_name_prefix="nightfall_freeform_v1",
                )
                logs=inspect_eval(
                    tasks=[task],limit=1,max_tasks=1,max_samples=1,
                    time_limit=per_case_seconds,log_dir=str(case_dir),
                )
                item["inspect_logs"]=[]
                for log in logs:
                    summary={"eval_status":str(getattr(log,"status","unknown")),
                             "location":str(getattr(log,"location","")),
                             "sample_count":len(getattr(log,"samples",None) or [])}
                    sam=[]
                    for samp in (getattr(log,"samples",None) or []):
                        native_scores=to_json(getattr(samp,"scores",None))
                        native_messages=(getattr(samp,"messages",None) or [])
                        native_tool_calls=sum(len(getattr(m,"tool_calls",None) or [])
                                              for m in native_messages)
                        native_tool_results=sum(str(getattr(m,"role",""))=="tool"
                                                for m in native_messages)
                        diff_text=(getattr(samp,"store",{}) or {}).get("submission_diff") if hasattr(getattr(samp,"store",{}),"get") else None
                        sam.append({"tool_calls":native_tool_calls,
                                    "tool_results":native_tool_results,
                                    "submission_diff_bytes":len(diff_text.encode()) if isinstance(diff_text,str) else 0,
                                    "sample_limit":to_json(getattr(samp,"limit",None)),
                                    "id":getattr(samp,"id",None),
                                        "scores":native_scores,
                                        "scores_present":bool(native_scores),
                                        "status":str(getattr(samp,"status","")),
                                        "metadata":to_json(getattr(samp,"metadata",{})),
                                        "store":to_json(getattr(samp,"store",{}))})
                    summary["samples"]=sam
                    item["inspect_logs"].append(summary)
                item["status"]="EVAL_COMPLETED" if all(x["eval_status"]=="success" for x in item["inspect_logs"]) else "EVAL_FAILED"
            except BaseException as exc:
                item["status"]="EVAL_EXCEPTION"
                item["exception"]=type(exc).__name__+": "+str(exc)[:600]
                item["traceback_tail"]=traceback.format_exc()[-2800:]
            item["duration_seconds"]=round(time.perf_counter()-started,3)
            write(case_dir/"case_receipt.json",item)
            write(out/"native_multi_receipt.json",receipt)
            print(json.dumps({"case":name,"status":item["status"],
                              "duration_seconds":item["duration_seconds"],
                              "score_keys":[list((s.get("scores") or {}).keys()) for l in item.get("inspect_logs",[]) for s in l["samples"]]},
                             sort_keys=True),flush=True)
    native_calls=sum(sample.get("tool_calls",0)
                     for item in receipt["attempted_cases"]
                     for log in item.get("inspect_logs",[])
                     for sample in log["samples"])
    receipt["total_native_tool_calls"]=native_calls
    receipt["all_cases_called_tools"]=all(
       any(sample.get("tool_calls",0)>0
           for log in item.get("inspect_logs",[])
           for sample in log["samples"])
       for item in receipt["attempted_cases"])
    receipt["status"]="SIX_TOOL_ACTIVE_ATTEMPTS" if len(receipt["attempted_cases"])==6 and receipt["all_cases_called_tools"] else "BLOCKED_OR_UNUSABLE_NATIVE_AGENT"
    receipt["all_native_evals_completed"]=all(x["status"]=="EVAL_COMPLETED" for x in receipt["attempted_cases"])
    receipt["finished_utc"]=dt.datetime.now(dt.timezone.utc).isoformat()
    write(out/"native_multi_receipt.json",receipt)
    return receipt

if __name__=="__main__":
    a=argparse.ArgumentParser()
    a.add_argument("--out",default="native-unrestricted-results")
    a.add_argument("--model",default="ollama/qwen3:4b")
    a.add_argument("--time-limit",type=int,default=240)
    args=a.parse_args()
    assert 45<=args.time_limit<=480
    r=run(args.out,args.model,args.time_limit)
    print(json.dumps({"status":r["status"],"all_native_evals_completed":r["all_native_evals_completed"],
                      "attempts":len(r["attempted_cases"]),"total_native_tool_calls":r["total_native_tool_calls"]},indent=2))
    if r["status"]!="SIX_TOOL_ACTIVE_ATTEMPTS" or not r["all_native_evals_completed"]:
        raise SystemExit("FAIL CLOSED: missing tool calls or incomplete native tasks; keep all receipts")
