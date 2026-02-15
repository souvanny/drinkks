// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_accounts_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAccounts)
final getAccountsProvider = GetAccountsProvider._();

final class GetAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          FutureOr<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $FutureProvider<List<AccountEntity>> {
  GetAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAccountsHash();

  @$internal
  @override
  $FutureProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AccountEntity>> create(Ref ref) {
    return getAccounts(ref);
  }
}

String _$getAccountsHash() => r'c6cdda7c5e10644ce00d526909fb606832565b54';
