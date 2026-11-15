#!/usr/bin/env python3
"""Independent exact-rational interpolation/cover audit of Lean C105.416 certificate.

Uses only Python stdlib, no SymPy, no floating point. Parsing certificates from
Lean source and evaluating polynomial identity on 5x5 rational interpolation
grid proves polynomial identity because both sides have bidegree <= (4,4).
Independent check of coefficient signs, box cover, and exact constant.
This DOES NOT verify Lean's original-source theorem; strict Lean CI does that.
"""
from fractions import Fraction as F
from itertools import combinations, product
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[3]
FILE = ROOT / 'research/nightfall/formalization/observability/ShiftedC23802Bernstein.lean'
SRC = FILE.read_text(encoding='utf-8')
BOX = re.compile(r'private theorem box_(\d+) \(x t : ℝ\)(.*?)'
    r'have hidentity : normalizedPoly x t =\n(.*?) := by\n    unfold normalizedPoly', re.S)
TERM = re.compile(
    r'\((\d+(?:/\d+)?):ℝ\)\*\(x-\((\d+(?:/\d+)?):ℝ\)\)\^([0-4])'
    r'\*\(\((\d+(?:/\d+)?):ℝ\)-x\)\^([0-4])'
    r'\*\(t-\((\d+(?:/\d+)?):ℝ\)\)\^([0-4])'
    r'\*\(\((\d+(?:/\d+)?):ℝ\)-t\)\^([0-4])'
)
# There are only finitely many rational tile coordinates, and x/t degree 4.
def poly(x, t):
    b=F(11901,50000)
    return 3-(1-t)**2*(3-2*x**4 + 4*x*(1-x*x)*t/b + (1-x*x)*t*t/(b*b))

def main():
    boxes = []
    hashes = hashlib.sha256()
    for name, head, rhs in BOX.findall(SRC):
        nums=re.findall(r'\(([0-9]+(?:/[0-9]+)?):ℝ\)', head)
        # exactly four interval endpoints (the expected hxlo,hxhi,htlo,hthi)
        assert len(nums)==4, (name,nums)
        l,r,p,q=map(F,nums)
        assert 0 <= l < r <= 1 and 0 <= p < q <= 1
        terms=[]
        for m in TERM.finditer(rhs):
            coeff, xlow, i, xhigh, xrev, tlow, j, thigh, trev = m.groups()
            assert (F(xlow),F(xhigh),F(tlow),F(thigh))==(l,r,p,q)
            i=int(i);j=int(j)
            assert int(xrev)==4-i and int(trev)==4-j
            assert F(coeff)>=0
            terms.append((F(coeff),i,j))
        assert rhs.count('*(x-')==len(terms), (name,'unparsed terms')
        assert terms, name
        assert len(terms)<=25
        # A polynomial bidegree<=4 is uniquely determined by five distinct
        # points in each independent variable. This is an exact identity check.
        for a,b in product(range(5),repeat=2):
            x=l+(r-l)*F(a,4)
            t=p+(q-p)*F(b,4)
            claimed=sum((co*(x-l)**i*(r-x)**(4-i)*
                (t-p)**j*(q-t)**(4-j) for co,i,j in terms),F(0))
            actual=poly(x,t)
            assert claimed==actual, (name,x,t,claimed,actual)
        boxes.append((int(name),l,r,p,q,len(terms)))
        hashes.update((name+'|'+str(l)+'|'+str(r)+'|'+str(p)+'|'+str(q)+'|'
                       +str(len(terms))+'\n').encode())
    boxes.sort()
    assert len(boxes)==37, len(boxes)
    assert [b[0] for b in boxes] == list(range(1,38))
    total=sum(((r-l)*(q-p) for _,l,r,p,q,_ in boxes),F(0))
    assert total==1
    for (_,l,r,p,q,_),(_,L,R,P,Q,_) in combinations(boxes,2):
        intersection=max(F(0),min(r,R)-max(l,L))*max(F(0),min(q,Q)-max(p,P))
        assert intersection==0
    print('PASS: 37 rational rectangles; exact unit-square tiling; 25 grid identities/tile; '
          'nonnegative coefficients; 11901/50000')
    print('term count', sum(b[-1] for b in boxes))
    print('source_sha256',hashlib.sha256(FILE.read_bytes()).hexdigest())
    print('tile_receipt_sha256',hashes.hexdigest())

if __name__=='__main__':
    main()
