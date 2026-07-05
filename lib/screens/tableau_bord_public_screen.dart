import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/signalement.dart';

class TableauBordPublicScreen extends StatelessWidget {
  const TableauBordPublicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tableau de bord public'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppColors.bordure),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clm_stats_publiques')
            .doc('global')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.vertPrimaire));
          }
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          final total = data['total'] ?? 0;
          final mois = data['total_mois'] ?? 0;
          final traites = data['total_traites'] ?? 0;
    	  final urgents = data['urgents_non_traites'] ?? 0;
          final parCategorie = Map<String, dynamic>.from(data['par_categorie'] ?? {});
          final parPrefecture = Map<String, dynamic>.from(data['par_prefecture'] ?? {});

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metriques
                Row(children: [
                  _metrique('Total', '$total', AppColors.vertPrimaire, Icons.inventory_2_outlined),
                  const SizedBox(width: 12),
                  _metrique('Urgents', '$urgents', AppColors.rouge, 		Icons.warning_amber_outlined),
                  const SizedBox(width: 12),
                  _metrique('Traites', '$traites', AppColors.ambre, Icons.check_circle_outline),
                ]),
                const SizedBox(height: 24),

                // Par categorie
                _titreSection('Par objet de signalement'),
                const SizedBox(height: 10),
                parCategorie.isEmpty
                    ? _vide('Aucun signalement recu pour le moment.')
                    : _buildBars(parCategorie, AppColors.vertPrimaire, categoriesSignalement),
                const SizedBox(height: 24),

                // Par prefecture
                _titreSection('Par prefecture'),
                const SizedBox(height: 10),
                parPrefecture.isEmpty
                    ? _vide('Aucune donnee disponible.')
                    : _buildBarsPrefecture(parPrefecture, AppColors.bleu),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.grisLeger, borderRadius: BorderRadius.circular(10)),
                  child: const Row(children: [
                    Icon(Icons.shield_outlined, size: 16, color: AppColors.grisTexte),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Donnees agregees anonymes. Aucun signalement individuel n\'est accessible au public.',
                      style: TextStyle(fontSize: 12, color: AppColors.grisTexte, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBars(Map<String, dynamic> data, Color couleur, Map<String, String> labels) {
    final entries = data.entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int));
    final max = entries.first.value as int;
    final total = entries.fold(0, (s, e) => s + (e.value as int));
    return Column(
      children: entries.map((e) => _ligneBar(
        labels[e.key] ?? e.key, e.value as int, max, total, couleur)).toList(),
    );
  }

  Widget _buildBarsPrefecture(Map<String, dynamic> data, Color couleur) {
    final entries = data.entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int));
    final max = entries.first.value as int;
    final total = entries.fold(0, (s, e) => s + (e.value as int));
    return Column(
      children: entries.map((e) => _ligneBar(e.key, e.value as int, max, total, couleur)).toList(),
    );
  }

  Widget _titreSection(String titre) {
    return Text(titre.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grisTexte, letterSpacing: 0.06));
  }

  Widget _metrique(String label, String valeur, Color couleur, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.bordure, width: 0.5)),
        child: Column(children: [
          Icon(icon, size: 18, color: couleur),
          const SizedBox(height: 4),
          Text(valeur, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: couleur)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grisTexte), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _ligneBar(String label, int count, int max, int total, Color couleur) {
    final ratio = max > 0 ? count / max : 0.0;
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('$count ($pct%)', style: const TextStyle(fontSize: 12, color: AppColors.grisTexte)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: ratio, minHeight: 7,
            backgroundColor: AppColors.grisLeger,
            valueColor: AlwaysStoppedAnimation<Color>(couleur))),
      ]),
    );
  }

  Widget _vide(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.grisLeger, borderRadius: BorderRadius.circular(10)),
      child: Text(message, style: const TextStyle(fontSize: 13, color: AppColors.grisTexte)),
    );
  }
}
