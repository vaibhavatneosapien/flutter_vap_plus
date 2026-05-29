import 'dart:io';
import 'package:flutter/services.dart';

export 'package:flutter_vap_plus/vap_view.dart';
export 'package:flutter_vap_plus/vap_controller.dart';

/// Top-level plugin entry points that aren't tied to a specific VapView
/// instance.
class FlutterVapPlus {
  FlutterVapPlus._();

  static const MethodChannel _globalChannel =
      MethodChannel('flutter_vap_plus/global');

  /// Warm the iOS Metal pipeline so the first VapView mount doesn't pay
  /// MTLDevice creation + shader compile latency on the cold path.
  ///
  /// Safe to call multiple times — the native side guards with
  /// `dispatch_once`. No-op on Android (the AnimView surface init is
  /// cheap enough that prewarm doesn't move the needle).
  ///
  /// Call once from app startup (e.g. in `main()` after Flutter binding
  /// is ready). Returns when the dispatch has been scheduled; the actual
  /// Metal work runs on a background queue and the future may complete
  /// before the warmup finishes — which is fine, the goal is to start
  /// warming as early as possible, not to block startup on it.
  static Future<void> prewarm() async {
    if (!Platform.isIOS) return;
    try {
      await _globalChannel.invokeMethod<void>('prewarm');
    } catch (_) {
      // Prewarm is a pure optimization — never let a failure here break
      // app startup.
    }
  }
}
