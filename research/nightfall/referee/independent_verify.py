#!/usr/bin/env python3
"""Separate-language replay of a NIGHTFALL Referee JSON receipt.

Uses only the Python standard library, its own integer algorithms, and a
separate search implementation. Same research authorship is NOT an external
human referee. All acceptance is finite and scoped.
"""
import hashlib
import itertools
import json
import re
import sys
from fractions import Fraction
from functools import lru_cache
from pathlib import Path

def require(condition, message):
    if not condition:
        raise ValueError(message)

def exact_int(value):
    s=str(value).strip()
    require(re.fullmatch(r"-?\d+", s) is not None, "Non-integral input")
    return int(s)

def checksum(payload):
    raw=json.dumps(payload,ensure_ascii=False,separators=(",",":")).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()

def overlap(a,d):
    n=len(a)
    require(2<=n<=256 and 0<d<=10**27, "Unsupported dimensions")
    require(all(0<=x<=d for x in a), "Height outside feasible interval")
    require(2*sum(a)==n*d, "Mass normalization failed")
    # Independent implementation: iterate distinct occupied cell-pairs.
    hist={k:0 for k in range(1-n,n)}
    for i,ai in enumerate(a):
        for j,aj in enumerate(a):
            hist[i-j] += ai*(d-aj)
    high=max(hist.values())
    best=Fraction(2*high,n*d*d)
    return hist,high,best

def check_overlap(report):
    src=report["source"];a=list(map(exact_int,src["heights"]));d=exact_int(src["denominator"])
    hist,high,best=overlap(a,d)
    score=report.get("claimedScore")
    claim_ok=score is None or not str(score).strip() or Fraction(str(score))==best
    result=report["result"];summary=result["summary"]
    require(result["shifts"]==[{"lag":k,"numerator":str(v)} for k,v in hist.items()],"Lag transcript mismatch")
    require(result["cellCount"]==len(a) and result["denominator"]==str(d),"Cell metadata mismatch")
    require(result["mass"]==str(sum(a)),"Mass metadata mismatch")
    require(result["dualPathAgreement"] is True,"Dual path disagreement")
    require(Fraction(int(summary["score"]["numerator"]),int(summary["score"]["denominator"]))==best,"Maximum fraction mismatch")
    require(summary["maxNumerator"]==str(high),"Maximum numerator mismatch")
    require(summary["maxLags"]==[k for k,v in hist.items() if v==high],"Maximizing lags mismatch")
    require(result["claimMatches"]==(None if score is None or not str(score).strip() else claim_ok),"Claim comparison mismatch")
    require(result["status"]==("FINITE_CHECK_PASSED" if claim_ok else "REJECT"),"Claim status mismatch")
    attacks=report["negativeControls"]
    require(attacks["scoreTamperRejected"] is True,"Score-tamper control failed")
    transfer=attacks["massPreservingWitnessMutation"]
    if transfer.get("rejected") is True:
        i,j=transfer["to"],transfer["from"]
        require(isinstance(i,int) and isinstance(j,int) and i!=j and 0<=i<len(a) and 0<=j<len(a),"Invalid witness mutation")
        modified=a.copy();modified[i]+=1;modified[j]-=1
        _,_,newscore=overlap(modified,d)
        require(newscore!=best and str(newscore)==transfer["newScore"],"Mutation control failed")
    status=("FINITE_CHECK_PASSED" if claim_ok and transfer.get("rejected") is True
            else "REJECTED" if not claim_ok else "INCONCLUSIVE")
    require(report["verdict"]==status,"Verdict differs from independent replay")
    return {"domain":report["domain"],"verdict":status,"exact_score":str(best),"max_lags":summary["maxLags"]}

def weak_four(a):
    checks=0
    for v in itertools.combinations(a,4):
        checks+=1
        diffs={v[j]-v[i] for i in range(4) for j in range(i+1,4)}
        if len(diffs)<5:
            return False,checks
    return True,checks

