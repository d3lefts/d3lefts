#!/usr/bin/env python3
"""RYEV Q7 face-deficit proof gate. Python standard library; no MIP dependency.
Scope: exact graph counting conditional on the published ex(Q6,C4)=132 theorem.
The face-count identity is elementary prior art; this script applies it as a
new non-seed-local candidate gate and independently replays 180 historical seeds.
"""
from collections import Counter
from pathlib import Path
import hashlib
import json

HERE=Path(__file__).resolve().parent
INPUT=HERE/"canonical_180.txt"
INPUT_SHA="2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1"
Q6_EXTREMAL=132

def geometry():
    edges=[(v,v|(1<<d),d) for v in range(128) for d in range(7) if not(v&(1<<d))]
    eid={(u,v):k for k,(u,v,d) in enumerate(edges)}
    faces=[[] for _ in range(14)]
    directions=[[] for _ in range(7)]
    for k,(u,v,d) in enumerate(edges):
        directions[d].append(k)
        for axis in range(7):
            if d!=axis:faces[2*axis + ((u>>axis)&1)].append(k)
    squares=[]
    for base in range(128):
        for a in range(7):
            if base&(1<<a): continue
            for b in range(a+1,7):
                if base&(1<<b): continue
                x=base|(1<<a);y=base|(1<<b);z=x|(1<<b)
                squares.append((eid[base,x],eid[base,y],eid[x,z],eid[y,z]))
    assert len(edges)==448 and len(squares)==672
    assert all(len(f)==192 for f in faces) and all(len(s)==64 for s in directions)
    return edges,squares,faces,directions

def decode(text,edges):
    assert len(text)==112 and set(text)<=set("0123456789abcdef")
    old=[(v,v|(1<<d)) for d in range(7) for v in range(128) if not(v&(1<<d))]
    mapping={(u,v):k for k,(u,v,_) in enumerate(edges)}
    raw=bytes.fromhex(text)
    chosen={mapping[old[k]] for k in range(448) if raw[k//8] & (128>>(k%8))}
    return chosen

def c4_independent(selected,edges):
    # Independent *vertex common-neighbour* test, distinct from square enumeration.
    adj=[set() for _ in range(128)]
    for e in selected:
        u,v,_=edges[e];adj[u].add(v);adj[v].add(u)
    for u in range(128):
        for v in range(u+1,128):
            if (u^v).bit_count()==2 and len(adj[u]&adj[v])>1:
                return False
    return True

def audit(selected,geo,face_cap=Q6_EXTREMAL,require_c4=True):
    edges,squares,faces,directions=geo
    if len(selected)!=len(set(selected)) or any(not isinstance(x,int) or x<0 or x>=448 for x in selected):
        raise ValueError("Invalid edge IDs")
    if require_c4:
        if any(sum(e in selected for e in sq)==4 for sq in squares):
            raise ValueError("C4 detected by square enumeration")
        if not c4_independent(selected,edges):
            raise ValueError("C4 detected independently by common neighbours")
    f=[sum(e in selected for e in row) for row in faces]
    d=[sum(e in selected for e in row) for row in directions]
    m=len(selected)
    if any(v>face_cap for v in f):
        raise ValueError("One Q6 face exceeds assumed theorem bound: "+str(face_cap))
    assert sum(d)==m
    assert sum(f)==6*m
    assert sum(face_cap-v for v in f)==14*face_cap-6*m
    assert all(f[2*i]+f[2*i+1]+d[i]==m for i in range(7))
    assert all(d[i]>=m-2*face_cap for i in range(7))
    if m>=305:
        assert min(d)>=41
        assert sum(v>=131 for v in f)>=5
        assert len({i for i in range(7) if max(f[2*i:2*i+2])>=131})>=3
    return {"edges":m,"dir":d,"faces":f,
      "deficit":sum(Q6_EXTREMAL-v for v in f),
      "nearExtremalFaces":sum(v>=131 for v in f),
      "extremalFaces":sum(v==132 for v in f),
      "degreeProfile":dict(sorted(Counter(len([e for e in selected if (edges[e][0]==v or edges[e][1]==v)]) for v in range(128)).items()))}

def odd_square_seed():
    # Independent compact gauge construction attributed to Ryev #48,
    # no imported Q7 witness edge list.
    spin=int("dca10a6bb6b6b45e6b80e5e55e366b1e",16)
    edges,_,_,_=geometry()
    out=set()
    for k,(u,v,d) in enumerate(edges):
        base=sum((u>>j)&1 for j in range(d))%2
        if base^((spin>>u)&1)^((spin>>v)&1):out.add(k)
    return out

def main():
    geo=geometry()
    data=INPUT.read_bytes()
    assert hashlib.sha256(data).hexdigest()==INPUT_SHA
    words=data.decode("ascii").splitlines()
    assert len(words)==180 and len(set(words))==180
    profiles=Counter()
    minima=Counter()
    rows=[]
    for k,w in enumerate(words):
        record=audit(decode(w,geo[0]),geo)
        assert record["edges"]==304 and record["deficit"]==24
        profiles[tuple(sorted(record["dir"]))]+=1
        minima[record["nearExtremalFaces"]]+=1
        rows.append({"id":k,"direction":record["dir"],"q6Faces":record["faces"]})
    canonical=audit(odd_square_seed(),geo)
    assert canonical["edges"]==304 and canonical["deficit"]==24
    # Adversarial fake "305": adding an original nonedge to a saturated
    # 304-edge odd-square configuration creates a 4-edge square. Never accept.
    available=set(range(448))-odd_square_seed()
    bad=None
    for e in available:
        s=odd_square_seed()|{e}
        if any(len(s.intersection(sq))==4 for sq in geo[1]):
            bad=s;break
    assert bad is not None
    try:audit(bad,geo)
    except ValueError:pass
    else:raise AssertionError("False 305 candidate accepted")
    # Deliberately corrupted imported Q6 bound must fail on a known 132 face.
    try:audit(odd_square_seed(),geo,face_cap=131)
    except ValueError:pass
    else:raise AssertionError("Incorrect 131-face theorem accepted")
    print(json.dumps({
      "format":"nightfall-q7-global-face-gate-v1",
      "inputSha256":INPUT_SHA,
      "importedQ6UpperBound":132,
      "priorArt":"Harborth–Nienborg (1994) Q6 C4-free maximum; OEIS A245762 recurrence",
      "candidate305Necessity":{"directionMinimum":41,"near131FacesMinimum":5,
         "coordinateDirectionsWithNearFaceMinimum":3,"totalQ6FaceDeficit":18},
      "catalogueCount":180,
      "catalogue304FaceDeficit":24,
      "nearFaceCountHistogram":dict(sorted(minima.items())),
      "directionSortedProfiles":{",".join(map(str,k)):v for k,v in sorted(profiles.items())},
      "gaugeSeed304":canonical,
      "negativeControls":["invalid 305 with a C4 refused","false Q6 face maximum 131 refused"],
      "status":"PASS_IMPORTED_Q6_PREMISE_NO_NEW_GLOBAL_BOUND"
    },indent=2))

if __name__=="__main__":main()
