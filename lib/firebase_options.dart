// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// ⚠️ À REMPLIR TOI-MÊME avec les valeurs de TON projet Firebase.
///
/// Comment faire (5 minutes, aucune installation requise) :
/// 1. Va sur https://console.firebase.google.com → "Ajouter un projet"
/// 2. Une fois le projet créé, clique sur l'icône Android pour ajouter une app
///    - Nom du package Android : com.chatmoderne.app
/// 3. Télécharge le fichier "google-services.json" généré
///    → dépose-le dans android/app/google-services.json (remplace le fichier modèle)
/// 4. Dans la console Firebase → Paramètres du projet → tes apps → config SDK,
///    copie les valeurs ci-dessous (apiKey, appId, messagingSenderId, projectId, storageBucket)
/// 5. Active dans la console : Authentication (méthode E-mail/Mot de passe),
///    Firestore Database (mode production), Storage.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return android; // web non utilisé pour l'APK
    if (Platform.isAndroid) return android;
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REMPLACE_MOI_apiKey',
    appId: 'REMPLACE_MOI_appId',
    messagingSenderId: 'REMPLACE_MOI_messagingSenderId',
    projectId: 'REMPLACE_MOI_projectId',
    storageBucket: 'REMPLACE_MOI_projectId.appspot.com',
  );
}
