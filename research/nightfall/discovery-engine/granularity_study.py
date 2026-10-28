#!/usr/bin/env python3
"""Proof-sensitive, paired, held-out NIGHTFALL granularity ablation.

Fixed, event-adaptive, atomic, and training-selected policies have identical
candidate pools and exact-verifier call limits. The source bytes and evidence
zones are immutable. All findings are bounded synthetic proxy results.
"""
from __future__ import annotations
import argparse
from dataclasses import asdict, dataclass
from hashlib import sha256
import json
from pathlib import Path
import random
import sys

from adaptive_resolution import build_hierarchy
from granularity_oracle import overlap_certificate, source_certificate

SCHEMA="nightfall.granularity-study.v1"
TRIALS=8
POOL=8
TRAIN=12
TEST=12
DOMAINS=("overlap_proxy","source_spans_proxy")


@dataclass(frozen=True)
class Policy:
    fine: int
    edge: int
    coarse: int


POLICIES=tuple(Policy(f,e,c) for f in (3,6,12) for e in (0,1,2) for c in (2,4))
FIXED=Policy(6,0,4)
ADAPTIVE=Policy(6,2,4)
ATOMIC=Policy(1,0,1)


def fixture(domain: str, seed: int) -> dict:
    rng=random.Random(seed)
    if domain=="overlap_proxy":
        n=31
        mass=10
        ids=rng.sample(range(n),mass)
        base=bytearray(b"0"*n)
        for i in ids:base[i]=49
        rounds=[]
        for _ in range(TRIALS):
            moves=[]
            for j in range(POOL):
                one=rng.choice([i for i,v in enumerate(base) if v==49])
                zero=rng.choice([i for i,v in enumerate(base) if v==48])
                moves.append((one,zero))
            rounds.append(moves)
        return {"domain":domain,"raw":bytes(base),"mass":mass,"hard":(),"rounds":rounds}
    if domain=="source_spans_proxy":
        n=48
        raw=bytearray()
        while len(raw)<n:
            label=49 if rng.random()<0.56 else 48
            raw.extend(bytes([label])*rng.randrange(2,10))
        raw=bytes(raw[:n])
        hard=(12,24,36)
        rounds=[]
        for _ in range(TRIALS):
            spans=[]
            for j in range(POOL):
                start=rng.randrange(0,n-1)
                end=min(n,start+rng.randrange(1,8))
                spans.append((start,end))
            rounds.append(spans)
        return {"domain":domain,"raw":raw,"hard":hard,"rounds":rounds}
    raise ValueError("Unknown synthetic study domain")


def segment(raw: bytes, hard: tuple[int,...], policy: Policy):
    # Edge signal represents discontinuities in native atoms. Source authority
    # boundaries are immutable for every policy including the fixed baseline.
    scores={i: (0.0 if raw[i]==raw[i-1] else
                 (0.0,0.72,1.0)[policy.edge]) for i in range(1,len(raw))}
    tree=build_hierarchy(raw,signals=scores,hard_boundaries=hard,
                         max_fine_bytes=policy.fine,
                         max_coarse_children=policy.coarse)
    assert tree.dechunk(raw)==raw
    return tree


def overlap_proxy(bits: bytes, tree):
    """Coarse mass-center pair approximation. Used for ranking alone."""
    n=len(bits)
    centers=[]
    for c in tree.coarse:
        mass=sum(v==49 for v in bits[c.start:c.end])
        if mass:
            centers.append((round((c.start+c.end-1)/2),mass))
    hist=[0]*n
    ops=0
    for x,mx in centers:
        for y,my in centers:
            if x==y:continue
            hist[(y-x)%n]+=mx*my
            ops+=1
    return max(hist[1:]),ops


def source_proxy(bits: bytes, tree, start:int,end:int):
    """Coarse evidence average over intersecting parent blocks."""
    total=0
    ops=0
    for c in tree.coarse:
        intersection=max(0,min(end,c.end)-max(start,c.start))
        if intersection:
            mean=sum(v==49 for v in bits[c.start:c.end])/(c.end-c.start)
            total+=intersection*mean
            ops+=c.end-c.start
    return total/(end-start),ops


def evaluate_case(case:dict,policy:Policy) -> dict:
    raw=case["raw"]
    hard=case["hard"]
    base=raw
    oracle_calls=0
    proxy_ops=0
    reductions=[]
    false_selection=0
    certified_positive=0
    if case["domain"]=="overlap_proxy":
        baseline=overlap_certificate(base,case["mass"])["max"]
        current=base
        best=baseline
    else:
        baseline=0
        best=0
    for round_id,candidates in enumerate(case["rounds"]):
        choices=[]
        for slot, candidate in enumerate(candidates):
            if case["domain"]=="overlap_proxy":
                a,b=candidate
                # Every candidate comes from an immutable seed; all arms receive
                # the same pool. A has exactly one candidate check per round.
                proposed=bytearray(base)
                proposed[a],proposed[b]=proposed[b],proposed[a]
                proposed=bytes(proposed)
                tree=segment(proposed,hard,policy)
                score,cost=overlap_proxy(proposed,tree)
                rank=(score,slot)
            else:
                start,end=candidate
                tree=segment(base,hard,policy)
                score,cost=source_proxy(base,tree,start,end)
                # Crossing hard trust zones is visible even at fixed resolution.
                crossing=any(start<k<end for k in hard)
                rank=(1 if crossing else 0,-score,slot)
            proxy_ops+=cost
            reductions.append(len(base)/max(1,len(tree.coarse)))
            choices.append((rank,slot))
        selected=min(choices)[1]
        oracle_calls+=1
        if case["domain"]=="overlap_proxy":
            a,b=candidates[selected]
            proposal=bytearray(base)
            proposal[a],proposal[b]=proposal[b],proposal[a]
            verified=overlap_certificate(bytes(proposal),case["mass"])
            best=min(best,verified["max"])
        else:
            a,b=candidates[selected]
            passed=source_certificate(base,hard,a,b)
            certified_positive+=int(passed)
            false_selection+=int(not passed)
    if case["domain"]=="overlap_proxy":
        gain=baseline-best
        metric=gain
    else:
        gain=certified_positive
        metric=certified_positive
    return {"case_sha256":sha256(raw).hexdigest(),"certified_gain":gain,
            "initial_score":baseline,"final_score":best,
            "exact_calls":oracle_calls,"coarse_ops":proxy_ops,
            "mean_compression":round(sum(reductions)/len(reductions),5),
            "verified_source_admissions":certified_positive,
            "rejected_source_proposals":false_selection,
            "metric":metric}


