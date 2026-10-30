#!/usr/bin/env python3
"""Exact symbolic breakpoint certificate for an infinite modular rectangle family.
For every integer D>=8 and p=4D-c with c=1 or c=3, classify all holes
of the nine modular (2D-1)x(2D-1) sumset rectangles.
"""
def value(f,D):return f[0]*D+f[1]
def shift(a,b,axis):
    return (2*a,-a-b) if axis=="x" else (a+b,a+b)
def boundary_list(c,axis):
    p=(4,-c)
    lines={(0,0),p}
    # Every possible wrapped rectangle boundary is an affine function
    # of D; all relevant x/y shifts are covered by wraps -1..2.
    for a in range(3):
        for b in range(3):
            sx,sy=shift(a,b,axis)
            for k in range(-1,3):
                st=(sx-4*k,sy+k*c)
                lines.add(st)
                lines.add((st[0]+2,st[1]-1)) # half-open length 2D-1
    checked=0
    for f in lines:
        for g in lines:
            if f==g:continue
            delta=value(f,8)-value(g,8)
            slope=f[0]-g[0]
            if delta==0:assert slope==0,(c,axis,"coincident only at D8",f,g)
            else:assert delta*slope>=0,(c,axis,"future boundary crossing",f,g)
            checked+=1
    active=sorted((f for f in lines if 0<=value(f,8)<=value(p,8)),
                  key=lambda f:value(f,8))
    assert active[0]==(0,0) and active[-1]==p
    assert len(active)==len(set(active))
    assert all(value(active[i],8)<value(active[i+1],8) for i in range(len(active)-1))
    return active,checked
def covered(D,c,x,y):
    p=4*D-c
    for a in range(3):
        for b in range(3):
            start_x=a*(2*D-1)-b
            start_y=(a+b)*(D+1)
            if (x-start_x)%p <2*D-1 and (y-start_y)%p <2*D-1:
                return True
    return False
def classify(c):
    X,nx=boundary_list(c,"x");Y,ny=boundary_list(c,"y")
    # Membership of each cell cannot change for D>=8 because all
    # 9 rectangles' wrapped boundary lines are in X,Y and their order
    # is immutable. Exactly one representative D=8 evaluates each cell.
    uncovered=[]
    for i in range(len(X)-1):
        for j in range(len(Y)-1):
            if not covered(8,c,value(X[i],8),value(Y[j],8)):
                box=(X[i],X[i+1],Y[j],Y[j+1])
                xl,xr,yl,yr=box
                assert xr[0]==xl[0] and xr[1]-xl[1]==1
                assert yr[0]==yl[0] and yr[1]-yl[1]==3
                uncovered.append(box)
    expected={((2,-2),(2,-1),(2,-1),(2,2)),
              ((4,-4),(4,-3),(0,4 if c==3 else 2),(0,7 if c==3 else 5))}
    assert len(uncovered)==2 and set(uncovered)==expected,(c,uncovered)
    # Independent finite stress tests do not replace the universal
    # affine order argument above.
    for D in (8,9,12,16,29):
        actual={(x,y) for x in range(4*D-c) for y in range(4*D-c)
                if not covered(D,c,x,y)}
        predicted={(x,y) for xl,xr,yl,yr in uncovered
                   for x in range(value(xl,D),value(xr,D))
                   for y in range(value(yl,D),value(yr,D))}
        assert actual==predicted
    return {"c":c,"active_x_boundaries":len(X),"active_y_boundaries":len(Y),
            "symbolic_cells":(len(X)-1)*(len(Y)-1),
            "ordered_boundary_checks":nx+ny,"hole_strips":sorted(uncovered)}
if __name__=="__main__":
    for c in (1,3):print("PASS SYMBOLIC",classify(c))
    print("PROVISIONAL THEOREM: exactly six holes for all D>=8 in both moduli 4D-1 and 4D-3")
    print("Additive statement does not need primality or powers of two.")
    print("Universal validity rests on the explicit affine boundary-order argument.")
