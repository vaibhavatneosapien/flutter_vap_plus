import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'vap_controller.dart';
import 'vap_view.dart';

/// iOS Platform-View shell. Native side (`QGVAPWrapView`) handles infinite
/// loop via `repeatCount:-1` in the patched ObjC; Dart no longer issues
/// replay on `onComplete`.
class VapViewForIos extends StatelessWidget {
  final void Function(VapController controller) onControllerCreated;
  final VapScaleFit fit;
  final void Function(dynamic event, dynamic arguments)? onEvent;

  const VapViewForIos({
    super.key,
    required this.onControllerCreated,
    required this.fit,
    this.onEvent,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'scaleType': fit.name,
    };
    return UiKitView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (viewId) {
        // No artificial 1s delay. The race the upstream delay masked is
        // solved differently here — the native side initializes
        // synchronously inside `initWithFrame:` and the wrap view persists
        // across plays.
        onControllerCreated(VapController(
          viewId: viewId,
          onEvent: onEvent,
        ));
      },
    );
  }
}
