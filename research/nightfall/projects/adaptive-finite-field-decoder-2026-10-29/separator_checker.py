"""Independent exact Gaussian-integer check for the {1,4} separator.
Run: python3 separator_checker.py
"""
T=sorted(set([(2,0),(-2,0),(0,2),(0,-2)]+
             [(2*a,2*b) for a in (-1,1) for b in (-1,1)]+
             [(a,b) for a in (-1,1) for b in (-1,1)]))
assert len(T)==12
norms=sorted({(a-4*c)**2+(b-4*d)**2 for a,b in T for c,d in T})
assert norms==[8,18,20,34,36,40,50,52,68,72,82,98,100,104,130,136,162,164,200]
def factors(n):
    s=set();d=2
    while d*d<=n:
        if n%d==0:
            s.add(d)
            while n%d==0:n//=d
        d+=1
    if n>1:s.add(n)
    return s
bad=sorted(set().union(*(factors(n) for n in norms)))
assert bad==[2,3,5,7,13,17,41]
assert all(p<=19 or p%8!=5 for p in bad)
print("PASS: 144 Gaussian collision pairs; excluded prime divisors:",bad)
