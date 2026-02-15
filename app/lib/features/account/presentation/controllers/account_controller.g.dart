// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountController)
final accountControllerProvider = AccountControllerProvider._();

final class AccountControllerProvider
    extends $AsyncNotifierProvider<AccountController, List<AccountEntity>> {
  AccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountControllerHash();

  @$internal
  @override
  AccountController create() => AccountController();
}

String _$accountControllerHash() => r'3d07a8cbbec8f9136c4aead37215e4922845c2c4';

abstract class _$AccountController extends $AsyncNotifier<List<AccountEntity>> {
  FutureOr<List<AccountEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AccountEntity>>, List<AccountEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AccountEntity>>, List<AccountEntity>>,
              AsyncValue<List<AccountEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
