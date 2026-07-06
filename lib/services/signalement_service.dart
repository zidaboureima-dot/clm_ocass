import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signalement.dart';

class SignalementService {
  static final SignalementService _instance = SignalementService._internal();

  SignalementService._internal();

  factory SignalementService() {
    return _instance;
  }

  Future<String> soumettre(Signalement signalement) async {
    final Map<String, dynamic> donnees = {
      'categorie_code': signalement.categorieCode,
      'structure_sante': signalement.structureSante,
      'prefecture': signalement.prefecture,
      'region': signalement.region,
      'commune': signalement.commune,
      'urgence': signalement.urgence.name,
      'description': signalement.description,
      'date_approximative': signalement.dateApproximative,
      'soumis_le': FieldValue.serverTimestamp(),
      'statut': 'nouveau',
      'anonyme': true,
      'a_note_vocale': false,
      'audio_path': null,
      'consentement_vocal_le': null,
    };

    await FirebaseFirestore.instance
        .collection('clm_signalements')
        .doc(signalement.id)
        .set(donnees);

    return signalement.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTous() {
    return FirebaseFirestore.instance
        .collection('clm_signalements')
        .snapshots();
  }

  Future<int> compterParCategorie(String categorie) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clm_signalements')
        .where('categorie_code', isEqualTo: categorie)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> compterParPrefecture(String prefecture) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clm_signalements')
        .where('prefecture', isEqualTo: prefecture)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}