def score_cases(cases: list[dict],policy:Policy) -> dict:
    runs=[evaluate_case(c,policy) for c in cases]
    return {"policy":asdict(policy),"cases":len(runs),
            "certified_gain_sum":sum(x["certified_gain"] for x in runs),
            "exact_calls":sum(x["exact_calls"] for x in runs),
            "coarse_ops":sum(x["coarse_ops"] for x in runs),
            "mean_compression":round(sum(x["mean_compression"] for x in runs)/len(runs),5),
            "successful_cases":sum(x["certified_gain"]>0 for x in runs),
            "rejected_source_proposals":sum(x["rejected_source_proposals"] for x in runs),
            "case_results":runs}


def training_objective(res:dict) -> tuple:
    # Exact downstream successes first, proxy cost only for ties.
    # Scores across domains are normalized by number of cases/trials.
    return (res["certified_gain_sum"],-res["coarse_ops"])


def run_study(seed:int=1729,training:int=TRAIN,testing:int=TEST)->dict:
    if not isinstance(seed,int) or not 0<=seed<2**32:
        raise ValueError("invalid seed")
    if not 3<=training<=32 or not 3<=testing<=32:
        raise ValueError("split sizes must be 3..32")
    # Frozen disjoint split identities. Held-out generation happens after
    # selecting the learned policy; the selector never sees test case scores.
    seeds={}
    for domain in DOMAINS:
        seeds[domain]={
          "train":[seed+100_000*(1+DOMAINS.index(domain))+i*7907 for i in range(training)],
          "test":[seed+10_000_000+100_000*(1+DOMAINS.index(domain))+i*7907 for i in range(testing)]}
    train={d:[fixture(d,s) for s in seeds[d]["train"]] for d in DOMAINS}
    selection=[]
    for policy in POLICIES:
        by_domain={d:score_cases(train[d],policy) for d in DOMAINS}
        # Normalize distinct domain scores; independent validation never tunes
        # on held-out results. Explicit cost tiebreaker, exact-call invariant.
        value=sum(by_domain[d]["certified_gain_sum"]/training for d in DOMAINS)
        cost=sum(by_domain[d]["coarse_ops"] for d in DOMAINS)
        selection.append((value,-cost,policy))
    selection.sort(key=lambda v:(-v[0],-v[1],v[2].fine,v[2].edge,v[2].coarse))
    learned=selection[0][2]
    test={d:[fixture(d,s) for s in seeds[d]["test"]] for d in DOMAINS}
    results={}
    for d in DOMAINS:
        results[d]={k:score_cases(test[d],p) for k,p in (
            ("atomic",ATOMIC),("fixed",FIXED),("adaptive",ADAPTIVE),("trained",learned))}
        expected=testing*TRIALS
        if any(r["exact_calls"]!=expected for r in results[d].values()):
            raise AssertionError("exact-verifier budget mismatch")
        digests=[x["case_sha256"] for x in results[d]["fixed"]["case_results"]]
        if any([x["case_sha256"] for x in r["case_results"]]!=digests for r in results[d].values()):
            raise AssertionError("inconsistent raw test cases")
    source_hashes={d:{k:[sha256(fixture(d,s)["raw"]).hexdigest() for s in v]
                      for k,v in parts.items()} for d,parts in seeds.items()}
    return {"schema":SCHEMA,"label":"BOUNDED SYNTHETIC BENCHMARK — NOT A SCIENTIFIC RECORD",
            "seed":seed,"training_per_domain":training,"heldout_per_domain":testing,
            "candidate_pool_per_round":POOL,"exact_verifier_calls_per_case":TRIALS,
            "selection_search_count":len(POLICIES),
            "learned_policy":asdict(learned),
            "training_selected_on":"certified training gains, proxy-cost tiebreak; heldout data excluded",
            "raw_identity_sha256":source_hashes,
            "results":results,
            "limits":["Synthetic binary cyclic-overlap proxy, separate from continuous EA #36.",
                      "Synthetic atomic support spans, separate from natural-web SourceBound accuracy.",
                      "Discrete joint policy-selection, no neural end-to-end training.",
                      "Repeated domains, training effort and independent peer review remain outstanding."]}


def main():
    p=argparse.ArgumentParser()
    p.add_argument("--seed",type=int,default=1729)
    p.add_argument("--train",type=int,default=TRAIN)
    p.add_argument("--test",type=int,default=TEST)
    p.add_argument("--output",type=Path,default=Path("granularity_results.json"))
    args=p.parse_args()
    result=run_study(args.seed,args.train,args.test)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+"\n")
    for domain,rs in result["results"].items():
        print(domain," ".join(f"{name}:gain={v['certified_gain_sum']} cost={v['coarse_ops']}"
              for name,v in rs.items()))
    print("POLICY",result["learned_policy"],"RESULT",args.output)


if __name__=="__main__":
    main()
