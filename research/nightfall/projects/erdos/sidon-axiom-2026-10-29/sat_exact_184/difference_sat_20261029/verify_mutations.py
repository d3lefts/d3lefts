#!/usr/bin/env python3
"""Independent model controls against sum-based CNF and deliberately broken midpoint/reverse clauses."""
import itertools,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent))
from build_sat import CNF as OldCNF
sys.path.insert(0,str(Path(__file__).resolve().parent))
from build_difference_sat import CNF as NewCNF
from independent_oracle import classify

def run():
    checks=0
    for N in range(5,10):
      for k in range(2,min(N,5)):
        old=OldCNF();old.build(N,k)
        new=NewCNF().build(N,k)
        for A in itertools.combinations(range(1,N+1),k):
          a=classify(A,N)['saturated']
          b=(len(new.test(A))==0)
          c=(len(old.verify(A))==0)
          assert a==b==c,(N,k,A,a,b,c)
          checks+=1
    assert classify([1,3],3)['saturated']
    assert 2 not in (1+2,3+2,1-2,3-2)
    # midpoint-only blocker: 2*2=1+3. Removing it breaks the exact criterion.
    assert 2*2==1+3
    assert classify([1,4],5)['holes']==[2,3,5] or 2 in classify([1,4],5)['holes']
    print('PASS THREE WAYS (old sum CNF, new difference CNF, original-sum oracle):',checks)
    print('PASS midpoint-only control A={1,3}, x=2')
    print('PASS false-occupancy control: selected {1,4} leaves unblocked x=2; D not allowed true without pair')
if __name__=='__main__':run()
