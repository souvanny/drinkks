livekit-cli create-token \
--api-key devkey --api-secret secret \
--join --room ma-super-room --identity bob1 \
--valid-for 24h

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEPRECATION NOTICE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The `livekit-cli` binary has been renamed to `lk`, and some of the options and
commands have changed. Though legacy commands my continue to work, they have
been hidden from the USAGE notes and may be removed in future releases.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

valid for (mins):  1440
Token grants:
{
"roomJoin": true,
"room": "ma-super-room"
}

Project URL: http://localhost:7880
Access token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzA3NTk0MjgsImlkZW50aXR5IjoiYm9iMSIsImlzcyI6ImRldmtleSIsIm5hbWUiOiJib2IxIiwibmJmIjoxNzcwNjczMDI4LCJzdWIiOiJib2IxIiwidmlkZW8iOnsicm9vbSI6Im1hLXN1cGVyLXJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.lIO9T15YuI8AlgPUeHCwoSUb7dw2g3QU7D9jVCUzvdc


=======


bash
# 1. Générer les clés API
docker run --rm livekit/livekit:latest livekit-server generate-keys
# 2. Créer la structure de dossiers
mkdir -p livekit-prod/{certs,data,config}
cd livekit-prod
# 3. Placer vos certificats SSL
# cert.pem et key.pem dans le dossier certs/
# 4. Créer le fichier de configuration
nano config/livekit.yaml
# 5. Démarrer
docker-compose -f docker-compose.prod.yml up -d