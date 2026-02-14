// features/venues/presentation/screens/venues_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const textPrimary = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message de bienvenue
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

            // Liste des bars virtuels
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
          // Navigation vers l'écran des tables avec GoRouter
          final venueId = venue['id'] ?? 'default'; // Assurez-vous d'avoir un ID
          context.go('/venues/$venueId/tables');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du bar
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

            // Informations
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

                  // Nombre de personnes connectées
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.group,
                  //       color: primaryColor,
                  //       size: 16,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '${venue['activeUsers']} personnes',
                  //       style: TextStyle(
                  //         color: textPrimary.withOpacity(0.6),
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ],
                  // ),
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