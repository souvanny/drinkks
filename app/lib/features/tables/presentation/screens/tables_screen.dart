import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../../services/api_service.dart';
import '../controllers/tables_controller.dart';
import 'prejoin.dart';

class TablesScreen extends ConsumerWidget {
  final String venueId;
  final Dio _dio = Dio(); // À idéalement injecter via un provider

  TablesScreen({
    super.key,
    required this.venueId,
  });

  // Méthode pour générer le token LiveKit
  Future<void> _generateLiveKitToken(BuildContext context, WidgetRef ref, Map<String, dynamic> table) async {
    try {
      // Appel via le controller qui utilise le service
      final tokenData = await ref.read(tablesControllerProvider.notifier).generateTokenForTable(table);

      if (tokenData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de générer le token de connexion'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Navigation vers la page de pré-join
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreJoinPage(
              args: JoinArgs(
                url: tokenData['server_url'],
                token: tokenData['participant_token'],
                e2ee: false,
                e2eeKey: null,
                simulcast: true,
                adaptiveStream: true,
                dynacast: true,
                preferredCodec: 'VP8',
                enableBackupVideoCodec: true,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Erreur de connexion';
        if (e is ApiException) {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tablesControllerProvider);

    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const secondaryColor = Color(0xFF8B5CF6);
    const textPrimary = Colors.white;
    const occupiedColor = Color(0xFF10B981);
    const emptyColor = Color(0xFF6B7280);
    const barColor = Color(0xFF8B4513); // Couleur bois du bar

    // Données statiques pour les tables
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
      body: SafeArea(
        child: Container(
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

              Column(
                children: [
                  // AppBar personnalisée
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: textPrimary),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Le Lounge Étoilé',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Ambiance feutrée • Jazz doux',
                                style: TextStyle(
                                  color: textPrimary.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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

                  // Légende avec option pour le bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: barColor,
                          label: 'Bar',
                          icon: Icons.local_bar,
                        ),
                      ],
                    ),
                  ),

                  // Contenu principal avec le bar au centre
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomScrollView(
                        slivers: [
                          // Sliver pour les tables (première rangée)
                          SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                if (index < 2) {
                                  final table = tablesData[index];
                                  return _buildTableCard(
                                    table,
                                    occupiedColor,
                                    emptyColor,
                                    primaryColor,
                                    textPrimary,
                                    onTap: () {
                                      final isFull = (table['occupiedSeats'] as int) == (table['totalSeats'] as int);
                                      if (!isFull) {
                                        _generateLiveKitToken(context, ref, table);
                                      }
                                    },
                                  );
                                }
                                return null;
                              },
                              childCount: 2,
                            ),
                          ),

                          // // Sliver pour le bar central
                          // SliverToBoxAdapter(
                          //   child: Container(
                          //     height: 180,
                          //     margin: const EdgeInsets.symmetric(vertical: 20),
                          //     child: _buildBarIsland(  // ← Ici, il faut appeler la fonction
                          //       barColor,
                          //       primaryColor,
                          //       textPrimary,
                          //     ),
                          //   ),
                          // ),

                          // Sliver pour les autres tables
                          SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                if (index < tablesData.length - 2) {
                                  final table = tablesData[index + 2];
                                  return _buildTableCard(
                                    table,
                                    occupiedColor,
                                    emptyColor,
                                    primaryColor,
                                    textPrimary,
                                    onTap: () {
                                      final isFull = (table['occupiedSeats'] as int) == (table['totalSeats'] as int);
                                      if (!isFull) {
                                        _generateLiveKitToken(context, ref, table);
                                      }
                                    },
                                  );
                                }
                                return null;
                              },
                              childCount: tablesData.length - 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBarIsland(Color barColor, Color primaryColor, Color textPrimary) {
    return InkWell(
      onTap: () {
        // Lancer une visio avec le barman
        print('Démarrer une visio avec le barman');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              barColor.withOpacity(0.8),
              barColor.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.amber.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Effet de bois en arrière-plan
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _WoodGrainPainter(),
                ),
              ),
            ),

            // Contenu principal à gauche
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar et informations du barman
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar et nom sur la même ligne
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar du barman
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Avatar
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2D3748),
                                    border: Border.all(
                                      color: Colors.amber,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),

                                // Badge "En ligne"
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Nom et description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Marc, le Barman',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Spécialiste cocktails • Disponible',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Compteur de personnes au bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.group,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '3 personnes au bar',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Icônes de bouteilles (optionnel)
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildBottleIcon(Icons.local_drink, Colors.blue.withOpacity(0.8), 24),
                          const SizedBox(width: 8),
                          _buildBottleIcon(Icons.wine_bar, Colors.red.withOpacity(0.8), 24),
                          const SizedBox(width: 8),
                          _buildBottleIcon(Icons.local_drink, Colors.green.withOpacity(0.8), 24),
                          const SizedBox(width: 8),
                          _buildBottleIcon(Icons.local_drink, Colors.purple.withOpacity(0.8), 24),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bouton "Discuter" à droite
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade600,
                              Colors.orange.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.video_call,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Discuter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Petite indication (optionnel)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1:1',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleIcon(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.6,
      ),
    );
  }


  Widget _buildTableCard(
      Map<String, dynamic> table,
      Color occupiedColor,
      Color emptyColor,
      Color primaryColor,
      Color textPrimary, {
        required VoidCallback onTap,
      }) {
    final occupiedSeats = table['occupiedSeats'] as int;
    final totalSeats = table['totalSeats'] as int;
    final isFull = occupiedSeats == totalSeats;
    final availableSeats = totalSeats - occupiedSeats;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carte de la table
        Expanded(
          child: InkWell(
            onTap: isFull ? null : onTap,
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
                        <svg width="80" height="80" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                          <!-- Plateau de table -->
                          <circle cx="50" cy="50" r="35" fill="#2D3748" stroke="#4A5568" stroke-width="2"/>
                          
                          <!-- Pied de table -->
                          <rect x="48" y="70" width="4" height="20" fill="#4A5568" rx="2"/>
                          
                          <!-- Détails du plateau -->
                          <circle cx="50" cy="50" r="30" fill="none" stroke="#6366F1" stroke-width="1" stroke-dasharray="4 4"/>
                        </svg>
                        ''',
                        width: 80,
                        height: 80,
                      ),
                    ),

                    // Places autour de la table
                    Positioned.fill(
                      child: _buildSeats(
                        occupiedSeats,
                        totalSeats,
                        occupiedColor,
                        emptyColor,
                      ),
                    ),

                    // Badge des places disponibles (en bas à droite)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chair,
                              color: isFull ? Colors.red : primaryColor,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$availableSeats',
                              style: TextStyle(
                                color: isFull ? Colors.redAccent : primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Icône de verre (si occupé) - en haut à gauche
                    if (occupiedSeats > 0)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.local_drink,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),

                    // Indicateur "Complet" au centre de la table
                    if (isFull)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'COMPLET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Nom de la table en dehors du cadre (en bas)
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            table['name'],
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeats(int occupied, int total, Color occupiedColor, Color emptyColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        final radius = 48.0;

        return Stack(
          children: List.generate(total, (index) {
            final angle = (2 * 3.14159 * index / total) - (3.14159 / 2);
            final x = centerX + radius * cos(angle);
            final y = centerY + radius * sin(angle);
            final isOccupied = index < occupied;

            return Positioned(
              left: x - 18,
              top: y - 18,
              child: Container(
                width: 36,
                height: 36,
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isOccupied ? Icons.person : Icons.person_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    if (isOccupied)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
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
      final radius = random.nextDouble() * 1.2 + 0.3;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Effet de grain de bois
    final grainPaint = Paint()
      ..color = Color(0xFF5D2906)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final random = Random(123);
    for (int i = 0; i < 50; i++) {
      final startY = random.nextDouble() * size.height;
      final endY = startY + random.nextDouble() * 20;
      final x = random.nextDouble() * size.width;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x + random.nextDouble() * 50, endY),
        grainPaint,
      );
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
    final x = sin(seed * 1000.0) * 10000.0;
    return x - x.floorToDouble();
  }
}