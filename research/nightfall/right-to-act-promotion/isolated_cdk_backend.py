"""Restricted Docker execution backend for *untrusted* CDK source.

Host's VersionedGate/semantic effect verifier are NEVER mounted or executed
inside sandbox. This is OS-level namespace/capability containment, NOT a
microVM, gVisor, or universal Docker-escape proof.
"""
from __future__ import annotations
from pathlib import Path
import hashlib, json, os, shutil, subprocess, tempfile, time
from promotion_runner import hash_source

IMAGE = 'nightfall-iac-cdk-sandbox:v16'
CDK_CODE = r'''
import json
from pathlib import Path
from aws_cdk import App, Environment, assertions
from core_infrastructure.root_account.organisation import OrganisationStack
app = App()
stack = OrganisationStack(app,'OrganisationStack',
                          env=Environment(account='181739179312',region='us-east-1'))
template=assertions.Template.from_stack(stack).to_json()
Path('/out/result.json').write_text(json.dumps(template))
'''

class SandboxedCDK:
    def __init__(self,image=IMAGE):
        if not shutil.which('docker'):
            raise RuntimeError('Docker is required: cannot execute untrusted code on host')
        self.image=image
        self.calls=0
        self.report=[]
        inspected=subprocess.run(['docker','image','inspect','--format','{{.Id}}',image],
                                 capture_output=True,text=True,timeout=30,check=True)
        self.image_id=inspected.stdout.strip()
        if not self.image_id.startswith('sha256:'):
            raise RuntimeError('unrecognized container image identifier')

    def argv(self,source,out,cmd):
        # No network, root or ambient privileges; input source mounted readonly.
        return ['docker','run','--rm','--network=none','--user=65534:65534',
                '--cap-drop=ALL','--security-opt=no-new-privileges',
                '--read-only','--pids-limit=128','--memory=2048m','--cpus=2',
                '--env=PYTHONDONTWRITEBYTECODE=1','--env=PYTHONPATH=/src',
                '--env=HOME=/tmp',
                '--tmpfs=/tmp:rw,nosuid,nodev,size=256m,mode=1777',
                '--mount',f'type=bind,source={source},target=/src,readonly',
                '--mount',f'type=bind,source={out},target=/out',
                '--workdir=/src',self.image,*cmd]

    def __call__(self,source):
        source=Path(source).resolve(strict=True)
        if not source.is_dir():raise RuntimeError('source is not a directory')
        before=hash_source(source)
        with tempfile.TemporaryDirectory(prefix='nightfall-untrusted-out-') as tmp:
            out=Path(tmp);out.chmod(0o777)
            cmd=self.argv(source,out,['python','-c',CDK_CODE])
            t=time.monotonic()
            run=subprocess.run(cmd,capture_output=True,text=True,timeout=240)
            seconds=round(time.monotonic()-t,3)
            self.calls+=1
            if run.returncode:
                raise RuntimeError('containerized CDK failed (no host fallback): '+run.stderr[-2500:])
            candidate=out/'result.json'
            if not candidate.is_file():raise RuntimeError('sandbox did not emit synthesized template')
            data=json.loads(candidate.read_text())
            if not isinstance(data,dict) or not isinstance(data.get('Resources'),dict):
                raise RuntimeError('sandbox emitted invalid CloudFormation')
            after=hash_source(source)
            if before!=after:raise RuntimeError('sandbox source changed across execution')
            report={'source_sha256':before,'image_id':self.image_id,
                    'sandbox':'docker-nonroot-capdrop-no-new-privs-readonly-network-none',
                    'seconds':seconds,
                    'template_sha256':hashlib.sha256(
                        (json.dumps(data,sort_keys=True,separators=(',',':'))+'\n').encode()).hexdigest()}
            probe=out/'probe.json'
            if probe.exists():
                # Untrusted audit hint; trust independent host observations instead.
                report['untrusted_probe']=json.loads(probe.read_text())
            self.report.append(report)
            return data,seconds

    def security_probe(self,source,secret_path,secret_value):
        """Execute attack probes in same sandbox with no trusted directory bind."""
        source=Path(source).resolve(strict=True)
        before=hash_source(source)
        with tempfile.TemporaryDirectory(prefix='nightfall-probe-out-') as tmp:
            out=Path(tmp);out.chmod(0o777)
            program=r'''
import json,os,pathlib,socket
secret=pathlib.Path(os.environ.get('NO_SECRET','/secret'))
# Exact host pathname deliberately disclosed; it must not be mounted.
secret=pathlib.Path('''+repr(str(secret_path))+r''')
def run(fn):
 try:return {'ok':True,'result':str(fn())[:160]}
 except Exception as e:return {'ok':False,'error':type(e).__name__}
tests={
  'read_host_secret':run(lambda:secret.read_text()),
  'overwrite_host_secret':run(lambda:secret.write_text('BREACHED')),
  'read_host_via_proc':run(lambda:(pathlib.Path('/proc/1/root')/str(secret).lstrip('/')).read_text()),
  'write_source':run(lambda:pathlib.Path('/src/untrusted_write').write_text('BREACHED')),
  'read_docker_socket':run(lambda:pathlib.Path('/var/run/docker.sock').open('rb').read(1)),
  'escalate_uid':run(lambda:os.setuid(0)),
  'write_system_etc':run(lambda:pathlib.Path('/etc/nightfall-probe').write_text('BREACHED')),
}
s=socket.socket()
s.settimeout(0.5)
try:s.connect(('1.1.1.1',80));tests['network_egress']={'ok':True}
except Exception as e:tests['network_egress']={'ok':False,'error':type(e).__name__}
finally:s.close()
st=pathlib.Path('/proc/self/status').read_text()
details={'uid':os.getuid(),'euid':os.geteuid(),
         'cap_eff':next((x.split(':',1)[1].strip() for x in st.splitlines() if x.startswith('CapEff:')),'unknown'),
         'no_new_privs':next((x.split(':',1)[1].strip() for x in st.splitlines() if x.startswith('NoNewPrivs:')),'unknown'),
         'tests':tests}
pathlib.Path('/out/probe.json').write_text(json.dumps(details,sort_keys=True))
'''
            envcmd=['python','-c',program]
            run=subprocess.run(self.argv(source,out,envcmd),
                               capture_output=True,text=True,timeout=75)
            if run.returncode:
                raise RuntimeError('sandbox attack probe did not execute: '+run.stderr[-1500:])
            probe=json.loads((out/'probe.json').read_text())
        assert before==hash_source(source),'sandbox modified input mount'
        assert secret_path.read_text()==secret_value,'trusted secret was modified'
        assert probe['uid']==65534 and probe['euid']==65534
        assert probe['cap_eff']=='0000000000000000'
        assert probe['no_new_privs']=='1'
        assert all(not t['ok'] for t in probe['tests'].values()),probe
        return probe
