"""Unix peer-cred socket protocol; intentionally lacks total request lifetime."""
import argparse
import json
import os
import socket
import struct
from pathlib import Path
from .engine import Authority

MAX_REQUEST = 65536

def peer_uid(sock):
    if not hasattr(socket, 'SO_PEERCRED'):
        raise RuntimeError('Linux SO_PEERCRED required')
    return struct.unpack('3i', sock.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))[1]

def serve(sock_path, state_path, secret, uid, ready=None):
    addr = Path(sock_path)
    if addr.exists():
        addr.unlink()
    service = Authority(state_path, secret, uid)
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as listener:
        listener.bind(str(addr))
        os.chmod(addr, 0o666)
        listener.listen(16)
        if ready is not None:
            ready()
        try:
            while True:
                client, _ = listener.accept()
                with client:
                    # Known seed defect: idle peer and slow drip may monopolize
                    # this single-threaded service past a total request deadline.
                    data = bytearray()
                    while len(data) < MAX_REQUEST and not data.endswith(b'\n'):
                        chunk = client.recv(min(4096, MAX_REQUEST - len(data)))
                        if not chunk:
                            break
                        data.extend(chunk)
                    try:
                        envelope = json.loads(bytes(data))
                        result = service.handle(envelope, peer_uid(client))
                    except (ValueError, TypeError, UnicodeError) as exc:
                        result = {'ok': False, 'reason': 'invalid_json_or_request', 'type': type(exc).__name__}
                    client.sendall((json.dumps(result, sort_keys=True) + '\n').encode())
        finally:
            if addr.exists():
                addr.unlink()

def request(sock_path, envelope, timeout=3.0):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        sock.connect(str(sock_path))
        sock.sendall((json.dumps(envelope) + '\n').encode())
        data = bytearray()
        while not data.endswith(b'\n'):
            data.extend(sock.recv(4096))
        return json.loads(data)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--socket', required=True)
    parser.add_argument('--state', required=True)
    parser.add_argument('--key-file', required=True)
    parser.add_argument('--uid', type=int, required=True)
    args = parser.parse_args()
    serve(args.socket, args.state, Path(args.key_file).read_bytes(), args.uid)

if __name__ == '__main__':
    main()
