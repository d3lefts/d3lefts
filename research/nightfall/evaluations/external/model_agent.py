"""Bounded, tool-using external-model repair trial.

The inference step can read/edit only a disposable task copy. Untrusted source
is executed only in a no-network Docker container without credentials.
Not a production-grade isolation or independent scientific certification.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import urllib.error
import urllib.request

ENDPOINT = "https://models.github.ai/inference/chat/completions"
TOOL_DEFS = [
  {"type":"function","function":{"name":"list_files","description":"List task-visible files","parameters":{"type":"object","properties":{},"additionalProperties":False}}},
  {"type":"function","function":{"name":"inspect","description":"Read a relative file within the task candidate","parameters":{"type":"object","properties":{"path":{"type":"string"}},"required":["path"],"additionalProperties":False}}},
  {"type":"function","function":{"name":"write_file","description":"Replace the entire content of one existing Python implementation file. Cannot modify tests or ISSUE.","parameters":{"type":"object","properties":{"path":{"type":"string"},"content":{"type":"string"}},"required":["path","content"],"additionalProperties":False}}},
  {"type":"function","function":{"name":"run_public_tests","description":"Execute the agent-visible smoke tests in a no-network, credential-free Docker container","parameters":{"type":"object","properties":{},"additionalProperties":False}}},
  {"type":"function","function":{"name":"finish","description":"Stop editing and submit your attempted repair for withheld contract scoring","parameters":{"type":"object","properties":{},"additionalProperties":False}}}
]
def sha(data):return hashlib.sha256(data).hexdigest()

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--candidate",required=True)
    parser.add_argument("--task",choices=["dispatchq","artifactgraph"],required=True)
    parser.add_argument("--model",default="openai/gpt-4.1")
    parser.add_argument("--out",required=True)
    parser.add_argument("--max-model-turns",type=int,default=8)
    parser.add_argument("--max-tools",type=int,default=20)
    args=parser.parse_args()
    root=Path(args.candidate).resolve()
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    codepaths=sorted(p.relative_to(root).as_posix() for p in root.rglob("*.py") if "tests" not in p.parts and p.is_file())
    allowed=set(codepaths)
    visible=sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file() and p.relative_to(root).parts[0] not in ("__pycache__",))
    initial={p:(root/p).read_bytes() for p in codepaths}
    issue=(root/"ISSUE.md").read_text()
    model_token=os.environ.get("GITHUB_TOKEN","")
    messages=[
      {"role":"system","content":"You are an external coding agent doing an independently scored software repair. Use available tools to inspect, edit implementation files and run PUBLIC tests. Do not edit tests or the issue. Satisfy the entire written contract, not only public smoke tests. Call finish when ready. You have a strict call budget."},
      {"role":"user","content":f"TASK {args.task}. Files: {visible}. Work only in the candidate. Contract follows:\\n{issue}"}
    ]
    events=[];usage=[];status="model_not_started";error=None;tools_used=0;started=time.monotonic()
    def invoke(name,inputs):
        nonlocal tools_used
        tools_used+=1
        if tools_used>args.max_tools:return {"error":"tool budget exhausted"}
        if name=="list_files":return {"files":visible}
        if name in ("inspect","write_file"):
            rel=inputs.get("path","")
            if not isinstance(rel,str) or rel not in (visible if name=="inspect" else allowed):
                return {"error":"path not in allowed file set"}
            file=root/rel
            if name=="inspect":return {"path":rel,"content":file.read_text(encoding="utf-8")[:24000]}
            code=inputs.get("content")
            if not isinstance(code,str) or not code or len(code)>60000:return {"error":"invalid content"}
            file.write_text(code,encoding="utf-8")
            return {"written":rel,"new_sha256":sha(code.encode())}
        if name=="run_public_tests":
            cmd=["docker","run","--rm","--network","none","--read-only","--tmpfs","/tmp:rw,exec,nosuid,size=64m",
                "--cap-drop","ALL","--security-opt","no-new-privileges","--memory","512m","--pids-limit","128",
                "--user","65534:65534","-e","PYTHONDONTWRITEBYTECODE=1",
                "-v",str(root)+":/task:ro","-w","/task","python:3.13-slim",
                "python","-m","unittest","discover","-s","tests","-v"]
            try:
                r=subprocess.run(cmd,capture_output=True,text=True,timeout=90,env={"PATH":os.environ.get("PATH","/usr/bin:/bin")})
                return {"exit_code":r.returncode,"output":(r.stdout+r.stderr)[-6000:]}
            except Exception as exc:return {"error":"test tool failed: "+str(exc)[:250]}
        if name=="finish":return {"finished":True}
        return {"error":"unknown tool"}
    for turn in range(args.max_model_turns):
        if not model_token:
            status="no_external_model_token";error="GitHub Models credential unavailable";break
        payload={"model":args.model,"messages":messages,"tools":TOOL_DEFS,"tool_choice":"auto","temperature":0.1,"max_tokens":9000}
        try:
            req=urllib.request.Request(ENDPOINT,data=json.dumps(payload).encode(),
                 headers={"Accept":"application/vnd.github+json","Content-Type":"application/json",
                          "Authorization":"Bearer "+model_token},method="POST")
            with urllib.request.urlopen(req,timeout=100) as response:
                result=json.load(response)
        except Exception as exc:
            status="inference_error";error=str(exc)[:500];break
        usage.append(result.get("usage",{}))
        choice=result["choices"][0]["message"]
        calls=choice.get("tool_calls") or []
        messages.append({k:v for k,v in choice.items() if k in ("role","content","tool_calls")})
        if not calls:
            status="model_stopped_without_finish";error=str(choice.get("content",""))[-600:];break
        done=False
        for call in calls:
            func=call.get("function") or {}
            name=func.get("name","")
            try:args_dict=json.loads(func.get("arguments","{}"))
            except Exception:args_dict={}
            # Do not store full source edits in the public event summary.
            event={"turn":turn+1,"tool":name,"path":args_dict.get("path") if name in ("inspect","write_file") else None}
            response=invoke(name,args_dict)
            event["result"]=response if name!="inspect" else {"content_len":len(response.get("content",""))}
            events.append(event)
            messages.append({"role":"tool","tool_call_id":call["id"],"content":json.dumps(response)})
            if name=="finish" and response.get("finished"):done=True
        if done:
            status="completed";break
        if tools_used>=args.max_tools:
            status="tool_budget_exhausted";break
    else:status="model_turn_budget_exhausted"
    modified={p:sha((root/p).read_bytes()) for p in codepaths if (root/p).read_bytes()!=initial[p]}
    receipt={"schema":"nightfall.external-trial.v0.1","task":args.task,"model_requested":args.model,
       "model_responses_received":len(usage),"status":status,"error":error,
       "model_tool_budget":args.max_tools,"model_turn_budget":args.max_model_turns,
       "tools_used":tools_used,"modified_file_hashes":modified,
       "candidate_initial_file_hashes":{p:sha(v) for p,v in initial.items()},
       "issue_sha256":sha(issue.encode()),"wall_seconds":round(time.monotonic()-started,2),
       "usage":usage,"independent_external_model_execution":status!="no_external_model_token" and len(usage)>0}
    (out/"receipt.json").write_text(json.dumps(receipt,indent=2,sort_keys=True)+"\\n")
    (out/"trace.json").write_text(json.dumps(events,indent=2,sort_keys=True)+"\\n")
    (out/"transcript.json").write_text(json.dumps(messages,indent=2)+"\\n")
    print(json.dumps({k:v for k,v in receipt.items() if k not in ("candidate_initial_file_hashes","usage")},sort_keys=True))
if __name__=="__main__":main()
