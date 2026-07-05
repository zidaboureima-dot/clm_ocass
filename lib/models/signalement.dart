// models/signalement.dart
enum NiveauUrgence { normal, urgent, critique }
enum StatutSignalement { nouveau, enCours, traite, archive }

const Map<String, String> categoriesSignalement = {
  'rupture_medicaments': 'Rupture de medicaments / intrants',
  'absence_personnel': 'Absence injustifiee du personnel',
  'mauvais_accueil': 'Mauvais accueil / discrimination',
  'paiement_informel': 'Paiement informel exige',
  'infrastructure': 'Infrastructure degradee',
  'refus_soins': 'Refus de prise en charge',
  'qualite_soins': 'Qualite des soins insuffisante',
  'autre': 'Autre dysfonctionnement',
};

const Map<String, List<String>> regionsEtPrefectures = {
  'Boke': ['Boke', 'Boffa', 'Fria', 'Gaoual', 'Koundara'],
  'Conakry': ['Dixinn', 'Gbessia', 'Kagbelen', 'Kaloum', 'Kassa', 'Lambanyi', 'Maneah', 'Matam', 'Matoto', 'Ratoma', 'Sanoyah', 'Sonfonia', 'Tombolia'],
  'Faranah': ['Faranah', 'Dabola', 'Dinguiraye', 'Kissidougou'],
  'Kankan': ['Kankan', 'Kerouane', 'Kouroussa', 'Mandiana', 'Siguiri'],
  'Kindia': ['Kindia', 'Coyah', 'Dubreka', 'Forecariah', 'Telimele'],
  'Labe': ['Labe', 'Koubia', 'Lelouma', 'Mali', 'Tougue'],
  'Mamou': ['Mamou', 'Dalaba', 'Pita'],
  'Nzerekore': ['Nzerekore', 'Beyla', 'Gueckedou', 'Lola', 'Macenta', 'Yomou'],
};

const List<String> prefecturesGuinee = [
  'Boke', 'Boffa', 'Fria', 'Gaoual', 'Koundara',
  'Dixinn', 'Gbessia', 'Kagbelen', 'Kaloum', 'Kassa', 'Lambanyi', 'Maneah', 'Matam', 'Matoto', 'Ratoma', 'Sanoyah', 'Sonfonia', 'Tombolia',
  'Faranah', 'Dabola', 'Dinguiraye', 'Kissidougou',
  'Kankan', 'Kerouane', 'Kouroussa', 'Mandiana', 'Siguiri',
  'Kindia', 'Coyah', 'Dubreka', 'Forecariah', 'Telimele',
  'Labe', 'Koubia', 'Lelouma', 'Mali', 'Tougue',
  'Mamou', 'Dalaba', 'Pita',
  'Nzerekore', 'Beyla', 'Gueckedou', 'Lola', 'Macenta', 'Yomou',
];

class Signalement {
  final String id;
  final String categorieCode;
  final String structureSante;
  final String prefecture;
  final String region;
  final String? commune;
  final NiveauUrgence urgence;
  final String description;
  final String? dateApproximative;
  final DateTime soumisLe;
  final StatutSignalement statut;

  Signalement({
    required this.id,
    required this.categorieCode,
    required this.structureSante,
    required this.prefecture,
    required this.region,
    this.commune,
    required this.urgence,
    required this.description,
    this.dateApproximative,
    required this.soumisLe,
    this.statut = StatutSignalement.nouveau,
  });

  String get categorieLabel => categoriesSignalement[categorieCode] ?? categorieCode;

  String get urgenceLabel {
    switch (urgence) {
      case NiveauUrgence.normal: return 'Normal';
      case NiveauUrgence.urgent: return 'Urgent';
      case NiveauUrgence.critique: return 'Critique';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categorie_code': categorieCode,
      'structure_sante': structureSante,
      'prefecture': prefecture,
      'region': region,
      'commune': commune,
      'urgence': urgence.name,
      'description': description,
      'date_approximative': dateApproximative,
      'soumis_le': soumisLe.toIso8601String(),
      'statut': statut.name,
      'anonyme': true,
    };
  }

  factory Signalement.fromFirestore(String id, Map<String, dynamic> data) {
    return Signalement(
      id: id,
      categorieCode: data['categorie_code'] ?? '',
      structureSante: data['structure_sante'] ?? '',
      prefecture: data['prefecture'] ?? '',
      region: data['region'] ?? '',
      commune: data['commune'],
      urgence: NiveauUrgence.values.firstWhere(
          (e) => e.name == data['urgence'], orElse: () => NiveauUrgence.normal),
      description: data['description'] ?? '',
      dateApproximative: data['date_approximative'],
      soumisLe: DateTime.parse(data['soumis_le'] ?? DateTime.now().toIso8601String()),
      statut: StatutSignalement.values.firstWhere(
          (e) => e.name == data['statut'], orElse: () => StatutSignalement.nouveau),
    );
  }
}