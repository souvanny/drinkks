// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_venuess_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getVenuess)
final getVenuessProvider = GetVenuessProvider._();

final class GetVenuessProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VenuesEntity>>,
          List<VenuesEntity>,
          FutureOr<List<VenuesEntity>>
        >
    with
        $FutureModifier<List<VenuesEntity>>,
        $FutureProvider<List<VenuesEntity>> {
  GetVenuessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getVenuessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getVenuessHash();

  @$internal
  @override
  $FutureProviderElement<List<VenuesEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VenuesEntity>> create(Ref ref) {
    return getVenuess(ref);
  }
}

String _$getVenuessHash() => r'6b2a6082f558f080b70226dcebd34eb82d08e689';
