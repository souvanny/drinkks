// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialLoginController)
final socialLoginControllerProvider = SocialLoginControllerProvider._();

final class SocialLoginControllerProvider
    extends
        $AsyncNotifierProvider<SocialLoginController, List<SocialLoginEntity>> {
  SocialLoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialLoginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialLoginControllerHash();

  @$internal
  @override
  SocialLoginController create() => SocialLoginController();
}

String _$socialLoginControllerHash() =>
    r'82d698f3d28c8df6fe87dff1a1c82b30d5dba4b4';

abstract class _$SocialLoginController
    extends $AsyncNotifier<List<SocialLoginEntity>> {
  FutureOr<List<SocialLoginEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<SocialLoginEntity>>,
              List<SocialLoginEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SocialLoginEntity>>,
                List<SocialLoginEntity>
              >,
              AsyncValue<List<SocialLoginEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
