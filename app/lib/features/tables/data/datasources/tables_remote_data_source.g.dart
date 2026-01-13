// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tablesRemoteDataSource)
final tablesRemoteDataSourceProvider = TablesRemoteDataSourceProvider._();

final class TablesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TablesRemoteDataSource,
          TablesRemoteDataSource,
          TablesRemoteDataSource
        >
    with $Provider<TablesRemoteDataSource> {
  TablesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tablesRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tablesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TablesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TablesRemoteDataSource create(Ref ref) {
    return tablesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TablesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TablesRemoteDataSource>(value),
    );
  }
}

String _$tablesRemoteDataSourceHash() =>
    r'faaf82b4441e0fce90ae1381dc58e5f62907abaf';
