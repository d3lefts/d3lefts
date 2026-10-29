#!/usr/bin/env python3
"""Freeze a non-extremal full-prefix example using the boundary repair operator."""
import json
from construct_prefix import construct
prefix=[1,2,4,8,13]
result=construct(prefix,1009,0.27)
assert result['Sidon_independent_diff_oracle'] and result['above_1_sqrt2']
with open('certificate_p1009_delta027.json','w') as f:
    json.dump(result,f,sort_keys=True,separators=(',',':'))
    f.write('\n')
print(json.dumps({k:v for k,v in result.items() if k!='sorted_marks'},sort_keys=True))
