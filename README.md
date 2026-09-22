# Archives de cours

Site qui affiche, en direct et sans étape de build, un dossier de notes
Markdown exportées d'AppFlowy et synchronisées sur le NAS via Syncthing.
Rendu par [Docsify](https://docsify.js.org) (JS côté client), servi par
Apache avec une protection par mot de passe (Basic Auth).

Contrairement à un site généré statiquement, il n'y a **rien à rebuild** :
déposez un fichier dans le dossier synchronisé, il apparaît sur le site au
prochain rafraîchissement de la page. Le menu de navigation (`_sidebar.md`)
est **régénéré automatiquement** toutes les 15 secondes à partir des fichiers
présents — plus besoin de le maintenir à la main, rien ne peut manquer.

Un second service, **[FileBrowser Quantum](https://github.com/gtsteffaniak/filebrowser)**
(fork activement maintenu du FileBrowser original, archivé début septembre
2026), permet de créer/éditer les `.md` directement depuis le navigateur :
les changements atterrissent dans le même dossier, donc se synchronisent
automatiquement vers votre PC via Syncthing (et inversement).

## Architecture

- `site/` — le shell Docsify (`index.html`), baké dans l'image Docker.
- `notes-seed/` — `README.md` de départ, à copier **une fois** dans votre
  dossier synchronisé (voir plus bas). Pas besoin de `_sidebar.md` : il est
  généré automatiquement par le conteneur.
- Le dossier réel des notes (`notes/`) n'est **pas** dans ce dépôt : c'est un
  volume Docker (lecture-écriture) monté depuis un chemin du NAS, alimenté
  par Syncthing et éditable via FileBrowser.

## Couverture et icône façon Notion

En haut d'un fichier `.md`, ajoutez un bloc comme celui-ci pour afficher une
bannière et une icône en haut de la page :

```md
---
cover: https://images.unsplash.com/photo-xxxxx
icon: 🎓
---

# Le reste de votre note...
```

Les deux champs sont optionnels et indépendants.

## Mise en place sur le NAS (CasaOS)

1. **Installer Syncthing** depuis l'App Store CasaOS (déjà fait si vous avez
   cliqué sur Install).
2. Dans Syncthing, créez un dossier partagé (ex. `archives-notes`) et notez
   son chemin réel sur le NAS (visible dans les paramètres du dossier
   Syncthing, généralement sous `/DATA/AppData/syncthing/...` avec CasaOS).
3. Sur votre PC, installez aussi Syncthing, ajoutez le même dossier partagé,
   et connectez les deux appareils (QR code / ID d'appareil dans l'interface
   Syncthing).
4. Copiez `notes-seed/README.md` dans ce dossier partagé (juste une fois, au
   tout début — c'est la page d'accueil du site).
5. Clonez ce dépôt sur le NAS :

   ```bash
   git clone https://github.com/evomerse/archives.git
   cd archives
   ```

6. Créez `.env` à partir de l'exemple :

   ```bash
   cp .env.example .env
   ```

   Éditez-le avec le vrai chemin Syncthing (`NOTES_PATH`), votre mot de passe
   (`BASIC_AUTH_PASSWORD`) et un port libre (`HOST_PORT`).

7. Lancez :

   ```bash
   docker compose up -d --build
   ```

Le site est alors sur `http://<ip-du-nas>:8091` (lecture) et
`http://<ip-du-nas>:8092` (éditeur FileBrowser), protégés par mot de passe.

**FileBrowser — première connexion** : identifiants par défaut `admin` /
`admin`. Connectez-vous puis changez immédiatement le mot de passe (menu
utilisateur en haut à droite → Settings).

## Ajouter des notes (workflow au quotidien)

Deux façons, au choix :

- **Depuis AppFlowy** : exportez la page en Markdown (menu `...` → **Export**
  → **Markdown**), déposez le fichier dans votre dossier Syncthing local sur
  le PC. Notez que l'export AppFlowy **n'inclut pas** le contenu des
  sous-pages — exportez chaque page qui contient réellement du texte.
- **Depuis le site** : ouvrez FileBrowser (`http://<ip-du-nas>:8092`), créez
  ou éditez un `.md` directement dans le navigateur.

Dans les deux cas, aucune autre étape : pas de commit, pas de rebuild, pas de
`_sidebar.md` à toucher. Le fichier apparaît sur le site (menu inclus) sous
15 secondes, et se synchronise vers votre PC (ou l'inverse) via Syncthing.

## Exposer sur `archives.nasdenoeux.dpdns.org` (tunnel Cloudflare)

Ajoutez une route publique dans la config du tunnel pointant vers
`http://localhost:8091` (ou le port choisi dans `.env`).

## Mettre à jour le site lui-même (shell Docsify, config Apache)

Ce dépôt (`site/`, `Dockerfile`, etc.) ne change pas souvent. En cas de
modification :

```bash
git pull && docker compose up -d --build
```
