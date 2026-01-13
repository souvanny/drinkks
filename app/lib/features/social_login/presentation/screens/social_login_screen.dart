import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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
  bool _showMethods = false;

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSigningIn) return;

    setState(() {
      _isGoogleSigningIn = true;
      _errorMessage = null;
    });

    try {
      print('🔵 Début de la connexion Google...');
      await ref.read(socialLoginControllerProvider.notifier).signInWithGoogle();
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
          return 'Erreur réseau. Vérifiez votre connexion';
        default:
          return 'Erreur: ${error.message ?? error.code}';
      }
    }
    return 'Erreur de connexion. Veuillez réessayer.';
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

    // Palette de couleurs pour l'ambiance Drinkks
    const primaryColor = Color(0xFF6366F1); // Indigo doux
    const backgroundColor = Color(0xFF0F0F23); // Noir bleuté profond
    const surfaceColor = Color(0xFF1A1A2E); // Surface légèrement plus claire
    const accentColor = Color(0xFF8B5CF6); // Violet accent
    const textPrimary = Colors.white;
    const textSecondary = Color(0xFF94A3B8); // Gris bleuté

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Espace en haut
                const SizedBox(height: 40),

                // Logo et nom d'application animé
                _buildLogoHeader(primaryColor, accentColor),

                // Espacement
                const SizedBox(height: 48),

                // Message d'accueil
                _buildWelcomeText(textPrimary, textSecondary),

                // Espacement
                const SizedBox(height: 48),

                // Bouton Google principal
                _buildGoogleSignInButton(primaryColor, textPrimary),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  _buildErrorMessage(_errorMessage!, accentColor),
                ],

                // Séparateur élégant
                const SizedBox(height: 40),
                _buildDivider(textSecondary),

                // Bouton pour voir les autres méthodes
                if (!_showMethods) ...[
                  const SizedBox(height: 24),
                  _buildShowMethodsButton(textSecondary, accentColor),
                ],

                // Liste des autres méthodes
                if (_showMethods)
                  _buildOtherMethodsSection(
                    socialLoginState,
                    surfaceColor,
                    textPrimary,
                    textSecondary,
                    accentColor,
                  ),

                // Conditions d'utilisation
                const SizedBox(height: 40),
                _buildTermsAndPrivacy(textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLogoHeader(Color primaryColor, Color accentColor) {
    return Column(
      children: [
        // Logo animé (cercle avec effet de vague) - CLIQUEZ ICI !
        InkWell(
          onTap: () {
            // Navigation temporaire vers /venues
            print('🎬 Clic sur logo - Accès temporaire à /venues');
            context.go('/venues');
          },
          borderRadius: BorderRadius.circular(60),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.5, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Effet de vague extérieur
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),

                // Cercle intérieur avec icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        accentColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.videocam,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Nom de l'application avec effet de gradient
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryColor, accentColor],
            ).createShader(bounds);
          },
          child: Text(
            'Drinkks',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),

        // Tagline
        const SizedBox(height: 8),
        Text(
          'Visio • Social • Instantané',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rejoignez la conversation',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Prenez place à une table virtuelle, ',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              TextSpan(
                text: 'discutez en visio',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              TextSpan(
                text: ' et créez des connexions authentiques.',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(Color primaryColor, Color textPrimary) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isGoogleSigningIn
            ? null
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            const Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: _isGoogleSigningIn
            ? []
            : [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isGoogleSigningIn ? null : _signInWithGoogle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _isGoogleSigningIn
                  ? [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Connexion en cours...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ]
                  : [
                Image.asset(
                  'assets/images/logos/google-signin-logo_100_100.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: textPrimary,
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  'Continuer avec Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color textSecondary) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: textSecondary.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: textSecondary.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildShowMethodsButton(Color textSecondary, Color accentColor) {
    return TextButton(
      onPressed: () {
        setState(() {
          _showMethods = true;
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Autres méthodes de connexion',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethodsSection(
      AsyncValue<List<SocialLoginEntity>> socialLoginState,
      Color surfaceColor,
      Color textPrimary,
      Color textSecondary,
      Color accentColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Bientôt disponible',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nous travaillons à ajouter d\'autres options de connexion',
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        socialLoginState.when(
          data: (socialLogins) {
            final otherMethods = socialLogins
                .where((method) => method.id.toLowerCase() != 'google')
                .toList();

            if (otherMethods.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Plus d\'options arrivent bientôt...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return Column(
              children: otherMethods.map((method) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getColorForMethod(method.id).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForMethod(method.id),
                        color: _getColorForMethod(method.id),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      method.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Disponible prochainement',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Bientôt',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      _showComingSoonSnackbar(method.name);
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            ),
          ),
          error: (err, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Impossible de charger les autres méthodes',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
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

  Widget _buildTermsAndPrivacy(Color textSecondary) {
    return Column(
      children: [
        Text(
          'En vous connectant, vous acceptez nos',
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers les CGU
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Conditions d\'utilisation',
                style: TextStyle(
                  color: textSecondary.withOpacity(0.8),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' et ',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers la politique de confidentialité
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Politique de confidentialité',
                style: TextStyle(
                  color: textSecondary.withOpacity(0.8),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoonSnackbar(String methodName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$methodName sera disponible prochainement !',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
        return Colors.white;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.lightBlue;
      case 'email':
        return Colors.green;
      case 'phone':
        return Colors.purple;
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}