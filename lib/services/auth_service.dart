import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RoleUtilisateur { admin, superviseur, pointFocal, inconnu }

class ProfilUtilisateur {
  final String uid;
  final String email;
  final RoleUtilisateur role;
  final String? nom;
  final String? prefecture;
  final List<String> regionsCouvertes;
  final List<String> prefecturesCouvertes;

  const ProfilUtilisateur({
    required this.uid,
    required this.email,
    required this.role,
    this.nom,
    this.prefecture,
    this.regionsCouvertes = const [],
    this.prefecturesCouvertes = const [],
  });

  bool get estAdmin => role == RoleUtilisateur.admin;
  bool get estSuperviseur => role == RoleUtilisateur.superviseur;
  bool get estPointFocal => role == RoleUtilisateur.pointFocal;

  String get roleLabel {
    switch (role) {
      case RoleUtilisateur.admin: return 'Administrateur';
      case RoleUtilisateur.superviseur: return 'Superviseur';
      case RoleUtilisateur.pointFocal: return 'Point focal';
      case RoleUtilisateur.inconnu: return 'Role non defini';
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get utilisateurCourant => _auth.currentUser;
  bool get estConnecte => _auth.currentUser != null;
  Stream<User?> get fluxEtat => _auth.authStateChanges();

  Future<ProfilUtilisateur?> connexion({required String email, required String motDePasse}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: motDePasse);
    final user = credential.user;
    if (user == null) return null;
    return await _construireProfil(user);
  }

  Future<void> deconnexion() async {
    await _auth.signOut();
  }

  Future<ProfilUtilisateur?> profilCourant() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _construireProfil(user);
  }

  Future<ProfilUtilisateur> _construireProfil(User user) async {
    final email = user.email?.toLowerCase().trim() ?? '';

    // 1. Admin
    try {
      final adminDoc = await _db.collection('clm_admins').doc(user.uid).get();
      if (adminDoc.exists) {
        final data = adminDoc.data() ?? {};
        final actif = data['actif'] as bool? ?? false;
        if (actif) {
          return ProfilUtilisateur(
            uid: user.uid,
            email: email,
            role: RoleUtilisateur.admin,
            nom: data['nom'] as String?,
          );
        }
      }
    } catch (_) {}

    // 2. Superviseur
    try {
      final supDoc = await _db.collection('clm_superviseurs').doc(user.uid).get();
      if (supDoc.exists) {
        final data = supDoc.data() ?? {};
        final actif = data['actif'] as bool? ?? false;
        if (actif) {
          return ProfilUtilisateur(
            uid: user.uid,
            email: email,
            role: RoleUtilisateur.superviseur,
            nom: data['nom'] as String?,
            regionsCouvertes: List<String>.from(data['regions_couvertes'] ?? []),
          );
        }
      }
    } catch (_) {}

    // 3. Point focal
    try {
      final snap = await _db.collection('clm_points_focaux')
          .where('email', isEqualTo: email)
          .where('actif', isEqualTo: true)
          .limit(1).get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        return ProfilUtilisateur(
          uid: user.uid,
          email: email,
          role: RoleUtilisateur.pointFocal,
          nom: data['nom'] as String?,
          prefecture: data['prefecture'] as String?,
          prefecturesCouvertes: List<String>.from(data['prefectures_couvertes'] ?? []),
        );
      }
    } catch (_) {}

    return ProfilUtilisateur(uid: user.uid, email: email, role: RoleUtilisateur.inconnu);
  }

  Future<void> reinitialiserMotDePasse(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
