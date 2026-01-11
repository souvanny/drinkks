// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_login_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialLoginRepository)
final socialLoginRepositoryProvider = SocialLoginRepositoryProvider._();

final class SocialLoginRepositoryProvider
    extends
        $FunctionalProvider<
          SocialLoginRepository,
          SocialLoginRepository,
          SocialLoginRepository
        >
    with $Provider<SocialLoginRepository> {
  SocialLoginRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialLoginRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialLoginRepositoryHash();

  @$internal
  @override
  $ProviderElement<SocialLoginRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialLoginRepository create(Ref ref) {
    return socialLoginRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialLoginRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialLoginRepository>(value),
    );
  }
}

String _$socialLoginRepositoryHash() =>
    r'245216df254a2f1cbb530b4b7c64b67c6327439c';
