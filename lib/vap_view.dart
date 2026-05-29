import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_vap_plus/flutter_vap_plus.dart';
import 'package:flutter_vap_plus/vap_view_for_android.dart';
import 'package:flutter_vap_plus/vap_view_for_ios.dart';

class VapView extends StatefulWidget {
  final void Function(VapController controller) onControllerCreated;
  final VapScaleFit fit;
  final int? repeatCount;
  final void Function(dynamic event,dynamic arguments)? onEvent;

  /// iOS-only multiplier applied on top of the standard CENTER_CROP cover
  /// scale. 1.0 (default) matches a plain BoxFit.cover. Values > 1 crop
  /// further into the source — useful when the rendered RGB area has
  /// padding around the subject (e.g. the subject occupies only the middle
  /// portion of the source frame) and the standard cover scale leaves the
  /// subject visually smaller than the surrounding placeholder image.
  /// Ignored on Android.
  final double? centerCropZoom;

  const VapView({
    super.key,
    required this.onControllerCreated,
    this.fit = VapScaleFit.FIT_CENTER,
    this.repeatCount,
    this.onEvent,
    this.centerCropZoom,
  });

  @override
  State<VapView> createState() => _VapViewState();
}

class _VapViewState extends State<VapView> {
  VapController? controller;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return VapViewForAndroid(
        onControllerCreated: onControllerCreated,
        fit: widget.fit,
        repeatCount: widget.repeatCount ?? 1,
        onEvent: widget.onEvent,
      );
    } else if (Platform.isIOS) {
      return VapViewForIos(
        onControllerCreated: onControllerCreated,
        fit: widget.fit,
        onEvent: widget.onEvent,
        centerCropZoom: widget.centerCropZoom,
      );
    }
    return Container();
  }

  void onControllerCreated(VapController controller) {
    this.controller = controller;
    widget.onControllerCreated(controller);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

enum VapScaleFit {
  FIT_XY,
  FIT_CENTER,
  CENTER_CROP,
}
