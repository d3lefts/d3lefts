#!/usr/bin/env python3
"""RYEV global-face-first Q7 305 feasibility probe.
This is an exploratory MILP operator; timeouts are neither SAT nor UNSAT.
Proof-level mathematics lives in face_gate.py. Requires SciPy.
"""
from collections import Counter
import hashlib
import json
import sys
import time
import numpy as np
from scipy.optimize import Bounds, LinearConstraint, milp
from scipy.sparse import coo_matrix, vstack, csr_matrix
from face_gate import geometry, audit, odd_square_seed

def constraints(geo, fixed, bound=305):
    edges,squares,faces,directions=geo
    remaining=[e for e in range(448) if e not in fixed[0]]
    where={e:i for i,e in enumerate(remaining)}
    fixedYes=fixed[1]
    rows=[]
    right=[]
    # Every cycle is a coordinate square; impose exact <=3.
    for sq in squares:
        rows.append(sq)
        right.append(3)
    # All 14 Q6 faces obey Harborth-Nienborg's theorem.
    for row in faces:
        rows.append(row)
        right.append(132)
    # Every Q5 face obeys exact established 56-edge maximum.
    for a in range(7):
        for b in range(a+1,7):
            for va in (0,1):
                for vb in (0,1):
                    row=[e for e,(u,v,d) in enumerate(edges)
                         if d!=a and d!=b and (u>>a)&1==va and (u>>b)&1==vb]
                    assert len(row)==80
                    rows.append(row);right.append(56)
    rr=[];cc=[]
    caps=[]
    for k,row in enumerate(rows):
        off=sum(e in fixedYes for e in row)
        caps.append(right[k]-off)
        for e in row:
            if e in where:
                rr.append(k);cc.append(where[e])
    mat=coo_matrix((np.ones(len(rr),dtype=float),(rr,cc)),shape=(len(rows),len(remaining))).tocsr()
    # Require total >= 305; no untrusted numeric witness accepted.
    mat=vstack([mat,csr_matrix(np.ones((1,len(remaining))))]).tocsr()
    upper=np.r_[caps,np.inf]
    lower=np.r_[[-np.inf]*len(caps),[bound-len(fixedYes)]]
    return remaining,LinearConstraint(mat,lower,upper)

def run(seconds=20.0):
    geo=geometry()
    seed=odd_square_seed()
    base=audit(seed,geo)
    assert len(seed)==304
    # Freeze a Q6 coordinate half-face attaining the known optimum 132.
    face=geo[2][0] # x_0=0, original odd-square witness.
    frozen={e for e in face if e in seed}
    assert len(frozen)==132
    remaining,linear=constraints(geo,(set(face),frozen))
    t=time.monotonic()
    result=milp(np.zeros(len(remaining)),integrality=np.ones(len(remaining)),
         bounds=Bounds(0,1),constraints=linear,
         options={"time_limit":seconds,"mip_rel_gap":0.0,"disp":False})
    elapsed=time.monotonic()-t
    winner=None
    if result.x is not None:
        added={remaining[k] for k,val in enumerate(result.x) if val>.5}
        trial=frozen|added
        # No float/solver label is accepted as an exact mathematical witness.
        checked=audit(trial,geo)
        if len(trial)>=305:
            winning_edges=sorted((geo[0][e][0],geo[0][e][1]) for e in trial)
            text="".join("%d %d\\n"%(u,v) for u,v in winning_edges)
            winner={"edges":len(trial),"sha256":hashlib.sha256(text.encode()).hexdigest(),
                   "edgeList":winning_edges,
                   "independentSquareAudit":"PASS"}
    report={"format":"nightfall-q7-face-first-milp-v1","fixedQ6Face":"axis0 bit0",
        "frozenSelectedEdges":132,"otherBinaryVariables":len(remaining),
        "totalSquareConstraints":672,"q6FaceConstraints":14,"q5FaceConstraints":84,
        "requiredSelectedEdges":305,"solverStatus":int(result.status),
        "solverMessage":str(result.message),"elapsedSeconds":round(elapsed,3),
        "foundAndIndependentlyChecked305":winner is not None,
        "candidate":winner,
        "proofStatus":"NO_GLOBAL_UNSAT_CERTIFICATE; timeout/solver status is not a proof",
        "priorBaseline":304}
    print(json.dumps(report,indent=2))
    # For this exploratory script, status 1 (time cap) is a valid REPORTED
    # negative result; no certificate is asserted.
    if result.status not in (0,1):return 2
    return 0

if __name__=="__main__":
    try:limit=float(sys.argv[1]) if len(sys.argv)>1 else 20.0
    except ValueError:raise SystemExit("time budget must be a numeric number of seconds")
    raise SystemExit(run(limit))
