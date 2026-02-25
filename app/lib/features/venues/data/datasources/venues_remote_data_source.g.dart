// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venues_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(venuesRemoteDataSource)
final venuesRemoteDataSourceProvider = VenuesRemoteDataSourceProvider._();

final class VenuesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          VenuesRemoteDataSource,
          VenuesRemoteDataSource,
          VenuesRemoteDataSource
        >
    with $Provider<VenuesRemoteDataSource> {
  VenuesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venuesRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venuesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<VenuesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VenuesRemoteDataSource create(Ref ref) {
    return venuesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VenuesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VenuesRemoteDataSource>(value),
    );
  }
}

String _$venuesRemoteDataSourceHash() =>
    r'df55f457f4dce1a05d22e11bec5bbf9c8ea1bc21';
