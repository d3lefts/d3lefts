#!/usr/bin/env python3
"""Read-only discovery of unregistered Lean CI job candidates; no proof promotion."""
import argparse, datetime as dt, json, os, pathlib, urllib.parse, urllib.request

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--days",type=int,default=7)
    p.add_argument("--output",required=True)
    a=p.parse_args()
    if not 1<=a.days<=366: raise ValueError("days must be 1..366")
    repo=os.environ["GITHUB_REPOSITORY"]
    token=os.environ["GH_TOKEN"]
    root="https://api.github.com/repos/"+repo
    def get(route,params):
        req=urllib.request.Request(root+route+"?"+urllib.parse.urlencode(params),
            headers={"Authorization":"Bearer "+token,"Accept":"application/vnd.github+json","X-GitHub-Api-Version":"2022-11-28"})
        with urllib.request.urlopen(req,timeout=40) as response:
            return json.load(response)
    now=dt.datetime.now(dt.timezone.utc).date()
    first=now-dt.timedelta(days=a.days-1)
    def pages(route,params,key):
        page=1
        while True:
            result=get(route,{**params,"per_page":100,"page":page})
            batch=result[key]
            if page==1 and result.get("total_count",0)>1000:
                raise RuntimeError("API search window exceeds 1000; narrow query or split day")
            yield from batch
            if len(batch)<100:return
            page+=1
    ledger=json.loads(pathlib.Path("docs/proof-passport-v3.json").read_text())
    known_runs={row["run"] for row in ledger["records"] if row["run"]}
    known_jobs={(row["run"],row["job"]) for row in ledger["records"] if row["run"] and row["job"]}
    candidates=[]; scans=0; matching=0; seen=set()
    for i in range(a.days):
        day=(first+dt.timedelta(days=i)).isoformat()
        for run in pages("/actions/runs",{"created":day,"status":"completed"},"workflow_runs"):
            if run["id"] in seen:continue
            seen.add(run["id"]);scans+=1
            name=run.get("name","")
            if not any(k in name.lower() for k in ("lean","kernel","proof","certificate")):continue
            matching+=1
            for job in pages("/actions/runs/"+str(run["id"])+"/jobs",{"filter":"latest"},"jobs"):
                steps=job.get("steps",[])
                gate_steps=[s for s in steps if s.get("conclusion")=="success" and any(k in s.get("name","").lower() for k in ("kernel","leanchecker","axiom","named declaration","named-declaration","compile exact","compile pinned","compile source-exact"))]
                if job.get("conclusion")!="success" or not gate_steps:continue
                if (run["id"],job["id"]) in known_jobs:continue
                candidates.append({"run":run["id"],"job":job["id"],"workflow":name,"job_name":job["name"],"head":run["head_sha"],"event":run.get("event"),"run_attempt":run.get("run_attempt"),"job_url":job.get("html_url"),"successful_step_names":[s["name"] for s in gate_steps],"run_already_referenced":run["id"] in known_runs,"status":"candidate-only; source bytes, exact named output, pins and closure need audit"})
    out={"schema":"nightfall.lean-receipt-candidates.v1","start":first.isoformat(),"end":now.isoformat(),"completed_runs_seen":scans,"workflow_name_matches":matching,"candidate_jobs":len(candidates),"records":candidates,"scope":"Bounded daily completed-run metadata scan, not a census of local compiles or authenticated theorem proof. Successful job names and steps are discovery leads only. No registry write or promotion."}
    target=pathlib.Path(a.output);target.parent.mkdir(parents=True,exist_ok=True);target.write_text(json.dumps(out,indent=2)+"\n")
    print(json.dumps({k:v for k,v in out.items() if k!="records"},indent=2))
if __name__=="__main__":main()
