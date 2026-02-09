docker run --rm -it -v$PWD:/output livekit/generate


Generating config for production LiveKit deployment
This deployment will utilize docker-compose and Caddy. It'll set up a secure LiveKit installation with built-in TURN/TLS
SSL Certificates for HTTPS and TURN/TLS will be generated automatically via LetsEncrypt or ZeroSSL.

✔ LiveKit Server only
Primary domain name (i.e. livekit.myhost.com): livekit.project-takagi.fr
TURN domain name (i.e. livekit-turn.myhost.com): livekit-turn.project-takagi.fr
✔ Let's Encrypt (no account required)
✔ latest
✔ no - (we'll bundle Redis)
✔ Startup Shell Script
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
API Key: APITCL53pSLyZaR
API Secret: G2qNPc1PjNjfhdGGzwORQ7v4aLDhsNovnFN36PMXeho

Here's a test token generated with your keys: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4MDY2NzUyNDcsImlzcyI6IkFQSVRDTDUzcFNMeVphUiIsIm5hbWUiOiJUZXN0IFVzZXIiLCJuYmYiOjE3NzA2NzUyNDcsInN1YiI6InRlc3QtdXNlciIsInZpZGVvIjp7InJvb20iOiJteS1maXJzdC1yb29tIiwicm9vbUpvaW4iOnRydWV9fQ.QEcbDkWnd-6iPyU-ASRsCZWIDcKjXvNQDI4s46H3lxY

An access token identifies the participant as well as the room it's connecting to


======== generate token ========

livekit-cli create-token \
--api-key APITCL53pSLyZaR --api-secret G2qNPc1PjNjfhdGGzwORQ7v4aLDhsNovnFN36PMXeho \
--join --room ma-super-room --identity bob1 \
--valid-for 24h

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzA3NjM2MDMsImlkZW50aXR5IjoiYm9iMSIsImlzcyI6IkFQSVRDTDUzcFNMeVphUiIsIm5hbWUiOiJib2IxIiwibmJmIjoxNzcwNjc3MjAzLCJzdWIiOiJib2IxIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.VsfdN8ZyoLDrE7UJ2hOiMNao6ySsWJ5wvt5VETygC-M

