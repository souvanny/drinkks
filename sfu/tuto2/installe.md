https://github.com/livekit/livekit-cli/releases

brew install livekit-cli


livekit-cli create-token \
--api-key devkey --api-secret secret \
--join --room ma-super-room --identity bob1 \
--valid-for 24h

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjkzNTcwODYsImlkZW50aXR5IjoiYm9iMSIsImlzcyI6ImRldmtleSIsIm5hbWUiOiJib2IxIiwibmJmIjoxNzY5MjcwNjg2LCJzdWIiOiJib2IxIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.7y12SR2fOBz3itl-aZKo3OxY8hbI_tn2L3akVZzl8cY


livekit-cli create-token \
--api-key devkey --api-secret secret \
--join --room ma-super-room --identity bob2 \
--valid-for 24h

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjkzNTcxMTcsImlkZW50aXR5IjoiYm9iMiIsImlzcyI6ImRldmtleSIsIm5hbWUiOiJib2IyIiwibmJmIjoxNzY5MjcwNzE3LCJzdWIiOiJib2IyIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.V8435aLs4EwW9S3B0PpF-fxIh1q4xxQrvRmFkuzriL0



https://example.livekit.io


ws://192.168.1.43:7880

ws://localhost:7880

ifconfig | grep "inet " | grep -v 127.0.0.1
inet 192.168.1.43 netmask 0xffffff00 broadcast 192.168.1.255

ngrok http 7880

https://b8dceaf99fd7.ngrok-free.app