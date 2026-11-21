import math
def R(n):
    rows={1}; w=1
    for _ in range(n):
        rows={x|(y<<w) for r in rows for (x,y) in ((r,0),(0,r),(r,r))}; w*=2
    return rows
a=math.log2(3)
for k in range(1,7):
    Rk=list(R(k)); S={x^y for x in Rk for y in Rk}; S.discard(0)
    q=2**k
    print(f"k={k} q=2^k={q} |R|={len(Rk)} |S*|={len(S)}  |S*|/q^(2log2 3)={len(S)/q**(2*a):.4f}  9^k/2={9**k/2:.0f}")
