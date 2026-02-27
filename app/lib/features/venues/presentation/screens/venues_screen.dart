// flutter_lib/features/venues/presentation/screens/venues_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../controllers/venues_controller.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  bool _isLoggingOut = false;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedType;
  bool _showFilters = false;
  Timer? _searchDebounce;

  // Mapping des types vers les images
  static const Map<int, String> _typeToImage = {
    1: 'assets/images/venues/lounge.png',
    2: 'assets/images/venues/port.png',
    3: 'assets/images/venues/rooftop.png',
    4: 'assets/images/venues/jazz.png',
    5: 'assets/images/venues/garden.png',
    6: 'assets/images/venues/club.png',
  };

  // Mapping des types vers les libellés
  static const Map<int, String> _typeToLabel = {
    1: 'Lounge',
    2: 'Port',
    3: 'Rooftop',
    4: 'Jazz',
    5: 'Jardin',
    6: 'Club',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final controller = ref.read(venuesControllerProvider.notifier);
        controller.onSearchChanged(_searchController.text);
      }
    });
  }

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
        final notifier = ref.read(authStateNotifierProvider.notifier);
        await notifier.signOut();
        await Future.delayed(const Duration(milliseconds: 300));

        if (context.mounted) {
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
          context.go('/login');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    // Le listener va automatiquement déclencher la mise à jour
  }

  void _selectType(int? type) {
    setState(() {
      _selectedType = type;
    });
    final controller = ref.read(venuesControllerProvider.notifier);
    controller.filterByType(type);
  }

  String? _getImageForType(int? type) {
    if (type == null || !_typeToImage.containsKey(type)) {
      return 'assets/images/venues/default.png';
    }
    return _typeToImage[type];
  }

  String _getTypeLabel(int? type) {
    if (type == null || !_typeToLabel.containsKey(type)) {
      return 'Inconnu';
    }
    return _typeToLabel[type]!;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0F23);
    const primaryColor = Color(0xFF6366F1);
    const textPrimary = Colors.white;

    final venuesState = ref.watch(venuesControllerProvider);
    final controller = ref.read(venuesControllerProvider.notifier);

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
            ),
          )
              : const Icon(Icons.logout, color: textPrimary),
          onPressed: _isLoggingOut ? null : () => _handleLogout(context),
          tooltip: 'Se déconnecter',
        ),
        title: const Text(
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
            icon: const Icon(Icons.person, color: textPrimary),
            onPressed: () {
              context.go('/account');
            },
            tooltip: 'Mon compte',
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filtres',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un bar...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: _clearSearch,
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E3F),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // Filtres par type
              if (_showFilters) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('Tous', null, _selectedType == null),
                      ..._typeToLabel.entries.map(
                            (entry) => _buildFilterChip(
                          entry.value,
                          entry.key,
                          _selectedType == entry.key,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: venuesState.when(
        data: (venues) {
          return Column(
            children: [
              // Indicateur de nombre de résultats
              if (controller.totalItems > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${controller.totalItems} bar(s) trouvé(s)',
                        style: TextStyle(
                          color: textPrimary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: venues.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Aucun bar disponible'
                            : 'Aucun résultat pour "${_searchController.text}"',
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return _buildVenueCard(
                      venue,
                      primaryColor,
                      backgroundColor,
                      textPrimary,
                    );
                  },
                ),
              ),
              // Pagination
              if (controller.totalItems > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        color: controller.hasPreviousPage
                            ? primaryColor
                            : Colors.white24,
                        onPressed: controller.hasPreviousPage
                            ? () => controller.previousPage()
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E3F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Page ${controller.currentPage} / ${controller.totalPages}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        color: controller.hasNextPage
                            ? primaryColor
                            : Colors.white24,
                        onPressed: controller.hasNextPage
                            ? () => controller.nextPage()
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Bouton de rafraîchissement
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: primaryColor,
                        onPressed: () {
                          controller.refresh();
                        },
                        tooltip: 'Recharger depuis le serveur',
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erreur: $error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? value, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => _selectType(value),
        backgroundColor: const Color(0xFF1E1E3F),
        selectedColor: const Color(0xFF6366F1),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildVenueCard(
      dynamic venue,
      Color primaryColor,
      Color backgroundColor,
      Color textPrimary,
      ) {
    final imagePath = _getImageForType(venue.type);
    final typeLabel = _getTypeLabel(venue.type);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          context.go('/venues/${venue.uuid}/tables', extra: venue.name);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath!),
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
                padding: const EdgeInsets.all(8),
                child: Text(
                  venue.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.description ?? 'Aucune description',
                    style: TextStyle(
                      color: textPrimary.withOpacity(0.8),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}