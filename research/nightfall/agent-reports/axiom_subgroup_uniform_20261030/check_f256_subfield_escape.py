#!/usr/bin/env python3
"""Exact F256 subfield-escape test for the full F4* cubic phase subgroup.

Base field F16=F2[z]/(z^4+z+1), subgroup H=F4*={1,6,7}.
Quadratic tower F256=F16[u]/(u^2+u+8), since Tr_F16/F2(8)=1.
This is NOT the older F16 ambient sensing model.
"""


def m16(a,b):
    acc=0
    while b:
        if b&1:acc^=a
        b>>=1
        a<<=1
        if a&16:a^=19
    return acc


def p16(a,n):
    acc=1
    while n:
        if n&1:acc=m16(acc,a)
        a=m16(a,a)
        n>>=1
    return acc


H=tuple(x for x in range(1,16) if p16(x,3)==1)
assert H==(1,6,7)
trace=lambda d: d^p16(d,2)^p16(d,4)^p16(d,8)
assert trace(8)==1
DELTA=8


def m256(x,y):
    a,b=x
    c,e=y
    be=m16(b,e)
    # u²=u+DELTA in characteristic two.
    return (m16(a,c)^m16(DELTA,be),m16(a,e)^m16(b,c)^be)


def p256(x,n):
    acc=(1,0)
    while n:
        if n&1:acc=m256(acc,x)
        x=m256(x,x)
        n>>=1
    return acc


def check():
    successful=[]
    for offset in range(16):
        seen={}
        for eta in H:
            for theta in H:
                # Each coefficient belongs to the F16-subfield, while
                # the pair uses the F16-basis (1,u) of F256.
                linear=(offset^eta,offset^theta)
                out=p256(linear,3)
                seen.setdefault(out,[]).append((eta,theta))
        assert len(seen)<=len(H)*len(H)
        if len(seen)==9:
            successful.append(offset)
        if offset in (0,1,6,7):
            # Full F4* base-subfield offset cannot pack all three phases.
            assert len(seen)<9
    assert successful==list(range(2,6))+list(range(8,16))
    # Deliberately corrupted zero-offset code must collide.
    assert len({p256((eta,theta),3) for eta in H for theta in H})<9
    print({"ambient_field":"F256","base_field":"F16",
           "phase_subgroup":"F4*=<1,6,7>","oracle":"z^3",
           "offset":2,"separated_phase_words":9,
           "good_offsets":successful,
           "negative_control":"PASS",
           "scientific_scope":"finite phase code, not F16 recovery or novelty"})


if __name__=="__main__":
    check()
