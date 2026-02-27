// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tablesService)
final tablesServiceProvider = TablesServiceProvider._();

final class TablesServiceProvider
    extends $FunctionalProvider<TablesService, TablesService, TablesService>
    with $Provider<TablesService> {
  TablesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tablesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tablesServiceHash();

  @$internal
  @override
  $ProviderElement<TablesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TablesService create(Ref ref) {
    return tablesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TablesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TablesService>(value),
    );
  }
}

String _$tablesServiceHash() => r'241524e4f94abab9e88bb1fe6baf8d3433d83757';
