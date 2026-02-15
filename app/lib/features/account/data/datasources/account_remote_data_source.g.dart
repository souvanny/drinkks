// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountRemoteDataSource)
final accountRemoteDataSourceProvider = AccountRemoteDataSourceProvider._();

final class AccountRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AccountRemoteDataSource,
          AccountRemoteDataSource,
          AccountRemoteDataSource
        >
    with $Provider<AccountRemoteDataSource> {
  AccountRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AccountRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRemoteDataSource create(Ref ref) {
    return accountRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRemoteDataSource>(value),
    );
  }
}

String _$accountRemoteDataSourceHash() =>
    r'53ff15520eb0b74c67501459a5e2e8b065c3b943';
