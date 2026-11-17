#!/usr/bin/env python3
"""Exact-rational crossing of two observed conditional-loss curves.

Arithmetic is exact for integer trace counts and rational input loss weights;
model assumptions and observed rates are not thereby certified.
"""
import argparse
from fractions import Fraction
import json
from compare import read_checked,paired_components


def crossing(left,right,miss_cost=Fraction(12),false_alarm_cost=Fraction(2),
             acquisition_weight=Fraction(1,20)):
    a,pa=read_checked(left)
    b,pb=read_checked(right)
    if pa==pb:raise ValueError('policies must differ')
    ed,qd,cd=paired_components(a,b)
    dm=Fraction(sum(ed),len(ed))
    df=Fraction(sum(qd),len(qd))
    dc=Fraction(sum(int(x['acquisition_cost'])-int(y['acquisition_cost'])
                    for x,y in zip(a,b)),len(a))
    # R_left - R_right = intercept + p*slope
    intercept=false_alarm_cost*df+acquisition_weight*dc
    slope=miss_cost*dm-false_alarm_cost*df
    pivot=None if slope==0 else -intercept/slope
    def fmt(n):return f'{n.numerator}/{n.denominator}'
    return {'left':pa,'right':pb,
            'conditional_miss_delta_exact':fmt(dm),
            'conditional_false_alarm_delta_exact':fmt(df),
            'loss_intercept_at_p0_exact':fmt(intercept),
            'loss_slope_exact':fmt(slope),
            'crossing_prevalence_exact':None if pivot is None else fmt(pivot),
            'crossing_in_unit_interval':pivot is not None and 0<=pivot<=1,
            'scope':'Exact arithmetic on observed finite synthetic trace rates, not population truth.'}

if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('left');ap.add_argument('right')
    ap.add_argument('--miss-cost',default='12')
    ap.add_argument('--false-alarm-cost',default='2')
    ap.add_argument('--acquisition-weight',default='1/20')
    x=ap.parse_args()
    try:
        costs=[Fraction(v) for v in [x.miss_cost,x.false_alarm_cost,x.acquisition_weight]]
        if min(costs)<0: raise ValueError('loss coefficients must be nonnegative')
        res=crossing(x.left,x.right,*costs)
    except (ValueError,ZeroDivisionError,OSError) as exc:ap.error(str(exc))
    print(json.dumps(res,indent=2,sort_keys=True))
