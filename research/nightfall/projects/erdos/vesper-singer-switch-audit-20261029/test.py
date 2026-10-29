#!/usr/bin/env python3
"""Hard acceptance gates; independent sources and direct pair-sum counterchecks."""
from audit import audit
from global_min import run as min_run
from independent import run as witness_run, CASES
def check():
    a= audit(5);b=audit(7)
    assert a["source_D"]==[12,16,18,21,28,29]
    assert b["source_D"]==[3,19,21,29,32,33,38,53]
    assert a["cut_pair_trials"]==28830 and b["cut_pair_trials"]==116964
    assert (a["min_positive_overlap"],b["min_positive_overlap"])==(4,10)
    assert (a["min_witness_u_c1_c2"],b["min_witness_u_c1_c2"])==([3,13,8],[2,25,51])
    assert a["mean_overlap_exact"]=={"numerator":9455,"denominator":961}
    assert b["mean_overlap_exact"]=={"numerator":60116,"denominator":3249}
    g=min_run(5,31,(12,16,18,21,28,29))
    h=min_run(7,57,(3,19,21,29,32,33,38,53))
    assert g["all_source_cuts"]["pairs"]==28830
    assert g["all_source_cuts"]["one_deletion_possible"]==0
    assert g["all_source_cuts"]["two_deletions_possible"]==204
    assert h["all_source_cuts"]["pairs"]==116964
    assert h["all_source_cuts"]["one_deletion_possible"]==0
    assert h["all_source_cuts"]["two_deletions_possible"]==0
    assert (g["global_min_deletions_in_this_affine_class"],h["global_min_deletions_in_this_affine_class"])==(2,3)
    wa,wb=[witness_run(*x) for x in CASES]
    assert (wa["min_removed_exact"],wb["min_removed_exact"])==(2,3)
    assert (wa["retained_cardinality"],wb["retained_cardinality"])==(10,13)
    # Negative controls: a duplicate or added invalid 2-sum must be rejected.
    from independent import strong_sidon
    assert not strong_sidon([0,1,2])[0] # 0+2=1+1
    assert not strong_sidon([1,2,3,4])[0]
    assert strong_sidon([0,1,4])[0]
    print("PASS q=5/q=7: 145794 cut pairs, global 2/3 deletion floors, literal witness replay")
if __name__=="__main__":check()
