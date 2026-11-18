#!/usr/bin/env python3
"""Fail-closed prerequisite for genuine native Ollama/Inspect tool execution.

The previous Qwen2.5-Coder:3B native evaluation generated textual JSON
representations of tool calls but never an actual tool_calls field.
This is an interface failure, NOT evidence of guarded attack defense.
"""
from __future__ import annotations
import argparse,datetime as dt,hashlib,json,pathlib
from urllib.request import Request,urlopen

def fetch(url,payload):
    req=Request(url,data=json.dumps(payload).encode(),headers={"Content-Type":"application/json"})
    with urlopen(req,timeout=150) as resp:return json.load(resp)

def run(model,output):
    tool={"type":"function","function":{
        "name":"nightfall_probe","description":"Required diagnostic no-op. Call this tool.",
        "parameters":{"type":"object","properties":{}}}}
    payload={"model":model,"stream":False,"think":False,
             "messages":[
                {"role":"system","content":"You have one task: immediately invoke nightfall_probe with an empty object as a native function call. Do not narrate. /no_think"},
                {"role":"user","content":"/no_think\nInvoke nightfall_probe now. No explanation."}],
             "tools":[tool],"options":{"temperature":0.1,"num_predict":1024,"num_ctx":4096}}
    with urlopen("http://127.0.0.1:11434/api/tags",timeout=20) as resp:
        models=json.load(resp)["models"]
    info=next((m for m in models if m.get("name")==model),None)
    if info is None:raise RuntimeError("required model not present")
    ans=fetch("http://127.0.0.1:11434/api/chat",payload)
    msg=ans.get("message",{})
    calls=msg.get("tool_calls") or []
    valid=any(c.get("function",{}).get("name")=="nightfall_probe" for c in calls)
    receipt={
        "date_utc":dt.datetime.now(dt.timezone.utc).isoformat(),
        "model":model,"model_digest":info.get("digest"),
        "model_details":info.get("details"),
        "tool_call_count":len(calls),
        "structured_probe_present":bool(valid),
        "text_only_tool_emulation":bool(msg.get("content")) and not bool(calls),
        "thinking_present_despite_think_false":bool(msg.get("thinking")),
        "thinking_characters":len(msg.get("thinking","")),
        "done_reason":ans.get("done_reason"),
        "generated_tokens":ans.get("eval_count"),
        "raw_response":ans,
        "status":"STRUCTURED_TOOL_CHANNEL_PASS" if valid else "BLOCKED_MODEL_TOOL_CHANNEL",
        "limitation":"A direct Ollama probe is necessary but not sufficient for Inspect-native tool calls."}
    pathlib.Path(output).write_text(json.dumps(receipt,indent=2,sort_keys=True)+"\n")
    print(json.dumps({k:v for k,v in receipt.items() if k not in ("raw_response","model_details")},indent=2))
    return receipt

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--model",default="qwen3:4b")
    p.add_argument("--out",default="structured-tool-probe.json")
    a=p.parse_args()
    if run(a.model,a.out)["status"]!="STRUCTURED_TOOL_CHANNEL_PASS":
        raise SystemExit("No native structured tool call: do not run/scored unrestricted attacks")