def sidon_replay(points,subset,claimed):
    n=len(points)
    require(4<=n<=30 and sorted(set(points))==points,"Unsupported Sidon coordinates")
    require(len(subset)>=1 and len(set(subset))==len(subset) and set(subset)<=set(points),"Invalid explicit subset")
    require(0<=claimed<=n,"Invalid maximum size")
    weak,checks=weak_four(points)
    sums={x+y for i,x in enumerate(subset) for y in subset[i:]}
    valid=len(sums)==len(subset)*(len(subset)+1)//2
    edges=[sum(1<<i for i in t) for t in itertools.combinations(range(n),3)
           if points[t[0]]+points[t[2]]==2*points[t[1]]]
    if not weak or not valid or claimed<len(subset):
        return weak,checks,len(sums),edges,None,False
    target=claimed+1;budget=n-target
    if budget<0:
        return weak,checks,len(sums),edges,0,True
    @lru_cache(maxsize=None)
    def impossible(deleted,left):
        if impossible.cache_info().currsize>90000:
            raise RuntimeError("search cap reached")
        unhit=[e for e in edges if not (e & deleted)]
        if not unhit:return False
        used=0;packing=0
        for e in unhit:
            if not e&used:
                used |= e;packing+=1
        if packing>left:return True
        cnt=[sum(bool(e&(1<<i)) for e in unhit) for i in range(n)]
        edge=max(unhit,key=lambda e:sum(cnt[i] for i in range(n) if e&(1<<i)))
        return all(impossible(deleted|(1<<i),left-1) for i in range(n) if edge&(1<<i))
    try:
        proved=impossible(0,budget)
        return weak,checks,len(sums),edges,impossible.cache_info().currsize,proved
    except RuntimeError:
        return weak,checks,len(sums),edges,None,False

def check_sidon(report):
    src=report["source"];a=list(map(exact_int,src["points"]));b=list(map(exact_int,src["subset"]));claimed=report["claimedMaximum"]
    weak,checks,sums,edges,states,proved=sidon_replay(a,b,claimed)
    r=report["result"]
    require(r["cellCount"]==len(a) and r["subsetSize"]==len(b) and r["claimedMaximum"]==claimed,"Sidon metadata mismatch")
    require(r["weakSidonA"]["pass"]==weak and r["weakSidonB"]["pass"]==weak,"Weak Sidon cross-check mismatch")
    require(r["weakSidonA"]["tested"]==checks,"Four-point test count mismatch")
    require(r["subset"]["pass"]==(sums==len(b)*(len(b)+1)//2),"Sidon pair-sum property mismatch")
    if r["subset"]["pass"]:require(r["subset"]["pairSums"]==sums,"Pair-sum count mismatch")
    proof=r["proof"]
    if weak and r["subset"]["pass"] and claimed>=len(b):
        require(proof is not None,"Missing finite exclusion result")
        require(proof["arithmeticProgressions"]==len(edges),"Progression edge count mismatch")
        if states is not None:
            require(proof["states"]==states,"Memoized proof-state count mismatch")
            require((proof["status"]=="PROVED")==proved,"Finite exclusion verdict mismatch")
    else:
        require(proof is None,"Claim was impossible before exclusion search")
    passed=weak and r["subset"]["pass"] and claimed==len(b) and proved
    require(r["status"]==("FINITE_CHECK_PASSED" if passed else "REJECT_OR_INCONCLUSIVE"),"Sidon status mismatch")
    att=report["negativeControls"]
    require(att["corruptedSubsetRejected"] is True and att["understatedMaximumRejected"] is True,"Adversarial subset control failed")
    expected="FINITE_CHECK_PASSED" if passed else "REJECTED_OR_INCONCLUSIVE"
    require(report["verdict"]==expected,"Sidon receipt verdict mismatch")
    return {"domain":report["domain"],"verdict":expected,"points":len(a),"progressions":len(edges),"proof_states":states,"subset":len(b)}

def replay(report):
    require(report.get("format")=="nightfall-referee-receipt-v1","Unsupported report format")
    require(report.get("version")=="1.0.0","Verifier version mismatch")
    domain=report.get("domain")
    if domain=="continuous-step-overlap":
        payload={"domain":domain,"input":report["source"],"claimedScore":report.get("claimedScore")}
        fn=check_overlap
    elif domain=="weak-sidon-4-5-finite":
        payload={"domain":domain,"input":report["source"],"claimedMaximum":report["claimedMaximum"]}
        fn=check_sidon
    else:raise ValueError("Unknown finite domain")
    require(report.get("inputSha256")==checksum(payload),"Canonical input SHA-256 differs")
    result=fn(report)
    result["input_sha256"]=report["inputSha256"]
    result["replay"]="PASS"
    result["scope"]="Independent Python implementation; same research team, not independent external review"
    return result

if __name__=="__main__":
    try:
        if len(sys.argv)!=2:raise ValueError("Usage: python3 research/nightfall/referee/independent_verify.py RECEIPT.json")
        report=json.loads(Path(sys.argv[1]).read_text("utf-8"))
        print(json.dumps(replay(report),indent=2))
    except Exception as exc:
        print("PYTHON_REPLAY_REJECTED: "+str(exc),file=sys.stderr)
        sys.exit(1)
