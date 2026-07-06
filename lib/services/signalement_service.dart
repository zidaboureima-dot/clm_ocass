import 'package:flutter/material.dart';
import '../models/signalement.dart';
import '../services/signalement_service.dart';

class SignalementScreen extends StatefulWidget {
  const SignalementScreen({super.key});

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  final prefectureController = TextEditingController();
  final structureController = TextEditingController();
  final descriptionController = TextEditingController();
  
  String _urgenceSelectionnee = 'moyenne';
  String _categorieSelectionnee = '';
  bool _soumettant = false;

  final List<String> prefectures = [
    'Boke', 'Conakry', 'Coyah', 'Dabola', 'Dalaba', 'Dubreka',
    'Forecariah', 'Fria', 'Gaoual', 'Gueckedou', 'Kindia', 'Kissidougou',
    'Koubia', 'Kouroussa', 'Labe', 'Lelouma', 'Mamou', 'Mandiana',
    'Nzerekore', 'Pita', 'Siguiri', 'Telimele', 'Tougue', 'Yomou'
  ];

  final Map<String, String> categories = {
    'rupture_medicaments': 'Rupture de medicaments',
    'absence_personnel': 'Absence injustifiee du personnel',
    'mauvais_accueil': 'Mauvais accueil / discrimination',
    'paiement_informel': 'Paiement informel exige',
    'infrastructure': 'Infrastructure degradee',
    'refus_soins': 'Refus de prise en charge',
    'qualite_soins': 'Qualite des soins insuffisante',
    'autre': 'Autre dysfonctionnement',
  };

  String _obtenirRegionDePrefecture(String prefecture) {
    const regionsEtPrefectures = {
      'Boke': 'Boke', 'Boffa': 'Boke', 'Fria': 'Boke', 'Gaoual': 'Boke', 'Koundara': 'Boke',
      'Conakry': 'Conakry', 'Dixinn': 'Conakry', 'Gbessia': 'Conakry',
      'Faranah': 'Faranah', 'Dabola': 'Faranah', 'Dinguiraye': 'Faranah', 'Kissidougou': 'Faranah',
      'Kankan': 'Kankan', 'Kerouane': 'Kankan', 'Kouroussa': 'Kankan', 'Mandiana': 'Kankan', 'Siguiri': 'Kankan',
      'Kindia': 'Kindia', 'Coyah': 'Kindia', 'Dubreka': 'Kindia', 'Forecariah': 'Kindia', 'Telimele': 'Kindia',
      'Labe': 'Labe', 'Koubia': 'Labe', 'Lelouma': 'Labe', 'Mali': 'Labe', 'Tougue': 'Labe',
      'Mamou': 'Mamou', 'Dalaba': 'Mamou', 'Pita': 'Mamou',
      'Nzerekore': 'Nzerekore', 'Beyla': 'Nzerekore', 'Gueckedou': 'Nzerekore', 'Lola': 'Nzerekore', 'Macenta': 'Nzerekore', 'Yomou': 'Nzerekore',
    };
    return regionsEtPrefectures[prefecture] ?? 'Inconnue';
  }

  Future<void> _soumettre() async {
    if (prefectureController.text.isEmpty ||
        structureController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _categorieSelectionnee.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    setState(() => _soumettant = true);

    try {
      final urgenceEnum = _urgenceSelectionnee == 'haute'
          ? NiveauUrgence.critique
          : _urgenceSelectionnee == 'moyenne'
              ? NiveauUrgence.urgent
              : NiveauUrgence.normal;

      final region = _obtenirRegionDePrefecture(prefectureController.text);

      final sig = Signalement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categorieCode: _categorieSelectionnee,
        structureSante: structureController.text,
        prefecture: prefectureController.text,
        region: region,
        urgence: urgenceEnum,
        description: descriptionController.text,
        soumisLe: DateTime.now(),
      );

      await SignalementService().soumettre(sig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signalement envoye avec succes")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de soumission : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _soumettant = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau signalement"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Localisation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: prefectureController.text.isEmpty ? null : prefectureController.text,
              decoration: const InputDecoration(
                labelText: "Prefecture *",
                border: OutlineInputBorder(),
              ),
              items: prefectures
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => prefectureController.text = v ?? ''),
            ),
            const SizedBox(height: 16),
            const Text(
              "Structure de sante",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: structureController,
              decoration: const InputDecoration(
                labelText: "Nom de l'etablissement *",
                border: OutlineInputBorder(),
              ),
              maxLength: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              "Type de probleme",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categorieSelectionnee.isEmpty ? null : _categorieSelectionnee,
              decoration: const InputDecoration(
                labelText: "Categorie *",
                border: OutlineInputBorder(),
              ),
              items: categories.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _categorieSelectionnee = v ?? ''),
            ),
            const SizedBox(height: 16),
            const Text(
              "Niveau d'urgence",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['basse', 'moyenne', 'haute'].map((u) {
                final couleur = u == 'haute' ? Colors.red : u == 'moyenne' ? Colors.orange : Colors.green;
                return ChoiceChip(
                  label: Text(u.replaceFirst(u[0], u[0].toUpperCase())),
                  selected: _urgenceSelectionnee == u,
                  onSelected: (sel) => setState(() => _urgenceSelectionnee = u),
                  selectedColor: couleur,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Description du probleme",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Decrivez le probleme (20 a 3000 caracteres) *",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 10,
              maxLength: 3000,
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _soumettant ? null : _soumettre,
              child: _soumettant
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Soumettre"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    prefectureController.dispose();
    structureController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
