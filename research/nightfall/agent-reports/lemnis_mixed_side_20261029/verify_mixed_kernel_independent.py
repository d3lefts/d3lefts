#!/usr/bin/env python3
"""Independent K matrix-unit kernel calculation, no partial-trace routine."""
from itertools import product

def outer(u,v):return {(a,b):x*v0.conjugate() for a,x in u.items() for b,v0 in v.items()}
def kern(A,B,n):
    ans=0j
    for (a,b),x in A.items():
        for (c,d),y in B.items():
            k=1
            for j in range(n):
                k*=2*int(a[j]==c[j] and b[j]==d[j])-int(a[j]==b[j] and c[j]==d[j])
                if not k:break
            ans+=x.conjugate()*y*k
    return ans  # Gaussian integer numerator of 2^n*<A,K_n B>
# 4-site qutrit mixed-side witness, product-factored proof via local kernels
n=4
bin={0:1,1:1}; triple={0:1,1:1,2:1};last={2:1}
row1=(bin,triple,bin,triple);row2=(last,triple,last,triple)
col1=(triple,bin,triple,bin);col2=(triple,last,triple,last)
def norm(v):return sum(abs(z)**2 for z in v.values())
def dot(a,b):return sum(x.conjugate()*b.get(k,0) for k,x in a.items())
def sameQ(row,col):
    z=1
    for u,v in zip(row,col):z*=norm(u)*norm(v)-0.5*abs(dot(v,u))**2
    return z
def pairQ(ri,ci,rh,ch):
    z=1
    for u,v,x,y in zip(ri,ci,rh,ch):
        z*=dot(u,x)*dot(y,v)-0.5*dot(v,u).conjugate()*dot(y,x)
    return z
assert sameQ(row1,col1)==256
assert sameQ(row2,col2)==625/16
assert pairQ(row1,col1,row2,col2)==1
print('4-site independent tensor-kernel check PASS; Q with negative second block =',256+625/16-2)
# 3-site arbitrary entangled Gaussian integer factors, alternating-side local support
u1={(0,0,0):1+1j,(1,1,0):2,(0,2,0):-1j}
u2={(2,2,2):2j,(2,0,2):1}
v1={(0,0,0):1,(2,1,1):1+1j}
v2={(0,2,0):1,(2,2,2):2j}
X,Y=outer(u1,v1),outer(u2,v2)
N=3
z1=sum(x*v1.get(k,0).conjugate() for k,x in u1.items())
z2=sum(x*v2.get(k,0).conjugate() for k,x in u2.items())
expected=(-1)**N*z1.conjugate()*z2
assert kern(X,Y,N)==expected,(kern(X,Y,N),expected)
# Scalar product numerator is exact integer for t=1/2; rank-one lower 2^-3 *norms
qX=kern(X,X,N);qY=kern(Y,Y,N)
assert qX.imag==qY.imag==0
qX=int(qX.real);qY=int(qY.real)
assert qX >= sum(abs(z)**2 for z in u1.values())*sum(abs(z)**2 for z in v1.values())
assert qY >= sum(abs(z)**2 for z in u2.values())*sum(abs(z)**2 for z in v2.values())
print('entangled complex n=3 mixed-side cross numerator',kern(X,Y,N),'self numerators',qX,qY,'PASS')
# swap sign for one factor and verify positivity in odd two-block case
assert qX+qY-2*abs(kern(X,Y,N))>=0
print('PASS independent exact matrix-unit kernel')
