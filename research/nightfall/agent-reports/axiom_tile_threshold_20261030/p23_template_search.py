#!/usr/bin/env python3
"""Exact GF(23)^2 finite template obstruction, no global no-go claim.

Base rectangle is an axis-generated 2^a x 2^b binary cube.
Enumerate every valid unordered first-two-shift pair and every third shift.
Check whether the FULL ordinary pair sumset is missing an element.
Off-diagonal-only escape is independently checked by p23_offdiag.cpp.
"""
P=23;Q=P*P
def add(a,b):
    return ((a%P+b%P)%P)+P*((a//P+b//P)%P)
def mask(z,points):
    bits=0
    for a in points:bits|=1<<add(z,a)
    return bits
FULL=(1<<Q)-1

def two_shift(ax,ay):
    base=[x+P*y for x in range(ax) for y in range(ay)]
    rect=[x+P*y for x in range(2*ax-1) for y in range(2*ay-1)]
    tile=[mask(z,base) for z in range(Q)]
    squares=[mask(z,rect) for z in range(Q)]
    valid=0
    for v in range(1,Q):
        vv=add(v,v)
        for w in range(v+1,Q):
            vw=add(v,w);ww=add(w,w)
            T=tile[0]|tile[v]|tile[w]|tile[vw]
            if T.bit_count()!=256:continue
            valid+=1
            shifts=(0,v,w,vv,vw,ww,add(vv,w),add(v,ww),add(vv,ww))
            s=0
            for z in shifts:s|=squares[z]
            assert s==FULL,("hole",ax,ay,v,w)
    return valid

def three_shift():
    ax,ay=8,4
    base=[x+P*y for x in range(ax) for y in range(ay)]
    rect=[x+P*y for x in range(2*ax-1) for y in range(2*ay-1)]
    tile=[mask(z,base) for z in range(Q)]
    squares=[mask(z,rect) for z in range(Q)]
    four=eight=0
    for v in range(1,Q):
        vv=add(v,v)
        for w in range(v+1,Q):
            vw=add(v,w);ww=add(w,w)
            U=tile[0]|tile[v]|tile[w]|tile[vw]
            if U.bit_count()!=128:continue
            four+=1
            shifts=(0,v,w,vv,vw,ww,add(vv,w),add(v,ww),add(vv,ww))
            s=0
            for z in shifts:s|=squares[z]
            for t in range(1,Q):
                T=U|tile[t]|tile[add(v,t)]|tile[add(w,t)]|tile[add(vw,t)]
                if T.bit_count()!=256:continue
                eight+=1
                if s==FULL:continue
                tt=add(t,t)
                full=s
                for z in shifts:full|=squares[add(z,t)]|squares[add(z,tt)]
                assert full==FULL,("hole",v,w,t)
    return four,eight

if __name__=="__main__":
    for a,b in ((8,8),(16,4),(4,16)):
        n=two_shift(a,b)
        assert n==({(8,8):12800,(16,4):21160,(4,16):21160}[(a,b)])
        print("PASS two shifts",a,b,"valid",n,"all full sumsets")
    n3=three_shift()
    assert n3==(53640,2153616),n3
    print("PASS three shifts 8x4",n3,"all full sumsets")
    print("SCOPE: only axis-rectangle + 2/3 shift templates; no general impossibility")
