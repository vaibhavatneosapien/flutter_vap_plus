import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'vap_controller.dart';
import 'vap_view.dart';

/// Android Platform-View shell. Loop semantics live entirely on the native
/// side (`AnimView.setLoop`); `repeatCount` is forwarded as a creation
/// param. `repeatCount <= 0` (default 0) → infinite loop, no Dart-side
/// replay needed.
class VapViewForAndroid extends StatelessWidget {
  final void Function(VapController controller) onControllerCreated;
  final VapScaleFit fit;
  final int repeatCount;
  final void Function(dynamic event, dynamic arguments)? onEvent;
  final void Function(Object error)? onError;

  const VapViewForAndroid({
    super.key,
    required this.onControllerCreated,
    required this.fit,
    required this.repeatCount,
    this.onEvent,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'scaleType': fit.name,
      'repeatCount': repeatCount,
    };
    return AndroidView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (viewId) {
        // No artificial delay. The 1s `Future.delayed` upstream caller
        // added pre-existed to mask a separate "no-listener-yet" race that
        // is fixed in the patched Kotlin (`setAnimListener` moved to
        // `init`). Delivering the controller synchronously is safe now.
        onControllerCreated(VapController(
          viewId: viewId,
          onEvent: onEvent,
        ));
      },
    );
  }
}
