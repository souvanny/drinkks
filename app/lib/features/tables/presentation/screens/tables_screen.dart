import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/tables_controller.dart';

class TablesScreen extends ConsumerWidget {
  final String venueId;

  const TablesScreen({
    super.key,
    required this.venueId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tablesControllerProvider);

    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const secondaryColor = Color(0xFF8B5CF6);
    const textPrimary = Colors.white;
    const occupiedColor = Color(0xFF10B981);
    const emptyColor = Color(0xFF6B7280);

    // Données statiques pour les tables (à remplacer par vos données réelles)
    final tablesData = [
      {
        'id': '1',
        'name': 'Table du Coin',
        'occupiedSeats': 3,
        'totalSeats': 4,
      },
      {
        'id': '2',
        'name': 'Table du Milieu',
        'occupiedSeats': 1,
        'totalSeats': 4,
      },
      {
        'id': '3',
        'name': 'Table VIP',
        'occupiedSeats': 4,
        'totalSeats': 4,
      },
      {
        'id': '4',
        'name': 'Table Fenêtre',
        'occupiedSeats': 0,
        'totalSeats': 4,
      },
      {
        'id': '5',
        'name': 'Table Bar',
        'occupiedSeats': 2,
        'totalSeats': 4,
      },
      {
        'id': '6',
        'name': 'Table Intime',
        'occupiedSeats': 3,
        'totalSeats': 4,
      },
    ];

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
          'Le Lounge Étoilé',
          style: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor.withOpacity(0.9),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Effet d'étoiles en arrière-plan
            Positioned.fill(
              child: CustomPaint(
                painter: _StarsPainter(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec ambiance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.nightlight_round, color: secondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Ambiance feutrée • Jazz doux',
                          style: TextStyle(
                            color: textPrimary.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${tablesData.length} tables',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Légende
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(
                          color: occupiedColor,
                          label: 'Occupé',
                          icon: Icons.person,
                        ),
                        _buildLegendItem(
                          color: emptyColor,
                          label: 'Libre',
                          icon: Icons.person_outline,
                        ),
                        _buildLegendItem(
                          color: primaryColor,
                          label: 'Rejoindre',
                          icon: Icons.video_call,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Liste des tables
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: tablesData.length,
                      itemBuilder: (context, index) {
                        final table = tablesData[index];
                        return _buildTableCard(
                          table,
                          occupiedColor,
                          emptyColor,
                          primaryColor,
                          textPrimary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(
      Map<String, dynamic> table,
      Color occupiedColor,
      Color emptyColor,
      Color primaryColor,
      Color textPrimary,
      ) {
    final occupiedSeats = table['occupiedSeats'] as int;
    final totalSeats = table['totalSeats'] as int;
    final isFull = occupiedSeats == totalSeats;

    return InkWell(
      onTap: () {
        if (!isFull) {
          // Rejoindre la table
          print('Rejoindre la table: ${table['name']}');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFull ? Colors.red.withOpacity(0.3) : primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // SVG de la table au centre
              Center(
                child: SvgPicture.string(
                  '''
                  <svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <!-- Plateau de table -->
                    <circle cx="50" cy="50" r="35" fill="#2D3748" stroke="#4A5568" stroke-width="2"/>
                    
                    <!-- Pied de table -->
                    <rect x="48" y="70" width="4" height="20" fill="#4A5568" rx="2"/>
                    
                    <!-- Détails du plateau -->
                    <circle cx="50" cy="50" r="30" fill="none" stroke="#6366F1" stroke-width="1" stroke-dasharray="4 4"/>
                  </svg>
                  ''',
                  width: 100,
                  height: 100,
                ),
              ),

              // Places autour de la table
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: _buildSeats(occupiedSeats, totalSeats, occupiedColor, emptyColor),
              ),

              // Nom de la table et statut
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      table['name'],
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFull
                            ? Colors.red.withOpacity(0.2)
                            : primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isFull ? 'Complet' : '${totalSeats - occupiedSeats} place(s) libre(s)',
                        style: TextStyle(
                          color: isFull ? Colors.redAccent : primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Icône de verre
              if (occupiedSeats > 0)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_drink,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeats(int occupied, int total, Color occupiedColor, Color emptyColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        final radius = 60.0;

        return Stack(
          children: List.generate(total, (index) {
            final angle = (2 * 3.14159 * index / total) - (3.14159 / 2);
            final x = centerX + radius * cos(angle);
            final y = centerY + radius * sin(angle);
            final isOccupied = index < occupied;

            return Positioned(
              left: x - 20,
              top: y - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOccupied ? occupiedColor : emptyColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isOccupied ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Classe Random simple pour le CustomPainter
class Random {
  final int seed;

  Random(this.seed);

  double nextDouble() {
    // Simple pseudo-random generator for painting
    final x = sin(seed * 1000.0) * 10000.0;
    return x - x.floorToDouble();
  }
}