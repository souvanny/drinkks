// flutter_lib/features/tables/presentation/controllers/tables_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tables_entity.dart';
import '../../domain/usecases/get_tabless_usecase.dart';
import '../../../../services/sfu_service.dart';
import '../../../../providers/auth_provider.dart';

part 'tables_controller.g.dart';

// Nouveau state pour gérer la génération de token
class TokenGenerationState {
  final bool isLoading;
  final Map<String, dynamic>? tokenData;
  final Object? error;

  const TokenGenerationState({
    this.isLoading = false,
    this.tokenData,
    this.error,
  });

  TokenGenerationState copyWith({
    bool? isLoading,
    Map<String, dynamic>? tokenData,
    Object? error,
  }) {
    return TokenGenerationState(
      isLoading: isLoading ?? this.isLoading,
      tokenData: tokenData ?? this.tokenData,
      error: error ?? this.error,
    );
  }
}

@riverpod
class TablesController extends _$TablesController {
  late SfuService _sfuService;

  @override
  FutureOr<List<TablesEntity>> build() {
    _sfuService = ref.watch(sfuServiceProvider);
    return ref.watch(getTablessProvider.future);
  }

  // Nouvelle méthode pour générer le token
  Future<Map<String, dynamic>?> generateTokenForTable(Map<String, dynamic> table) async {
    final authState = ref.read(authStateNotifierProvider);

    if (!authState.isFullyAuthenticated) {
      print('❌ Utilisateur non authentifié');
      return null;
    }

    final connectedUserName = authState.user?.displayName ?? 'Utilisateur';
    final connectedUserIdentity = authState.user?.uid ?? '';

    if (connectedUserName.isEmpty || connectedUserIdentity.isEmpty) {
      print('❌ Informations utilisateur manquantes');
      return null;
    }

    try {
      print('🔄 Génération du token pour la table: ${table['name']}');

      final tokenData = await _sfuService.generateToken(
        participantIdentity: connectedUserIdentity,
        participantName: connectedUserName,
        roomName: table['name'],
      );

      print('✅ Token généré avec succès');
      return tokenData;

    } catch (e) {
      print('❌ Erreur lors de la génération du token: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.refresh(getTablessProvider.future));
  }
}