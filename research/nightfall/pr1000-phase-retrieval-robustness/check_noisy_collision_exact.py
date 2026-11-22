#!/usr/bin/env python3
"""Independent exact-rational finite probe for NoisyCausalCollision.lean.

NO global proof, topology certificate, or novelty evidence is claimed.
The Lean theorem is universal; this file deliberately uses different finite
arithmetic and explicitly recomputes the actual corrupted-history path.
"""
from fractions import Fraction as Q
from random import Random
from itertools import product
from hashlib import sha256
import json

rng = Random(1001)

def row(stage, history, n):
    # History-conditioned; L1 norm <= 1 implies Euclidean operator norm <= 1.
    # Note the dependence on the actual (possibly corrupted) history.
    scale = Q(1, (stage + 2) * (1 + sum(abs(x) for x in history)))
    return tuple(scale * Q((stage + 3 * i) % 5 - 2, 4 * n) for i in range(n))

def dot(a, x):
    return sum((v * w for v, w in zip(a, x)), Q(0))

def trace(x, noise, m):
    # Reverse chronological, matching Lean's history recursion.
    h = ()
    for stage in range(m):
        a = row(stage, h, len(x))
        assert sum(abs(t) for t in a) <= 1
        h = (dot(a, x)**2 + noise(stage),) + h
    return h

def cancellation(y, stage):
    return -dot(row(stage, (Q(0),) * stage, len(y)), y) ** 2

def pm_square(z, y):
    return min(sum((a-b)**2 for a,b in zip(z,y)),
               sum((a+b)**2 for a,b in zip(z,y)))

def one_case(n,m,y,z,sigma):
    assert sum(x*x for x in y) <= sigma
    e0=lambda k:Q(0)
    e1=lambda k:cancellation(y,k)
    assert all(abs(e1(k))<=sigma for k in range(m))
    t0=trace((Q(0),)*n,e0,m)
    t1=trace(y,e1,m)
    assert t0==t1==(Q(0),)*m
    risk_square=max(pm_square(z,(Q(0),)*n),pm_square(z,y))
    assert 4*risk_square >= sum(x*x for x in y)
    return {
        "n":n,"m":m,"sigma":str(sigma),"y":tuple(map(str,y)),
        "zero_transcript":tuple(map(str,t0)), "risk_sq":str(risk_square)
    }

def main():
    trials=[]
    for n,m in product(range(2,9),[0,1,2,3,5,8]):
        for k in range(5):
            a=Q(rng.randint(-2,2),2**rng.randint(2,7))
            y=tuple(a if i==k%n else Q(0) for i in range(n))
            sigma=sum(t*t for t in y)
            z=tuple(Q(rng.randint(-9,9),2**rng.randint(1,6)) for _ in range(n))
            trials.append(one_case(n,m,y,z,sigma))
    # Negative-control mutation: removing the nonzero cancellation must alter
    # the transcript for a policy that actually senses its chosen signal.
    x=(Q(1,2),Q(0))
    assert trace(x,lambda _:Q(0),2)!=trace(x,lambda k:cancellation(x,k),2)
    print("PASS:",len(trials),"independent exact rational trials")
    payload=json.dumps(trials,sort_keys=True,separators=(',',':')).encode()
    print("SHA256(trial-data):",sha256(payload).hexdigest())
    print("No global proof, no topology input and no robust minimax upper bound.")

if __name__=="__main__":
    main()
