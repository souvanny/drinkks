// flutter_lib/features/venues/presentation/controllers/venues_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/usecases/get_venues_usecase.dart';

part 'venues_controller.g.dart';

// Fonction utilitaire pour normaliser le texte (supprimer accents, lowercase)
String _normalizeText(String text) {
  return text
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');
}

@riverpod
class VenuesController extends _$VenuesController {
  // Pagination côté client
  static const int _pageSize = 10;
  int _currentPage = 1;
  String _currentSearch = '';
  int? _currentType;

  // Toutes les venues chargées (données brutes de l'API)
  List<VenuesEntity> _allVenues = [];

  // Venues filtrées (après recherche ET filtre par type)
  List<VenuesEntity> _filteredVenues = [];

  // Venues paginées pour la page courante
  List<VenuesEntity> _paginatedVenues = [];

  // Stats des rooms
  Map<String, dynamic> _stats = {};

  @override
  FutureOr<List<VenuesEntity>> build() {
    return _fetchAllVenues();
  }

  Future<List<VenuesEntity>> _fetchAllVenues() async {
    // Forcer le rafraîchissement du provider en invalidant son cache
    ref.invalidate(getVenuesProvider);

    _allVenues = await ref.watch(
      getVenuesProvider(
        search: null, // Plus de filtre serveur
        type: null,   // Plus de filtre serveur
      ).future,
    );

    // Récupérer les stats
    try {
      _stats = await ref.read(getVenuesStatsProvider.future);
    } catch (e) {
      print('Erreur lors de la récupération des stats: $e');
      _stats = {};
    }

    // Appliquer les filtres en mémoire
    _applyFilters();
    return _paginatedVenues;
  }

  // Getter pour les stats
  Map<String, dynamic> get stats => _stats;

  // Applique la recherche et les filtres en mémoire, puis met à jour la pagination
  void _applyFilters() {
    // Commencer avec toutes les venues
    _filteredVenues = List.from(_allVenues);

    // 🔵 ÉTAPE 1: Appliquer le filtre de type (en mémoire)
    if (_currentType != null) {
      _filteredVenues = _filteredVenues
          .where((venue) => venue.type == _currentType)
          .toList();
    }

    // 🔵 ÉTAPE 2: Appliquer la recherche locale (en mémoire)
    if (_currentSearch.isNotEmpty) {
      final normalizedSearch = _normalizeText(_currentSearch);
      _filteredVenues = _filteredVenues.where((venue) {
        final normalizedName = _normalizeText(venue.name);
        final normalizedDescription = _normalizeText(venue.description ?? '');

        return normalizedName.contains(normalizedSearch) ||
            normalizedDescription.contains(normalizedSearch);
      }).toList();
    }

    // Réinitialiser la page courante si nécessaire
    if (_currentPage > totalPages) {
      _currentPage = totalPages > 0 ? totalPages : 1;
    }

    _updatePaginatedList();
  }

  void _updatePaginatedList() {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < _filteredVenues.length) {
      _paginatedVenues = _filteredVenues.sublist(
        startIndex,
        endIndex > _filteredVenues.length ? _filteredVenues.length : endIndex,
      );
    } else {
      _paginatedVenues = [];
    }
  }

  // Méthode appelée à chaque modification du champ de recherche
  void onSearchChanged(String query) {
    _currentSearch = query;
    _currentPage = 1;
    _applyFilters(); // ✅ Uniquement filtrage en mémoire
    state = AsyncValue.data(_paginatedVenues);
  }

  Future<void> nextPage() async {
    if (_currentPage < totalPages) {
      _currentPage++;
      _updatePaginatedList();
      state = AsyncValue.data(_paginatedVenues);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      _updatePaginatedList();
      state = AsyncValue.data(_paginatedVenues);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      _updatePaginatedList();
      state = AsyncValue.data(_paginatedVenues);
    }
  }

  // 🔵 NOUVELLE MÉTHODE: Filtrage par type en mémoire
  Future<void> filterByType(int? type) async {
    _currentType = type;
    _currentPage = 1;
    _applyFilters(); // ✅ Uniquement filtrage en mémoire
    state = AsyncValue.data(_paginatedVenues);
  }

  // Méthode pour recharger depuis le serveur
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAllVenues());
  }

  // Getters
  int get currentPage => _currentPage;
  int get totalPages => (_filteredVenues.length / _pageSize).ceil();
  int get totalItems => _filteredVenues.length;
  int get pageSize => _pageSize;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  List<VenuesEntity> get allVenues => _allVenues;
  List<VenuesEntity> get filteredVenues => _filteredVenues;
  String get currentSearch => _currentSearch;
}