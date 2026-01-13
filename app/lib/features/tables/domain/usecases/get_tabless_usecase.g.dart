// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_tabless_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getTabless)
final getTablessProvider = GetTablessProvider._();

final class GetTablessProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TablesEntity>>,
          List<TablesEntity>,
          FutureOr<List<TablesEntity>>
        >
    with
        $FutureModifier<List<TablesEntity>>,
        $FutureProvider<List<TablesEntity>> {
  GetTablessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getTablessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getTablessHash();

  @$internal
  @override
  $FutureProviderElement<List<TablesEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TablesEntity>> create(Ref ref) {
    return getTabless(ref);
  }
}

String _$getTablessHash() => r'a540bcb396d51fbb80a1e6601cd7d6608e758543';
