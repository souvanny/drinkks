// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venues_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VenuesController)
final venuesControllerProvider = VenuesControllerProvider._();

final class VenuesControllerProvider
    extends $AsyncNotifierProvider<VenuesController, List<VenuesEntity>> {
  VenuesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venuesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venuesControllerHash();

  @$internal
  @override
  VenuesController create() => VenuesController();
}

String _$venuesControllerHash() => r'4ec6992af54d18e5b774498b8f7ef9fa393a08e2';

abstract class _$VenuesController extends $AsyncNotifier<List<VenuesEntity>> {
  FutureOr<List<VenuesEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<VenuesEntity>>, List<VenuesEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VenuesEntity>>, List<VenuesEntity>>,
              AsyncValue<List<VenuesEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
