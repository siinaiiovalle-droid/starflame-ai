#!/bin/bash
cd /Users/huangcanran/Documents/工业炉公司/website

# Kill any existing
pkill -f "python3.*http.server.*8888" 2>/dev/null
pkill -f "ssh.*serveo.*8888" 2>/dev/null
sleep 2

# Start HTTP server
python3 -m http.server 8888 --bind 127.0.0.1 &
sleep 1

# Start tunnel and capture URL
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ServerAliveInterval=60 \
    -R 80:127.0.0.1:8888 serveo.net 2>&1 | while read line; do
    echo "$line"
    if echo "$line" | grep -q "Forwarding HTTP"; then
        URL=$(echo "$line" | grep -o 'https://[^ ]*')
        echo "URL=$URL" > /tmp/starflame_url.txt
        echo ""
        echo "========================================="
        echo "  公网地址: $URL"
        echo "========================================="
        echo ""
        break
    fi
done

# Keep running
wait
