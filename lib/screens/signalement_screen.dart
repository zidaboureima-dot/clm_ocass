import 'package:flutter/material.dart';
import '../models/signalement.dart';
import '../services/signalement_service.dart';

class SignalementScreen extends StatefulWidget {
  const SignalementScreen({super.key});

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  final descriptionController = TextEditingController();
  bool _soumettant = false;

  Future<void> _soumettre() async {
    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir la description")),
      );
      return;
    }

    setState(() => _soumettant = true);

    try {
      final sig = Signalement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categorieCode: 'autre',
        structureSante: 'Non specifie',
        prefecture: 'Non specifie',
        region: 'Non specifie',
        urgence: NiveauUrgence.normal,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Decrivez le dysfonctionnement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description (minimum 20 caracteres)",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 5,
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
    descriptionController.dispose();
    super.dispose();
  }
}