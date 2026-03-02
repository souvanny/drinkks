// flutter_lib/features/tables/presentation/screens/tables_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../services/tables_service.dart';
import '../controllers/tables_controller.dart';
import 'prejoin.dart';

// Modèle pour les stats (à partager avec VenuesScreen)
class TableRoomStats {
  final String name;
  final int participantsCount;
  final List<Map<String, dynamic>> participants;

  TableRoomStats({
    required this.name,
    required this.participantsCount,
    required this.participants,
  });

  factory TableRoomStats.fromJson(Map<String, dynamic> json) {
    return TableRoomStats(
      name: json['name'] ?? '',
      participantsCount: json['participants_count'] ?? 0,
      participants: List<Map<String, dynamic>>.from(json['participants'] ?? []),
    );
  }
}

class TablesStats {
  final List<TableRoomStats> rooms;
  final Map<String, dynamic> participantsByRoom;
  final Map<String, dynamic> summary;

  TablesStats({
    required this.rooms,
    required this.participantsByRoom,
    required this.summary,
  });

  factory TablesStats.fromJson(Map<String, dynamic> json) {
    final roomsList = <TableRoomStats>[];
    if (json['rooms'] != null) {
      for (final room in json['rooms'] as List) {
        roomsList.add(TableRoomStats.fromJson(room as Map<String, dynamic>));
      }
    }

    return TablesStats(
      rooms: roomsList,
      participantsByRoom: json['participants_by_room'] as Map<String, dynamic>? ?? {},
      summary: json['summary'] as Map<String, dynamic>? ?? {},
    );
  }

  // Récupérer les participants pour une table spécifique
  List<Map<String, dynamic>> getParticipantsForTable(String tableName) {
    final fullTableName = tableName.contains(':') ? tableName : ' : $tableName';
    for (final room in rooms) {
      if (room.name.contains(fullTableName)) {
        return room.participants;
      }
    }
    return participantsByRoom[fullTableName]?['participants'] as List<Map<String, dynamic>>? ?? [];
  }

  // Récupérer le nombre de participants pour une table spécifique
  int getParticipantsCountForTable(String tableName) {
    final fullTableName = tableName.contains(':') ? tableName : ' : $tableName';
    for (final room in rooms) {
      if (room.name.contains(fullTableName)) {
        return room.participantsCount;
      }
    }
    return participantsByRoom[fullTableName]?['count'] as int? ?? 0;
  }

  // Obtenir les identités des participants pour une table
  List<String> getParticipantIdentitiesForTable(String tableName) {
    final participants = getParticipantsForTable(tableName);
    return participants.map((p) => p['identity'] as String).toList();
  }
}

class TablesScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String? venueName; // Optionnel, sera utilisé comme fallback

  const TablesScreen({
    super.key,
    required this.venueId,
    this.venueName,
  });

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  int _nbSeats = 0;
  String _venueName = ''; // Sera rempli par l'API
  bool _isLoading = true;
  String? _error;

  // Données des stats reçues de l'écran précédent ou à charger
  TablesStats? _stats;

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

    // Récupérer les stats passées en extra
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final extra = GoRouterState.of(context).extra;
    //   if (extra != null && extra is Map<String, dynamic>) {
    //     if (extra.containsKey('stats')) {
    //       setState(() {
    //         _stats = TablesStats.fromJson(extra['stats'] as Map<String, dynamic>);
    //       });
    //     }
    //   }
    // });

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
          _venueName = response['venue_name'] as String; // Récupération du nom depuis l'API

          // Mettre à jour les stats avec la réponse si disponibles
          if (response.containsKey('stats')) {
            _stats = TablesStats.fromJson(response['stats'] as Map<String, dynamic>);
          }

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
  Future<void> _generateLiveKitToken(BuildContext context, WidgetRef ref, Map<String, dynamic> table, String venueName) async {
    try {
      final tokenData = await ref.read(tablesControllerProvider.notifier).generateTokenForTable(table, venueName);

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

  // Construire le nom complet de la table
  String _buildFullTableName(String venueName, String tableName) {
    return '$venueName : $tableName';
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
                  // AppBar personnalisée avec le nom du lieu (depuis l'API)
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
                                _venueName.isNotEmpty ? _venueName : (widget.venueName ?? 'Chargement...'),
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
                                    ? 'Chargement des tables...'
                                    : '${_nbSeats} table${_nbSeats > 1 ? 's' : ''} disponible${_nbSeats > 1 ? 's' : ''}',
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
                              '$_nbSeats',
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

                  // Espacement après l'appbar
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
                  else if (_nbSeats == 0)
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
                          _nbSeats,
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

  Widget _buildTablesGrid(
      int nbSeats,
      Color occupiedColor,
      Color emptyColor,
      Color textPrimary,
      ) {
    // Générer les tables avec des sièges vides pour l'instant
    final tables = List.generate(nbSeats, (index) {
      final tableName = 'Table ${index + 1}';
      final fullTableName = _buildFullTableName(_venueName, tableName);

      // Récupérer le nombre de participants pour cette table depuis les stats
      final participantsCount = _stats?.getParticipantsCountForTable(fullTableName) ?? 0;
      final tableColor = _getTableColor(index);

      return {
        'id': (index + 1).toString(),
        'name': tableName,
        'fullName': fullTableName,
        'occupiedSeats': participantsCount, // Utiliser le nombre réel de participants
        'totalSeats': 4, // 4 sièges par table
        'color': tableColor,
        'participants': _stats?.getParticipantsForTable(fullTableName) ?? [],
      };
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24), // Espacement en bas
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24, // Espacement vertical entre les lignes
          childAspectRatio: 1,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return _buildTableCard(
            table,
            occupiedColor,
            emptyColor,
            textPrimary,
            onTap: () {
              _generateLiveKitToken(context, ref, table, _venueName);
            },
          );
        },
      ),
    );
  }

  Widget _buildTableCard(
      Map<String, dynamic> table,
      Color occupiedColor,
      Color emptyColor,
      Color textPrimary, {
        required VoidCallback onTap,
      }) {
    final occupiedSeats = table['occupiedSeats'] as int;
    final totalSeats = table['totalSeats'] as int;
    final isFull = occupiedSeats == totalSeats;
    final availableSeats = totalSeats - occupiedSeats;
    final tableColor = table['color'] as Color;
    final participants = table['participants'] as List<dynamic>;

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
                    // SVG de la table au centre avec la couleur
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

                    // Badge des places disponibles (en bas à droite)
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
                              '$availableSeats',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.local_drink,
                                color: Colors.amber,
                                size: 16,
                              ),
                              if (occupiedSeats > 1)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$occupiedSeats',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Indicateur "COMPLET" au centre
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

                    // Liste des participants (au survol ou en overlay)
                    if (occupiedSeats > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Tooltip(
                            message: participants.map((p) => p['identity']).join('\n'),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 14,
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
                table['name'],
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