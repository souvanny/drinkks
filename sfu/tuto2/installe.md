https://github.com/livekit/livekit-cli/releases

brew install livekit-cli


livekit-cli create-token \
--api-key devkey --api-secret secret \
--join --room ma-super-room --identity bob1 \
--valid-for 24h

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjkzODExOTQsImlkZW50aXR5IjoiYm9iMSIsImlzcyI6ImRldmtleSIsIm5hbWUiOiJib2IxIiwibmJmIjoxNzY5Mjk0Nzk0LCJzdWIiOiJib2IxIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.jRgUElL9n9eGq8MjGQXEUGif6_o8aL1yPjrE-6CUVkc


livekit-cli create-token \
--api-key devkey --api-secret secret \
--join --room ma-super-room --identity bob2 \
--valid-for 24h

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjkzODE0NjIsImlkZW50aXR5IjoiYm9iMiIsImlzcyI6ImRldmtleSIsIm5hbWUiOiJib2IyIiwibmJmIjoxNzY5Mjk1MDYyLCJzdWIiOiJib2IyIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.JmP6U7olsh4oqqGaTmXO3ImFBmitbyev6Q1mLpdovJk



https://example.livekit.io


ws://192.168.1.43:7880
ws://192.168.1.43:7880?transport=tcp

ws://localhost:7880
ws://localhost:7880?transport=tcp

ifconfig | grep "inet " | grep -v 127.0.0.1
inet 192.168.1.43 netmask 0xffffff00 broadcast 192.168.1.255

ngrok http 7880

https://b8dceaf99fd7.ngrok-free.app

https://147401cfd300.ngrok-free.app?transport=tcp