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
  final int nbTables;

  const TablesScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.nbTables,
  });

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  int _seatsPerTable = 4;
  int _totalCapacity = 0;
  String _venueUuid = '';
  bool _isLoading = true;
  String? _error;

  // Données des tables
  Map<String, int> _nbParticipantsByTable = {};
  Map<String, int> _nbSeatsByTable = {};
  int _activeTables = 0;
  int _availableTables = 0;
  int _totalParticipants = 0;

  // Palette de couleurs fixes pour les tables
  static const List<Color> _tableColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Rose
    Color(0xFFEF4444), // Rouge
    Color(0xFFF59E0B), // Orange
    Color(0xFF10B981), // Vert émeraude
    Color(0xFF3B82F6), // Bleu
    Color(0xFF06B6D4), // Cyan
    Color(0xFF8B5CF6), // Violet clair
    Color(0xFFEC4899), // Rose foncé
    Color(0xFF14B8A6), // Turquoise
    Color(0xFFF97316), // Orange vif
  ];

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
          _venueUuid = response['venueUuid'] as String;
          _seatsPerTable = response['seatsPerTable'] as int;
          _totalCapacity = response['totalCapacity'] as int;
          _nbParticipantsByTable = Map<String, int>.from(response['nbParticipantsByTable'] ?? {});
          _nbSeatsByTable = Map<String, int>.from(response['nbSeatsByTable'] ?? {});
          _activeTables = response['activeTables'] as int;
          _availableTables = response['availableTables'] as int;
          _totalParticipants = _nbParticipantsByTable.values.fold(0, (sum, count) => sum + count);
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
  Future<void> _generateLiveKitToken(BuildContext context, WidgetRef ref, int tableNumber, String venueUuid) async {
    try {
      final tokenData = await ref.read(tablesControllerProvider.notifier).generateTokenForTable(
          {'name': 'Table $tableNumber'},
          tableNumber - 1,
          venueUuid
      );

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

  // Obtenir une couleur pour une table en fonction de son index
  Color _getTableColor(int index) {
    return _tableColors[index % _tableColors.length];
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const textPrimary = Colors.white;
    const occupiedColor = Color(0xFF10B981);
    const emptyColor = Color(0xFF6B7280);

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
              // Effet d'étoiles en arrière-plan
              Positioned.fill(
                child: CustomPaint(
                  painter: _StarsPainter(),
                ),
              ),

              Column(
                children: [
                  // AppBar personnalisée avec stats
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
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
                                  if (!_isLoading)
                                    Text(
                                      '${widget.nbTables} table${widget.nbTables > 1 ? 's' : ''} · $_totalParticipants participant${_totalParticipants > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: textPrimary.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Barre de stats
                        if (false)
                        if (!_isLoading && _totalCapacity > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.people,
                                value: _totalParticipants,
                                label: 'Présents',
                                color: Colors.green,
                              ),
                              _buildStatItem(
                                icon: Icons.event_seat,
                                value: _activeTables,
                                label: 'Tables actives',
                                color: Colors.orange,
                              ),
                              _buildStatItem(
                                icon: Icons.chair,
                                value: _availableTables,
                                label: 'Tables libres',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

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
                  else if (widget.nbTables == 0)
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_seat,
                                color: Colors.white24,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune table disponible',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: _buildTablesGrid(
                          widget.nbTables,
                          occupiedColor,
                          emptyColor,
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

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid(
      int nbTables,
      Color occupiedColor,
      Color emptyColor,
      Color textPrimary,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 1,
        ),
        itemCount: nbTables,
        itemBuilder: (context, index) {
          final tableNumber = (index + 1).toString();
          final occupiedSeats = _nbParticipantsByTable[tableNumber] ?? 0;
          final totalSeats = _nbSeatsByTable[tableNumber] ?? _seatsPerTable;
          final tableColor = _getTableColor(index);

          return _buildTableCard(
            tableNumber: tableNumber,
            occupiedSeats: occupiedSeats,
            totalSeats: totalSeats,
            tableColor: tableColor,
            occupiedColor: occupiedColor,
            emptyColor: emptyColor,
            textPrimary: textPrimary,
            onTap: () {
              _generateLiveKitToken(context, ref, index + 1, _venueUuid);
            },
          );
        },
      ),
    );
  }

  Widget _buildTableCard({
    required String tableNumber,
    required int occupiedSeats,
    required int totalSeats,
    required Color tableColor,
    required Color occupiedColor,
    required Color emptyColor,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final isFull = occupiedSeats == totalSeats;
    final availableSeats = totalSeats - occupiedSeats;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carte de la table
        Expanded(
          child: InkWell(
            onTap: isFull ? null : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.transparent,
              shadowColor: tableColor.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tableColor.withOpacity(0.2),
                      tableColor.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: isFull
                        ? Colors.red.withOpacity(0.5)
                        : tableColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tableColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // SVG de la table au centre
                    Center(
                      child: SvgPicture.string(
                        '''
                        <svg width="80" height="80" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                          <circle cx="50" cy="50" r="35" fill="#2D3748" stroke="${_colorToHex(tableColor)}" stroke-width="2"/>
                          <rect x="48" y="70" width="4" height="20" fill="#4A5568" rx="2"/>
                          <circle cx="50" cy="50" r="30" fill="none" stroke="${_colorToHex(tableColor)}" stroke-width="1.5" stroke-dasharray="4 4"/>
                        </svg>
                        ''',
                        width: 70,
                        height: 70,
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

                    // Badge des places disponibles
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull
                              ? Colors.red.withOpacity(0.9)
                              : tableColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chair,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$occupiedSeats/$totalSeats',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Icône de participants
                    if (occupiedSeats > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: occupiedSeats == totalSeats
                                ? Colors.red.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                color: occupiedSeats == totalSeats ? Colors.red : Colors.green,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$occupiedSeats',
                                style: TextStyle(
                                  color: occupiedSeats == totalSeats ? Colors.red : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Indicateur "COMPLET"
                    if (isFull)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'COMPLET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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

        // Nom de la table
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tableColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Table $tableNumber',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
            final angle = (2 * pi * index / total) - (pi / 2);
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
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
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

  // Convertir une couleur en hexadécimal pour SVG
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
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