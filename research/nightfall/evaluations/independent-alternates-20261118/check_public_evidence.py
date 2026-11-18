#!/usr/bin/env python3
"""Check PUBLIC receipt structure only; never pretend to replay a private grader."""
from pathlib import Path
import json,re
HERE=Path(__file__).resolve().parent
SHA=re.compile('[a-f0-9]{64}\\Z')
x=json.loads((HERE/'PUBLIC_EVIDENCE.json').read_text())
assert x['schema']=='nightfall.swe.independent-alternate-internal-evidence.v1'
assert x['as_of']=='2026-11-18'
assert x['accepted_blind_agent_scores']==0
assert x['author_ref_used_for_construction'] is False
assert x['two_alternates_source_public'] is False
assert x['source_scope'].find('not by an independent human reviewer')>=0
assert x['claim_status']=='source_frozen_internal_private_grader_replay_not_external_certification'
assert len(x['limitations'])>=6
assert any('same-process Docker grader' in item and 'compromised' in item for item in x['limitations'])
assert any('never Qwen outputs' in item for item in x['limitations'])
a=x['b1'];b=x['b2']
assert (a['private_grader_cases_passed'],a['private_grader_cases_total'])==(37,37)
assert (a['private_grader_points'],a['private_grader_max_points'])==(100,100)
assert a['grader_version']=='private-author-v0.3'
assert (a['state_machine_operations'],a['random_state_machine_seeds'])==(3840,32)
assert (a['process_race_rounds'],a['process_workers_per_round'],a['observed_duplicate_leases'])==(10,6,0)
assert (b['private_grader_cases_passed'],b['private_grader_cases_total'])==(25,25)
assert b['grader_version']=='private-author-v0.1'
assert (b['independent_public_metamorphic_groups_passed'],b['random_dags'])==(16,80)
assert set(b['frozen_independent_source_hashes'])=={'cache.py','engine.py','manifest.py'}
for z in (a['grader_archive_sha256'],a['private_grader_source_sha256'],
          a['frozen_independent_repair_source_sha256'],b['grader_archive_sha256'],
          *b['frozen_independent_source_hashes'].values(),
          x['private_replay_packet_sha256']):
    assert type(z) is str and SHA.fullmatch(z)
assert 'source' not in x.get('private_correct_implementation',{})
assert (HERE/'README.md').is_file()
report = {'status':'PASS','check':'public-metadata-consistency-only',
          'private_grader_executed_by_this_checker':False,
          'source_implemented_in_this_repository':False,
          'third_party_human_review':False,
          'blind_agent_scores':0,
          'b1_private_author_report':[37,37,100,100],
          'b2_private_author_report':[25,25]}
print(json.dumps(report,sort_keys=True))
