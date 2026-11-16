from pathlib import Path
import json
root=Path(__file__).parent
S='https://json-schema.org/draft/2020-12/schema'
def write(name,v):
 (root/name).write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n')
idstr={'type':'string','pattern':'^[a-z][a-z0-9-]{1,63}$'}
source={'$schema':S,'$id':'https://commonwealth.example.invalid/schemas/synthetic-source-v0.4','title':'Synthetic Source Record','type':'object','additionalProperties':False,'required':['sourceId','text','status','sourceUri'],
 'properties':{'sourceId':idstr,'text':{'type':'string','minLength':1,'maxLength':50000},'status':{'enum':['DRAFT','PROPOSED','ENACTED','REPEALED','UNKNOWN']},'sourceUri':{'type':'string','pattern':'^synthetic:'},'institutionId':idstr,'key':{'type':'string','minLength':8}}}
write('synthetic-source.schema.json',source)
policy={'$schema':S,'$id':'https://commonwealth.example.invalid/schemas/policy-v0.4','title':'Fictional Procedural Policy','type':'object','additionalProperties':False,'required':['quorum','yesNumerator','yesDenominator','strict'],
'properties':{'quorum':{'type':'integer','minimum':1},'yesNumerator':{'type':'integer','minimum':1},'yesDenominator':{'type':'integer','minimum':1},'strict':{'type':'boolean'},'approvalBasis':{'enum':['DECISIVE','CAST','PRESENT','ELIGIBLE']},'quorumFraction':{'type':'object','additionalProperties':False,'required':['numerator','denominator','strict','basis'],'properties':{'numerator':{'type':'integer','minimum':1},'denominator':{'type':'integer','minimum':1},'strict':{'type':'boolean'},'basis':{'const':'ELIGIBLE'}}}},
'$comment':'Cross-field constraints numerator <= denominator are checked by runtime independent policy evaluator.'}
write('procedural-policy.schema.json',policy)
passport={'$schema':S,'$id':'https://commonwealth.example.invalid/schemas/portable-evidence-v0.4','title':'Portable Synthetic Governance Evidence Envelope','type':'object','additionalProperties':False,'required':['envelope','payload','signature','signerTrust'],
 'properties':{'envelope':{'const':'commonwealth.os.portable-evidence.v1'},'signerTrust':{'const':'UNVERIFIED_UNLESS_PINNED_EXTERNALLY'},'signature':{'type':'object','additionalProperties':False,'required':['alg','keyId','publicKeyPem','signature'],'properties':{'alg':{'const':'Ed25519'},'keyId':{'type':'string','pattern':'^[a-f0-9]{64}$'},'publicKeyPem':{'type':'string'},'signature':{'type':'string'}}},
 'payload':{'type':'object','required':['format','institution','item','events','authorityJournal','members','policies','revisions','attendance','votes','sources','sourceDependencies','projections','publicationApprovals','legalAuthority','officialCertification'],
 'properties':{'format':{'const':'commonwealth.os.demo-evidence.v2'},'officialCertification':{'const':False},'legalAuthority':{'const':'NOT_ASSESSED'},'institution':{'type':'object'},'item':{'type':'object'},'events':{'type':'array'},'authorityJournal':{'type':'array'},'members':{'type':'array'},'policies':{'type':'array'},'revisions':{'type':'array'},'attendance':{'type':'array'},'votes':{'type':'array'},'sources':{'type':'array'},'sourceDependencies':{'type':'array'},'projections':{'type':'array'},'publicationApprovals':{'type':'array'}}}}}
write('portable-evidence-v2.schema.json',passport)
command={'type':'object','required':['institutionId','itemId','action','expectedVersion','payload','key'], 'properties':{'institutionId':idstr,'itemId':idstr,'action':{'enum':['CREATE','REVISE','SUBMIT','AGENDA','BEGIN','ATTEND','LOCK','OPEN','CAST','CLOSE','REVIEW','VOID','ATTACH_SOURCE','PREPARE_PUBLICATION','REVIEW_PUBLICATION','PUBLISH_PREVIEW','CORRECT_PUBLICATION']},'expectedVersion':{'type':'integer','minimum':0},'payload':{'type':'object'},'key':{'type':'string','minLength':8,'maxLength':120}}}
write('command.schema.json',{'$schema':S,'title':'Institution-scoped synthetic legislative command','type':'object',**command})
paths={}
def op(method,path,summary,role,request=None):
 p=paths.setdefault(path,{})
 x={'operationId':summary.lower().replace(' ','_'),'summary':summary,'description':'Synthetic-only. Authorization verified server-side. '+role,'responses':{'200':{'description':'Synthetic result'},'400':{'description':'Malformed request'},'401':{'description':'Unauthorized'},'403':{'description':'Forbidden'},'409':{'description':'State/authority conflict'}}}
 if path!='/healthz':x['security']=[{'BearerToken':[]}]
 if request:x['requestBody']={'required':True,'content':{'application/json':{'schema':request}}}
 p[method]=x
op('get','/healthz','Health','No credentials')
op('get','/api/v1/me','Read actor','Current synthetic credential')
op('post','/api/v1/commands','Execute transition','Institution-bound actor',{ '$ref':'./command.schema.json'})
for path,descr in [('/api/v1/eligibility','Change eligibility'),('/api/v1/policies','Change rules'),('/api/v1/actors/revoke','Revoke synthetic actor'),('/api/v1/sources','Import fictional source'),('/api/v1/recertify','Analyze change impact')]:op('post',path,descr,'Administrator or auditor as documented',{'type':'object'})
for suffix,descr in [('', 'Read item'),('/evidence','Export restricted signed evidence'),('/public-preview','Read reviewed fictional projection')]:op('get','/api/v1/institutions/{institutionId}/items/{itemId}'+suffix,descr,'Institution-scoped; evidence requires auditor/clerk/admin')
openapi={'openapi':'3.1.0','info':{'title':'Commonwealth OS Synthetic Backend API','version':'0.4.0','description':'LOCAL research-only. No official voting, real municipal ingestion, or real ID federation.'},'servers':[{'url':'http://127.0.0.1:4180'}],'components':{'securitySchemes':{'BearerToken':{'type':'http','scheme':'bearer','description':'Local synthetic tokens; never for real identities'}}},'paths':paths}
write('openapi.json',openapi)
