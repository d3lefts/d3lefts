#!/usr/bin/env python3
"""Exact rational palette MAP error bound from posterior variance.
Risk <= 2 Var(Y) / Delta^2, for a finite real palette with gap Delta.
The factor two is sharp (equal binary prior).
"""
from fractions import Fraction as F
from itertools import product
import json

checks=0
worst=F(0)
equality=[]
for q in range(2,6):
    palettes=[tuple(F(i) for i in range(q)),
              tuple(F(i*i+3*i) for i in range(q))]
    for palette in palettes:
        gap=min(palette[i+1]-palette[i] for i in range(q-1))
        for nums in product(range(5),repeat=q):
            total=sum(nums)
            if not total:continue
            probs=[F(n,total) for n in nums]
            mu=sum((p*a for p,a in zip(probs,palette)),F(0))
            var=sum((p*(a-mu)**2 for p,a in zip(probs,palette)),F(0))
            error=1-max(probs)
            bound=2*var/gap**2
            assert error<=bound,(q,palette,nums,error,bound)
            checks+=1
            if error:
                ratio=error/bound if bound else F(0)
                worst=max(worst,ratio)
                if ratio==1:equality.append((q,nums))
assert worst==1
print(json.dumps({"status":"PASS","cases":checks,"sharp_constant":2,
                  "worst_ratio":str(worst),"equality_examples":len(equality)},
                 indent=2))
