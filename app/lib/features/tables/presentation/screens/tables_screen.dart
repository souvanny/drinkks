// flutter_lib/features/tables/presentation/screens/tables_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../services/tables_service.dart';
import '../controllers/tables_controller.dart';
import 'prejoin.dart';

class TablesScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const TablesScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  int _nbSeats = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVenueTables();
  }

  Future<void> _loadVenueTables() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tablesService = ref.read(tablesServiceProvider);
      final response = await tablesService.getVenueTables(widget.venueId);

      if (mounted) {
        setState(() {
          _nbSeats = response['nb_seats'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Méthode pour générer le token LiveKit
  Future<void> _generateLiveKitToken(BuildContext context, WidgetRef ref, Map<String, dynamic> table) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const secondaryColor = Color(0xFF8B5CF6);
    const textPrimary = Colors.white;
    const occupiedColor = Color(0xFF10B981);
    const emptyColor = Color(0xFF6B7280);
    const barColor = Color(0xFF8B4513);

    final tablesState = ref.watch(tablesControllerProvider);

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
                const Color(0xFF1A1A2E),
              ],
            ),
          ),
          child: Stack(
            children: [
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
                                widget.venueName,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _isLoading
                                    ? 'Chargement...'
                                    : '${_nbSeats} tables disponibles',
                                style: TextStyle(
                                  color: textPrimary.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_isLoading)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              '$_nbSeats tables',
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur: $_error',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadVenueTables,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: _buildTablesGrid(
                        _nbSeats,
                        occupiedColor,
                        emptyColor,
                        primaryColor,
                        textPrimary,
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

  Widget _buildTablesGrid(
      int nbSeats,
      Color occupiedColor,
      Color emptyColor,
      Color primaryColor,
      Color textPrimary,
      ) {
    // Générer les tables avec des sièges vides pour l'instant
    final tables = List.generate(nbSeats, (index) {
      return {
        'id': (index + 1).toString(),
        'name': 'Table ${index + 1}',
        'occupiedSeats': 0, // Tous vides pour l'instant
        'totalSeats': 4, // 4 sièges par table
      };
    });

    // Diviser en deux rangées
    final firstRowTables = tables.take(2).toList();
    final remainingTables = tables.skip(2).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: [
          // Première rangée
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index < firstRowTables.length) {
                  final table = firstRowTables[index];
                  return _buildTableCard(
                    table,
                    occupiedColor,
                    emptyColor,
                    primaryColor,
                    textPrimary,
                    onTap: () {
                      _generateLiveKitToken(context, ref, table);
                    },
                  );
                }
                return null;
              },
              childCount: firstRowTables.length,
            ),
          ),

          // Tables restantes
          if (remainingTables.isNotEmpty)
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < remainingTables.length) {
                    final table = remainingTables[index];
                    return _buildTableCard(
                      table,
                      occupiedColor,
                      emptyColor,
                      primaryColor,
                      textPrimary,
                      onTap: () {
                        _generateLiveKitToken(context, ref, table);
                      },
                    );
                  }
                  return null;
                },
                childCount: remainingTables.length,
              ),
            ),
        ],
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
                    Center(
                      child: SvgPicture.string(
                        '''
                        <svg width="80" height="80" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                          <circle cx="50" cy="50" r="35" fill="#2D3748" stroke="#4A5568" stroke-width="2"/>
                          <rect x="48" y="70" width="4" height="20" fill="#4A5568" rx="2"/>
                          <circle cx="50" cy="50" r="30" fill="none" stroke="#6366F1" stroke-width="1" stroke-dasharray="4 4"/>
                        </svg>
                        ''',
                        width: 80,
                        height: 80,
                      ),
                    ),

                    Positioned.fill(
                      child: _buildSeats(
                        occupiedSeats,
                        totalSeats,
                        occupiedColor,
                        emptyColor,
                      ),
                    ),

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

                    if (isFull)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'COMPLET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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