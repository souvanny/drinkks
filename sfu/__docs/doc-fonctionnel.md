- Il faut utiliser la doc install.md

- les dossiers suivants sont des tests, ne plus en tenir compte : 
  - tuto1
  - tuto2
  - tuto3
  - ubuntu

- Après avoir exécuté les commandes suivante un dossier va être créé

docker pull livekit/generate
docker run --rm -it -v$PWD:/output livekit/generate

- Le dossier livekit.project-takagi.fr est créé si l'url saisi est livekit.project-takagi.fr
- cd livekit.project-takagi.fr
- tous les fichier sont présents
  - docker-compose up -d
- Si on veut créer un token :

livekit-cli create-token \
--api-key APITCL53pSLyZaR --api-secret G2qNPc1PjNjfhdGGzwORQ7v4aLDhsNovnFN36PMXeho \
--join --room ma-super-room --identity bob1 \
--valid-for 24h


- se rendre ensuite sur https://example.livekit.io/?tab=custom


