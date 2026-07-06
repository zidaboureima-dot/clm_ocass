import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilUtilisateur {
  final String uid;
  final String email;
  final String role;
  final bool actif;

  ProfilUtilisateur({
    required this.uid,
    required this.email,
    required this.role,
    required this.actif,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<User?> connexion(String email, String password) async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deconnexion() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<ProfilUtilisateur?> obtenirProfil(String uid) async {
    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('clm_admins')
          .doc(uid)
          .get();
      if (adminDoc.exists) {
        return ProfilUtilisateur(
          uid: uid,
          email: adminDoc['email'] ?? '',
          role: 'admin',
          actif: adminDoc['actif'] ?? false,
        );
      }

      final supDoc = await FirebaseFirestore.instance
          .collection('clm_superviseurs')
          .doc(uid)
          .get();
      if (supDoc.exists) {
        return ProfilUtilisateur(
          uid: uid,
          email: supDoc['email'] ?? '',
          role: 'superviseur',
          actif: supDoc['actif'] ?? false,
        );
      }

      final pfDoc = await FirebaseFirestore.instance
          .collection('clm_points_focaux')
          .doc(uid)
          .get();
      if (pfDoc.exists) {
        return ProfilUtilisateur(
          uid: uid,
          email: pfDoc['email'] ?? '',
          role: 'point_focal',
          actif: pfDoc['actif'] ?? false,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}