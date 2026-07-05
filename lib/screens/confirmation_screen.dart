import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'signalement_screen.dart';
import 'tableau_bord_public_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final String referenceId;
  const ConfirmationScreen({super.key, required this.referenceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, size: 22),
          tooltip: 'Accueil',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
        title: const Text('Signalement transmis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppColors.bordure),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: AppColors.vertClair, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, size: 44, color: AppColors.vertPrimaire),
              ),
              const SizedBox(height: 24),
              Text('Signalement transmis',
                  style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Votre signalement a été enregistré de façon anonyme. Il sera analysé par l\'équipe CLM/OCASS.',
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.grisLeger, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text('Référence anonyme',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.grisTexte)),
                  const SizedBox(height: 4),
                  Text(referenceId.substring(0, 8).toUpperCase(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 18,
                          fontWeight: FontWeight.w600, color: AppColors.vertFonce, letterSpacing: 2)),
                ]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const SignalementScreen()), (route) => false),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Nouveau signalement'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TableauBordPublicScreen())),
                icon: const Icon(Icons.bar_chart_outlined, size: 18),
                label: const Text('Voir le tableau de bord public'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
