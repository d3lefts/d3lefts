#!/usr/bin/env python3
"""Deterministic counterexamples to graph-only and time-skewed authorization."""
import json

def or_gate(x): return int(any(x))
def and_gate(x): return int(all(x))

def run():
    # Same graph and sensors: a plan valid for AND fails for OR.
    x=(0,1)
    observed={'source_0':x[0]}
    assert and_gate(x)==0 and or_gate(x)==1 and observed['source_0']==0
    # Two unversioned reads cannot distinguish stable safe from changed unsafe.
    safe=[(0,0),(0,0),(0,0)]
    skew=[(0,0),(1,0),(1,0)]
    # Read source 0 at t=0; source 1 at t=1; authorize at t=2.
    transcript_safe=(safe[0][0],safe[1][1])
    transcript_skew=(skew[0][0],skew[1][1])
    assert transcript_safe==transcript_skew==(0,0)
    assert or_gate(safe[2])==0 and or_gate(skew[2])==1
    # A signed epoch tag distinguishes the mixed snapshots (provided it is authenticated).
    epoch_safe=('e0','e0')
    epoch_skew=('e0','e1')
    assert epoch_safe!=epoch_skew
    result={'status':'PASS','same_graph_AND_to_OR_unsound_without_contract_authentication':True,
            'time_skew_same_observation_transcript_opposite_current_safety':True,
            'consequence':'A trusted version atomicity/linearization guarantee is necessary; merely adding local timestamps is not sufficient if a change can occur after the last read.'}
    print(json.dumps(result,sort_keys=True,indent=2))
if __name__=='__main__':run()
