#!/usr/bin/env python3
"""Historical receipt reconciliation. Read-only; no mathematical status promotion."""
import argparse, base64, collections, concurrent.futures, datetime as dt, hashlib, json, os, pathlib, re, urllib.error, urllib.parse, urllib.request

ALLOWED={"propext","Classical.choice","Quot.sound"}
SHA=re.compile(r"^[a-f0-9]{40}$")
ANSI=re.compile(r"\x1b\[[0-9;]*m")
TS=re.compile(r"^\d{4}-\d\d-\d\dT\S+Z ")
class Redirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self,req,fp,code,msg,headers,newurl):
        out=super().redirect_request(req,fp,code,msg,headers,newurl)
        if out and urllib.parse.urlsplit(newurl).netloc!="api.github.com":
            out.remove_header("Authorization")
        return out
class API:
    def __init__(self):
        self.root="https://api.github.com/repos/"+os.environ["GITHUB_REPOSITORY"]
        self.token=os.environ["GH_TOKEN"]
        self.opener=urllib.request.build_opener(Redirect())
    def get(self,route,params=None,raw=False):
        url=self.root+route+("?" + urllib.parse.urlencode(params) if params else "")
        req=urllib.request.Request(url,headers={"Authorization":"Bearer "+self.token,"Accept":"application/vnd.github+json","X-GitHub-Api-Version":"2022-11-28"})
        with self.opener.open(req,timeout=45) as res:
            data=res.read()
        return data.decode("utf-8",errors="replace") if raw else json.loads(data)
    def pages(self,route,params,key,cap=None):
        page=1; seen=set()
        while True:
            j=self.get(route,{**params,"per_page":100,"page":page})
            if cap and j.get("total_count",0)>cap:raise ValueError("partition exceeds API cap")
            batch=j[key]
            for x in batch:
                if x["id"] in seen: raise RuntimeError("duplicate page identity")
                seen.add(x["id"]);yield x
            if len(batch)<100:return
            page+=1
def atomic(path,data):
    p=pathlib.Path(path);p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(data,indent=2,sort_keys=True)+"\n")
def parse_log(log):
    lines=log.splitlines()
    # First checkout hash is the actual tested commit, not merely PR head.
    tested=None
    for i,l in enumerate(lines[:-1]):
        if "[command]" in l and "git log -1 --format=%H" in l:
            v=TS.sub("",lines[i+1]).strip()
            if SHA.fullmatch(v):tested=v;break
    clean="\n".join(TS.sub("",ANSI.sub("",l)) for l in lines if "\x1b[36;1m" not in l and "##[group]" not in l)
    names={}
    for m in re.finditer(r"'([\w.]+)' depends on axioms:\s*\[([^\]]*)\]",clean):
        ax={a.strip().strip("'\"") for a in m[2].split(",") if a.strip()}
        if ax<=ALLOWED:names[m[1]]=sorted(ax)
    for m in re.finditer(r"'([\w.]+)' does not depend on any axioms",clean):names[m[1]]=[]
    for m in re.finditer(r"(?m)^(Nightfall\.[\w.]+)\s+\[([^\]\n]*)\]\s*$",clean):
        ax={a.strip().strip("'\"") for a in m[2].split(",") if a.strip()}
        if ax<=ALLOWED:names[m[1]]=sorted(ax)
    return tested,names,clean
def declared_names(source,names):
    # Only bind explicitly printed qualified names or matching namespace and local declaration.
    # No suffix-only match without namespace evidence.
    explicit=set(re.findall(r"(?m)^\s*#print axioms\s+([\w.]+)",source))
    ns=set(re.findall(r"(?m)^\s*namespace\s+([\w.]+)",source))
    locals_=set(re.findall(r"(?m)^\s*(?:(?:private|protected|noncomputable)\s+)*(?:theorem|lemma|def)\s+([\w.]+)",source))
    return sorted(n for n in names if n in explicit or (n.rsplit(".",1)[-1] in locals_ and any(n.startswith(p+".") for p in ns if "." in p)))
def audit_run(api,run_id,rows):
    output=[]
    try:
        run=api.get("/actions/runs/"+str(run_id))
        jobs=list(api.pages("/actions/runs/"+str(run_id)+"/jobs",{"filter":"all"},"jobs"))
    except Exception as e:
        return [{"path":x["path"],"blob":x["blob"],"run":run_id,"disposition":"run-unavailable","detail":type(e).__name__+": "+str(e)} for x in rows]
    passed=[];errors=[]
    for j in jobs:
        if j.get("conclusion")!="success":continue
        steps=[s["name"] for s in j.get("steps",[]) if s.get("conclusion")=="success"]
        # All successful jobs are inspected, including mixed overall failures.
        try:
            log=api.get("/actions/jobs/"+str(j["id"])+"/logs",raw=True)
            tested,names,clean=parse_log(log)
            if names:passed.append((j,tested,names,steps,hashlib.sha256(log.encode()).hexdigest()))
        except Exception as e:errors.append({"job":j["id"],"error":type(e).__name__+": "+str(e)})
    for x in rows:
        row={"path":x["path"],"blob":x["blob"],"run":run_id,"run_head":run["head_sha"],"run_conclusion":run.get("conclusion"),"attempts_reported":run.get("run_attempt"),"jobs":[{"id":j["id"],"name":j["name"],"conclusion":j.get("conclusion")} for j in jobs],"matches":[],"errors":list(errors)}
        source=pathlib.Path(x["path"]).read_text()
        for j,tested,names,steps,log_hash in passed:
            selected=declared_names(source,names)
            if not selected:continue
            if not tested:
                row["errors"].append({"job":j["id"],"error":"no full tested checkout hash"});continue
            try:
                actual=api.get("/contents/"+urllib.parse.quote(x["path"],safe="/"),{"ref":tested})
                if actual.get("sha")!=x["blob"]:
                    row["errors"].append({"job":j["id"],"error":"tested source blob differs","tested_blob":actual.get("sha"),"tested":tested});continue
                if not actual.get("content"):raise ValueError("source content absent")
                raw=base64.b64decode(actual["content"])
                if hashlib.sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest()!=x["blob"]:raise ValueError("source hash mismatch")
                selected=declared_names(raw.decode(),names)
                if not selected:continue
                row["matches"].append({"job":j["id"],"tested":tested,"declarations":selected,"axioms":{n:names[n] for n in selected},"successful_steps":steps,"kernel_step_named":any("kernel" in s.lower() or "leanchecker" in s.lower() for s in steps),"log_sha256":log_hash})
            except Exception as e:row["errors"].append({"job":j["id"],"error":type(e).__name__+": "+str(e)})
        row["disposition"]="exact-source-named-audit" if row["matches"] else ("no-successful-job" if jobs and not any(j.get("conclusion")=="success" for j in jobs) else "unresolved-log-source-or-scope")
        output.append(row)
    return output
