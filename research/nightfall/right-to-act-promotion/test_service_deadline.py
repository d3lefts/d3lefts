"""Independent bounded-client-lifetime regression for trusted authority service."""
import pathlib,os,socket,subprocess,sys,tempfile,time,threading
import authority_service as a

def run_case(kind):
    with tempfile.TemporaryDirectory() as path:
        d=pathlib.Path(path);key=b'x'*32;(d/'shared_key').write_bytes(key)
        b={'Resources':{}};p={'policy_version':1}
        a.initialize(d,{'version':'v-00000001','source_hash':'x'*64,
            'policy_hash':a.digest(p),'baseline_hash':a.digest(b)},b,p)
        sock=d/'gate.sock'
        proc=subprocess.Popen([sys.executable,str(pathlib.Path(a.__file__).resolve()),
             'serve','--trust',str(d),'--sock',str(sock),'--uid',str(os.getuid())],
             stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
        try:
            for _ in range(100):
                if sock.exists():break
                time.sleep(0.01)
            assert sock.exists()
            c=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);c.connect(str(sock))
            stop=threading.Event()
            def drip():
                while not stop.is_set():
                    try:c.send(b'{')
                    except (BrokenPipeError,ConnectionResetError,OSError):break
                    time.sleep(0.12)
            if kind=='drip':
                thread=threading.Thread(target=drip,daemon=True);thread.start()
            time.sleep(0.1)
            t=time.monotonic()
            result=a.request(sock,{'op':'status'},key)
            elapsed=time.monotonic()-t
            assert result.get('ok') is True,(kind,result)
            assert 0<=elapsed<3.2,(kind,elapsed)
            stop.set();c.close()
        finally:
            proc.terminate();proc.communicate(timeout=4)

def test_silent_client_cannot_starve_trusted_request():
    run_case('idle')

def test_slow_drip_cannot_starve_trusted_request():
    run_case('drip')
