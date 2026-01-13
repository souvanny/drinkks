// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venues_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(venuesRepository)
final venuesRepositoryProvider = VenuesRepositoryProvider._();

final class VenuesRepositoryProvider
    extends
        $FunctionalProvider<
          VenuesRepository,
          VenuesRepository,
          VenuesRepository
        >
    with $Provider<VenuesRepository> {
  VenuesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venuesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venuesRepositoryHash();

  @$internal
  @override
  $ProviderElement<VenuesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VenuesRepository create(Ref ref) {
    return venuesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VenuesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VenuesRepository>(value),
    );
  }
}

String _$venuesRepositoryHash() => r'955ae296e3ec7371336fe0c1b64a9ea6bb687cc9';
