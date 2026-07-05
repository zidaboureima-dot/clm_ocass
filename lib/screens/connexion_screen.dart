// screens/connexion_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin/admin_shell.dart';
import 'point_focal/point_focal_shell.dart';
import 'superviseur/superviseur_shell.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  final _authService = AuthService();

  bool _chargement = false;
  bool _mdpVisible = false;
  String? _erreur;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _chargement = true; _erreur = null; });

    try {
      final profil = await _authService.connexion(
        email: _emailCtrl.text,
        motDePasse: _mdpCtrl.text,
      );

      if (!mounted) return;

      if (profil == null || profil.role == RoleUtilisateur.inconnu) {
        setState(() {
          _erreur = 'Aucun rôle assigné à ce compte. Contactez l\'administrateur.';
          _chargement = false;
        });
        await _authService.deconnexion();
        return;
      }

      if (profil.estAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminShell(profil: profil)),
        );
      } else if (profil.estSuperviseur) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuperviseurShell(profil: profil),
          ),
        );
      } else if (profil.estPointFocal) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => PointFocalShell(profil: profil)),
        );
      }
    } on Exception catch (e) {
      final msg = e.toString();
      setState(() {
        _erreur = msg.contains('wrong-password') || msg.contains('user-not-found')
            ? 'Identifiant ou mot de passe incorrect.'
            : msg.contains('too-many-requests')
                ? 'Trop de tentatives. Réessayez dans quelques minutes.'
                : 'Erreur de connexion. Vérifiez votre réseau.';
        _chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // En-tête
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.vertClair,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 26, color: AppColors.vertFonce),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CLM/OCASS',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Accès restreint',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text('Connexion',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Réservé aux administrateurs et points focaux autorisés.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        prefixIcon: Icon(Icons.email_outlined,
                            size: 20, color: AppColors.grisTexte),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email invalide'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mdpCtrl,
                      obscureText: !_mdpVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _seConnecter(),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: AppColors.grisTexte),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mdpVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.grisTexte,
                          ),
                          onPressed: () =>
                              setState(() => _mdpVisible = !_mdpVisible),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mot de passe trop court'
                          : null,
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rougeClair,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.rouge, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(_erreur!,
                                  style: const TextStyle(
                                      color: AppColors.rouge, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _chargement
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.vertPrimaire),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _seConnecter,
                            child: const Text('Se connecter'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _reinitialiserMdp(),
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grisLeger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Droits par rôle',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.grisTexte)),
                    const SizedBox(height: 8),
                    _ligneRole(Icons.admin_panel_settings_outlined, 'Administrateur',
                        'Accès complet, gestion, export rapport'),
                    const SizedBox(height: 6),
                    _ligneRole(Icons.person_outline, 'Point focal',
                        'Signalements de sa préfecture uniquement'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ligneRole(IconData icon, String titre, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grisTexte),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 13, color: AppColors.grisTexte, height: 1.4),
              children: [
                TextSpan(
                    text: '$titre : ',
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _reinitialiserMdp() {
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Entrez votre email ci-dessus pour réinitialiser'),
          backgroundColor: AppColors.ambre,
        ),
      );
      return;
    }
    AuthService()
        .reinitialiserMotDePasse(_emailCtrl.text)
        .then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de réinitialisation envoyé'),
          backgroundColor: AppColors.vertPrimaire,
        ),
      );
    });
  }
}