def leads(api,out):
    pending=json.loads(pathlib.Path("docs/lean-pending-source-custody.json").read_text())
    groups=collections.defaultdict(list)
    for x in pending["sources"]:
        for run in sorted(set(map(int,re.findall(r"\b\d{10,12}\b",x.get("receipt_scope",""))))):
            groups[run].append({"path":x["path"],"blob":x["source_blob_sha"]})
    rows=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for batch in pool.map(lambda r:audit_run(api,r,groups[r]),sorted(groups)):rows.extend(batch)
    counts=dict(collections.Counter(x["disposition"] for x in rows))
    result={"schema":"nightfall.historical-lead-audit.v1","source_checkpoint":os.environ.get("GITHUB_SHA"),"runs":len(groups),"paths":len({x["path"] for x in rows}),"rows":rows,"counts":counts,"scope":"Named ordinary-axiom output, source bytes at tested checkout and successful job metadata only. Does not independently replay Lean or infer complete kernel coverage from steps. All lead pairs retained, including failed and inaccessible."}
    atomic(out,result)
    print("LEAD_SUMMARY "+json.dumps({k:v for k,v in result.items() if k!="rows"},sort_keys=True),flush=True)
    for row in rows:print("LEAD_ROW "+json.dumps(row,separators=(",",":"),sort_keys=True),flush=True)
def history(api,out):
    repo=api.get("")
    start=dt.date.fromisoformat(repo["created_at"][:10])
    end=dt.datetime.now(dt.timezone.utc).date()
    rows=[]; partitions=[]
    def scan(lo,hi):
        # Non-overlapping inclusive UTC date partitions; recursively split API's 1000 cap.
        q={"created":lo.isoformat()+".."+hi.isoformat()}
        first=api.get("/actions/runs",{**q,"per_page":1,"page":1})
        total=first.get("total_count",0)
        if total>1000:
            if lo==hi:raise RuntimeError("single-day cap exceeded: "+str(lo))
            mid=lo+(hi-lo)//2;scan(lo,mid);scan(mid+dt.timedelta(days=1),hi);return
        batch=list(api.pages("/actions/runs",q,"workflow_runs",cap=1000))
        if len(batch)!=total:raise RuntimeError("moving or incomplete partition "+str(q)+" expected "+str(total)+" got "+str(len(batch)))
        partitions.append({"start":str(lo),"end":str(hi),"count":total})
        rows.extend({k:r.get(k) for k in ["id","name","path","event","status","conclusion","head_sha","run_attempt","created_at","updated_at","html_url"]} for r in batch)
    scan(start,end)
    if len({r["id"] for r in rows})!=len(rows):raise RuntimeError("overlapping run identities")
    result={"schema":"nightfall.historical-run-index.v1","start":str(start),"end":str(end),"repository":os.environ["GITHUB_REPOSITORY"],"runs":len(rows),"partitions":partitions,"records":rows,"scope":"All API-visible workflow run metadata, no workflow name filter, at scan time. Deleted runs, expired logs, local-only compiles and individual old job attempts not guaranteed. Current day can change; partition count mismatches fail closed."}
    atomic(out,result)
    print("HISTORY_SUMMARY "+json.dumps({k:v for k,v in result.items() if k!="records"},sort_keys=True),flush=True)
def main():
    p=argparse.ArgumentParser();p.add_argument("--mode",choices=["leads","history","self-test"],required=True);p.add_argument("--output",default="passport-receipts/audit.json");a=p.parse_args()
    if a.mode=="self-test":
        h="a"*40
        log="[command]/usr/bin/git log -1 --format=%H\n"+h+"\n'Nightfall.Test.good' depends on axioms: [propext,\n Classical.choice, Quot.sound]\n'Nightfall.Test.bad' depends on axioms: [sorryAx]\n\x1b[36;1m'Nightfall.Test.echo' does not depend on any axioms\x1b[0m"
        tested,names,_=parse_log(log)
        assert tested==h and set(names)=={"Nightfall.Test.good"}
        assert declared_names("namespace Nightfall.Test\n theorem good : True := trivial\n",names)==["Nightfall.Test.good"]
        assert declared_names("namespace Other.Test\n theorem good : True := trivial\n",names)==[]
        print("PASS: tested checkout, multiline ordinary axioms, rejected sorry and echoed audit, namespace isolation")
    elif a.mode=="leads":leads(API(),a.output)
    else:history(API(),a.output)
if __name__=="__main__":main()
