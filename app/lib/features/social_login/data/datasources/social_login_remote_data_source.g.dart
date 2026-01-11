// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_login_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialLoginRemoteDataSource)
final socialLoginRemoteDataSourceProvider =
    SocialLoginRemoteDataSourceProvider._();

final class SocialLoginRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SocialLoginRemoteDataSource,
          SocialLoginRemoteDataSource,
          SocialLoginRemoteDataSource
        >
    with $Provider<SocialLoginRemoteDataSource> {
  SocialLoginRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialLoginRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialLoginRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SocialLoginRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialLoginRemoteDataSource create(Ref ref) {
    return socialLoginRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialLoginRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialLoginRemoteDataSource>(value),
    );
  }
}

String _$socialLoginRemoteDataSourceHash() =>
    r'4c702cae0479e7fb4185f7dc09648f98affcfe75';
