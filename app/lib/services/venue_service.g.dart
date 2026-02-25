// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(venueService)
final venueServiceProvider = VenueServiceProvider._();

final class VenueServiceProvider
    extends $FunctionalProvider<VenueService, VenueService, VenueService>
    with $Provider<VenueService> {
  VenueServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venueServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venueServiceHash();

  @$internal
  @override
  $ProviderElement<VenueService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VenueService create(Ref ref) {
    return venueService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VenueService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VenueService>(value),
    );
  }
}

String _$venueServiceHash() => r'290c2a47c5e90c2bc0cf80bac2b374644d0375ce';
