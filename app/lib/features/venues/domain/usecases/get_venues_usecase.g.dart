// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_venues_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getVenues)
final getVenuesProvider = GetVenuesFamily._();

final class GetVenuesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VenuesEntity>>,
          List<VenuesEntity>,
          FutureOr<List<VenuesEntity>>
        >
    with
        $FutureModifier<List<VenuesEntity>>,
        $FutureProvider<List<VenuesEntity>> {
  GetVenuesProvider._({
    required GetVenuesFamily super.from,
    required ({int page, int limit, String? search, int? type}) super.argument,
  }) : super(
         retry: null,
         name: r'getVenuesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getVenuesHash();

  @override
  String toString() {
    return r'getVenuesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<VenuesEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VenuesEntity>> create(Ref ref) {
    final argument =
        this.argument as ({int page, int limit, String? search, int? type});
    return getVenues(
      ref,
      page: argument.page,
      limit: argument.limit,
      search: argument.search,
      type: argument.type,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetVenuesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getVenuesHash() => r'31b31665348244ac2786515ee31604c48b04d44d';

final class GetVenuesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<VenuesEntity>>,
          ({int page, int limit, String? search, int? type})
        > {
  GetVenuesFamily._()
    : super(
        retry: null,
        name: r'getVenuesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetVenuesProvider call({
    required int page,
    required int limit,
    String? search,
    int? type,
  }) => GetVenuesProvider._(
    argument: (page: page, limit: limit, search: search, type: type),
    from: this,
  );

  @override
  String toString() => r'getVenuesProvider';
}
