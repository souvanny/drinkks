// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sfu_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sfuService)
final sfuServiceProvider = SfuServiceProvider._();

final class SfuServiceProvider
    extends $FunctionalProvider<SfuService, SfuService, SfuService>
    with $Provider<SfuService> {
  SfuServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sfuServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sfuServiceHash();

  @$internal
  @override
  $ProviderElement<SfuService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SfuService create(Ref ref) {
    return sfuService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SfuService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SfuService>(value),
    );
  }
}

String _$sfuServiceHash() => r'eec97a26458eb6027d15e5c5845938b8e56f520d';
