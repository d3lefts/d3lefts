import copy
import pytest
from independent_effect_verifier import check_baseline, check_promotion, EffectViolation
from promotion_runner import POLICY


def sample():
    b={'Resources':{
        'ResearchOU':{'Type':'AWS::Organizations::OrganizationalUnit',
                      'Properties':{'Name':'Research','ParentId':{'Ref':'root'},
                                    'Tags':[{'Key':'DataClassification','Value':'Internal'}]}},
        'WeightsOU':{'Type':'AWS::Organizations::OrganizationalUnit',
                      'Properties':{'Name':'Weight-Storage','ParentId':{'Ref':'root'},
                                    'Tags':[{'Key':'DataClassification','Value':'Restricted'}]}},
        'PolicyDenyFSX':{'Type':'AWS::Organizations::Policy',
                 'Properties':{'Name':'Deny-FSx-Exports','TargetIds':[{'Ref':'WeightsOU'}],
                               'Content':{'Statement':[{'Effect':'Deny','Resource':'*',
                                          'Action':['fsx:CreateDataRepositoryTask', 'fsx:CopyBackup',
                                                    'fsx:CreateDataRepositoryAssociation',
                                                    'fsx:UpdateDataRepositoryAssociation']}]}}}}}
    c=copy.deepcopy(b)
    c['Resources']['AppliedInterpretabilityOU']={'Type':'AWS::Organizations::OrganizationalUnit',
            'Properties':{'Name':'Applied-Interpretability','ParentId':{'Ref':'ResearchOU'},
                          'Tags':[{'Key':x,'Value':y} for x,y in POLICY['required_tags'].items()]}}
    c['Resources']['PolicyDenyFSX']['Properties']['TargetIds'].append({'Ref':'AppliedInterpretabilityOU'})
    return b,c

def test_legit():
    b,c=sample()
    assert check_baseline(b)['baseline_resource_count']==3
    assert check_promotion(b,c,POLICY)['new_logical_id']=='AppliedInterpretabilityOU'

def test_policy_content_weakening():
    b,c=sample()
    c['Resources']['PolicyDenyFSX']['Properties']['Content']['Statement'][0]['Action'].remove('fsx:CopyBackup')
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_fsx_attachment_removed():
    b,c=sample();c['Resources']['PolicyDenyFSX']['Properties']['TargetIds']=[]
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_existing_resource_change():
    b,c=sample();c['Resources']['WeightsOU']['Properties']['Name']='Evil'
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_bad_parent():
    b,c=sample();c['Resources']['AppliedInterpretabilityOU']['Properties']['ParentId']={'Ref':'WeightsOU'}
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_extra_resource():
    b,c=sample();c['Resources']['OverPrivilege']={'Type':'AWS::IAM::Role','Properties':{'RoleName':'Admin'}}
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_loss_of_protection():
    b,c=sample();c['Resources'].pop('PolicyDenyFSX')
    with pytest.raises(EffectViolation):check_promotion(b,c,POLICY)

def test_changed_policy_scope():
    b,c=sample();policy=copy.deepcopy(POLICY);policy['policy_version']=2
    with pytest.raises(EffectViolation):check_promotion(b,c,policy)
