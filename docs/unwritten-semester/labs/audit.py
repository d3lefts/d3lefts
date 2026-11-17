#!/usr/bin/env python3
"""Independent-format checker for AURORA traces.

Deliberately does not import aurora.py. Checks trace arithmetic and policy logic,
NOT the simulator's probabilistic assumptions or real-world validity.
"""
import csv
import hashlib
import json
import sys
from pathlib import Path

REQUIRED = ('trial', 'policy', 'event', 'common_outage', 'a', 'b', 'c',
            'alarm', 'operable', 'acquisition_cost')


def verify_trace(path):
    with Path(path).open(newline='', encoding='utf-8') as stream:
        reader = csv.DictReader(stream)
        if not reader.fieldnames or set(reader.fieldnames) != set(REQUIRED):
            raise ValueError('wrong header/schema')
        rows = list(reader)
    if not rows:
        raise ValueError('empty trace')
    counts = {'events': 0, 'quiet': 0, 'missed': 0, 'false_alerts': 0, 'operable': 0, 'cost': 0}
    for index, row in enumerate(rows):
        if row['trial'] != str(index):
            raise ValueError('trial identifiers not sequential at row %s' % index)
        policy = row['policy']
        if policy not in ('single', 'any', 'quorum'):
            raise ValueError('invalid policy')
        if row['event'] not in ('0', '1') or row['common_outage'] not in ('0', '1'):
            raise ValueError('invalid world state')
        if row['alarm'] not in ('0', '1') or row['operable'] not in ('0', '1'):
            raise ValueError('invalid report state')
        chosen = ('a',) if policy == 'single' else ('a', 'b', 'c')
        for k in ('a', 'b', 'c'):
            if row[k] not in (('0', '1', 'NA') if k in chosen else ('NOT_ACQUIRED',)):
                raise ValueError('invalid acquisition status on row %s' % index)
            if row['common_outage'] == '1' and k in chosen and row[k] != 'NA':
                raise ValueError('common outage violated on row %s' % index)
        required_positive = 2 if policy == 'quorum' else 1
        observed = [row[k] for k in chosen]
        count_on = observed.count('1')
        count_present = observed.count('0') + count_on
        expected_alarm = '1' if count_on >= required_positive else '0'
        expected_operable = '1' if count_present >= required_positive else '0'
        expected_cost = 3 if policy == 'single' else 16
        if (row['alarm'] != expected_alarm or row['operable'] != expected_operable
                or row['acquisition_cost'] != str(expected_cost)):
            raise ValueError('policy/cost mismatch on row %s' % index)
        event = row['event'] == '1'
        if event:
            counts['events'] += 1
            counts['missed'] += row['alarm'] == '0'
        else:
            counts['quiet'] += 1
            counts['false_alerts'] += row['alarm'] == '1'
        counts['operable'] += row['operable'] == '1'
        counts['cost'] += expected_cost
    n = len(rows)
    return dict(
        status='trace-arithmetic-verified',
        episodes=n,
        events=counts['events'],
        quiet_episodes=counts['quiet'],
        missed_count=counts['missed'],
        false_alarm_count=counts['false_alerts'],
        operable_count=counts['operable'],
        miss_fraction_given_event=(counts['missed']/counts['events'] if counts['events'] else None),
        false_alarm_fraction_given_quiet=(counts['false_alerts']/counts['quiet'] if counts['quiet'] else None),
        operability_fraction=counts['operable']/n,
        mean_acquisition_cost_units=counts['cost']/n,
        sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest(),
        limitation='Does not validate sensor distributions, source integrity, field fitness, or safety.'
    )


def main():
    if len(sys.argv) != 2:
        sys.exit('usage: python3 labs/audit.py path/to/trace.csv')
    try:
        report = verify_trace(sys.argv[1])
    except (ValueError, OSError, csv.Error) as exc:
        print('FAIL:', exc, file=sys.stderr)
        sys.exit(1)
    print(json.dumps(report, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
