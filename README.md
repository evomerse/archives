# Archives de cours

Site qui affiche, en direct et sans étape de build, un dossier de notes
Markdown exportées d'AppFlowy et synchronisées sur le NAS via Syncthing.
Rendu par [Docsify](https://docsify.js.org) (JS côté client), servi par
Apache avec une protection par mot de passe (Basic Auth).

Contrairement à un site généré statiquement, il n'y a **rien à rebuild** :
déposez un fichier dans le dossier synchronisé, il apparaît sur le site au
prochain rafraîchissement de la page.

## Architecture

- `site/` — le shell Docsify (`index.html`), baké dans l'image Docker.
- `notes-seed/` — `README.md` et `_sidebar.md` de départ, à copier **une
  fois** dans votre dossier synchronisé (voir plus bas).
- Le dossier réel des notes (`notes/`) n'est **pas** dans ce dépôt : c'est un
  volume Docker monté depuis un chemin du NAS, alimenté par Syncthing.

## Mise en place sur le NAS (CasaOS)

1. **Installer Syncthing** depuis l'App Store CasaOS (déjà fait si vous avez
   cliqué sur Install).
2. Dans Syncthing, créez un dossier partagé (ex. `archives-notes`) et notez
   son chemin réel sur le NAS (visible dans les paramètres du dossier
   Syncthing, généralement sous `/DATA/AppData/syncthing/...` avec CasaOS).
3. Sur votre PC, installez aussi Syncthing, ajoutez le même dossier partagé,
   et connectez les deux appareils (QR code / ID d'appareil dans l'interface
   Syncthing).
4. Copiez `notes-seed/README.md` et `notes-seed/_sidebar.md` dans ce dossier
   partagé (juste une fois, au tout début).
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

Le site est alors sur `http://<ip-du-nas>:8091` (ou le port choisi), protégé
par Basic Auth.

## Ajouter des notes (workflow au quotidien)

1. Dans AppFlowy, exportez la page en Markdown (menu `...` → **Export** →
   **Markdown**). Notez que l'export **n'inclut pas** le contenu des
   sous-pages — exportez chaque page qui contient réellement du texte.
2. Déposez le(s) fichier(s) `.md` dans votre dossier Syncthing local (sur
   votre PC) — la sync vers le NAS est automatique.
3. Optionnel : ajoutez une ligne dans `_sidebar.md` (à la racine du dossier
   synchronisé) pour que la note apparaisse dans le menu. Sans ça, le fichier
   reste consultable directement via son URL, juste absent du menu.
4. C'est tout — pas de commit, pas de rebuild. Rafraîchissez le site.

## Exposer sur `archives.nasdenoeux.dpdns.org` (tunnel Cloudflare)

Ajoutez une route publique dans la config du tunnel pointant vers
`http://localhost:8091` (ou le port choisi dans `.env`).

## Mettre à jour le site lui-même (shell Docsify, config Apache)

Ce dépôt (`site/`, `Dockerfile`, etc.) ne change pas souvent. En cas de
modification :

```bash
git pull && docker compose up -d --build
```
