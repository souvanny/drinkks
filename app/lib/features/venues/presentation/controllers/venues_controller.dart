// flutter_lib/features/venues/presentation/controllers/venues_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/usecases/get_venues_usecase.dart';

part 'venues_controller.g.dart';

@riverpod
class VenuesController extends _$VenuesController {
  // Pagination côté client
  static const int _pageSize = 20;
  int _currentPage = 1;
  String? _currentSearch;
  int? _currentType;

  // Toutes les venues chargées
  List<VenuesEntity> _allVenues = [];

  // Venues filtrées pour la page courante
  List<VenuesEntity> _paginatedVenues = [];

  @override
  FutureOr<List<VenuesEntity>> build() {
    return _fetchAllVenues();
  }

  Future<List<VenuesEntity>> _fetchAllVenues() async {
    _allVenues = await ref.watch(
      getVenuesProvider(
        search: _currentSearch,
        type: _currentType,
      ).future,
    );

    _updatePaginatedList();
    return _paginatedVenues;
  }

  void _updatePaginatedList() {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < _allVenues.length) {
      _paginatedVenues = _allVenues.sublist(
        startIndex,
        endIndex > _allVenues.length ? _allVenues.length : endIndex,
      );
    } else {
      _paginatedVenues = [];
    }
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

  Future<void> search(String query) async {
    _currentSearch = query.isEmpty ? null : query;
    _currentPage = 1; // Revenir à la première page
    await refresh();
  }

  Future<void> filterByType(int? type) async {
    _currentType = type;
    _currentPage = 1; // Revenir à la première page
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAllVenues());
  }

  // Getters
  int get currentPage => _currentPage;
  int get totalPages => (_allVenues.length / _pageSize).ceil();
  int get totalItems => _allVenues.length;
  int get pageSize => _pageSize;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  List<VenuesEntity> get allVenues => _allVenues;
}