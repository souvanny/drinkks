// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tablesRepository)
final tablesRepositoryProvider = TablesRepositoryProvider._();

final class TablesRepositoryProvider
    extends
        $FunctionalProvider<
          TablesRepository,
          TablesRepository,
          TablesRepository
        >
    with $Provider<TablesRepository> {
  TablesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tablesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tablesRepositoryHash();

  @$internal
  @override
  $ProviderElement<TablesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TablesRepository create(Ref ref) {
    return tablesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TablesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TablesRepository>(value),
    );
  }
}

String _$tablesRepositoryHash() => r'e1101c1fd0ee9937e6af20cff3e97441681de356';
