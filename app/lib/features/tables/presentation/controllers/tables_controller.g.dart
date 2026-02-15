// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TablesController)
final tablesControllerProvider = TablesControllerProvider._();

final class TablesControllerProvider
    extends $AsyncNotifierProvider<TablesController, List<TablesEntity>> {
  TablesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tablesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tablesControllerHash();

  @$internal
  @override
  TablesController create() => TablesController();
}

String _$tablesControllerHash() => r'f15b9925908014fc546d034ff7c0a2a99081cf9c';

abstract class _$TablesController extends $AsyncNotifier<List<TablesEntity>> {
  FutureOr<List<TablesEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TablesEntity>>, List<TablesEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TablesEntity>>, List<TablesEntity>>,
              AsyncValue<List<TablesEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
