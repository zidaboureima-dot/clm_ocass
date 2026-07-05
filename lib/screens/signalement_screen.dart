// screens/signalement_screen.dart
// Écran cœur métier. Pas d'authentification requise, accessible à tous.
// Aucun champ identifiant dans le formulaire.

import 'package:flutter/material.dart';
import '../models/signalement.dart';
import '../services/signalement_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notice_anonymat.dart';
import 'confirmation_screen.dart';

class SignalementScreen extends StatefulWidget {
  const SignalementScreen({super.key});

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SignalementService();

  // Contrôleurs
  final _structureCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  // Valeurs sélectionnées
  String? _categorieCode;
  String? _prefecture;
  NiveauUrgence _urgence = NiveauUrgence.normal;

  bool _enSoumission = false;
  int _etapeActuelle = 0; // Stepper 0-2

  @override
  void dispose() {
    _structureCtrl.dispose();
    _descriptionCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enSoumission = true);

    try {
      final id = await _service.soumettre(
        categorieCode: _categorieCode!,
        structureSante: _structureCtrl.text.trim(),
        prefecture: _prefecture!,
        urgence: _urgence,
        description: _descriptionCtrl.text.trim(),
        dateApproximative: _dateCtrl.text.trim().isEmpty
            ? null
            : _dateCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(referenceId: id),
        ),
      );
    } catch (e) {
      setState(() => _enSoumission = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de soumission : $e'),
          backgroundColor: AppColors.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.vertClair,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.vertFonce),
            ),
            const SizedBox(width: 10),
            const Text('CLM/OCASS Guinée'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppColors.bordure),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _etapeActuelle,
          onStepContinue: () {
            if (_etapeActuelle == 0) {
              if (_categorieCode == null || _prefecture == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complétez tous les champs obligatoires'),
                    backgroundColor: AppColors.ambre,
                  ),
                );
                return;
              }
              setState(() => _etapeActuelle = 1);
            } else if (_etapeActuelle == 1) {
              if (_structureCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Indiquez la structure de santé concernée'),
                    backgroundColor: AppColors.ambre,
                  ),
                );
                return;
              }
              setState(() => _etapeActuelle = 2);
            } else {
              _soumettre();
            }
          },
          onStepCancel: () {
            if (_etapeActuelle > 0) {
              setState(() => _etapeActuelle--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  if (_etapeActuelle == 2)
                    _enSoumission
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.vertPrimaire))
                        : ElevatedButton.icon(
                            onPressed: details.onStepContinue,
                            icon: const Icon(Icons.send_outlined, size: 18),
                            label: const Text('Soumettre le signalement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vertFonce,
                            ),
                          )
                  else
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_etapeActuelle == 0
                          ? 'Continuer'
                          : 'Continuer'),
                    ),
                  if (_etapeActuelle > 0) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Retour'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // ÉTAPE 1 : Classification
            Step(
              title: const Text('Classification'),
              subtitle: const Text('Objet et localité'),
              isActive: _etapeActuelle >= 0,
              state: _etapeActuelle > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NoticeAnonyme(),
                  const SizedBox(height: 20),
                  const SectionLabel('Objet du signalement *'),
                  DropdownButtonFormField<String>(
                    value: _categorieCode,
                    decoration: const InputDecoration(
                      hintText: 'Choisir une catégorie',
                    ),
                    items: categoriesSignalement.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _categorieCode = v),
                    validator: (v) =>
                        v == null ? 'Sélectionnez une catégorie' : null,
                  ),
                  const SizedBox(height: 16),
                  const SectionLabel('Préfecture / Commune *'),
                  DropdownButtonFormField<String>(
                    value: _prefecture,
                    decoration: const InputDecoration(
                      hintText: 'Localité du signalement',
                    ),
                    items: prefecturesGuinee
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p,
                                  style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _prefecture = v),
                    validator: (v) =>
                        v == null ? 'Sélectionnez une préfecture' : null,
                  ),
                  const SizedBox(height: 16),
                  const SectionLabel('Niveau d\'urgence'),
                  _urgenceSelector(),
                ],
              ),
            ),

            // ÉTAPE 2 : Structure concernée
            Step(
              title: const Text('Structure de santé'),
              subtitle: const Text('Établissement concerné'),
              isActive: _etapeActuelle >= 1,
              state: _etapeActuelle > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Nom de l\'établissement *'),
                  TextFormField(
                    controller: _structureCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Centre de santé, hôpital, dispensaire...',
                      prefixIcon: Icon(Icons.local_hospital_outlined,
                          color: AppColors.vertPrimaire, size: 20),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Indiquez la structure concernée'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const SectionLabel('Date approximative (optionnel)'),
                  TextFormField(
                    controller: _dateCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ex. : début juin 2025, semaine dernière...',
                      prefixIcon: Icon(Icons.calendar_today_outlined,
                          color: AppColors.grisTexte, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // ÉTAPE 3 : Description
            Step(
              title: const Text('Description'),
              subtitle: const Text('Détail du dysfonctionnement'),
              isActive: _etapeActuelle >= 2,
              state: StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.ambreClair,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.ambre, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ne mentionnez pas votre nom, téléphone '
                            'ou toute information vous identifiant.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.ambre),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionLabel('Description du dysfonctionnement *'),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Décrivez la situation observée : quoi, quand, '
                          'qui était concerné (sans nommer les victimes), '
                          'conséquences observées...',
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) {
                      if (v == null || v.trim().length < 20) {
                        return 'Description trop courte (20 caractères minimum)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _recapitulatif(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _urgenceSelector() {
    final options = [
      (NiveauUrgence.normal, 'Normal', AppColors.grisTexte, AppColors.grisLeger),
      (NiveauUrgence.urgent, 'Urgent', AppColors.ambre, AppColors.ambreClair),
      (NiveauUrgence.critique, 'Critique', AppColors.rouge, AppColors.rougeClair),
    ];

    return Row(
      children: options.map((opt) {
        final (niveau, label, textColor, bgColor) = opt;
        final selected = _urgence == niveau;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _urgence = niveau),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(
                  right: niveau != NiveauUrgence.critique ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? bgColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? textColor : AppColors.bordure,
                  width: selected ? 1.5 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected ? textColor : AppColors.grisTexte,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _recapitulatif() {
    if (_categorieCode == null || _prefecture == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisLeger,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.grisTexte)),
          const SizedBox(height: 8),
          _ligneRecap(Icons.category_outlined,
              categoriesSignalement[_categorieCode!] ?? ''),
          _ligneRecap(Icons.place_outlined, _prefecture!),
          _ligneRecap(
              Icons.local_hospital_outlined, _structureCtrl.text.trim()),
          _ligneRecap(
              Icons.warning_amber_outlined, _urgence.name.capitalize()),
        ],
      ),
    );
  }

  Widget _ligneRecap(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.grisTexte),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.grisTexte)),
          ),
        ],
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
