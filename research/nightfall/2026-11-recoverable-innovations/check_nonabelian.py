"""Noncommutative S3 path cancellation checks, independent of cyclic implementation."""
from itertools import permutations
from random import Random
R=Random(84323)
G=list(permutations((0,1,2)))
unit=(0,1,2)
def multiply(a,b):return tuple(a[b[i]] for i in range(3))
def inverse(a):
    out=[0]*3
    for i,j in enumerate(a):out[j]=i
    return tuple(out)
def relative_path(parent,edge,u,v):
    ancestors={u}
    z=u
    while z:
        z=parent[z];ancestors.add(z)
    down=[];z=v
    while z not in ancestors:
        down.append(z);z=parent[z]
    lca=z
    out=unit;z=u
    while z!=lca:
        out=multiply(out,inverse(edge[z]))
        z=parent[z]
    for e in reversed(down):out=multiply(out,edge[e])
    return out
count=0
for trial in range(120):
    n=R.randint(2,7)
    parent=[-1]+[R.randrange(i) for i in range(1,n)]
    for _ in range(70):
        root=R.choice(G)
        increments={v:R.choice(G) for v in range(1,n)}
        x=[root]
        for v in range(1,n):x.append(multiply(x[parent[v]],increments[v]))
        for u in range(n):
            for v in range(n):
                actual=multiply(inverse(x[u]),x[v])
                predicted=relative_path(parent,increments,u,v)
                assert actual==predicted,(trial,u,v)
                count+=1
print({"noncommutative_S3_path_checks":count,"result":"passed"})
