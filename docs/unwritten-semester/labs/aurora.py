#!/usr/bin/env python3
"""AURORA: a synthetic, seeded three-channel anomaly monitoring teaching model.

No field data, safety approval, or real-world calibration is implied.
Standard library only. The underlying random world is independent of policy.
"""
from __future__ import annotations
import argparse
import csv
import json
import random
from pathlib import Path

FIELDS = ['trial', 'policy', 'event', 'common_outage', 'a', 'b', 'c',
          'alarm', 'operable', 'acquisition_cost']
# sensitivity, false-positive probability, local loss probability, cost
CHANNELS = {'a': (.90, .07, .08, 3), 'b': (.85, .045, .09, 5),
            'c': (.93, .08, .07, 8)}


def validate(policy: str, trials: int, common_fail: float, prevalence: float) -> None:
    if policy not in ('single', 'any', 'quorum'):
        raise ValueError('policy must be single, any, or quorum')
    if trials < 1:
        raise ValueError('trials must be positive')
    if not 0 <= common_fail <= 1 or not 0 <= prevalence <= 1:
        raise ValueError('probabilities must be within [0,1]')


def simulate(seed: int = 2026, trials: int = 5000, policy: str = 'quorum',
             common_fail: float = 0.025, prevalence: float = 0.15):
    validate(policy, trials, common_fail, prevalence)
    rng = random.Random(seed)
    selected = ('a',) if policy == 'single' else ('a', 'b', 'c')
    threshold = 2 if policy == 'quorum' else 1
    per_episode_cost = sum(CHANNELS[k][3] for k in selected)
    for trial in range(trials):
        event = int(rng.random() < prevalence)
        common_outage = int(rng.random() < common_fail)
        readings = {}
        for sensor, (sensitivity, fp_rate, local_failure, _) in CHANNELS.items():
            is_local_out = rng.random() < local_failure
            positive = rng.random() < (sensitivity if event else fp_rate)
            readings[sensor] = 'NA' if (common_outage or is_local_out) else str(int(positive))
        record = {k: (readings[k] if k in selected else 'NOT_ACQUIRED') for k in CHANNELS}
        available = sum(record[k] in ('0', '1') for k in selected)
        positives = sum(record[k] == '1' for k in selected)
        yield dict(trial=trial, policy=policy, event=event, common_outage=common_outage,
                   **record, alarm=int(positives >= threshold),
                   operable=int(available >= threshold), acquisition_cost=per_episode_cost)


def summarize(rows):
    rows = list(rows)
    n = len(rows)
    event_rows = [r for r in rows if int(r['event']) == 1]
    quiet_rows = [r for r in rows if int(r['event']) == 0]
    missed = sum(int(r['alarm']) == 0 for r in event_rows)
    false_alerts = sum(int(r['alarm']) == 1 for r in quiet_rows)
    operable_count = sum(int(r['operable']) for r in rows)
    return {
        'episodes': n,
        'events': len(event_rows),
        'quiet_episodes': len(quiet_rows),
        'missed_count': missed,
        'false_alarm_count': false_alerts,
        'operable_count': operable_count,
        'miss_fraction_given_event': (missed / len(event_rows)
                                      if event_rows else None),
        'false_alarm_fraction_given_quiet': (false_alerts / len(quiet_rows)
                                             if quiet_rows else None),
        'operability_fraction': operable_count / n,
        'mean_acquisition_cost_units': sum(int(r['acquisition_cost']) for r in rows) / n,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seed', type=int, default=2026)
    parser.add_argument('--trials', type=int, default=5000)
    parser.add_argument('--policy', choices=['single', 'any', 'quorum'], default='quorum')
    parser.add_argument('--common-fail', type=float, default=0.025)
    parser.add_argument('--prevalence', type=float, default=0.15)
    parser.add_argument('--out', default='labs/output.csv')
    args = parser.parse_args()
    rows = list(simulate(args.seed, args.trials, args.policy, args.common_fail, args.prevalence))
    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps(dict(source='synthetic/AURORA-v1', policy=args.policy, seed=args.seed,
                          common_fail=args.common_fail, prevalence=args.prevalence,
                          output=str(output), **summarize(rows)), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
