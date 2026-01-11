import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/social_login_controller.dart';

class SocialLoginScreen extends ConsumerWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialLoginState = ref.watch(socialLoginControllerProvider);


    // Variable pour gérer l'état local de connexion Google
    bool isSigningIn = false;
    String? errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drinkks'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.security,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),

              // Titre
              const Text(
                'Connexion Sécurisée',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              // const Text(
              //   'Choisissez votre méthode de connexion',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 48),

              // Bouton Google Sign-In (simplifié)
              if (isSigningIn)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Connexion en cours...'),
                    const SizedBox(height: 32),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Simuler la connexion Google
                      try {
                        isSigningIn = true;
                        errorMessage = null;

                        // Appeler la méthode signInWithGoogle si elle existe
                        // ou simuler la connexion
                        await Future.delayed(const Duration(seconds: 2));

                        // Si succès, naviguer vers l'écran d'accueil
                        print('✅ Connexion Google simulée réussie');

                        // Exemple de navigation
                        // Navigator.pushReplacementNamed(context, '/home');

                      } catch (e) {
                        errorMessage = 'Erreur: $e';
                        print('❌ Erreur: $e');
                      } finally {
                        isSigningIn = false;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône Google
                        Image.asset(
                          'assets/images/logos/google-signin-logo_100_100.png',
                          height: 24,
                          width: 24,
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
                ),

              // Afficher les erreurs
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),



              // Liste des méthodes de connexion disponibles (optionnel)
              Expanded(
                child: socialLoginState.when(
                  data: (socialLogins) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   'Autres méthodes disponibles:',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: socialLogins.length,
                            itemBuilder: (context, index) {
                              final method = socialLogins[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Icon(
                                    _getIconForMethod(method.id),
                                    color: _getColorForMethod(method.id),
                                  ),
                                  title: Text(method.name),
                                  subtitle: Text('ID: ${method.id}'),
                                  onTap: () {
                                    print('Sélectionné: ${method.name}');
                                    // Ici vous pourriez appeler une méthode spécifique
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Erreur de chargement: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      default:
        return Icons.login;
    }
  }

  Color _getColorForMethod(String methodId) {
    switch (methodId.toLowerCase()) {
      case 'google':
        return const Color(0xFFEA4335); // Rouge Google
      case 'apple':
        return Colors.black;
      case 'facebook':
        return const Color(0xFF1877F2); // Bleu Facebook
      default:
        return Colors.blue;
    }
  }
}