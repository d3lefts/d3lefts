#!/usr/bin/env python3
"""Independent exact-rational audit of physical heat-bath collapse under a locally invertible binary star."""
from fractions import Fraction as F
from math import comb
import json

assertions=0

def verify(ok, context):
 global assertions
 assertions+=1
 if not ok: raise AssertionError(context)

def exact_root_influence(m,eps):
 a=1-eps;b=eps
 total=F(0)
 for k in range(m+1):
  A=a**k*b**(m-k)
  B=b**k*a**(m-k)
  contribution=F(2)*A*B/(A+B)
  total+=comb(m,k)*contribution
  verify(contribution>=0,'nonnegative conditional variance contribution')
 return total

def main():
 entries=[]
 for e in (F(1,6),F(1,4),F(1,3)):
  a=1-e;b=e
  last=F(1)
  for m in range(1,17):
   actual=exact_root_influence(m,e)
   # Compare to exact square of Bhattacharyya exponential: (2sqrt(ab))^(2m)=(4ab)^m.
   verify(actual*actual <= (4*a*b)**m,'sharp exponential upper bound')
   verify(actual<1,'positive-support noisy copies reduce root heatbath influence')
   verify(actual<=last,'nonincreasing in number of noisy leaves')
   if m%2==0:
    central=comb(m,m//2)*(a*b)**(m//2)
    verify(actual>=central,'central binomial matching-exponent lower bound')
   last=actual
   if m in (1,2,4,8,16): entries.append({'eps':str(e),'m':m,'heatbath_influence':str(actual)})
 print(json.dumps({'status':'PASS','assertions':assertions,'examples':entries,
       'interpretation':'physical heat-bath root influence exponentially small while direct root read has zero risk'}))
if __name__=='__main__':main()
