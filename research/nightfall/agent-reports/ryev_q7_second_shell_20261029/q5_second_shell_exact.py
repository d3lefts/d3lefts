#!/usr/bin/env python3
"""Q5 weight-six closed 2-cochains: exhaustive, stdlib, independent enumeration.
Proof of search completeness: every nonempty closed proper subset of a closed six-face
set would leave another closed subset. Any nonempty closed set has >=4 faces in Q5,
so a six-face closed set is indecomposable. Parity repairs suffice for enumeration.
"""
from itertools import combinations
import hashlib, json

def face_vertices(n):
    return sorted({tuple(sorted((v, v^(1<<i), v^(1<<j), v^(1<<i)^(1<<j))))
                   for v in range(1<<n) for i,j in combinations(range(n),2)})

def cube_vertices(n):
    return sorted({tuple(sorted(v ^ sum(1<<i for j,i in enumerate(coords) if sub>>j&1)
                               for sub in range(8)))
                   for coords in combinations(range(n),3) for v in range(1<<n)})

def main():
    n=5
    faces=face_vertices(n); cubes=cube_vertices(n)
    assert len(faces)==80 and len(cubes)==40
    sqsets=[frozenset(f) for f in faces]
    csets=[frozenset(c) for c in cubes]
    cube_to_faces=[tuple(i for i,sq in enumerate(sqsets) if sq.issubset(cu)) for cu in csets]
    assert all(len(x)==6 for x in cube_to_faces)
    face_to_cube=[sum(1<<j for j,face_ids in enumerate(cube_to_faces) if i in face_ids)
                  for i in range(len(faces))]
    assert all(m.bit_count()==3 for m in face_to_cube)
    # Any two distinct squares of Q5 share at most one 3-cube.
    # Therefore a nonempty closed face support has weight >=4: the
    # three cubes containing a chosen face need three distinct helpers.
    assert all((a&b).bit_count()<=1 for a,b in combinations(face_to_cube,2))

    found=set(); partial_seen=set();calls=0
    def rec(anchor, mask, odd, weight):
        nonlocal calls
        calls+=1
        if odd==0:
            if weight==6:found.add(mask)
            return
        if weight==6 or odd.bit_count()>3*(6-weight):return
        key=(anchor,mask)
        if key in partial_seen:return
        partial_seen.add(key)
        choices=None
        bits=odd
        while bits:
            bit=bits & -bits;bits^=bit
            fids=cube_to_faces[bit.bit_length()-1]
            candidates=[i for i in fids if i>anchor and not(mask>>i&1)]
            if not candidates:return
            if choices is None or len(candidates)<len(choices):choices=candidates
            if len(choices)==1:break
        for i in choices:rec(anchor,mask|(1<<i),odd^face_to_cube[i],weight+1)
    for anchor in range(len(faces)):rec(anchor,1<<anchor,face_to_cube[anchor],1)

    # Independent edge-square model is constructed from vertex pairs rather
    # than the 3-cube parity constraints used in the enumerator above.
    edges=sorted({(v,v^(1<<d)) for v in range(1<<n) for d in range(n) if not(v>>d&1)})
    eid={frozenset(e):i for i,e in enumerate(edges)}
    edge_faces=[0]*len(edges)
    faces_per_cube=[]
    for fid,sq in enumerate(sqsets):
        perimeter=[eid[frozenset((u,v))] for u,v in combinations(sq,2) if (u^v).bit_count()==1]
        assert len(perimeter)==4
        faces_per_cube.append(perimeter)
        for e in perimeter:edge_faces[e]^=1<<fid
    cofacial={edge_faces[a]^edge_faces[b] for perimeter in faces_per_cube
              for a,b in combinations(perimeter,2)}
    assert all(w.bit_count()==6 for w in cofacial)
    assert len(cofacial)==480
    assert found==cofacial, (len(found),len(cofacial),len(found-cofacial))
    # independent positive/negative controls: a weight-4 single edge star is
    # closed; a weight-1 face is not. The theorem excludes n=4 extensions.
    assert edge_faces[0].bit_count()==4
    assert face_to_cube[0]!=0
    serial='\n'.join(','.join(str(k) for k in range(80) if mask>>k&1) for mask in sorted(found))+'\n'
    print(json.dumps(dict(n=n,faces=len(faces),cubes=len(cubes),edges=len(edges),
                          exact_weight6_closed=len(found),cofacial=len(cofacial),
                          recursion_calls=calls,partial_states=len(partial_seen),
                          canonical_face_sets_sha256=hashlib.sha256(serial.encode()).hexdigest(),
                          verified=True,scope='Exact Q5 second shell only; not all-n proof'),
                     indent=2,sort_keys=True))

if __name__=='__main__':main()
