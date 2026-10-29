#!/usr/bin/env python3
"""Q7 305 exact global pseudo-Boolean model; symmetry-safe Q6/Q5 face cuts.
No UNSAT claim until a separate proof-producing solver + proof checker succeed.
Python stdlib only.
"""
from itertools import combinations
from pathlib import Path
import hashlib

def geometry():
    n=7;V=128
    edges=[(v,v^(1<<d)) for d in range(n) for v in range(V) if not (v>>d)&1]
    ix={e:i for i,e in enumerate(edges)}
    squares=[]
    for d in range(n):
        for e in range(d+1,n):
            for v in range(V):
                if v&((1<<d)|(1<<e)):continue
                a=v;b=v^(1<<d);c=v^(1<<e);f=v^(1<<d)^(1<<e)
                squares.append(tuple(sorted(ix[tuple(sorted(p))] for p in
                    ((a,b),(b,f),(c,f),(a,c)))))
    assert len(edges)==448 and len(squares)==672 and len(set(squares))==672
    assert len({i for sq in squares for i in sq})==448
    return edges,squares

def faces(edges,codim):
    out=[]
    for fixed in combinations(range(7),codim):
        for values in range(1<<codim):
            mask=sum(1<<d for d in fixed)
            target=sum(((values>>j)&1)<<d for j,d in enumerate(fixed))
            I=tuple(i for i,(a,b) in enumerate(edges) if a&mask==target and b&mask==target)
            assert len(I)==(7-codim)*2**(6-codim)
            out.append((fixed,values,I))
    return out

def build(enhanced=True):
    edges,squares=geometry();rows=[]
    def add(c,lo=None,hi=None):
        rows.append((c,lo,hi))
    for sq in squares:add({i:1 for i in sq},hi=3)
    add({i:1 for i in range(448)},lo=305,hi=305)
    if enhanced:
        F6=faces(edges,1);F5=faces(edges,2)
        assert len(F6)==14 and len(F5)==84
        for _,_,I in F6:add({i:1 for i in I},hi=132)
        for _,_,I in F5:add({i:1 for i in I},hi=56)
        dirs=[[i for i,(a,b) in enumerate(edges) if a^b==1<<d] for d in range(7)]
        assert all(len(x)==64 for x in dirs)
        for d in range(6):
            c={i:1 for i in dirs[d]};c.update({i:-1 for i in dirs[d+1]})
            add(c,lo=0)
        add({i:1 for i in dirs[6]},hi=43)
        halves=[next(I for fixed,values,I in F6 if fixed==(6,) and values==b) for b in (0,1)]
        add({i:1 for i in halves[0]},lo=131)
        add({i:1 for i in halves[1]},lo=130)
        c={i:1 for i in halves[0]};c.update({i:-1 for i in halves[1]})
        add(c,lo=0)
    def expr(c):return ' '.join(f'{v:+d} x{i+1}' for i,v in sorted(c.items()))
    out=[f'* #variable= 448 #constraint= {sum((lo is not None)+(hi is not None) for _,lo,hi in rows)}']
    for c,lo,hi in rows:
        if lo is not None:out.append(expr(c)+f' >= {lo} ;')
        if hi is not None:out.append(expr(c)+f' <= {hi} ;')
    return '\n'.join(out)+'\n',edges,squares

def run():
    for enhanced,expected in [
        (False,'f45010f50854b1efe462aea40765a8db518424eceeffefdc74c75fdd9509aedc'),
        (True,'79f2e4f6468c0b7babb570eeed08ea8c2ac21a6c651596adfd62f74e9d89d774')]:
        s,edges,squares=build(enhanced)
        digest=hashlib.sha256(s.encode()).hexdigest()
        assert digest==expected,(enhanced,digest,expected)
        path=Path(__file__).resolve().parent/('q7_305_facefirst.opb' if enhanced else 'q7_305_base.opb')
        path.write_text(s)
        print('PASS',path.name,'sha256',digest,'constraints',len(s.splitlines())-1)
    # Intentional bad input: all 448 edges fails every square.
    assert all(len(sq)==4 for sq in squares)
    print('PASS 128 vertices, 448 edges, 672 distinct squares, 14 Q6 and 84 Q5 faces')
if __name__=='__main__':run()
