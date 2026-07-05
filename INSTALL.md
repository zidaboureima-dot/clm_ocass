# CLM/OCASS Guinée — Guide d'installation

## Prérequis

- Flutter SDK ≥ 3.0
- Firebase CLI installé (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Accès à la console Firebase du projet Touma Nèda

---

## Étape 1 : Ajouter l'app Android dans la console Firebase

1. Aller dans la console Firebase > projet Touma Nèda
2. Cliquer sur "Ajouter une application" > Android
3. Nom du package Android : `com.sapservices.clm_ocass`
   (à renseigner aussi dans `android/app/build.gradle` > `applicationId`)
4. Télécharger le fichier `google-services.json`
5. Placer `google-services.json` dans `android/app/`

---

## Étape 2 : Configurer FlutterFire

Depuis la racine du projet :

```bash
flutterfire configure \
  --project=<ID_PROJET_FIREBASE_TOUMA_NEDA> \
  --out=lib/firebase_options.dart \
  --platforms=android
```

Cela génère `lib/firebase_options.dart` automatiquement.

---

## Étape 3 : Installer les dépendances

```bash
flutter pub get
```

---

## Étape 4 : Déployer les règles Firestore

```bash
firebase login
firebase use <ID_PROJET_FIREBASE_TOUMA_NEDA>
firebase deploy --only firestore:rules
```

Vérifier dans la console Firebase > Firestore > Règles que le déploiement est actif.

---

## Étape 5 : Configurer les Custom Claims (rôles)

Les rôles `admin` et `point_focal` sont assignés via Firebase Admin SDK
(Cloud Functions ou script Node.js côté serveur).

Exemple de script à exécuter une fois pour créer un admin :

```javascript
// scripts/set_admin.js
const admin = require('firebase-admin');
admin.initializeApp();

async function setAdmin(uid) {
  await admin.auth().setCustomUserClaims(uid, {
    role: 'admin'
  });
  console.log(`UID ${uid} défini comme admin`);
}

async function setPointFocal(uid, prefecture) {
  await admin.auth().setCustomUserClaims(uid, {
    role: 'point_focal',
    prefecture: prefecture
  });
  console.log(`UID ${uid} défini comme point focal de ${prefecture}`);
}

// Exemples d'appel :
// setAdmin('UID_DE_LADMIN');
// setPointFocal('UID_DU_PF', 'Conakry');
```

---

## Étape 6 : Lancer l'application

```bash
flutter run
```

---

## Structure des collections Firestore

```
clm_signalements/          ← signalements anonymes (création publique)
  {uuid}/
    categorie_code: string
    structure_sante: string
    prefecture: string
    commune: string?
    urgence: 'normal' | 'urgent' | 'critique'
    description: string
    date_approximative: string?
    soumis_le: ISO8601 string
    statut: 'nouveau' | 'enCours' | 'traite' | 'archive'
    anonyme: true          ← champ de contrôle obligatoire

clm_agregats/              ← lecture publique, écriture Cloud Functions
  stats_globales/
    total: int
    par_categorie: Map<string, int>
    par_prefecture: Map<string, int>
    mis_a_jour_le: timestamp

clm_points_focaux/         ← gestion des accès
  {uid}/
    nom: string
    prefecture: string
    actif: bool
    cree_le: timestamp
```

---

## Architecture de l'anonymat

L'anonymat est structurel, pas déclaratif. Trois niveaux :

1. **Modèle de données** : aucun champ identifiant (`Signalement.toFirestore()`)
2. **Règles Firestore** : création bloquée si champs `uid`, `email`, `telephone`, `nom` présents
3. **Pas d'appel Firebase Auth** lors de la soumission : le formulaire public ne nécessite aucune connexion

Pour aller plus loin (production) : Cloud Function intermédiaire qui reçoit le signalement via HTTPS, supprime les métadonnées réseau (IP, user-agent), puis écrit dans Firestore via Admin SDK.

---

## Prochaines phases

**Phase 2 — Tableau de bord public (React)**
- Lecture de `clm_agregats` uniquement
- Graphiques recharts par catégorie et préfecture
- Carte Leaflet/OpenStreetMap des préfectures

**Phase 3 — Interface admin (Flutter Web ou React)**
- Authentification Firebase Auth (email/password)
- Liste des signalements avec filtres et statuts
- Export CSV/PDF pour rapports de plaidoyer

**Phase 4 — Points focaux**
- Accès restreint par préfecture via custom claims
- Notifications push (Firebase Cloud Messaging) sur nouveaux signalements de leur zone
