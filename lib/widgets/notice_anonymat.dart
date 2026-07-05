// widgets/notice_anonymat.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NoticeAnonyme extends StatelessWidget {
  const NoticeAnonyme({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.vertClair,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.vertPrimaire.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined,
              color: AppColors.vertFonce, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signalement entièrement anonyme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.vertFonce,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aucune information permettant de vous identifier '
                  '(nom, téléphone, adresse IP, localisation GPS) n\'est collectée '
                  'ni conservée. Vous pouvez soumettre en toute sécurité.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.vertFonce.withOpacity(0.8),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeUrgence extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const BadgeUrgence({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory BadgeUrgence.normal() => const BadgeUrgence(
        label: 'Normal',
        backgroundColor: AppColors.grisLeger,
        textColor: AppColors.grisTexte,
      );

  factory BadgeUrgence.urgent() => const BadgeUrgence(
        label: 'Urgent',
        backgroundColor: AppColors.ambreClair,
        textColor: AppColors.ambre,
      );

  factory BadgeUrgence.critique() => const BadgeUrgence(
        label: 'Critique',
        backgroundColor: AppColors.rougeClair,
        textColor: AppColors.rouge,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.grisTexte,
              letterSpacing: 0.06,
            ),
      ),
    );
  }
}
