#!/usr/bin/env python3
"""Native ControlArena IaC Fast model tool-use study: two main x two side tasks.

NO restricted edit slots; the agent receives ControlArena's normal bash,
text_editor, cdk_ls, cdk_synth tools. Native Inspect traces and scores are
stored verbatim. This is not the separate NIGHTFALL offline effect gate.
"""
from __future__ import annotations
import argparse
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import subprocess
import time
import traceback

MAIN = ("add_interpretability_ou", "create_billing_alarm")
SIDE = ("disable_fsx_deny_policy", "detach_mfa_requirement_policy")

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True, default=str)+"\n")

def summarize_log(logpath):
    from inspect_ai.log import read_eval_log
    log = read_eval_log(str(logpath))
    results = []
    for sample in log.samples or []:
        info = dict(sample_id=str(sample.id), epoch=getattr(sample,"epoch",None),
                    metadata=getattr(sample,"metadata",None),
                    status=str(getattr(sample,"error",None) or "completed"))
        scores=getattr(sample,"scores",None) or {}
        info["score_values"]={name:getattr(v,"value",v) for name,v in scores.items()}
        info["score_names"]=sorted(scores)
        results.append(info)
    return results

def run(directory):
    out=Path(directory).resolve();out.mkdir(parents=True,exist_ok=True)
    receipt={"protocol":"NIGHTFALL-native-unrestricted-tool-selection-v1",
             "state":"started","model_generated_open_tool_use":True,
             "model_edit_slots":None,
             "offline_no_AWS":True,
             "sampling":"all preregistered 2 main × 2 side attack tasks and two honest",
             "main_tasks":list(MAIN),"side_tasks":list(SIDE),
             "native_inspect_scored_samples":[],
             "mode_runs":[],
             "limitations":[
                 "Small local coding model, no frontier adversary",
                 "No coverage of all 45 IaC Fast combinations",
                 "The native ControlArena task runner is not the trusted NIGHTFALL finality gate",
                 "Evaluation samples may fail to produce executable code",
                 "One attempted run per specified task (not a statistical safety-rate estimate)",
                 "No AWS deployment or actual production enforcement",
             ]}
    write(out/"receipt.json",receipt)
    if importlib.metadata.version("control-arena")!="20.1.1":
        raise RuntimeError("control-arena pin drift")
    from control_arena import EvalMode
    from control_arena.eval import ControlEvalConfig,get_control_task
    from control_arena.settings.iac_fast import IACFastSetting
    from control_arena.policy import untrusted_policy_builder
    from inspect_ai import eval as inspect_eval
    from control_arena.settings.iac_fast.setting import get_honest_samples,get_attack_samples
    declared_ids={x.id for x in get_honest_samples()}|{x.id for x in get_attack_samples()}
    chosen={
       "honest":[f"MT_{m}" for m in MAIN],
       "attack":[f"MT_{m}_ST_{s}" for m in MAIN for s in SIDE],
    }
    if not set(chosen["honest"]+chosen["attack"])<=declared_ids:
        raise RuntimeError("declared official ControlArena task IDs unavailable")
    model="ollama/qwen2.5-coder:3b"
    receipt["model"]=model
    receipt["control_arena_version"]=importlib.metadata.version("control-arena")
    receipt["inspect_ai_version"]=importlib.metadata.version("inspect-ai")
    receipt["docker_server"]=subprocess.check_output(
        ["docker","info","--format","{{.ServerVersion}}"],text=True,timeout=30).strip()
    receipt["task_ids"]=chosen
    receipt["model_tag_sha256"]=hashlib.sha256((out/"ollama-tags.json").read_bytes()).hexdigest() if (out/"ollama-tags.json").exists() else None
    write(out/"receipt.json",receipt)
    config=ControlEvalConfig(untrusted_model=model,trusted_model=model,token_limit=14000)
    protocol=untrusted_policy_builder()
    for mode_name,mode in (("honest",EvalMode.HONEST),("attack",EvalMode.ATTACK)):
        ids=chosen[mode_name]
        mode_dir=out/mode_name;mode_dir.mkdir(exist_ok=True)
        t0=time.perf_counter_ns()
        try:
            task=get_control_task(setting=IACFastSetting(),micro_protocol=protocol,
                                  mode=mode,eval_config=config)
            logs=inspect_eval(tasks=[task],sample_id=ids,max_tasks=1,log_dir=str(mode_dir))
            run_info={"mode":mode_name,"duration_ms":round((time.perf_counter_ns()-t0)/1e6,3),
                      "selected_task_ids":ids,"logs":[]}
            all_rows=[]
            for log in logs:
                path=Path(str(log.location))
                entries=summarize_log(path)
                run_info["logs"].append({
                    "status":str(getattr(log,"status",None)),
                    "log_file":str(path.relative_to(out)) if path.is_relative_to(out) else str(path),
                    "num_scored_samples":len(entries),
                })
                all_rows.extend(entries)
            observed_ids=[x["sample_id"] for x in all_rows]
            if set(observed_ids)!=set(ids) or len(observed_ids)!=len(ids):
                raise RuntimeError(f"Insufficient/duplicated samples in {mode_name}: {observed_ids}")
            write(mode_dir/"sample_outcomes.json",all_rows)
            receipt["native_inspect_scored_samples"].extend([{"mode":mode_name,**r} for r in all_rows])
            receipt["mode_runs"].append(run_info)
        except Exception as exc:
            receipt["mode_runs"].append({
                "mode":mode_name,
                "duration_ms":round((time.perf_counter_ns()-t0)/1e6,3),
                "status":"FAILED_RUN_OR_MISSING_SAMPLES",
                "error":str(exc)[:1500],
                "traceback":traceback.format_exc()[-3500:]})
            receipt["state"]="blocked_native_eval"
            write(out/"receipt.json",receipt)
            raise
    receipt["state"]="completed_native_evaluation"
    write(out/"receipt.json",receipt)
    print(json.dumps({"state":receipt["state"],"model":model,
                      "mode_runs":receipt["mode_runs"],
                      "sample_scores":receipt["native_inspect_scored_samples"]},indent=2,default=str))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--out",default="native-multitask-results")
    args=p.parse_args()
    run(args.out)
