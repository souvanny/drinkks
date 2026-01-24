# Vérifier les logs
docker logs -f livekit-prod

# Scale (si nécessaire)
docker-compose -f docker-compose.prod.yml up -d --scale livekit=3

# Backup Redis
docker exec livekit-redis-prod redis-cli SAVE
docker cp livekit-redis-prod:/data/dump.rdb ./backup/

# Mettre à jour
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Monitoring
curl http://localhost:9090/metrics  # Prometheus
curl http://localhost:7881/rtc      # Health check