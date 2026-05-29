#import "FlutterVapPlugin.h"
#import "NativeVapView.h"
#import <Metal/Metal.h>

// QGVAPlayer caches its MTLDevice in this global, populated lazily on the
// first QGHWDMetalRenderer alloc. Pre-allocating it here at app launch
// shifts the cost off the cold-start path of the first VapView mount.
extern id<MTLDevice> kQGHWDMetalRendererDevice;

@implementation FlutterVapPlugin

// Keep the prewarmed default Metal library alive for the lifetime of the
// process. Releasing it after prewarm would let the driver evict the
// compiled function cache before the first real VapView uses it.
static id<MTLLibrary> sPrewarmedDefaultLibrary = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    NativeVapViewFactory* factory = [[NativeVapViewFactory alloc] initWithRegistrar: registrar];
    [registrar registerViewFactory:factory withId:@"flutter_vap"];

    FlutterMethodChannel *globalChannel = [FlutterMethodChannel
        methodChannelWithName:@"flutter_vap_plus/global"
              binaryMessenger:registrar.messenger];
    [globalChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"prewarm" isEqualToString:call.method]) {
            [FlutterVapPlugin prewarm];
            result(nil);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

+ (void)prewarm {
    // Run off the platform thread so callers don't block; Metal API calls
    // are thread-safe for device/library creation.
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            if (!kQGHWDMetalRendererDevice) {
                kQGHWDMetalRendererDevice = MTLCreateSystemDefaultDevice();
            }
            if (kQGHWDMetalRendererDevice && !sPrewarmedDefaultLibrary) {
                // Loading the default library compiles+links the bundled
                // .metal sources once. The driver caches the compiled
                // function variants per-device so subsequent
                // QGVAPMetalShaderFunctionLoader instances hit the cache
                // instead of repeating the compile.
                sPrewarmedDefaultLibrary = [kQGHWDMetalRendererDevice newDefaultLibrary];
            }
        });
    });
}

@end
