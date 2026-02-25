import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/venues_repository_impl.dart';
import '../../domain/entities/venues_entity.dart';
import '../../domain/usecases/get_venues_usecase.dart';

part 'venues_controller.g.dart';

@riverpod
class VenuesController extends _$VenuesController {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 20;
  String? _currentSearch;
  int? _currentType;

  @override
  FutureOr<List<VenuesEntity>> build() {
    // Rafraîchir lors du changement de page/recherche/filtre
    // ref.listenSelf((previous, next) {
    //   // Logique si nécessaire
    // });

    return _fetchVenues();
  }

  Future<List<VenuesEntity>> _fetchVenues() async {
    final venues = await ref.watch(
      getVenuesProvider(
        page: _currentPage,
        limit: _limit,
        search: _currentSearch,
        type: _currentType,
      ).future,
    );

    // Récupérer les métadonnées de pagination depuis le repository
    final repository = ref.read(venuesRepositoryProvider);
    _totalPages = await repository.getTotalPages();

    return venues;
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await refresh();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await refresh();
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      await refresh();
    }
  }

  Future<void> search(String query) async {
    _currentSearch = query.isEmpty ? null : query;
    _currentPage = 1; // Revenir à la première page pour la recherche
    await refresh();
  }

  Future<void> filterByType(int? type) async {
    _currentType = type;
    _currentPage = 1; // Revenir à la première page pour le filtre
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchVenues());
  }

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get limit => _limit;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;
}