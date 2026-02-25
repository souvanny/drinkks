import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3F),
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && !_isLoggingOut) {
      setState(() => _isLoggingOut = true);

      try {
        print('🔴 [VENUES] Début de la déconnexion');

        // Récupérer le notifier
        final notifier = ref.read(authStateNotifierProvider.notifier);

        // Appeler la méthode de déconnexion du notifier
        await notifier.signOut();

        // Attendre un peu pour la propagation
        await Future.delayed(const Duration(milliseconds: 300));

        // Vérification
        final authState = ref.read(authStateNotifierProvider);
        final firebaseUser = ref.read(authServiceProvider).currentUser;

        print('👤 [VENUES] État après déconnexion: $authState');
        print('👤 [VENUES] Firebase user: ${firebaseUser?.uid ?? 'null'}');

        if (context.mounted) {
          // Navigation forcée vers login
          context.go('/login');
        }

      } catch (e, stack) {
        print('❌ [VENUES] Erreur déconnexion: $e');
        print('📚 [VENUES] Stack: $stack');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur déconnexion: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );

          // Même en cas d'erreur, forcer la navigation
          context.go('/login');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const textPrimary = Colors.white;

    // Surveiller l'état d'auth (pour debug)
    ref.listen<AuthState>(authStateNotifierProvider, (previous, next) {
      print('🔄 [VENUES] Auth state changed: $next');
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: _isLoggingOut
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              )
          )
              : const Icon(Icons.logout, color: textPrimary),
          onPressed: _isLoggingOut ? null : () => _handleLogout(context),
          tooltip: 'Se déconnecter',
        ),
        title: Text(
          'Nos Bars Virtuels',
          style: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: textPrimary),
            onPressed: () {
              context.go('/account');
            },
            tooltip: 'Mon compte',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Choisissez votre ambiance',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _venues.length,
                itemBuilder: (context, index) {
                  final venue = _venues[index];
                  return _buildVenueCard(venue, primaryColor, backgroundColor, textPrimary);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue, Color primaryColor, Color backgroundColor, Color textPrimary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          final venueId = venue['id'] ?? 'default';
          context.go('/venues/$venueId/tables');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(venue['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                child: Text(
                  venue['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue['description'],
                    style: TextStyle(
                      color: textPrimary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _venues = [
    {
      'id': 'lounge',
      'name': 'Le Lounge Étoilé',
      'description': 'Ambiance lounge avec vue sur les étoiles',
      'image': 'assets/images/venues/lounge.png',
      'activeUsers': 24,
    },
    {
      'id': 'port',
      'name': 'Le Bar du Port',
      'description': 'Son des vagues et cocktails fruités',
      'image': 'assets/images/venues/port.png',
      'activeUsers': 18,
    },
    {
      'id': 'rooftop',
      'name': 'Le Rooftop Urbain',
      'description': 'Vue panoramique sur la skyline',
      'image': 'assets/images/venues/rooftop.png',
      'activeUsers': 32,
    },
    {
      'id': 'jazz',
      'name': 'La Cave Jazz',
      'description': 'Ambiance intime et musique live',
      'image': 'assets/images/venues/jazz.png',
      'activeUsers': 12,
    },
    {
      'id': 'garden',
      'name': 'Le Garden Tropical',
      'description': 'Jardin virtuel avec cocktails exotiques',
      'image': 'assets/images/venues/garden.png',
      'activeUsers': 28,
    },
    {
      'id': 'club',
      'name': 'Le Club Privé',
      'description': 'Accès exclusif, ambiance feutrée',
      'image': 'assets/images/venues/club.png',
      'activeUsers': 8,
    },
  ];
}