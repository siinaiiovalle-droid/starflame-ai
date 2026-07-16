#!/usr/bin/env python3
"""Persistent web server + serveo tunnel daemon for StarFlame AI website."""
import subprocess, time, os, re, urllib.request, signal, sys

os.chdir('/Users/huangcanran/Documents/工业炉公司/website')
URL_FILE = '/tmp/starflame_live_url.txt'

def start_server(port=8890):
    """Start the HTTP server."""
    subprocess.run(f'pkill -f "python3.*http.server.*{port}" 2>/dev/null', shell=True)
    time.sleep(0.5)
    proc = subprocess.Popen(
        ['python3', '-m', 'http.server', str(port), '--bind', '127.0.0.1'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    time.sleep(1)
    try:
        r = urllib.request.urlopen(f'http://127.0.0.1:{port}/', timeout=3)
        if r.status == 200:
            print(f"[OK] Server on port {port}")
            return proc
    except:
        pass
    print("[FAIL] Server failed to start")
    sys.exit(1)

def start_tunnel(port=8890):
    """Start serveo tunnel and return the URL."""
    subprocess.run('pkill -f "ssh.*serveo" 2>/dev/null', shell=True)
    time.sleep(1)
    proc = subprocess.Popen(
        ['ssh', '-o', 'StrictHostKeyChecking=no', '-o', 'ConnectTimeout=15',
         '-o', 'ServerAliveInterval=60', '-o', 'ServerAliveCountMax=3',
         '-R', f'80:127.0.0.1:{port}', 'serveo.net'],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    url = None
    for _ in range(40):
        line = proc.stdout.readline()
        if not line:
            break
        m = re.search(r'(https://[^\s]+)', line)
        if m:
            url = m.group(1)
            break
    return proc, url

def main():
    server = start_server(8890)
    
    while True:
        print("[*] Starting tunnel...")
        tunnel, url = start_tunnel(8890)
        
        if url:
            with open(URL_FILE, 'w') as f:
                f.write(url)
            print(f"\n{'='*55}")
            print(f"  🌐 星焰智能 · 公网地址")
            print(f"  {url}")
            print(f"{'='*55}\n")
        else:
            print("[!] Failed to get URL, retrying in 10s...")
        
        # Wait for tunnel to die, then reconnect
        tunnel.wait()
        print("[!] Tunnel disconnected, reconnecting...")
        time.sleep(3)

if __name__ == '__main__':
    main()
