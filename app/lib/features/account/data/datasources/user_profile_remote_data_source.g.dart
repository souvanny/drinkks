// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileRemoteDataSource)
final userProfileRemoteDataSourceProvider =
    UserProfileRemoteDataSourceProvider._();

final class UserProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          UserProfileRemoteDataSource,
          UserProfileRemoteDataSource,
          UserProfileRemoteDataSource
        >
    with $Provider<UserProfileRemoteDataSource> {
  UserProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<UserProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRemoteDataSource create(Ref ref) {
    return userProfileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRemoteDataSource>(value),
    );
  }
}

String _$userProfileRemoteDataSourceHash() =>
    r'64d4c19c04bba420484565a11a27cc96bad83f1a';
