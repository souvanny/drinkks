// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/PLACE_FONTS_HERE
  String get placeFontsHere => 'assets/fonts/PLACE_FONTS_HERE';

  /// List of all assets
  List<String> get values => [placeFontsHere];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/bn
  $AssetsImagesBnGen get bn => const $AssetsImagesBnGen();

  /// Directory path: assets/images/de
  $AssetsImagesDeGen get de => const $AssetsImagesDeGen();

  /// Directory path: assets/images/en
  $AssetsImagesEnGen get en => const $AssetsImagesEnGen();

  /// Directory path: assets/images/es
  $AssetsImagesEsGen get es => const $AssetsImagesEsGen();

  /// Directory path: assets/images/fr
  $AssetsImagesFrGen get fr => const $AssetsImagesFrGen();

  /// Directory path: assets/images/ja
  $AssetsImagesJaGen get ja => const $AssetsImagesJaGen();

  /// File path: assets/images/logo.png.placeholder
  String get logoPng => 'assets/images/logo.png.placeholder';

  /// Directory path: assets/images/logos
  $AssetsImagesLogosGen get logos => const $AssetsImagesLogosGen();

  /// File path: assets/images/splash.png
  AssetGenImage get splash => const AssetGenImage('assets/images/splash.png');

  /// File path: assets/images/splash_icon.png
  AssetGenImage get splashIcon =>
      const AssetGenImage('assets/images/splash_icon.png');

  /// File path: assets/images/splash_icon2.png
  AssetGenImage get splashIcon2 =>
      const AssetGenImage('assets/images/splash_icon2.png');

  /// Directory path: assets/images/venues
  $AssetsImagesVenuesGen get venues => const $AssetsImagesVenuesGen();

  /// List of all assets
  List<dynamic> get values => [logoPng, splash, splashIcon, splashIcon2];
}

class $AssetsImagesBnGen {
  const $AssetsImagesBnGen();

  /// File path: assets/images/bn/welcome.png.placeholder
  String get welcomePng => 'assets/images/bn/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesDeGen {
  const $AssetsImagesDeGen();

  /// File path: assets/images/de/welcome.png.placeholder
  String get welcomePng => 'assets/images/de/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesEnGen {
  const $AssetsImagesEnGen();

  /// File path: assets/images/en/welcome.png.placeholder
  String get welcomePng => 'assets/images/en/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesEsGen {
  const $AssetsImagesEsGen();

  /// File path: assets/images/es/welcome.png.placeholder
  String get welcomePng => 'assets/images/es/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesFrGen {
  const $AssetsImagesFrGen();

  /// File path: assets/images/fr/welcome.png.placeholder
  String get welcomePng => 'assets/images/fr/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesJaGen {
  const $AssetsImagesJaGen();

  /// File path: assets/images/ja/welcome.png.placeholder
  String get welcomePng => 'assets/images/ja/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesLogosGen {
  const $AssetsImagesLogosGen();

  /// File path: assets/images/logos/google-signin-logo.svg
  String get googleSigninLogo => 'assets/images/logos/google-signin-logo.svg';

  /// File path: assets/images/logos/google-signin-logo_100_100.png
  AssetGenImage get googleSigninLogo100100 =>
      const AssetGenImage('assets/images/logos/google-signin-logo_100_100.png');

  /// List of all assets
  List<dynamic> get values => [googleSigninLogo, googleSigninLogo100100];
}

class $AssetsImagesVenuesGen {
  const $AssetsImagesVenuesGen();

  /// File path: assets/images/venues/club.png
  AssetGenImage get club =>
      const AssetGenImage('assets/images/venues/club.png');

  /// File path: assets/images/venues/garden.png
  AssetGenImage get garden =>
      const AssetGenImage('assets/images/venues/garden.png');

  /// File path: assets/images/venues/jazz.png
  AssetGenImage get jazz =>
      const AssetGenImage('assets/images/venues/jazz.png');

  /// File path: assets/images/venues/lounge.png
  AssetGenImage get lounge =>
      const AssetGenImage('assets/images/venues/lounge.png');

  /// File path: assets/images/venues/port.png
  AssetGenImage get port =>
      const AssetGenImage('assets/images/venues/port.png');

  /// File path: assets/images/venues/rooftop.png
  AssetGenImage get rooftop =>
      const AssetGenImage('assets/images/venues/rooftop.png');

  /// List of all assets
  List<AssetGenImage> get values => [club, garden, jazz, lounge, port, rooftop];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
