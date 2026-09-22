# Archives de cours

Site statique (Astro + [Starlight](https://starlight.astro.build)) publiant des
notes exportées d'AppFlowy, protégé par un mot de passe vérifié côté serveur
(Cloudflare Pages Functions).

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

4. Commit + push → Cloudflare Pages redéploie automatiquement.

## Développement local

```bash
npm install
npm run dev
```

Pour tester l'authentification en local (Cloudflare Pages Functions) :

```bash
cp .dev.vars.example .dev.vars   # puis éditez les valeurs
npm run build
npx wrangler pages dev dist
```

## Déploiement (Cloudflare Pages)

1. Poussez ce dépôt sur GitHub.
2. Dans le [dashboard Cloudflare](https://dash.cloudflare.com/) → **Workers & Pages**
   → **Create application** → **Pages** → **Connect to Git**, sélectionnez le dépôt.
3. Build command : `npm run build` — Output directory : `dist`.
4. Dans **Settings → Environment variables**, ajoutez en tant que **secrets** (pas en clair) :
   - `SITE_PASSWORD` : le mot de passe partagé avec la promo.
   - `AUTH_SECRET` : une longue chaîne aléatoire (sert à signer le cookie de session,
     différente du mot de passe).
5. Dans **Settings → Domains**, ajoutez le domaine personnalisé
   `archives.nasdenoeux.dpdns.org` (le DNS étant déjà sur Cloudflare, le
   sous-domaine est proposé automatiquement).

## Comment marche la protection par mot de passe

`functions/_middleware.js` intercepte chaque requête sur le site :

- si un cookie de session valide (signé par HMAC-SHA256 avec `AUTH_SECRET`) est
  présent, la requête passe ;
- sinon, redirection vers `/login/` où le mot de passe est vérifié côté serveur
  contre `SITE_PASSWORD` (jamais exposé au navigateur) ;
- en cas de succès, un cookie `HttpOnly` + `Secure` valable 30 jours est posé.

Ce n'est pas un système multi-utilisateur : tout le monde partage le même mot
de passe, ce qui est suffisant pour un usage entre camarades de promo.
