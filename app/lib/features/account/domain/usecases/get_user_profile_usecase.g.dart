// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_profile_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getUserProfile)
final getUserProfileProvider = GetUserProfileProvider._();

final class GetUserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfileEntity>,
          UserProfileEntity,
          FutureOr<UserProfileEntity>
        >
    with
        $FutureModifier<UserProfileEntity>,
        $FutureProvider<UserProfileEntity> {
  GetUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getUserProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserProfileEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfileEntity> create(Ref ref) {
    return getUserProfile(ref);
  }
}

String _$getUserProfileHash() => r'7ccad3731031f4a0ef5233cbe58b660b3e7e4a3f';
