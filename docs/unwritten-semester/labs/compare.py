#!/usr/bin/env python3
"""Paired AURORA policy loss comparison under an explicitly assumed event prevalence.

Checks traces with the separate trace-arithmetic auditor first. The interval
quantifies independent synthetic episode Monte Carlo variation only. It does
not validate the latent generator, costs, population prevalence, or deployment.
"""
from __future__ import annotations
import argparse
import csv
import json
import math
import random
from pathlib import Path
from audit import verify_trace


def read_checked(path):
    verify_trace(path)
    with Path(path).open(newline='', encoding='utf-8') as fp:
        rows = list(csv.DictReader(fp))
    policies = {r['policy'] for r in rows}
    if len(policies) != 1 or not policies <= {'any', 'quorum'}:
        raise ValueError('compare.py requires one any or quorum trace per file (full sensor acquisition)')
    return rows, policies.pop()


def paired_components(left, right):
    if len(left) != len(right):
        raise ValueError('traces have different episode counts')
    event_delta, quiet_delta = [], []
    for index, (a, b) in enumerate(zip(left, right)):
        for key in ('trial', 'event', 'common_outage', 'a', 'b', 'c'):
            if a[key] != b[key]:
                raise ValueError(f'worlds not paired: {key} differs on row {index}')
        # Loss(left) - loss(right), before multiplying by the loss parameter.
        if a['event'] == '1':
            event_delta.append(int(a['alarm'] == '0') - int(b['alarm'] == '0'))
        else:
            quiet_delta.append(int(a['alarm'] == '1') - int(b['alarm'] == '1'))
    if not event_delta or not quiet_delta:
        raise ValueError('need at least one event and one quiet episode for conditional rates')
    cost_delta = (sum(int(a['acquisition_cost'])-int(b['acquisition_cost'])
                      for a,b in zip(left,right))/len(left))
    return event_delta, quiet_delta, cost_delta


def mean(values):
    return sum(values)/len(values)


def risk_delta(event_delta, quiet_delta, cost_delta, prevalence, false_alarm_cost,
               miss_cost, acquisition_weight):
    return (prevalence*miss_cost*mean(event_delta)
            + (1-prevalence)*false_alarm_cost*mean(quiet_delta)
            + acquisition_weight*cost_delta)


def percentile(xs, fraction):
    """Piecewise-linear empirical quantile, explicitly documented and deterministic."""
    ys = sorted(xs)
    position = (len(ys)-1)*fraction
    lo, hi = math.floor(position), math.ceil(position)
    return ys[lo]+(ys[hi]-ys[lo])*(position-lo)


def compare(path_a, path_b, *, prevalence=.15, false_alarm_cost=2, miss_cost=12,
            acquisition_weight=.05, bootstrap=800, seed=2026):
    if not 0 <= prevalence <= 1 or min(false_alarm_cost,miss_cost,acquisition_weight) < 0:
        raise ValueError('prevalence must be in [0,1] and costs must be nonnegative')
    if not 100 <= bootstrap <= 100000:
        raise ValueError('bootstrap repetitions must lie in [100,100000]')
    a,pa=read_checked(path_a)
    b,pb=read_checked(path_b)
    if pa == pb:
        raise ValueError('the two files must use different policies')
    ed,qd,cd=paired_components(a,b)
    estimate = risk_delta(ed,qd,cd,prevalence,false_alarm_cost,miss_cost,acquisition_weight)
    rng=random.Random(seed)
    n_e,n_q=len(ed),len(qd)
    boot=[]
    for _ in range(bootstrap):
        em=sum(ed[rng.randrange(n_e)] for _ in range(n_e))/n_e
        qm=sum(qd[rng.randrange(n_q)] for _ in range(n_q))/n_q
        boot.append(prevalence*miss_cost*em+(1-prevalence)*false_alarm_cost*qm
                    +acquisition_weight*cd)
    lower,upper=percentile(boot,.025),percentile(boot,.975)
    return {
      'status':'checked-paired-synthetic-comparison',
      'left_policy':pa, 'right_policy':pb,
      'comparison':'left loss minus right loss; negative favors left',
      'paired_episodes':len(a), 'event_episodes':n_e, 'quiet_episodes':n_q,
      'assumed_target_event_prevalence':prevalence,
      'loss_parameters': {'false_alarm':false_alarm_cost,'miss':miss_cost,
                          'per_acquisition_unit':acquisition_weight},
      'conditional_miss_rate_delta_left_minus_right':mean(ed),
      'conditional_false_alarm_rate_delta_left_minus_right':mean(qd),
      'mean_acquisition_cost_delta_left_minus_right':cd,
      'estimated_target_loss_delta':estimate,
      'percentile_bootstrap_95_interval':[lower,upper],
      'bootstrap_repetitions':bootstrap,'bootstrap_seed':seed,
      'interpretation':('uncertainty from finite independent synthetic episodes only; '
                        'not a model-validity, cost-validity, or field safety certificate'),
      'limits':('Only any/quorum full-acquisition policies are comparable with complete '
                'episode-level world checks. Data are generated under a fixed model; '
                'bootstrap may be inadequate near rare-event boundaries.')
    }


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('left');p.add_argument('right')
    p.add_argument('--prevalence',type=float,default=.15)
    p.add_argument('--false-alarm-cost',type=float,default=2)
    p.add_argument('--miss-cost',type=float,default=12)
    p.add_argument('--acquisition-weight',type=float,default=.05)
    p.add_argument('--bootstrap',type=int,default=800)
    p.add_argument('--seed',type=int,default=2026)
    args=p.parse_args()
    try: out=compare(args.left,args.right,prevalence=args.prevalence,
                     false_alarm_cost=args.false_alarm_cost,miss_cost=args.miss_cost,
                     acquisition_weight=args.acquisition_weight,
                     bootstrap=args.bootstrap,seed=args.seed)
    except (ValueError,OSError,csv.Error) as exc: p.error(str(exc))
    print(json.dumps(out,indent=2,sort_keys=True))

if __name__=='__main__':main()
