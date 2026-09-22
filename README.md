# Archives de cours

Site statique (Astro + [Starlight](https://starlight.astro.build)) publiant des
notes exportées d'AppFlowy, servi par Apache avec une protection par mot de
passe (Basic Auth), dans un conteneur Docker prévu pour tourner sur un NAS.

## Ajouter des notes

1. Dans AppFlowy, ouvrez la page à publier → menu `...` → **Export** → **Markdown**.
2. Placez le fichier `.md` dans `src/content/docs/notes/` (sous-dossiers autorisés,
   par ex. `src/content/docs/notes/reseaux/tp1.md`).
3. Vérifiez que le fichier a un en-tête au minimum comme ceci :

   ```md
   ---
   title: Titre de la note
   ---
   ```

4. Commit + push, puis sur le NAS : `git pull && docker compose up -d --build`.

## Développement local

```bash
npm install
npm run dev
```

## Déploiement sur le NAS (Docker)

1. Clonez le dépôt sur le NAS :

   ```bash
   git clone https://github.com/evomerse/archives.git
   cd archives
   ```

2. Créez le fichier `.env` à partir de l'exemple, changez le mot de passe et
   choisissez un port libre sur le NAS (`8091` par défaut, à adapter si déjà pris) :

   ```bash
   cp .env.example .env
   ```

   ```
   BASIC_AUTH_USER=promo
   BASIC_AUTH_PASSWORD=votre-mot-de-passe
   HOST_PORT=8091
   ```

3. Build + lancement :

   ```bash
   docker compose up -d --build
   ```

   Le site est alors servi sur `http://<ip-du-nas>:8091` (ou le port choisi),
   protégé par une authentification HTTP Basic (le navigateur affiche une
   popup native de connexion — nom d'utilisateur + mot de passe définis
   dans `.env`).

4. Pour mettre à jour après avoir ajouté des notes :

   ```bash
   git pull && docker compose up -d --build
   ```

5. Pour exposer le site sur `archives.nasdenoeux.dpdns.org` via votre tunnel
   Cloudflare existant, ajoutez une route publique dans la config du tunnel
   pointant vers `http://localhost:8091` (ou le port choisi) — le tunnel gère
   déjà le HTTPS et le DNS, il n'y a rien d'autre à configurer côté Apache.

## Alternative sans Docker (Apache existant du NAS)

Si vous préférez ne pas passer par un conteneur, servez directement le dossier
`dist/` (généré par `npm run build`) via l'Apache déjà présent sur le NAS :

```apache
<Directory "/chemin/vers/archives/dist">
    AuthType Basic
    AuthName "Archives de cours"
    AuthUserFile "/chemin/vers/archives/.htpasswd"
    Require valid-user
</Directory>
```

Générez le fichier `.htpasswd` avec :

```bash
htpasswd -c /chemin/vers/archives/.htpasswd promo
```

Il faudra relancer `npm run build` (ou passer par le conteneur ci-dessus, plus
simple) à chaque ajout de note pour régénérer `dist/`.
