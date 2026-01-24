# Mode simple
docker-compose -f docker-compose.local.yml up -d

# Mode avec Redis
docker-compose -f docker-compose.local-redis.yml up -d

# Vérifier les logs
docker logs -f livekit

-- PROD --

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