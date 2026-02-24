// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserProfileController)
final userProfileControllerProvider = UserProfileControllerProvider._();

final class UserProfileControllerProvider
    extends $AsyncNotifierProvider<UserProfileController, UserProfileEntity> {
  UserProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileControllerHash();

  @$internal
  @override
  UserProfileController create() => UserProfileController();
}

String _$userProfileControllerHash() =>
    r'c24754cc155347f7d2fa200f8f3a552820dce78f';

abstract class _$UserProfileController
    extends $AsyncNotifier<UserProfileEntity> {
  FutureOr<UserProfileEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserProfileEntity>, UserProfileEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfileEntity>, UserProfileEntity>,
              AsyncValue<UserProfileEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
