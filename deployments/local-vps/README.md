# openOMSI — Serveur dédié Docker (WSL2 / Linux VPS)

Déploiement reproductible du **serveur Linux openOMSI v0.3.45**, sans compilation Rust sur le VPS.
Les fichiers du jeu OMSI 2 sont fournis localement par l'utilisateur et ne sont **jamais intégrés à Git**.

Ce dossier est destiné à Docker Desktop avec WSL2 sur Windows **et** à Docker Engine + Compose sur un VPS Debian/Ubuntu x64. Le launcher Windows, openMapper et Development Tools restent séparés.

## Structure versionnée

| Fichier | Utilisation |
| --- | --- |
| `compose.yaml` | Exécution du serveur, ports et volumes persistants |
| `Dockerfile` | Image Debian du serveur Linux précompilé |
| `fetch-server.ps1` / `fetch-server.sh` | Téléchargement officiel et vérification SHA-256 |
| `.env.example` / `.env.vps.example` | Exemples de chemins Windows et Linux |
| `config/server.cfg.example` | Configuration de test Grundorf, quatre joueurs |
| `scripts/sync-omsi2.ps1` | Copie additive de l'installation Steam |
| `scripts/preflight.ps1` | Contrôles de configuration **sans démarrer le serveur** |
| `scripts/prepare-openomsi-wsl.sh` | Raccourcis facultatifs pour une distribution WSL2 dédiée |

Le dépôt exclut `.env`, `bin/`, `content/`, `data/`, `downloads/` et `config/server.cfg`.
Il préserve les fichiers LICENSE, COPYING et les attributions présentes dans les archives officielles.

## Windows — Docker Desktop et disque E:

1. Activer le moteur **WSL2** dans Docker Desktop. Configurer son *Disk image location* sur E: depuis l'interface Docker Desktop avant le téléchargement des images.
2. Conserver une installation complète d'OMSI 2, par exemple `C:\Program Files (x86)\Steam\steamapps\common\OMSI 2`.
3. Copier le jeu dans l'espace de données sur E: (l'installation Steam ne sera pas modifiée) :

```powershell
$lab = 'E:\Projects\openOMSI-Lab'
$deploy = Join-Path $lab 'repos\openOMSI\deployments\local-vps'
& "$deploy\scripts\sync-omsi2.ps1" -Destination "$lab\data\omsi2"
Set-Location $deploy
Copy-Item .env.example .env
Copy-Item config\server.cfg.example config\server.cfg
.\fetch-server.ps1 -Version '0.3.45'
& .\scripts\preflight.ps1
docker compose up -d --build
docker compose ps
Invoke-RestMethod 'http://127.0.0.1:27025/status'
```

Dans `.env`, définir `OMSI_DIR` avec le **chemin réel de la copie** OMSI 2. Exemple : `E:/Projects/openOMSI-Lab/data/omsi2`. Ne pas ajouter ce fichier à Git.

Sous Windows, le launcher openOMSI peut rejoindre `127.0.0.1:27015` depuis **Multijoueur → Serveurs → Ajouter un serveur**.

Si un autre projet utilise déjà les ports 27015 ou 27025, arrêter son serveur ou adapter le Compose ; ne pas arrêter globalement Docker Desktop pour résoudre ce conflit.

## WSL UI sans modification du programme

Il est possible de créer une distribution WSL2 appelée `openOMSI`, stockée par exemple dans `E:\WSL\Distributions\openOMSI`.
**Attention :** une distribution WSL2 et un conteneur Docker Desktop ne sont pas la même chose. WSL UI affiche la distribution ; le serveur réel demeure dans Docker Desktop.

Le script de confort suivant peut être exécuté **uniquement dans une distribution dédiée** :

```bash
sudo bash scripts/prepare-openomsi-wsl.sh /mnt/e/Projects/openOMSI-Lab/repos/openOMSI/deployments/local-vps
```

Il crée un compte Linux `omsi` et les raccourcis `openomsi-compose` et `openomsi-status`. Il n'installe pas Docker et ne démarre rien.

Depuis la distribution intégrée à Docker Desktop :

```bash
openomsi-compose ps
openomsi-compose logs --tail 80 --no-color
openomsi-status
```

Pour arrêter openOMSI sans supprimer les données : `docker compose stop`, puis éventuellement `wsl --terminate openOMSI` depuis Windows. Ne pas arrêter les autres distributions ou conteneurs.

## VPS Ubuntu/Debian x64

```bash
cd deployments/local-vps
cp .env.vps.example .env
cp config/server.cfg.example config/server.cfg
# Installer curl, unzip et sha256sum si nécessaire.
bash fetch-server.sh
# Copier une installation OMSI 2 complète dans /srv/openomsi/omsi2
# puis vérifier OMSI_DIR et les chemins de cartes dans .env et config/server.cfg
docker compose config --quiet
docker compose up -d --build
docker compose ps
curl -fsS http://127.0.0.1:27025/status
```

Dans `.env.vps.example`, le port de jeu est prévu pour un accès distant (`BIND_ADDRESS=0.0.0.0`). Configurer le pare-feu du VPS avant de publier le service. Ne pas exposer l'administration sans VPN ou tunnel SSH.

**Ports :** 27015 UDP (session), 27015 TCP (transferts), 27025 TCP (HTTP/WebSocket). Vérifier les besoins du client et la politique de pare-feu avant d'ouvrir le port HTTP à Internet.

Seules les images et configurations sont recréées sur Linux : ne pas transférer le VHDX de WSL ou de Docker Desktop vers le VPS.

## Saint-Servan

La carte n'est pas fournie par ce dépôt. Le premier test utilise `maps/Grundorf/global.cfg` parce que Grundorf est installé dans OMSI 2 de base.

Après avoir installé Saint-Servan et ses dépendances dans votre jeu Steam :

1. Synchroniser les fichiers du jeu avec `scripts/sync-omsi2.ps1`.
2. Trouver le nom exact du dossier contenant `global.cfg`.
3. Remplacer la directive `map` dans `config/server.cfg`.
4. Exécuter `docker compose restart`, contrôler les logs, le chargement de la carte et la charge CPU/RAM.

## Sauvegardes et sécurité

Sauvegarder au minimum les fichiers `config/server.cfg`, `content/` et `data/`, puis les fichiers OMSI 2 personnels nécessaires. Ne pas conserver de clés ou de données privées dans Git.

Le fichier `LICENSE` du binaire officiel est conservé dans l'image Docker. Les autres fichiers d'attribution et licences du dépôt sont inchangés. Le projet openOMSI et OMSI 2 sont deux logiciels distincts.
