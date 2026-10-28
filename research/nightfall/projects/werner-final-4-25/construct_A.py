#!/usr/bin/env python3
"""Constructor A: exact sufficient Werner thresholds via three-site derivative transfer."""
from fractions import Fraction as F
from math import comb, factorial
import csv, json
from pathlib import Path
r=Path(__file__).resolve().parent
b=[F(1)]
for n in range(1,26):
    b.append(max(b[n-1]*F(1,3),b[n-2]*F(2,9) if n>=2 else F(0),b[n-3]*F(4,27) if n>=3 else F(0)))
def score(k,delta):
    return F(3*k)*delta+sum((F(2*comb(k,j))*delta**j/b[j] for j in range(3,k+1,2)),F(0))
conditional={4:'0.49791',5:'0.47189',6:'0.44876',7:'0.43228',8:'0.41990',9:'0.40960',10:'0.40148',11:'0.39500',12:'0.38980',13:'0.38540',14:'0.38160',15:'0.37849',16:'0.37564',17:'0.37313',18:'0.37089',19:'0.36812',20:'0.36636',21:'0.36110',22:'0.36110',23:'0.35100',24:'0.340215',25:'0.339940'}
sourceonly={4:'0.4979',5:'0.4700',6:'0.44635',7:'0.4298',8:'0.4175',9:'0.4080',10:'0.4003',11:'0.3942',12:'0.3890',13:'0.3847',14:'0.3809',15:'0.37752',16:'0.37492',17:'0.37226',18:'0.37007',19:'0.36812',20:'0.36636',21:'0.36110',22:'0.36110',23:'0.35100',24:'0.340215',25:'0.339940'}
select={24:F(8659,25000),25:F(4323,12500)}
recs=[];cert={}
for k in range(4,26):
    left,right=0,100000000
    for _ in range(27):
        mid=(left+right+1)//2
        if score(k,F(mid,10**9))<1:left=mid
        else:right=mid-1
    analytic=F(1,3)+F(left,10**9)
    if k in select:
        t=select[k];d=t-F(1,3);rem=F(1)-score(k,d)
        assert rem>0
        cert[str(k)]={'t':str(t),'delta':str(d),'b':str(b[k]),'R':str(score(k,d)),'relative_slack':str(rem),'margin':str(b[k]*rem)}
    old=F(conditional[k]);final=max(old,select.get(k,F(0)))
    recs.append({'k':k,'archive_theorem_only_t':sourceonly[k],'archive_best_t':conditional[k],'archive_best_source':'quantitative_source_margin_conditional' if k<=18 else 'published_theorem_conditional','new_3block_analytic_sup_t_1e9':str(analytic),'new_3block_t':str(select[k]) if k in select else '','best_final_t':str(final),'best_final_decimal':f'{float(final):.9f}','gain_vs_archive':str(final-old),'best_final_evidence':'3block_exact_published_2_3_only' if k in select else ('quantitative_margin_conditional' if k<=18 else 'published_theorem_conditional')})
with (r/'COPY4_TO_25.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(recs[0]));w.writeheader();w.writerows(recs)
c=F(31,100)
head=3*c+sum((2*c**j/(factorial(j)*b[j]) for j in range(3,19,2)),F(0))
tail=2*(3*c)**19/factorial(19)/(1-(3*c)**2/F(20*21))
assert head+tail<1
cert['uniform_k_ge_3']={'c':str(c),'explicit_upper_R':str(head+tail),'lower_slack':str(F(1)-head-tail),'formula':'t=1/3+31/(100*k)'}
(r/'certificate.json').write_text(json.dumps(cert,indent=2)+'\n')
print('A COMPLETE',[(x,cert[str(x)]['t'],float(F(cert[str(x)]['margin']))) for x in (24,25)],'uniform slack',float(F(cert['uniform_k_ge_3']['lower_slack']))
