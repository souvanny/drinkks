import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/examples/localization_assets_demo.dart';
import 'package:flutter_riverpod_clean_architecture/features/account/presentation/screens/account_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/social_login/presentation/screens/social_login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/presentation/screens/survey_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/venues/presentation/screens/venues_screen.dart';
import '../../features/tables/presentation/screens/tables_screen.dart';
import '../../providers/auth_provider.dart'; // IMPORTANT: Ajouter cet import pour authStateNotifierProvider

final routerProvider = Provider<GoRouter>((ref) {
  // CORRECTION 1: Utiliser authStateNotifierProvider au lieu de authProvider
  final authState = ref.watch(authProvider);
  // final authState = ref.watch(authStateNotifierProvider);

  // Watch for locale changes - this rebuilds the router when locale changes
  ref.watch(persistentLocaleProvider);

  // Create a router with locale awareness
  return GoRouter(
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      // Permettre l'accès à /venues et /venues/* sans authentification
      if (state.matchedLocation.startsWith('/venues')) {
        return null; // Pas de redirection, autoriser l'accès
      }
      if (state.matchedLocation.startsWith('/account')) {
        return null; // Pas de redirection, autoriser l'accès
      }

      // CORRECTION 2: Utiliser isAuthenticated du nouveau provider
      final isLoggedIn = authState.isAuthenticated;

      // Check if the user is going to the login page
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;

      // Check if the user is going to the register page
      final isGoingToRegister =
          state.matchedLocation == AppConstants.registerRoute;

      // If not logged in and not going to login or register, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppConstants.loginRoute;
      }

      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppConstants.homeRoute;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Login route
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const SocialLoginScreen(),
      ),

      // Register route
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Settings route
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Language settings route
      GoRoute(
        path: AppConstants.languageSettingsRoute,
        name: 'language_settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),

      // Localization Assets Demo route
      GoRoute(
        path: AppConstants.localizationAssetsDemoRoute,
        name: 'localization_assets_demo',
        builder: (context, state) => const LocalizationAssetsDemo(),
      ),

      // Chat route
      GoRoute(
        path: AppConstants.chatRoute,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),

      // Survey route
      GoRoute(
        path: AppConstants.surveyRoute,
        name: 'survey',
        builder: (context, state) => const SurveyScreen(),
      ),

      // CORRECTION 3: Route pour account (supprimer la route dupliquée sous survey)
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountScreen(),
      ),

      // Venues route (écran des bars)
      GoRoute(
        path: AppConstants.venuesRoute,
        name: 'venues',
        builder: (context, state) => const VenuesScreen(),
        routes: [
          // Sous-route pour les tables d'un bar spécifique
          GoRoute(
            path: ':venueId/tables',
            name: 'tables',
            builder: (context, state) {
              final venueId = state.pathParameters['venueId']!;
              return TablesScreen(venueId: venueId);
            },
          ),
        ],
      ),

      // Initial route - redirects based on auth state
      GoRoute(
        path: AppConstants.initialRoute,
        name: 'initial',
        redirect: (context, state) => authState.isAuthenticated
            ? AppConstants.homeRoute
            : AppConstants.loginRoute,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Page ${state.uri.path} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});