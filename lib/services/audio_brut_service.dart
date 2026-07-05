import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AudioBrutService {
  static final AudioBrutService _instance = AudioBrutService._internal();

  AudioBrutService._internal();

  factory AudioBrutService() {
    return _instance;
  }

  Future<void> soumettreBrut(String audioPath, String? region) async {
    final docId = FirebaseFirestore.instance
        .collection('clm_audio_bruts')
        .doc()
        .id;

    final Map<String, dynamic> donnees = {
      'audio_path': 'clm_audio_bruts/$docId.m4a',
      'soumis_le': FieldValue.serverTimestamp(),
      'anonyme': false,
      'consentement_vocal_le': FieldValue.serverTimestamp(),
      'region': region,
    };

    final batch = FirebaseFirestore.instance.batch();
    final ref = FirebaseFirestore.instance.collection('clm_audio_bruts').doc(docId);

    batch.set(ref, donnees);

    // Upload audio
    if (audioPath.isNotEmpty) {
      final file = File(audioPath);
      final storagePath = 'clm_audio_bruts/$docId.m4a';
      await FirebaseStorage.instance.ref(storagePath).putFile(file);
    }

    await batch.commit();

    // Nettoyage temp
    try {
      await File(audioPath).delete();
    } catch (_) {}
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAudioBruts() {
    return FirebaseFirestore.instance
        .collection('clm_audio_bruts')
        .orderBy('soumis_le', descending: true)
        .snapshots();
  }

  Future<void> supprimerBrut(String docId, String audioPath) async {
    try {
      await FirebaseStorage.instance.ref(audioPath).delete();
    } catch (_) {}
    await FirebaseFirestore.instance.collection('clm_audio_bruts').doc(docId).delete();
  }
}
