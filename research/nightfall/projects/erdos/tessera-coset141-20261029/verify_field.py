#!/usr/bin/env python3
"""Independent polynomial F_(5^6) field construction of Singer q=25 source."""
p=5
poly=(1,1,1,0,0,0)
one=(1,0,0,0,0,0)
alpha=(1,3,0,0,0,0)
def multiply(a,b):
    tmp=[0]*11
    for i in range(6):
        for j in range(6):
            tmp[i+j]=(tmp[i+j]+a[i]*b[j])%5
    for k in range(10,5,-1):
        t=tmp[k]
        for j in range(6):tmp[k-6+j]=(tmp[k-6+j]-t*poly[j])%5
    return tuple(tmp[:6])
def power(a,n):
    result=one
    while n:
        if n&1:result=multiply(result,a)
        a=multiply(a,a);n>>=1
    return result
assert power(alpha,15624)==one
assert all(power(alpha,15624//p)!=one for p in (2,3,7,31))
v=651;state=one;D=[]
for e in range(v):
    a=power(state,25);b=power(state,625)
    trace=tuple((x+y+z)%5 for x,y,z in zip(state,a,b))
    if trace==(0,0,0,0,0,0):D.append(e)
    state=multiply(state,alpha)
assert state[1:]==(0,0,0,0,0)
EXPECTED=(21,72,81,86,88,105,197,217,247,278,316,334,357,
360,368,405,430,434,440,462,483,498,525,537,538,584)
assert tuple(D)==EXPECTED
assert len(D)==26
assert len({(x-y)%v for x in D for y in D if x!=y})==650
print('PASS field-generated 26 Singer marks, 650 nonzero differences; source agrees with independent integer-table verifier')
