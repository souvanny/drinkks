import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/social_login_entity.dart';
import '../controllers/social_login_controller.dart';

class SocialLoginScreen extends ConsumerStatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  ConsumerState<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends ConsumerState<SocialLoginScreen> {
  bool _isGoogleSigningIn = false;
  String? _errorMessage;
  bool _showMethods = false; // Pour afficher/masquer les autres méthodes

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSigningIn) return;

    setState(() {
      _isGoogleSigningIn = true;
      _errorMessage = null;
    });

    try {
      print('🔵 Début de la connexion Google...');

      // Appeler la méthode signInWithGoogle du controller
      final user = await ref
          .read(socialLoginControllerProvider.notifier)
          .signInWithGoogle();

      // if (user != null) {
      //   print('✅ Connexion Google réussie: ${user.email}');
      //
      //   // Afficher un message de succès
      //   _showSuccessMessage(user);
      //
      //   // Naviguer vers l'écran d'accueil après un délai
      //   await Future.delayed(const Duration(seconds: 1));
      //
      //   // TODO: Décommenter pour la navigation
      //   // Navigator.pushReplacementNamed(context, '/home');
      //
      // } else {
      //   print('⚠️ Connexion Google annulée par l\'utilisateur');
      //   setState(() {
      //     _errorMessage = 'Connexion annulée';
      //   });
      // }
    } catch (e) {
      print('❌ Erreur Google Sign-In: $e');
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
      });
      _showErrorSnackbar(e);
    } finally {
      setState(() {
        _isGoogleSigningIn = false;
      });
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'popup-closed-by-user':
          return 'Connexion annulée';
        case 'network-request-failed':
          return 'Erreur réseau. Vérifiez votre connexion Internet';
        case 'account-exists-with-different-credential':
          return 'Un compte existe déjà avec cet email';
        case 'user-disabled':
          return 'Ce compte a été désactivé';
        case 'user-not-found':
          return 'Compte non trouvé';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'invalid-email':
          return 'Email invalide';
        default:
          return 'Erreur: ${error.message ?? error.code}';
      }
    }
    return 'Erreur de connexion. Veuillez réessayer.';
  }

  void _showSuccessMessage(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bienvenue ${user.displayName ?? user.email} !',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getUserFriendlyError(error)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socialLoginState = ref.watch(socialLoginControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drinkks'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo amélioré
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_drink,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Titre
                Text(
                  'Bienvenue sur Drinkks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  'Connectez-vous pour découvrir nos boissons',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Bouton Google Sign-In
                _buildGoogleSignInButton(),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Bouton pour voir les autres méthodes
                if (!_showMethods)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showMethods = true;
                      });
                    },
                    child: Text(
                      'Voir d\'autres méthodes',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                // Liste des autres méthodes (seulement si showMethods = true)
                if (_showMethods)
                  _buildOtherMethodsSection(socialLoginState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGoogleSigningIn ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isGoogleSigningIn
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Connexion en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône Google depuis assets
            Image.asset(
              'assets/images/logos/google-signin-logo_100_100.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                // Fallback si l'image n'est pas trouvée
                return Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Colors.red,
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Continuer avec Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethodsSection(
      AsyncValue<List<SocialLoginEntity>> socialLoginState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Autres méthodes de connexion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        socialLoginState.when(
          data: (socialLogins) {
            // Filtrer pour ne pas afficher Google si on veut
            final otherMethods = socialLogins
                .where((method) => method.id.toLowerCase() != 'google')
                .toList();

            if (otherMethods.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucune autre méthode disponible pour le moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children: otherMethods.map((method) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorForMethod(method.id).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForMethod(method.id),
                        color: _getColorForMethod(method.id),
                      ),
                    ),
                    title: Text(
                      method.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('Connectez-vous avec ${method.name}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _showComingSoonSnackbar(method.name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getColorForMethod(method.id),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Bientôt'),
                    ),
                    onTap: () {
                      _showComingSoonSnackbar(method.name);
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Impossible de charger les autres méthodes',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoonSnackbar(String methodName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$methodName sera disponible prochainement !'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper methods
  IconData _getIconForMethod(String methodId) {
    switch (methodId.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.flutter_dash;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.login;
    }
  }

  Color _getColorForMethod(String methodId) {
    switch (methodId.toLowerCase()) {
      case 'google':
        return const Color(0xFFEA4335);
      case 'apple':
        return Colors.black;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.lightBlue;
      case 'email':
        return Colors.green;
      case 'phone':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}