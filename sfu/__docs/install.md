sudo bash -c 'cat << EOF >> /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
EOF'

====

sudo bash -c 'cat << EOF >> /etc/sysctl.conf
net.core.rmem_max=2500000
net.core.wmem_max=2500000
EOF'
sudo sysctl -p

====

# SSH et Web standard
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# LiveKit STUN/TURN (Signal et contrôle)
sudo ufw allow 3478/udp

# LiveKit RTC (Le flux vidéo/audio proprement dit)
sudo ufw allow 40000:50000/udp
sudo ufw allow 7881/tcp

# Activer le pare-feu
sudo ufw enable


====

docker pull livekit/generate
docker run --rm -it -v$PWD:/output livekit/generate

livekit.project-takagi.fr
livekit-turn.project-takagi.fr



curl -sSL https://get.livekit.io/cli | bash
sudo curl -sSL https://get.livekit.io/cli | bash


====

Your production config files are generated in directory: livekit.project-takagi.fr

Please point update DNS for the following domains to the IP address of your server.
 * livekit.project-takagi.fr
 * livekit-turn.project-takagi.fr
Once started, Caddy will automatically acquire TLS certificates for the domains.

The file "init_script.sh" is a script that can be used in the "user-data" field when starting a new VM.

Please ensure the following ports are accessible on the server
 * 443 - primary HTTPS and TURN/TLS
 * 80 - for TLS issuance
 * 7881 - for WebRTC over TCP
 * 3478/UDP - for TURN/UDP
 * 50000-60000/UDP - for WebRTC over UDP

Server URL: wss://livekit.project-takagi.fr
API Key: APIWJUYhiWkieei
API Secret: GeQggvpqJnZ7Q14qTfPKVNtFlxa8a5qlr4Ki6zISYJ6

Here's a test token generated with your keys: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4MDUzNzAwNjAsImlzcyI6IkFQSVdKVVloaVdraWVlaSIsIm5hbWUiOiJUZXN0IFVzZXIiLCJuYmYiOjE3NjkzNzAwNjAsInN1YiI6InRlc3QtdXNlciIsInZpZGVvIjp7InJvb20iOiJteS1maXJzdC1yb29tIiwicm9vbUpvaW4iOnRydWV9fQ.Y_nWlReEbi5j8kSyNTgpcSm-ubzF8Tf_rc5XjOwjBno

An access token identifies the participant as well as the room it's connecting to

=========




