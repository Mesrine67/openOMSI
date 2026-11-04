# Serveur openOMSI Linux — Docker Desktop WSL2 et VPS

Déploiement à partir du **binaire officiel Linux précompilé**, sans compiler le moteur Rust sur le VPS.
Ce dossier est indépendant des autres composants du jeu (openMapper, Development Tools).

## Prérequis

- Docker Desktop avec backend WSL2 sur Windows, ou Docker Engine + Compose v2 sous Ubuntu/Debian x64.
- Une installation originale et complète d'OMSI 2 (le dossier contient `Omsi.exe`, `maps`, `Vehicles`, etc.).
- Pour Saint-Servan : la carte et ses dépendances doivent être déjà présentes dans le contenu OMSI 2.

## Sur Windows (E:)

```powershell
cd deployments\local-vps
Copy-Item .env.example .env
Copy-Item config\server.cfg.example config\server.cfg
# Télécharger/extraire la release officielle v0.3.45 dans bin
# (ou copier le dossier deploy/bin du projet E:\Projects\openOMSI-Lab)
docker compose config --quiet
docker compose up -d --build
docker compose ps
Invoke-RestMethod http://127.0.0.1:27025/status
```

Préférer Docker Desktop Settings > Resources > Advanced > Disk image location pour mettre le stockage Docker sur E: avant le premier build. Ne pas manipuler directement ses VHDX.

## Sur VPS Ubuntu/Debian

```bash
cd deployments/local-vps
cp .env.vps.example .env
cp config/server.cfg.example config/server.cfg
# Préparer /srv/openomsi/omsi2 avec les fichiers de votre installation originale et les mods
./fetch-server.sh   # curl + sha256sum + unzip ; code source non compilé sur le VPS
docker compose config --quiet
docker compose up -d --build
docker compose ps
curl -fsS http://127.0.0.1:27025/status
```

Sous Linux, `.env` définit `OMSI_DIR=/srv/openomsi/omsi2`, l'adresse d'écoute `0.0.0.0` et les chemins de volume adaptés.
Ports requis : 27015/udp pour le jeu, 27015/tcp pour les transferts et 27025/tcp pour HTTP/WebSocket.
Ne jamais exposer sans protection le panneau d'administration ni ouvrir inutilement les ports.
Le fichier `server.cfg` démarre **sur Grundorf** pour la validation technique. Pour Saint-Servan, remplacer `map` par le vrai chemin `maps/<nom exact>/global.cfg`.

## Données et sauvegardes

- `config/`: configuration du serveur
- `content/`: mods partagés
- `data/`: bus uploadés et données persistantes
- `bin/`: exécutable Linux + libsteam_api.so + LICENSE depuis une release openOMSI

`docker compose down` conserve les données montées. Ne pas utiliser `down -v` pour supprimer les volumes.
Ne **jamais** publier le jeu ou les DLC d'OMSI 2 sur GitHub ; ces dossiers sont exclus de Git.
Le `LICENSE` original reste conservé dans les paquets de distribution et le conteneur.
