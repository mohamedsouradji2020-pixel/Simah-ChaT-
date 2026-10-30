# ChatModerne 💬

Application de messagerie moderne (Flutter + Firebase) : chat en temps réel, groupes, photos, statut en ligne, indicateur "écrit...", accusés de réception.

## 🚀 Obtenir ton APK (sans rien installer sur ton téléphone)

Tu auras besoin uniquement d'un **compte Google** et d'un **compte GitHub** (gratuits).

### Étape 1 — Créer le projet Firebase (backend de l'app)
1. Va sur **https://console.firebase.google.com**
2. Clique sur **"Ajouter un projet"**, nomme-le (ex: `chatmoderne`), continue jusqu'à la création.
3. Dans le menu de gauche → **Build → Authentication** → onglet "Sign-in method" → active **E-mail/Mot de passe**.
4. Menu de gauche → **Build → Firestore Database** → **Créer une base de données** → mode **production** → choisis une région proche (ex: `eur3`).
5. Menu de gauche → **Build → Storage** → **Commencer** → mode production.
6. Sur la page d'accueil du projet, clique l'icône **Android** pour ajouter une app :
   - Nom du package : `com.chatmoderne.app`
   - Télécharge le fichier **`google-services.json`**

### Étape 2 — Remplacer les fichiers de config
1. Remplace `android/app/google-services.json` par celui que tu viens de télécharger.
2. Ouvre `lib/firebase_options.dart` et remplace les valeurs `REMPLACE_MOI_...` par celles visibles dans :
   **Paramètres du projet Firebase (⚙️) → onglet "Général" → section "Vos applications" → config SDK**

### Étape 3 — Publier les règles de sécurité
Dans la console Firebase :
- **Firestore Database → Règles** → colle le contenu de `firestore.rules` → Publier
- **Storage → Règles** → colle le contenu de `storage.rules` → Publier

### Étape 4 — Pousser le projet sur GitHub
1. Crée un nouveau dépôt sur **github.com** (public ou privé), par exemple `chatmoderne`.
2. Depuis un ordinateur (ou l'interface web GitHub "upload files" si tu n'as que ton téléphone) :
   - Si tu as un terminal :
     ```
     git init
     git add .
     git commit -m "ChatModerne v1"
     git branch -M main
     git remote add origin https://github.com/TON-COMPTE/chatmoderne.git
     git push -u origin main
     ```
   - Sinon : sur la page du dépôt GitHub, clique **"Add file" → "Upload files"**, glisse TOUT le contenu du dossier `chatmoderne`, et valide ("Commit changes").

### Étape 5 — Récupérer l'APK compilé automatiquement
1. Sur GitHub, va dans l'onglet **"Actions"** de ton dépôt.
2. Le workflow **"Build APK"** se lance tout seul après ton push (≈5-8 minutes).
3. Une fois terminé (coche verte ✅), clique dessus → en bas, section **"Artifacts"** → télécharge **`chatmoderne-apk`**.
4. Dézippe, installe `app-release.apk` sur ton téléphone Android (autorise "sources inconnues" si demandé).

👉 Si le workflow échoue (croix rouge ❌), c'est presque toujours parce que l'étape 2 n'a pas été faite correctement — vérifie que `google-services.json` et `firebase_options.dart` contiennent bien TES vraies valeurs, pas les placeholders.

## 📱 Fonctionnalités incluses (v1)
- Inscription / connexion par e-mail
- Liste des conversations en temps réel
- Chat 1-to-1 : texte, photos, indicateur "écrit...", accusés ✓✓
- Statut en ligne / dernière connexion
- Création de groupes (structure prête, écran de gestion à étoffer)

## 🔜 Pour la suite (v2)
- Appels audio/vidéo
- Stories/Statuts éphémères
- Messages vocaux + transcription
- Résumé IA de conversation
- Mode multi-device

## 🛠️ Développer en local (si tu as un PC)
```bash
flutter pub get
flutter run
```
Pour générer l'APK toi-même :
```bash
flutter build apk --release
```
L'APK sera dans `build/app/outputs/flutter-apk/app-release.apk`.
