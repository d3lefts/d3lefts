#!/usr/bin/env python3
"""Exact adversarial controls for wrong messages, dependency and bogus receipts."""
from fractions import Fraction as F
from itertools import product
from pathlib import Path
import json,tempfile
from cache_attestation import message,posterior_u_given_z,audit as cache_audit
from check_receipt import verify as check_bellman

HERE=Path(__file__).parent
checks=[]

def expect_failure(label, doc):
    with tempfile.TemporaryDirectory() as tmp:
      path=Path(tmp)/'forged.json'
      path.write_text(json.dumps(doc,sort_keys=True,separators=(',',':'))+'\n')
      try:check_bellman(path)
      except (AssertionError,KeyError,ValueError):checks.append(label)
      else:raise AssertionError('FAIL-OPEN '+label)

raw=json.loads((HERE/'bellman_receipt.json').read_text())
assert check_bellman(HERE/'bellman_receipt.json')['status']=='PASS'
import copy
r=copy.deepcopy(raw);r['root_value']='0';expect_failure('fabricated optimal value',r)
r=copy.deepcopy(raw);r['states'][0]['posterior_unsafe']='0';expect_failure('incorrect posterior',r)
r=copy.deepcopy(raw);r['states'][0]['choice']='authorize';expect_failure('unauthorized stopping',r)
r=copy.deepcopy(raw);r['states'].pop();expect_failure('missing proof dependency',r)
r=copy.deepcopy(raw);r['source']['shared_noise_error']='1/2';expect_failure('replaced sensor error model',r)

# The same noise bit N is used in both sensors: conditional on A=B=0,
# their two errors are perfectly correlated. Treating as independent fails.
n=F(1,4)
correct_joint=n;fake_joint=n*n
assert correct_joint==F(1,4) and fake_joint==F(1,16)
checks.append('correlated sensors cannot be multiplied independently')

# Counterexample to omitting shared noise from the separator.
# U and A each fair, shared N has P(N=1)=1/4, observations z=U^N,
# y=A^N. Conditioning z=y=0 implies U=A exactly, but a naive
# independent-noise update makes posterior match probability 5/8.
weights={(u,a,n):(F(1,4)*(F(1,4) if n else F(3,4)))
         for u,a,n in product((0,1),repeat=3)}
cond={k:p for k,p in weights.items() if k[0]^k[2]==0 and k[1]^k[2]==0}
assert sum(cond.values())>0
true_safe=sum(p for (u,a,n),p in cond.items() if u==a)/sum(cond.values())
assert true_safe==1
false_safe=F(3,4)**2+F(1,4)**2
assert false_safe==F(5,8)
checks.append('unmodeled shared noise violates wrong-separator message')

# Explicit authorization error from recycling an old posterior instead of
# an unchanged *conditional* message after a change to the boundary prior.
m=message(1)
old=posterior_u_given_z(m,F(1,2));current=posterior_u_given_z(m,F(1,3))
assert old==F(3,4) and current==F(15,22)
assert 1-old<=F(3,10)<1-current
checks.append('stale marginal authorizes above current posterior-risk limit')

assert len(checks)==8
assert cache_audit()['status']=='PASS'
print(json.dumps({'status':'PASS','negative_controls':checks,
                  'correct_shared_noise_safe_posterior':'1',
                  'incorrect_independent_noise_safe_posterior':'5/8',
                  'stale_marginal_old':'3/4','correct_current':'15/22'},sort_keys=True))
