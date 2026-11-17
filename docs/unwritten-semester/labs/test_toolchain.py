"""Tests include mutations and negative checks, not just happy-path results."""
import csv
import tempfile
import unittest
from pathlib import Path
from aurora import simulate,FIELDS
from compare import paired_components,compare
from modelcheck import verify,policy
from passport import create,inspect,impact,safe_relpath

class ToolchainTests(unittest.TestCase):
    def write_trace(self,path,rows):
        with open(path,'w',newline='',encoding='utf-8') as f:
            writer=csv.DictWriter(f,fieldnames=FIELDS)
            writer.writeheader();writer.writerows(rows)

    def test_comparator_paired_reference_and_determinism(self):
        with tempfile.TemporaryDirectory() as tmp:
            a,b=Path(tmp)/'a.csv',Path(tmp)/'b.csv'
            self.write_trace(a,list(simulate(seed=2026,trials=250,policy='any')))
            self.write_trace(b,list(simulate(seed=2026,trials=250,policy='quorum')))
            result=compare(a,b,bootstrap=100)
            self.assertEqual(result,compare(a,b,bootstrap=100))
            self.assertEqual(result['paired_episodes'],250)
            self.assertLessEqual(result['conditional_miss_rate_delta_left_minus_right'],0)
            self.assertGreaterEqual(result['conditional_false_alarm_rate_delta_left_minus_right'],0)

    def test_comparator_refuses_unpaired_world(self):
        with tempfile.TemporaryDirectory() as tmp:
            a,b=Path(tmp)/'a.csv',Path(tmp)/'b.csv'
            self.write_trace(a,list(simulate(seed=1,trials=150,policy='any')))
            self.write_trace(b,list(simulate(seed=2,trials=150,policy='quorum')))
            with self.assertRaisesRegex(ValueError,'worlds not paired'):
                compare(a,b,bootstrap=100)

    def test_exhaustive_checker(self):
        report=verify()
        self.assertEqual(report['tested_states'],27)
        self.assertEqual(report['status'],'PASS')
        self.assertTrue(report['witnesses_any_alarms_but_quorum_does_not'])

    def test_mutated_quorum_checker_is_rejected(self):
        def bad_policy(states,name):
            if name=='quorum':return policy(states,'any')
            return policy(states,name)
        report=verify(bad_policy)
        self.assertEqual(report['status'],'FAIL')
        self.assertGreater(report['violations']['quorum_requires_two_positives'],0)

    def test_passport_identity_then_change(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);(root/'model.txt').write_text('v1',encoding='utf-8')
            manifest=create(root,['model.txt'],'synthetic assertion')
            self.assertEqual(inspect(root,manifest)['status'],'byte-identical')
            (root/'model.txt').write_text('v2',encoding='utf-8')
            self.assertEqual(inspect(root,manifest)['files']['model.txt'],'changed')

    def test_passport_rejects_traversal(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaisesRegex(ValueError,'unsafe path'):
                safe_relpath(Path(temp),'../../etc/passwd')

    def test_impact_transitive_and_cycle(self):
        graph={'claims':{'arithmetic':['file:trace.csv'],
                         'recommendation':['claim:arithmetic','file:model.txt'],
                         'presentation':['file:page.css']}}
        scan={'files':{'trace.csv':'changed','model.txt':'matching','page.css':'matching'}}
        out=impact(graph,scan)
        self.assertEqual(out['claims_needing_recheck'],['arithmetic','recommendation'])
        self.assertEqual(out['unaffected_in_declared_graph'],['presentation'])
        with self.assertRaisesRegex(ValueError,'cycle'):
            impact({'claims':{'a':['claim:b'],'b':['claim:a']}},{'files':{}})

if __name__=='__main__':unittest.main()

# Attach additional exact-arithmetic check with a distinct test name.
from exact_switch import crossing

def _test_exact_policy_switch(self):
    with tempfile.TemporaryDirectory() as tmp:
        a,b=Path(tmp)/'a.csv',Path(tmp)/'b.csv'
        self.write_trace(a,list(simulate(seed=2026,trials=5000,policy='any')))
        self.write_trace(b,list(simulate(seed=2026,trials=5000,policy='quorum')))
        out=crossing(a,b)
        self.assertEqual(out['crossing_prevalence_exact'],'19910/80843')
        self.assertTrue(out['crossing_in_unit_interval'])
ToolchainTests.test_exact_policy_switch=_test_exact_policy_switch
