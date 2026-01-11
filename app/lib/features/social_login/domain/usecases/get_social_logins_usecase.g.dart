// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_social_logins_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getSocialLogins)
final getSocialLoginsProvider = GetSocialLoginsProvider._();

final class GetSocialLoginsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SocialLoginEntity>>,
          List<SocialLoginEntity>,
          FutureOr<List<SocialLoginEntity>>
        >
    with
        $FutureModifier<List<SocialLoginEntity>>,
        $FutureProvider<List<SocialLoginEntity>> {
  GetSocialLoginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSocialLoginsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSocialLoginsHash();

  @$internal
  @override
  $FutureProviderElement<List<SocialLoginEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SocialLoginEntity>> create(Ref ref) {
    return getSocialLogins(ref);
  }
}

String _$getSocialLoginsHash() => r'3520f25d6ac3be09c359e09715135a2f6577795e';
